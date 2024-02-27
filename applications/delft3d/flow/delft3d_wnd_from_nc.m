function delft3d_wnd_from_nc(varargin)
%DELFT3D_WND_FROM_NC transforms netCDF wind file to delft3d *.wnd file
%
%  delft3d_wnd_from_nc(<keyword,value>)
%
% writes *.wnd file from netCDF file valid for ref_datenum in *.mdf file
%
% Implemented <keyword,value> pairs:
% * refdatenum: datenum or filename of *.mdf file
% * period:     2 datenums
% * dir   :     directory where to save *.wnd
% * nc    :     name or opendap url of netCDF file with wind data
%
% Example:
%
%See also: KNMI_POTWIND, DELFT3D_IO_WND, delft3d_wnd_from_knmi_potwind

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       <ADDRESS>
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
% Created: 05 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: delft3d_wnd_from_nc.m 7547 2012-10-22 13:33:33Z boer_g $
% $Date: 2012-10-22 21:33:33 +0800 (Mon, 22 Oct 2012) $
% $Author: boer_g $
% $Revision: 7547 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_wnd_from_nc.m $
% $Keywords: $


%% get data

   OPT.nc         = 'http://opendap.deltares.nl/thredds/dodsC/opendap/knmi/potwind/potwind_242.nc';
   OPT.period     = datenum(2009, 1, 1 + [0 365]);
   OPT.dir        = pwd;
   OPT.refdatenum = []; %datenum(1998,1,1); % offset from delftd *.mdf
   
   OPT = setproperty(OPT,varargin);

   if ischar(OPT.refdatenum)
      mdf            = delft3d_io_mdf('read',OPT.refdatenum);
      OPT.refdatenum = datenum(mdf.keywords.itdate,'yyyy-mm-dd');
   elseif isempty(OPT.refdatenum)
      error('refdatenum missing')
   end

   [dummy,start,count] = nc_varget_range(OPT.nc,'time',OPT.period);
   W.datenum           = nc_cf_time     (OPT.nc,'time'                       ,[  start],[  count]);
   W.UP                = nc_varget      (OPT.nc,'wind_speed'                 ,[0 start],[1 count]);
   W.DD                = nc_varget      (OPT.nc,'wind_from_direction'        ,[0 start],[1 count]);

%% Mind that there are NaN's in the direction
  
  mask = (isnan(W.DD));
  
  plot(W.UP(mask))
  ylabel('m/s')
  title('Wind speed when direction is NaN')
  print2screensize([OPT.dir,filesep,filename(OPT.nc),'_after_refdate_',datestr(OPT.refdatenum,30),'_NaN_in_direction.png'])
  
%% Remove nans (of either directory or speed)
%  For Delft3D there is no need to be equidistant in time.

   mask      = find(~isnan(W.UP) & ~isnan(W.DD));
 % W.UX      = interp1(W.datenum(mask),W.UX(mask),W.datenum);
 % W.UY      = interp1(W.datenum(mask),W.UY(mask),W.datenum);
 %[W.DD,W.UP] = CART2POL(W.UX,W.UY);
 % W.DD = deguc2degn(rad2deg(W.DD));
   
   W.datenum  = W.datenum(mask);
   W.UP       = W.UP     (mask);
   W.DD       = W.DD     (mask);
   
   nc_filename = filename(OPT.nc);
   refdatestr = datestr(OPT.refdatenum,30);
   myfilesep = filesep;
   
   delft3d_io_wnd('write',[OPT.dir,myfilesep,nc_filename,'_after_refdate_',refdatestr,'_nonan.wnd'],W,'refdatenum',OPT.refdatenum)