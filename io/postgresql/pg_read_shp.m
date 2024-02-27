function S = pg_read_shp(shp)
%PG_READ_SHP  Read shapefile into WKT struct
%
%   Read shapefile into WKT struct
%
%   Syntax:
%   S = pg_read_shp(shp)
%
%   Input:
%   shp       = path to shapefile
%
%   Output:
%   S         = WKT structure
%
%   Example
%   S   = pg_read_shp('example.shp')
%   WKT = pg_write_ewkt(S)
%
%   See also pg_write_ewkt, pg_write_ewkb, pg_read_ewkt, pg_read_ewkb

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

% $Id: pg_read_shp.m 7926 2013-01-18 13:07:55Z hoonhout $
% $Date: 2013-01-18 21:07:55 +0800 (Fri, 18 Jan 2013) $
% $Author: hoonhout $
% $Revision: 7926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_read_shp.m $
% $Keywords: $

%% check input

if ~isstruct(shp)
    if ~exist(shp, 'file')
        error('File not found: %s', shp);
    end

    [fdir, fname] = fileparts(shp);

    shp = m_shaperead(fullfile(fdir, fname));
end

%% build structure

S = struct(                     ...
    'type',     '',             ...
    'dims',     {{'x', 'y'}},   ...
    'srid',     0,              ...
    'coords',   cell(length(shp.ncst),1));

for i = 1:length(shp.ncst)
    
    sidx        = [find(all(isnan(shp.ncst{i}),2)) ;  size(shp.ncst{i},1)];
    
    S(i).type   = shp2wkt_type(shp.type);
    
    if length(sidx)>1
        S(i).type = ['Multi' S(i).type];
    end
    
    jj = 1;
    for j = 1:length(sidx)
        S(i).coords{j} = shp.ncst{i}(jj:sidx(j)-1,:);
        jj = sidx(j)+1;
    end
    
    if length(sidx)==1
        S(i).coords = S(i).coords{1};
    end
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wkt = shp2wkt_type(idx)

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
    
    wkt = types{idx};
    
end