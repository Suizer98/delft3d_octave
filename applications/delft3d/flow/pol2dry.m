function pol2dry(fileIn,fileOut,grd,varargin)
%POL2DRY Convert dry points to their encapsulating polygons and vice versa.
%BETA VERSION. Not guaranteed to work when polygon is outside grid.
%
%Syntax:
%	pol2dry(fileIn,fileOut,grd)
%
%Input:
%	fileIn:		[string] Filepath of input .thd,.pol or .ldb file.
%	fileOut:	[string] Filepath of output .thd,.pol or .ldb file.
%	grd:		[struct] grid struct as generated by delft3d_io_grd
%
%Examples:
%	From dry points to polygons:
%	pol2dry('c:\mysim\mysim.dry','c:\mysim\mysim.ldb',grd);
%   From polygons to dry points:
%	pol2dry('c:\mysim\mysim.ldb','c:\mysim\mysim.dry',grd);
%
%See also: pol2crs, pol2obs, pol2thd, pol2bnd, delft3d_io_dry

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl	
%
%		Arcadis Zwolle
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: pol2dry.m 11802 2015-03-12 14:52:41Z tonnon $
% $Date: 2015-03-12 22:52:41 +0800 (Thu, 12 Mar 2015) $
% $Author: tonnon $
% $Revision: 11802 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/pol2dry.m $

%% Preprocessing

%keywords
OPT=struct(); 
OPT=setproperty(OPT,varargin);

%Check existence
if ~exist(fileIn,'file')
    error(sprintf('Matlab cannot find %s',fileIn)); 
else
    [fpath fname fext]=fileparts(fileIn); 
end %end if exist

if strcmpi(fext,'.dry')
%% Conversion .dry to .pol

%read .dry file
dry=delft3d_io_dry('read',fileIn);

%convert dry points to polygons
Field=[];   
for k=1:length(dry.m0)
	xpol=grd.cor.x(dry.n0(k)+[-1 0],dry.m0(k)+[-1 0]);
	ypol=grd.cor.y(dry.n0(k)+[-1 0],dry.m0(k)+[-1 0]);
	
	xpol=xpol([1,2,4,3]); 
	ypol=ypol([1,2,4,3]); 
	
	Field1.Name=sprintf('dry%-.3d',k); 
	Field1.Data=[xpol(:),ypol(:)]; 
	Field=[Field,Field1]; 
end
INFO.Field=Field; 

%write polygons
tekal('write',fileOut,INFO); 

elseif strcmpi(fext,'.pol') || strcmpi(fext,'.ldb')
%% Conversion .pol to dry

%read polygons
pol=tekal('read',fileIn,'loaddata'); 
pol=pol.Field;

inpoly=zeros(size(grd.cen.x)); 
for k=1:length(pol)
	
	%Find points in polygon
	inpoly=inpoly+inpolygon(grd.cen.x,grd.cen.y,pol(k).Data(:,1),pol(k).Data(:,2)); 
	
end %end for k

%find indices dry points
[in im]=find(inpoly>0); 
in=in+1; im=im+1; 

%write to .dry file 
fid=fopen(fileOut,'w+'); 
for k=1:length(in)
	fprintf(fid,'%d\t%d\t%d\t%d\n',im(k),in(k),im(k),in(k)); 
end %end for k
fclose(fid);


else
	error('Not a valid file format.'); 
end %end if strcmpi(fext,

end %end function pol2dry