function varargout = arc_asc_cleanup_duplicates(year_original, year_duplicate, polygon, varargin)
%ARC_ASC_CLEANUP_DUPLICATES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = arc_asc_cleanup_duplicates(year_original, year_duplicate, polygon, varargin)
%
%   Input: For <keyword,value> pairs call arc_asc_cleanup_duplicates() without arguments.
%   year_original  =
%   year_duplicate =
%   polygon        =
%   varargin       =
%
%   Output:
%   varargout      =
%
%   Example
%   arc_asc_cleanup_duplicates
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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
% Created: 15 May 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: arc_asc_cleanup_duplicates.m 9222 2013-09-16 08:43:00Z heijer $
% $Date: 2013-09-16 16:43:00 +0800 (Mon, 16 Sep 2013) $
% $Author: heijer $
% $Revision: 9222 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/gis/arc_asc_cleanup_duplicates.m $
% $Keywords: $

%%
OPT = struct(...
    'ascdir', 'd:\heijer\sources\raw_vaklodingen\grid',...
    'dateFcn', @(s) datenum(regexp(s, '(?<=_)\d{4}(?=\d{4})', 'match'), 'yyyy'));

% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

[year_original year_duplicate] = deal(1985, 1984)
shp = shaperead('d:\heijer\Work\Deltares\Projects\KPP\BenO_kust\2013\data_op_orde\Verschil_polygons_CLEAN\1985min1984');
polygon = [shp.X; shp.Y]';

%% code
D = dir2(OPT.ascdir,...
    'file_incl', '\.asc$',...
    'no_dirs', true);

years = year(cellfun(@OPT.dateFcn, {D.name}));
idx = ismember(years, [year_original year_duplicate]);

fnames = cellfun(@(fname) fullfile(OPT.ascdir, fname), {D(idx).name},...
    'uniformoutput', false);

[x, y] = cellfun(@asc_asc_metainfo, fnames,...
    'uniformoutput', false);
[minx, maxx, miny, maxy] = cellfun(@(xx,yy) deal(min(xx), max(xx), min(yy), max(yy)), x, y);
polygons = arrayfun(@(mnx,mxx,mny,mxy) [mnx, mny; mnx, mxy; mxx, mxy; mxx, mny; mnx, mny], minx, maxx, miny, maxy,...
    'uniformoutput', false);
sidx = find(isnan([NaN; polygon(1:end-1,1)]));
eidx = find(isnan(polygon(:,1)))-1;
hascrossing = false(length(sidx), length(polygons));
for i =1:length(sidx)
    hascrossing(i,:) = cellfun(@(pg) ~isempty(findCrossingsOfPolygonAndPolygon(polygon(sidx(i):eidx(i),1), polygon(sidx(i):eidx(i),2),pg(:,1), pg(:,2))), polygons);
end

idx = any(hascrossing);
[fnames, x, y] = deal(fnames(idx), x(idx), y(idx));

[X,Y] = cellfun(@meshgrid, x, y,...
    'uniformoutput', false);

IN = cellfun(@(xx,yy) inpolygon(xx,yy, polygon(:,1), polygon(:,2)), X, Y,...
    'uniformoutput', false);
idx = cellfun(@(a) any(a(:)), IN);
[fnames, X, Y, IN] = deal(fnames(idx), X(idx), Y(idx), IN(idx));

% BoundingBox =  minmax(polygon')';
% idxx = cellfun(@(xp) any(xp>=BoundingBox(1,1) | xp<=BoundingBox(2,1)), x);
% idxy = cellfun(@(yp) any(yp>=BoundingBox(1,2) | yp<=BoundingBox(2,2)), y);
% idx = idxx & idxy;

[x,y,z] = cellfun(@arc_asc_read_full, fnames,...
    'uniformoutput', false);
NANvals = cellfun(@isnan, z,...
    'uniformoutput', false);
years = year(cellfun(@OPT.dateFcn, fnames(idx)));

settonan = cellfun(@(a,b) a&~b, IN, NANvals,...
    'uniformoutput', false);


function [x, y, fid, nodata_value] = asc_asc_metainfo(fname, varargin)

OPT = struct(...
    'close', true);
OPT = setproperty(OPT, varargin);

fid = fopen(fname);

s = textscan(fid,'%s %f',6);

ncols        = s{2}(strcmpi(s{1},'ncols'       ));
nrows        = s{2}(strcmpi(s{1},'nrows'       ));
xllcorner    = s{2}(strcmpi(s{1},'xllcorner'   ));
yllcorner    = s{2}(strcmpi(s{1},'yllcorner'   ));
cellsize     = s{2}(strcmpi(s{1},'cellsize'    ));
nodata_value = s{2}(strcmpi(s{1},'nodata_value'));
if isempty(ncols)||isempty(nrows)||isempty(xllcorner)||isempty(yllcorner)||isempty(cellsize)||isempty(nodata_value)
    error('reading asc file')
end
if OPT.close
    fclose(fid);
end

x = (xllcorner + cellsize/2) + (0:(ncols-1))*cellsize;
y = (yllcorner + cellsize/2) + (0:(nrows-1))*cellsize;


function [x,y,z] = arc_asc_read_full(fname, varargin)
OPT = struct(...
    'block_size', 1e6);
OPT = setproperty(OPT, varargin);

[x, y, fid, nodata_value] = asc_asc_metainfo(fname,...
    'close', false);

small_number  = 1e-16;
ncols = length(x);


kk = 0;
while ~feof(fid)
    % read the file
    kk       = kk+1;
    D{kk}    = textscan(fid,'%f64',floor(OPT.block_size/ncols)*ncols,'CollectOutput',true); %#ok<AGROW>
    D{kk}{1} = reshape(D{kk}{1},ncols,[])'; %#ok<AGROW>
    if all(abs(D{kk}{1}(:) - nodata_value) < small_number)
        D{kk}{1}(:,:) = nan; %#ok<AGROW>
    else
        D{kk}{1}(abs(D{kk}{1}-nodata_value) < small_number) = nan; %#ok<AGROW>
    end
end
fclose(fid);
if length(D) == 1
    z = D{1}{1};
else
    D2 = cellfun(@(x) x{1}, D, 'UniformOutput', false);
    z = cat(1, D2{:});
end