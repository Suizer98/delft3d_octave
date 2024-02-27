function [datenumbers,zone] = ncwrite_cf_time(ncFile, varName, datenumbers, varargin)
%ncwrite_cf_time  Writes time data in matlab datenum to a specified cf compliant time variable in a nc file
%
%   Syntax is exactly like ncwrite.
%
%   See also NCWRITE, NCREAD_CF_TIME

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 05 Sep 2012
% Created with Matlab version: 8.0.0.755 (R2012b)

% $Id: ncwrite_cf_time.m 11865 2015-04-15 14:58:43Z gerben.deboer.x $
% $Date: 2015-04-15 22:58:43 +0800 (Wed, 15 Apr 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11865 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwrite_cf_time.m $
% $Keywords: $

%% check if file is a cf comliant time variable
info          = ncinfo(ncFile,varName);
unitAttribute = strcmpi({info.Attributes.Name},'units');
assert(any(unitAttribute),'Variable must have attribute units')

%% get time data and vonvert from udunits to matlab datenum
time_units         = info.Attributes(unitAttribute).Value;
udunits            = datenum2udunits(datenumbers,time_units);
ncwrite(ncFile,varName,udunits,varargin{:});