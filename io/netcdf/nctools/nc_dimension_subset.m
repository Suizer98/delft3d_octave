function nc_dimension_subset(nc0,nc1,dim_name,dim_index,varargin)
%nc_dimension_subset - subset slices along 1 dimension from all nc variables
%
%   nc_dimension_subset(ncfile,ncfile_new,dim_name,dim_index)
%
% subset slices along one common dimension from all variables in a netCDF
% file, for instance to remove time indices where data is bad or old.
% dim_index is a 1-based integer vector, so the new 
% dimension length adds up to length(dim_index). You may
% remove, shuffle or duplicate dimension slices from ncfile, but note that 
% shuffling or duplication might destroy monotonicity in ncfile_new.
%
% Memory-efficiency: data is handled per variable per slice.
%
% Example: using test snctools data: replicate 1st and 2nd time step
%   nc_dimension_subset('tst_pres_temp_4D_netcdf4.nc','B4.nc','time',[1 1 2 2])
%
% Example: using test snctools data: copy only 2nd time step to new file
%   nc_dimension_subset('tst_pres_temp_4D_netcdf4.nc','B1.nc','time',[2])
%
% Example: remove all data before certain date
%   dates = nc_cf_time('1970_2010.nc','time')
%   ind = find(dates < datenum(2000,1,1));
%   nc_dimension_subset('1970_2010.nc','2000_2010.nc','time',ind)
%
% Example: remove all forecast data slices longer than 12 hour
%   hour = ncread('fmrc.nc','forecast_reference_time')
%   ind = find(hour > 12);
%   nc_dimension_subset('fmrc.nc','fmrc12.nc','forecast_time',ind)
%
%See also: ncinfo, structsubs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
%       G.J. de Boer
%
%       Deltares, Delft, NL.
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Aug 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: nc_dimension_subset.m 10617 2014-04-28 12:28:19Z boer_g $
% $Date: 2014-04-28 20:28:19 +0800 (Mon, 28 Apr 2014) $
% $Author: boer_g $
% $Revision: 10617 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_dimension_subset.m $
% $Keywords: $

%%
I0 = ncinfo(nc0);
I1 = I0;

%% shrink chosen dimension in meta-data
Length  = length(dim_index);
for id=1:length(I0.Dimensions)
   if strcmp(I1.Dimensions(id).Name,dim_name)
      I1.Dimensions(id).Length = Length;
   end
end
for iv=1:length(I1.Variables)
   for id=1:length(I1.Variables(iv).Dimensions)
      if strcmp(I1.Variables(iv).Dimensions(id).Name,dim_name);
        I1.Variables(iv).Dimensions(id).Length = Length;
        I1.Variables(iv).Size(id)              = Length;
      end
   end
end

%% save new - shrunken - file 
if exist(nc1)
   disp([nc1,' already exists, proceed to delete?'])
   pausedisp
   delete(nc1)
end
ncwriteschema(nc1, I1);
%nc_dump(nc1)

%% now copy subset of data into new file
for iv=1:length(I1.Variables)
   if isempty(I1.Variables(iv).Dimensions)
   else
   dimind = strcmp(dim_name,{I1.Variables(iv).Dimensions.Name});
   %disp([I.Variables(iv).Name,' ',num2str(dimind)]);
   if ~any(dimind)
       dat = ncread (nc0,I1.Variables(iv).Name);
             ncwrite(nc1,I1.Variables(iv).Name,dat)
      disp([mfilename,': copied:   "',I1.Variables(iv).Name,'"']);
   else
      for it1=1:length(dim_index)
            it0 = dim_index(it1);
           %disp([num2str(it0),':',num2str(it1)]);
            start0 = ones(size(I1.Variables(iv).Size));start0(dimind)=it0;
            count0 =           I1.Variables(iv).Size  ;count0(dimind)=1;
            start1 = ones(size(I1.Variables(iv).Size));start1(dimind)=it1;
            dat  = ncread (nc0,I1.Variables(iv).Name,start0,count0);
                   ncwrite(nc1,I1.Variables(iv).Name,dat   ,start1)
      end
      disp([mfilename,': modified: "',I1.Variables(iv).Name,'"']);
   end
   end
end