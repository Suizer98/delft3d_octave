function [t1,varargout] = jdb_datenum(t0)
%JDB_DATENUM conversion between Matlab datenumbers and PG datetime
%
% p = JDB_DATENUM(m) converts a Matlab datenumber array m into a 
% PostgreSQL datetimestring array p with format 'yyyy-mm-dd HH:MM:SS'.
%
% m = JDB_DATENUM(p) converts a PostgreSQL datetimestring p with
% format 'yyyy-mm-dd HH:MM:SS+timezone' into a Matlab datenumber m.
% any timezone information is lost.
%
% [m,tz] = JDB_DATENUM(p) returns any optional timezone in p into
% tz. JDB_DATENUM does not interpret timezones.
%
% The format of p is such that is fits in the timestamp datatype of
% (Postgre)SQL as in the following schema: 
%  ALTER  TABLE "TEST" ADD COLUMN "ObservationTime" timestamp with time zone;
%  INSERT INTO  "TEST" ("ObservationTime") VALUES ('2004-10-19 10:23:54+0'), ('2012-10-19 10:23:54+0')
%
% Example: 
%
%   p      = jdb_datenum([now;now+1])
%   [d,tz] = jdb_datenum({'1648-10-24 00:01:00+1',datestr(now,'yyyy-mm-dd HH:MM:SS')})
%
% See also: postgresql, nc_cf_time, datenum, datestr, time_fun

%% Copyright notice: see below


if iscellstr(t0)
    t0 = char(t0);
end

if ischar(t0)
    if isempty(t0)
        t1 = '' ; 
    else
        if size(t0,2) > 19
            varargout = {t0(:,20:end)};
            t0 = t0(:,1:19);
        end
        t1 = datenum(t0);
    end
elseif isnumeric(t0)
    if all(t0>1)
        t1 = datestr(t0,'yyyy-mm-dd HH:MM:SS');
    else
        t1 = datestr(t0,'HH:MM:SS');
    end
elseif iscell(t0)
    if all(cellfun(@isnumeric,t0))
        %Handle NaN's
        idx = ~cellfun(@isnan,t0);
        t1  = repmat({''},size(t0));
        if any(idx)
            if all(cellfun(@(x) x>1, t0(idx)))
                t1(idx) = cellstr(datestr(cell2mat(t0(idx)),'yyyy-mm-dd HH:MM:SS'));
            else
                t1(idx) = cellstr(datestr(cell2mat(t0(idx)),'HH:MM:SS'));
            end
        end
    else
        disp('Error converting date')
        t1 = nan(size(t0));
    end
else
    disp('Error converting date')
    t1 = nan(size(t0));
%     error('?')
end

% Be sure that the output is a cellstring
t1 = cellstr(t1);


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
%       ronald.vanderhout@vanoord.com
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
% $Id: jdb_datenum.m 12715 2016-05-04 17:01:35Z rho.x $
% $Date: 2016-05-05 01:01:35 +0800 (Thu, 05 May 2016) $
% $Author: rho.x $
% $Revision: 12715 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_datenum.m $
% $Keywords: $
