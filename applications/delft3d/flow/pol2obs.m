function pol2obs(fileIn,fileOut,grd,varargin)
%POL2OBS Convert tekal file to .obs or .src file or vice versa.
%
%Syntax:
%	pol2obs(fileIn,fileOut,grd,<keyword>,<value>,...)
%
%See also: pol2crs, pol2dry, pol2thd, pol2bnd, delft3d_io_obs

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

% $Id: pol2obs.m 13023 2016-12-01 10:41:15Z schrijve $
% $Date: 2016-12-01 18:41:15 +0800 (Thu, 01 Dec 2016) $
% $Author: schrijve $
% $Revision: 13023 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/pol2obs.m $

%% Preprocessing

%keywords
OPT.Rmax=1e3; %maximum distance observation point grid point
OPT=setproperty(OPT,varargin);

%Check existence
if ~exist(fileIn,'file')
    error(sprintf('Matlab cannot find %s',fileIn)); 
else
    [fpath fname fext]=fileparts(fileIn); 
end %end if exist
 

 %% Convert .obs or .src file to polygon
if strcmpi(fext,'.obs') 
	fid=fopen(fileIn); 
	
	%Read data line by line
	Field=[]; k=1; 
	line=fgetl(fid); 
	while line~=-1
		%Read name point
		name=line(1:22); 
		name=strtrim(name); 
		name(name==' ')=' '; 
		Field1.Comments=name; 
		Field1.Name=sprintf('point%-.3d',k); 
		line=line(22:end); 
		
		%Read position point
		mn=sscanf(line,'%d %d'); 
		if isempty(mn)
			error('Cannot read grid indices from file.'); 
		end 
		
		%convert to cartesian
		x=grd.cen.x(mn(2)-1,mn(1)-1); 
		y=grd.cen.y(mn(2)-1,mn(1)-1); 
		Field1.Data=[x,y];

		Field=[Field,Field1]; 
		line=fgetl(fid); 
		k=k+1; 
		
	end %end while
	fclose(fid); 
	
	%write to polygon
	INFO.Field=Field;
	tekal('write',fileOut,INFO); 
	
elseif strcmpi(fext,'.src') 
	fid=fopen(fileIn); 
	
	%Read data line by line
	Field=[]; k=1; 
	line=fgetl(fid); 
	while line~=-1
		%Read name point
		name=line(1:24); 
		name=strtrim(name); 
		name(name==' ')=' '; 
		Field1.Comments=name; 
		Field1.Name=sprintf('point%-.3d',k); 
		line=line(24:end); 
		
		%Read position point
		mn=sscanf(line,'%d %d %d'); 
		if isempty(mn)
			error('Cannot read grid indices from file.'); 
		end 
		
		%convert to cartesian
		x=grd.cend.x(mn(2),mn(1)); 
		y=grd.cend.y(mn(2),mn(1)); 
		Field1.Data=[x,y,mn(3)];

		Field=[Field,Field1]; 
		line=fgetl(fid); 
		k=k+1; 
		
	end %end while
	fclose(fid); 
	
	%write to polygon
	INFO.Field=Field;
	tekal('write',fileOut,INFO);


elseif strcmpi(fext,'.pol') | strcmpi(fext,'.ldb') 
%% Convert polygon to observation points

	%Enclosure. Needed to remove points outside enclosure. 
	enc=polyinterp(grd.Enclosure(:,1),grd.Enclosure(:,2),'d_step',NaN,'seperator','equal'); 
	for l=1:length(enc)
		enc(l).m=enc(l).x; enc(l).n=enc(l).y; 
		for k=1:length(enc(l).x)
			enc(l).x(k)=grd.cend.x(enc(l).n(k),enc(l).m(k)); 
			enc(l).y(k)=grd.cend.y(enc(l).n(k),enc(l).m(k)); 
		end
	end

	%read polygon
	pol=tekal('read',fileIn,'loaddata'); 
	pol=pol.Field; 
	
	

	%create output .obs or .src file
	fid=fopen(fileOut,'w+'); 
	for k=1:length(pol)
	
		xpol=pol(k).Data(:,1); ypol=pol(k).Data(:,2); 
		
		%removing points outside grid
		for l=1:length(enc)
			if isempty(xpol)
				break; 
			end
			inpoly=inpolygon(xpol,ypol,enc(l).x,enc(l).y); 
			if l==1
				%external enclosure
				xpol=xpol(inpoly); ypol=ypol(inpoly); 
			else
				%internal enclosure
				xpol=xpol(~inpoly); ypol=ypol(~inpoly); 
			end
		end
		%grid indices closest to point
		[n,m]=xy2mn(grd.cen.x,grd.cen.y,xpol,ypol,'Rmax',OPT.Rmax); 
		m=m+1; n=n+1;
		
		if size(pol(k).Data,2)==3
			z=pol(k).Data(1,3);
		else
			z=[]; 
        end
        m=m(:);n=n(:);z=z(:); % All columns
        
		if ~isnan(m) & ~isnan(n) & isempty(z)
		%Write grid indices to file if nearby gridpoint has been found
			line=pol(k).Comments; line=cell2mat(line); line=line(2:end);
			formatOut=['%-',num2str(max(20,length(line))),'s\n'];
			fprintf(fid,formatOut,line);
			formatOut='%d\t%d\t\r\n';
			fprintf(fid,formatOut,[m';n']);
        elseif ~isnan(m) & ~isnan(n) & ~isempty(z)
            line=pol(k).Comments; line=cell2mat(line); line=line(2:end);
            formatOut=['%-',num2str(max(20,length(line))),'s\n'];
            fprintf(fid,formatOut,line);
            formatOut='%d\t%d\t%d\n';
            fprintf(fid,formatOut,[m';n';z']);
		end %end if
	end %end for k
	fclose(fid); 

else
	error('Not a valid file format.'); 
end %end if strcmpi


end %end function obs2pol