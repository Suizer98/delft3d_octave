function varargout = nc_cf_time_range(ncfile,varname,lim,varargin)
%NC_CF_TIME_RANGE   reads get a monotonous subset from HUGE time vector into Matlab datenumber
%
%   datenumbers                     = nc_varget_range(ncfile,'varname',var_range);
%  [datenumbers,ind]                = nc_varget_range(...)
%  [datenumbers,start,count,<zone>] = nc_varget_range(...)
%
% extracts all time vectors from netCDF file ncfile as Matlab datenumbers.
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% time    = defined according to the CF convention as in:
% varname = optional name of specific time vector
% zone    = time zone (optional output 2nd argument)
%
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04s04.html
%
% When there is only one time variable, an array is returned,
% otherwise a warning is thrown.
%
% Example:
%
%  base              = 'http://opendap.deltares.nl:8080/thredds/dodsC';
% [D.datenum,D.zone] = nc_cf_time([base,'/opendap/knmi/potwind/potwind_343_2001.nc'],'time')
%
%See also: nc_cf_timeseries, NC_CF_GRID, UDUNITS2DATENUM, nc_varget_range

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

% This tools is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_cf_time_range.m 7850 2012-12-18 10:25:53Z boer_g $
% $Date: 2012-12-18 18:25:53 +0800 (Tue, 18 Dec 2012) $
% $Author: boer_g $
% $Revision: 7850 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_time_range.m $
% $Keywords: $

[t,start,count,zone] = nc_varget_range(ncfile,varname,lim,'time',1,varargin{:}); % nc_varget_range now handles time offset internally, but here we force it
    
if     nargout==1
   varargout = {t};
elseif nargout==2
   varargout = {t,[(start+1):(start+count)]};
elseif nargout==3
   varargout = {t,start,count};
elseif nargout==4
   varargout = {t,start,count,zone};
end    

%% EOF