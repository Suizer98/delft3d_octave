function varargout = writeBestTrackUnisys(tc_fname,tc,varargin)
%writeBestTrackUnisys write a Unisys cyclone best track file
%
%   see http://weather.unisys.com/hurricane/ for best track files
%
%   Syntax:
%       writeBestTrackUnisys(tc_fname,tc)
%
%   Input:
%       tc = struct with date, name, meta, time, lon, lat, vmax and p
%
%   Output:
%       Unisys cyclone best track file
%
%   Example:
%       writeBestTrackUnisys(tc_fname,tc);
%
%   See also readBestTrackUnisys DelftDashBoard

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 03 Jun 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: writeBestTrackUnisys.m 11279 2014-10-22 10:40:45Z bartgrasmeijer.x $
% $Date: 2014-10-22 12:40:45 +0200 (Wed, 22 Oct 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 11279 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/writeBestTrackUnisys.m $
% $Keywords: $

fid = fopen(tc_fname,'w+');
fprintf(fid,'%s\n',tc.date);
fprintf(fid,'%s\n',tc.name);
fprintf(fid,'%s\n',tc.meta);
for i = 1:length(tc.time)
    if ~isnan(tc.time(i))
        mystring = [num2str(i,'%8.2f'),datestr(tc.time(i),'mm/dd/hh')];
        fprintf(fid,'%3s %7s %7s %9s%s %7s %7s\n',num2str(i),num2str(tc.lat(i),'%6.2f'),...
            num2str(tc.lon(i),'%6.2f'),datestr(tc.time(i),'mm/dd/hh'),'Z',num2str(tc.vmax(i,1),'%02.0f'),num2str(tc.p(i,1)./100));
    end
end
fclose(fid);
