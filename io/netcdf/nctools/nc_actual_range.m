function actual_range = nc_actual_range(ncfile,varname)
%NC_ACTUAL_RANGE   reads or retrieves actual range from contiguous netCDF variable
%
%  [range] = nc_actual_range(ncfile,varname);
%
% gets the min and max value of a contiguous/coordinate variable by
% * first try to get value of attribute 'actual_range'
% * second get min and max of the 'hull' of the variable in matrix space:
%  for 1D variables: of all endpoints 
%  for 2D variables: of all ribs
%  for 3D variables: of all faces
%  for 4D variables: etc
%
% Make sure that the netCDF variable is contiguous, as no check is
% performed on this, only a warning if varname is not a 
% coordinate variable (lon,lat,x,y,time,z).
%
%See also: snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_actual_range.m 11865 2015-04-15 14:58:43Z gerben.deboer.x $
% $Date: 2015-04-15 22:58:43 +0800 (Wed, 15 Apr 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11865 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_actual_range.m $
% $Keywords: $

%% get actual_range

   info = nc_getvarinfo(ncfile, varname);
   fullsearch = 1;
   if ~isempty(info.Attribute)
      ind  = ismember({info.Attribute.Name}, 'standard_name');
      if any(ind)
        standard_name = info.Attribute(ind).Value;
        if ~strcmpi({'latitude',...
                'longitude',...
                'projection_x_coordinate',...
                'projection_y_coordinate',...
                'time',...
                'z'},standard_name);
         fprintf(1,['variable is not a CF coordinate variable and might not be contiguous: "%s"\n'],varname);
        end
      else
        standard_name = [];          
        fprintf(1,['variable is not a CF coordinate variable and might not be contiguous: "%s"\n'],varname);
      end

%% read attribute if present
   
      ind  = ismember({info.Attribute.Name}, 'actual_range');

      if sum(ind)==1
        actual_range = (info.Attribute(ind).Value);
        if ischar(actual_range); % not everyone knows you can insert matrices inside attributes, so some some put space separates strings in
           if strcmpi(standard_name,'time')
              fullsearch = 1;  % easier than parsing time string, given time is hardly ever > 1 dimension anyway           
           else
              actual_range = str2num(actual_range);
              fullsearch = 0;
           end
        end
        actual_range = actual_range(:)';
      end
      
   else
      fprintf(1,['variable is not a CF coordinate variable and might not be contiguous: "%s"\n'],varname);
   end

%% read data
   
   if fullsearch
       
      sz     = info.Size;
      varmin =  Inf;
      varmax = -Inf;
   
      %  for 1D read all endpoints 
      %  for 2D read all ribs
      %  for 3D read all faces

      if sz==1
         varmin       = nc_varget(ncfile,varname);
         varmax       = varmin;          
      else
      for idim=1:length(sz)
         start        =   0.*sz;
         count        =      sz;
         count(idim)  =      min(2,sz(idim));   % mind vectors with dimensions (1 x n)
         stride       = 1+0.*sz; 
         stride(idim) =      max(1,sz(idim)-1); % mind vectors with dimensions (1 x n)
         varval       = nc_varget(ncfile,varname,start,count,stride);
         varmin       = min(min(varval(:)),varmin(:));
         varmax       = max(max(varval(:)),varmax(:));
      end
   end
   
      actual_range = [varmin varmax];
  
   end
 
%% EOF