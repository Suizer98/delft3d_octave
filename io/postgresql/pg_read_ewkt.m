function S = pg_read_ewkt(s)
%PG_READ_EWKT  Read WKT (Well Known Text) string into WKT struct
%
%   Read a WKT (Well Known Text) string into struct
%
%   Syntax:
%   S = pg_read_ewkt(s)
%
%   Input: 
%   s         = WKT string
%
%   Output:
%   S         = WKT struct
%
%   Examples from http://en.wikipedia.org/wiki/Well-known_text
%   S = pg_read_ewkt('POINT (30 10)')
%   S = pg_read_ewkt('LINESTRING (30 10, 10 30, 40 40)')
%   S = pg_read_ewkt('POLYGON ((30 10, 40 40, 20 40, 10 20, 30 10))')
%   S = pg_read_ewkt('POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),(20 30, 35 35, 30 20, 20 30)))')
%
%   S = pg_read_ewkt('MULTIPOINT ((10 40), (40 30), (20 20), (30 10))')
%   S = pg_read_ewkt('MULTIPOINT (10 40, 40 30, 20 20, 30 10)')
%   S = pg_read_ewkt('MULTILINESTRING ((10 10, 20 20, 10 40),(40 40, 30 30, 40 20, 30 10))')
%   S = pg_read_ewkt('MULTIPOLYGON (((30 20, 45 40, 10 40, 30 20)),((15 5, 40 10, 10 20, 5 10, 15 5)))')
%   S = pg_read_ewkt('MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)),((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),(30 20, 20 15, 20 25, 30 20)))')
%
%   See also pg_write_ewkt, pg_read_ewkb, pg_write_ewkb,
%            java: http://www.vividsolutions.com/jts/JTSHome.htm
%            c++: http://trac.osgeo.org/geos/

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 18 Jan 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: pg_read_ewkt.m 11425 2014-11-22 12:08:47Z gerben.deboer.x $
% $Date: 2014-11-22 20:08:47 +0800 (Sat, 22 Nov 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11425 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_read_ewkt.m $
% $Keywords: $

%% parse text

if strmatch('MULTIPOLYGON',s)
    error('MULTIPOLYGON not yet implemented')
end

S = regexp(s, '(?<srid>\s*SRID\s*=\s*\d+\s*;)?\s*(?<type>\w+)\s*\((?<coords>.*)\)\s*$', 'names');

if isempty(S)
    error('Cannot parse WKT string');
end

%% parse srid

if isfield(S, 'srid') && ~isempty(S.srid)
    S.srid = str2num(regexprep(S.srid, '\s*SRID\s*=\s*(\d+)\s*;', '$1'));
else
    S.srid = 0;
end

%% parse coords

coords = regexp(S.coords, '\((.*?)\)', 'tokens');

if isempty(coords)
    coords = {{S.coords}};
end

S.coords = {};
for i = 1:length(coords)
    coords2 = regexp(coords{i}{1}, '\s*,\s*', 'split');
    for j = 1:length(coords2)
        S.coords{i}(j,:) = cellfun(@str2num, regexp(coords2{j}, '\s+', 'split'));
    end
end

if length(S.coords) == 1
    S.coords = S.coords{i};
end

%% parse dims

S.dims = {'x' 'y'};