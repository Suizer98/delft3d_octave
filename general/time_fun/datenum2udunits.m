function varargout = datenum2udunits(datenumber,isounits)
%datenum2udunits   converts date(s) in ISO 8601 units to Matlab datenumber(s)
%
%    [time,<zone>] = udunits2datenum(datenumber,isounits)
%
%
%    [time,<zone>] = udunits2datenum( [602218 648857], 'days since 0000-0-0 00:00:00 +01:00')
%
% where <zone> is optional and has the length of isounits.
%
%See web: <a href="http://www.unidata.ucar.edu/software/udunits/">http://www.unidata.ucar.edu/software/udunits/</a>
%See also: UDUNITS2DATENUM, timeZones, NC_CF_time, DATENUM, DATESTR, ISO2DATENUM, TIME2DATENUM, XLSDATE2DATENUM

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
% Created: 24 Aug 2012
% Created with Matlab version: 8.0.0.755 (R2012b)

% $Id: datenum2udunits.m 11866 2015-04-16 10:58:23Z gerben.deboer.x $
% $Date: 2015-04-16 18:58:23 +0800 (Thu, 16 Apr 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11866 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/datenum2udunits.m $
% $Keywords: $

%% input check
if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
    % version 2011a and older
    error(nargchk(2,2,nargin)) %#ok<NCHKN>
else
    % version 2011b and newer
    narginchk(2,2)
end

%% Interpret unit and reference date string

rest              = isounits;
[units,rest]      = strtok(rest);
[dummy,rest]      = strtok(rest); % since
[refdatenum,zone] = iso2datenum(rest);
time              = (datenumber - refdatenum).*convert_units('day',units);

varargout         = {time,strtrim(zone)};
   
%% EOF   