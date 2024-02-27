function s = pg_write_ewkt(S)
%PG_WRITE_EWKT  Write WKT (Well Known Text) struct to WKT string
%
%   Write a WKT (Well Known Text) struct to a string
%
%   Syntax:
%   s = pg_write_ewkt(S)
%
%   Input:
%   S         = WKT struct
%
%   Output:
%   s         = WKT string
%
%   Example
%   WKT = pg_write_ewkt(S)
%   S   = pg_read_ewkt(WKT)
%
%   See also pg_read_ewkt, pg_read_ewkb, pg_write_ewkb
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

% $Id: pg_write_ewkt.m 9032 2013-08-12 08:12:35Z boer_g $
% $Date: 2013-08-12 16:12:35 +0800 (Mon, 12 Aug 2013) $
% $Author: boer_g $
% $Revision: 9032 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_write_ewkt.m $
% $Keywords: $

%% check input

if ischar(S)
    % read wkb is input is string
    S = pg_read_wkb(S);
end

if ~isstruct(S) || ~isfield(S, 'type')
    % check if input is a valid struct
    error('Input should be a struct from pg_read_ewkb.m');
end

if length(S) > 1
    % structure array
    s = cell(size(S));
    for i = 1:length(S)
        s{i} = pg_write_ewkt(S(i));
    end
    return
end

s = '';

%% write srid

if isfield(S, 'srid') && S.srid>0
    s = [s sprintf('SRID=%d;', S.srid)];
end

%% write type

s = [s upper(S.type)];

%% write coordinates

coords = S.coords;

if ~iscell(S.coords)
    coords = {coords};
end

n1 = length(coords);
c1 = cell(n1, 1);
for i = 1:n1
    n2 = size(coords{i},1);
    c2 = cell(n2,1);
    for j = 1:n2
        c2{j} = sprintf('%10.4f %10.4f', coords{i}(j,1), coords{i}(j,2));
    end
    c1{i} = sprintf('(%s)', concat(c2, ',\n'));
end

if iscell(S.coords)
    s = [s sprintf('(%s)', concat(c1, ','))];
else
    s = [s concat(c1, ',')];
end