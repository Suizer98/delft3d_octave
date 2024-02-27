function [S, prop, s] = pg_read_ewkb(s)
%PG_READ_EWKB  Read WKB (Well Known Binary) string into WKT struct
%
%   Read hexadecimal WKB (Well Known Binary) string into WKT (Well Known
%   Text) struct
%
%   Syntax:
%   [S prop s] = pg_read_ewkb(s)
%
%   Input: 
%   s         = WKB string
%
%   Output:
%   S         = WKT struct
%   prop      = Additional structure with technical properties
%   s         = Remainder of WKB string that is not used
%
%   Example
%   S   = pg_read_ewkb(wkb)
%   WKT = pg_write_ewkt(S)
%
% Note: you can also download the <a href="http://www.vividsolutions.com/jts">JTS java toolbox</a>:
%
%   javaaddpath('your_location\jts-1.8.jar');        % load the java toolbox from above URL
%   rdr      = com.vividsolutions.jts.io.WKBReader(); % create reader instance called 'rdr'
%   geometry = rdr.read(rdr.hexToBytes(hex));         % create geometry object
%   srid     = geometry.getSRID;                      % unpak geometry for use in matlab coding style
%   x        = geometry.getCoordinate.x;
%   y        = geometry.getCoordinate.y;
%   z        = geometry.getCoordinate.z;
%              geometry.getNumPoints
%
%   See also pg_write_ewkt, pg_read_ewkt, pg_write_ewkb
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

% $Id: pg_read_ewkb.m 9032 2013-08-12 08:12:35Z boer_g $
% $Date: 2013-08-12 16:12:35 +0800 (Mon, 12 Aug 2013) $
% $Author: boer_g $
% $Revision: 9032 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_read_ewkb.m $
% $Keywords: $

%% convert object to string

if strcmpi(class(s),'org.postgresql.util.PGobject')
   s = char(s.toString);
end

S = struct( ...
    'type',     '', ...
    'dims',     {{'x', 'y'}}, ...
    'srid',     0,  ...
    'coords',   []      );

%% read properties

prop = struct( ...
    'byte_order', false,    ...
    'type',       0,        ...
    'multi',      false,    ...
    'srid',       false,    ...
    'z',          false,    ...
    'm',          false         );

[s, b] = read_bytes(s, prop, 2);

prop.byte_order = logical(b);

%% read type

type = nan(1,4);
[s, type(1)] = read_bytes(s, prop, 2);
[s, type(2)] = read_bytes(s, prop, 2);
[s, type(3)] = read_bytes(s, prop, 2);
[s, type(4)] = read_bytes(s, prop, 2);

if prop.byte_order
    type = fliplr(type);
end

% check srid
if bitand(type(1),32)
    prop.srid = true;
    type(1)   = bitset(type(1),6,0);
end

% check m
if bitand(type(1),64)
    prop.m  = true;
    type(1) = bitset(type(1),7,0);
end

% check z
if bitand(type(1),128)
    prop.z  = true;
    type(1) = bitset(type(1),8,0);
end

prop.type = type(1)*1000 + type(2)*100 + type(3)*10 + type(4);

[S.type, S.dims] = read_geometry(prop.type);

prop.multi = ~isempty(regexpi(S.type, '^MULTI'));

%% read srid

if prop.srid
    [s, S.srid] = read_bytes(s, prop, 8);
end

%% read coordinates

if ~ismember(prop.type, [1 2 3 4 5 6])
    error('Geometry type not yet implemented: %s', S.type)
else
    if prop.type > 1
        % read multipoint geometry
        [s, N] = read_bytes(s, prop, 8);
    else
        % read single point geometry
        N = 1;
    end
    
    if prop.multi
        % read multi part geometry
        S.coords = cell(N,1);
        for i = 1:N
            [I, ~, s] = pg_read_ewkb(s);
            S.coords{i} = I.coords;
        end
    else
        % read single part geometry
        S.coords = nan(N, 2 + prop.z + prop.m);
    
        for i = 1:N
            [s, S.coords(i,1)] = read_bytes(s, prop, 16);
            [s, S.coords(i,2)] = read_bytes(s, prop, 16);

            if prop.z
                [s, S.coords(i,3)] = read_bytes(s, prop, 16);
            end

            if prop.m
                [s, S.coords(i,3+prop.z)] = read_bytes(s, prop, 16);
            end
        end
    end
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read n bytes and convert to decimal number, return bytes left
function [s, b] = read_bytes(s, prop, n)

    b = s(1:n);
    s = s((n+1):end);

    b = reshape(b,2,n/2)';
    if prop.byte_order
        b = flipud(b);
    end
    
    switch n
        case {2 4 8}
            b = hex2dec(reshape(b',n,1)');
        case 16
            b = hex2num(reshape(b',n,1)');
        otherwise
            error('Unsupported number of bytes: %d', n);
    end
    
end

% convert geometry type index to type string and dimensions
function [type, dim] = read_geometry(idx)

    types = {                   ...
        'Geometry',             ...
        'Point',                ...
        'LineString',           ...
        'Polygon',              ...
        'MultiPoint',           ...
        'MultiLineString',      ...
        'MultiPolygon',         ...
        'GeometryCollection',   ...
        'CircularString',       ...
        'CompoundCurve',        ...
        'CurvePolygon',         ...
        'MultiCurve',           ...
        'MultiSurface',         ...
        'Curve',                ...
        'Surface',              ...
        'PolyhedralSurface',    ...
        'TIN',                  ...
        'Triangle'};

    dims = {                    ...
        {'x', 'y'},             ...
        {'x', 'y', 'z'},        ...
        {'x', 'y', 'm'},        ...
        {'x', 'y', 'z', 'm'}        };

     type = types{mod(idx,100)+1};
     dim  = dims{div(idx,1000)+1};
     
end
 