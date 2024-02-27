function transect=grid2transect(x,y,z,xi,yi,varargin)
%GRID2TRANSECT	interpolates values of scalarfield onto transect
%
%Syntax:
%	transect=grid2transect(x,y,z,xi,yi,<keyword>,<value>)
%
%Input:
%	x		= [mxn double] matrix with x-coordinates
%	y		= [mxn double] matrix with y-coordinates
%	z		= [mxn double] matrix with values
%	xi		= [lx1 double] column with x-coordinates transect
%	yi		= [lx1 double] column with y-coordinates transect
%
%Output:
%transect	= [struct] struct containing the cartesian x,y-coordinates and tangential
%			  coordinates d along the transect and the values z in these points and the are below
%			  water level. 
%
%Keywords:
%nstep		[integer] number of points along transects. If specified dstep must be empty.
%dstep		[double/] distance in tangential coordinates between points on transect.
%			If specified nstep must be empty. If vector it contains the distance between
%			points on transect.
%
%waterlevel	Water level used for calculation wet area. 
%
%
%Example
%[x,y]=meshgrid([0:100],[0:100]); z=ones(size(x)); 
%transect=grid2transect(x,y,z,[10 10],[10 80],'nstep',100); 

%   --------------------------------------------------------------------
%   Copyright (C) Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: grid2transect.m 11796 2015-03-11 15:17:32Z bartgrasmeijer.x $
% $Date: 2015-03-11 23:17:32 +0800 (Wed, 11 Mar 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 11796 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/grid2transect.m $
% $Keywords: $
%   --------------------------------------------------------------------

%%PREPROCESSING

%keywords
OPT.nstep=100;
OPT.dstep=[]; 
OPT.waterlevel=0;
OPT.ignorenans = false;
OPT=setproperty(OPT,varargin);

%output
transect=[]; 

%check dimensions
if sum(size(x)~=size(z))>0 |sum(size(x)~=size(y))>0
	error('x,y and z must have the same dimension'); 
end
if length(xi)~=length(yi)
	error('xi and yi must have the same dimension'); 
end

%convert to column vectors
x=reshape(x,[],1);
y=reshape(y,[],1); 

%find number of polygons xi,yi
ipoly=find(isnan(xi) & isnan(yi)); 
if isempty(ipoly) | ipoly(1)~=1
	ipoly=[0,ipoly];
end
if ipoly(end)~=length(xi)
	ipoly=[ipoly,length(xi)+1];
end

if ~isempty(OPT.dstep)
	OPT.nstep=[];
end

%% INTERPOLATION

for k=1:length(ipoly)-1

	%get nodes polygon
	xi1=xi(ipoly(k)+1:ipoly(k+1)-1); 
	yi1=yi(ipoly(k)+1:ipoly(k+1)-1); 
	
	
	%if polygon is closed open it
	if xi1(1)==xi1(end) & yi1(1)==yi1(end)
		xi1=xi1(1:end-1); 
		yi1=yi1(1:end-1); 
	end
	if isempty(xi1) | isempty(yi1)
		error(sprintf('Polygon %d is empty.',k)); 
	end
	
	%create points along polygon
	[di1 xi1 yi1]=local_interpTrans(xi1,yi1,OPT.nstep,OPT.dstep); 
	
	%interpolate scalar data in these points
	zi=nangriddata(x,y,z,xi1,yi1); 
	
	%calculate the wet area (i.e. the area below water level)
	ziA=zi-OPT.waterlevel; 
	ziA(ziA>0)=0;
    if ~OPT.ignorenans
        wetArea=-trapz(di1,ziA);
    else
        wetArea=-trapz(di1(~isnan(ziA)),ziA(~isnan(ziA)));
    end
	
	%write output
	transect1=struct('x',xi1,'y',yi1,'d',di1,'z',zi,'area',wetArea); 
	transect=[transect,transect1]; 
end %end for k


end %end function grid2transect

function [di xi yi]=local_interpTrans(x,y,nstep,dstep)
%LOCAL_INTERPTRANS Create points along transect

%tangential coordinates
d=distance(x,y);

if isempty(dstep)
	dstep=d(end)/nstep;
	di=[0:dstep:d(end)];
elseif length(dstep)==1
	di=[0:dstep:d(end)]; 
else
	dstep=reshape(dstep,1,[]); 
	di=[0,cumsum(dstep)]; 
end

%interpolation points polygon in tangential coordinates
di=unique([di,d]); 

%interpolation points polygon in cartesian coordinates
xi=interp1(d,x,di); 
yi=interp1(d,y,di); 

%format output
xi=reshape(xi,[],1); 
yi=reshape(yi,[],1); 
di=reshape(di,[],1); 

end %end function local_interpTrans
