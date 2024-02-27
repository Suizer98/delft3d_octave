function [trvk, tr] = jarkus_extend_with_vaklodingen(jarkus_id, jarkus_year, varargin)
%JARKUS_EXTEND_WITH_VAKLODINGEN  extend jarkus transect seaward using vaklodingen.
%
%   More detailed description goes here.
%
%   Syntax:
%   [trvk, tr] = jarkus_extend_with_vaklodingen(id, year)
%
%   Input:
%   jarkus_id       = identifier of jarkus transect
%   jarkus_year     = year of jarkus measurement
%   varargin        = propertyname-propertyvalue pairs:
%                   'jarkus_extend' - boolean to indicating whether the
%                   transect should first be extended as much as possible
%                   based on jarkus data of other years.
%                   'debug' - boolean giving the opportunity to plot some
%                   intermediate steps in order to check the process
%
%   Output:
%   trvk = jarkus transect structure, with data as interpolated from
%           vaklodingen
%   tr   = jarkus transect structure, with 'real' jarkus data
%
%   Example
%   transects = jarkus_extend_with_vaklodingen(7001503, 2010)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Mar 2012
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_extend_with_vaklodingen.m 14251 2018-03-28 11:29:53Z schrijve $
% $Date: 2018-03-28 19:29:53 +0800 (Wed, 28 Mar 2018) $
% $Author: schrijve $
% $Revision: 14251 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_extend_with_vaklodingen.m $
% $Keywords: $

%%
OPT = struct(...
    'jarkus_extend', false,...
    'debug', false);
OPT = setproperty(OPT, varargin);

%%
if ~(isstruct(jarkus_id) && jarkus_check(jarkus_id, 'id', 'x', 'y', 'cross_shore'))
    %     if ~isscalar(jarkus_id) && ~isinteger(jarkus_id)
    %         error('"id" must be a scalar and integer')
    %     end
    
    
    %%
    if ~OPT.jarkus_extend
        tr = jarkus_transects('id', jarkus_id, 'year', jarkus_year);
        tr = jarkus_interpolatenans(tr);
    else
        % retreive transect for all available years
        tr = jarkus_transects('id', jarkus_id);
        % interpolate nans in cross-shore direction (default)
        tr = jarkus_interpolatenans(tr);
        % interpolate nans in time
        tr = jarkus_interpolatenans(tr,...
            'interp', 'time', ...
            'dim', 1);
        % extrapolate nans in time with nearest neighbour method
        tr = jarkus_interpolatenans(tr,...
            'interp', 'time', ...
            'dim', 1,...
            'method', 'nearest', ...
            'extrap', true);
        % delete data of other years
        skipid = ~ismember(year(tr.time + datenum(1970,1,1)), jarkus_year);
        tr.time(skipid) = [];
        tr.altitude(skipid,:,:) = [];
    end
    
    nnid = sum(~isnan(squeeze(tr.altitude))) ~= 0;
else
    tr = jarkus_id;
end

x = tr.x;
dx = mean(diff(x,1,2), 2);
y = tr.y;
dy = mean(diff(y,1,2), 2);

x_rsp = tr.x(:,tr.cross_shore==0);
y_rsp = tr.y(:,tr.cross_shore==0);

% x and y direction when going offshore
x_direction = sign(dx);
y_direction = sign(dy);

px2y = cellfun(@(xi,yi) polyfit(xi,yi,1), num2cell(x,2), num2cell(y,2),...
    'uniformoutput', false);

%% retreive extent of vaklodingen
urls = opendap_catalog('http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/catalog.html',...
    'ignoreCatalogNc', true);



catalogidx = ~cellfun(@isempty, regexp(urls, 'catalog.nc$', 'match'));

[projectionCoverage_x, projectionCoverage_y] = deal([]);

if any(catalogidx)
    urlPath = cellstr(nc_varget(urls{catalogidx}, 'urlPath'));
    if isequal(numel(unique(urlPath)), sum(~catalogidx))
        % only possible if matlab/opendap bug that causes the urlPath
        % to be cropped at 64 characters does not occur
        projectionCoverage_x = nc_varget(urls{catalogidx}, 'projectionCoverage_x');
        projectionCoverage_y = nc_varget(urls{catalogidx}, 'projectionCoverage_y');
        projectionCoverage_x = projectionCoverage_x + ones(size(projectionCoverage_x))*[-10 0;0 10];
        projectionCoverage_y = projectionCoverage_y + ones(size(projectionCoverage_y))*[-10 0;0 10];
        
        ids = cellfun(@(s) s{1}, regexp(urlPath, '\d{3}_\d{4}', 'match'),...
            'uniformoutput', false);
    end
end

if ~any(catalogidx) || isempty(projectionCoverage_x)
    D = cellfun(@vaklodingen_definition, urls(~catalogidx));
    ids = {D.name};
    bboxs = [D.BoundingBox];
    projectionCoverage_x = bboxs(:,1:2:end)';
    projectionCoverage_y = bboxs(:,2:2:end)';
end

x_from = projectionCoverage_x(:,1);
x_to = projectionCoverage_x(:,2);
y_from = projectionCoverage_y(:,1);
y_to = projectionCoverage_y(:,2);

rectangles = [x_from y_from x_to-x_from  y_to-y_from];

% url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/vaklodingen/vaklodingen.nc';
% ids = nc_varget(url, 'id');
% rectangles = nc_varget(url, 'rectangle');
% x_from = nc_varget(url, 'x_from');
% x_to = nc_varget(url, 'x_to');
% y_from = nc_varget(url, 'y_from');
% y_to = nc_varget(url, 'y_to');

%% construct bounding boxes and find potential relevant ones
x_rect = [x_from x_from x_to x_to x_from];
y_rect = [y_from y_to y_to y_from y_from];

rect_select = false(size(ids,2), length(tr.id));
for ii = 1:length(tr.id)
    rect_preselect = any(sign(x_rect - x(ii,1)) == x_direction(ii), 2) & ...
        any(sign(y_rect - y(ii,1)) == y_direction(ii), 2) | ...
        any(sign(x_rect - x(end)) == -x_direction(ii), 2) & ...
        any(sign(y_rect - y(end)) == -y_direction(ii), 2);
    
    %% plot pre-selected area
    if OPT.debug
        figure;
        subplot(2,2,1);
        ldbncfile = 'http://opendap.tudelft.nl/thredds/dodsC/data2/deltares/deltares/landboundaries/holland.nc';
        plot(nc_varget(ldbncfile, 'x'), nc_varget(ldbncfile, 'y'))
        hold on
        for jj = 1:length(ids)
            rectangle('position', rectangles(jj,:), 'tag', ids{jj}, 'edgecolor', 'b');
        end
        for jj = find(rect_preselect)'
            rectangle('position', rectangles(jj,:),'tag', ids{jj}, 'edgecolor', 'r');
        end
        plot(x(ii,[1 end]),y(ii,[1 end]), 'r-o')
    end
    
    %% locate most landward and seaward points of extended transect
    if x_direction(ii) == 0
        if y_direction < 0
            y_0(ii) = max(y_to(rect_preselect));
            y_end(ii) = min(y_from(rect_preselect));
        else
            y_0(ii) = min(y_from(rect_preselect));
            y_end(ii) = max(y_to(rect_preselect));
        end
        [x_0(ii), x_end(ii)] = deal(x(ii,1));
    else
        if x_direction(ii) < 0
            x_0(ii) = max(x_to(rect_preselect));
            x_end(ii) = min(x_from(rect_preselect));
        else
            x_0(ii) = min(x_from(rect_preselect));
            x_end(ii) = max(x_to(rect_preselect));
        end
        y_0(ii) = polyval(px2y{ii}, x_0(ii));
        y_end(ii) = polyval(px2y{ii}, x_end(ii));
    end
    
    %% select the map areas that the transects is actually crossing
    xcr = cell(size(rect_preselect));
    [xcr(rect_preselect), ycr(rect_preselect)] = cellfun(@(xx,yy) findCrossingsOfLineAndPolygon([x(ii,1) x_end(ii)], [y(ii,1) y_end(ii)], xx, yy),...
        num2cell(x_rect(rect_preselect,:), 2), num2cell(y_rect(rect_preselect,:), 2),...
        'uniformoutput', false);
    
    rect_select(ii,~cellfun(@isempty, xcr)) = true;
    
    %% plot selected area
    if OPT.debug
        for sb = 1:2
            subplot(2,2,sb)
            for i = find(rect_select)'
                rectangle('position', rectangles(i,:),...
                    'tag', strtrim(ids{i}),...
                    'edgecolor', 'r',...
                    'linewidth', 2);
            end
        end
        hold on
        plot(x(ii, [1 end]),y(ii, [1 end]), 'r-o')
    end
    
    xe{ii} = [fliplr(x(ii,1):-dx(ii):x_0(ii)) x(ii,2):dx(ii):x_end(ii)];
    ye{ii} = [fliplr(y(ii,1):-dy(ii):y_0(ii)) y(ii,2):dy(ii):y_end(ii)];
    cse{ii} = round(sqrt((xe{ii} - x_rsp(ii)).^2 + (ye{ii} - y_rsp(ii)).^2));
    cse{ii}(diff(cse{ii})<0) = -cse{ii}(diff(cse{ii})<0);
end
cse = unique(cat(2, cse{:}));
cse = cse(cse>=min(tr.cross_shore));
xe = repmat(cse, length(tr.id), 1)/5 .* repmat(dx, 1, length(cse)) + repmat(x_rsp, 1, length(cse));
ye = repmat(cse, length(tr.id), 1)/5 .* repmat(dy, 1, length(cse)) + repmat(y_rsp, 1, length(cse));

kbgroups = unique(rect_select, 'rows');

ncfiles = cellfun(@(id) ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen' id '.nc'], ids(sum(rect_select)~=0),...
    'UniformOutput', false);
Ts = cellfun(@(ncfile) nc_varget(ncfile, 'time'), ncfiles,...
    'uniformoutput', false);
years = cellfun(@(T) year(T + datenum(1970,1,1)), Ts,...
    'uniformoutput', false);
uniqueyears = unique(cell2mat(years'));
jarkus_year = uniqueyears(ismember(uniqueyears, jarkus_year));
ze = NaN(length(jarkus_year), length(tr.id), length(cse));

for ig = 1:size(kbgroups,1)
    %% retreive bathymetry data from vaklodingen
    % relevant ncfiles
    ncfiles = cellfun(@(id) ['http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen' id '.nc'], ids(kbgroups(ig,:)),...
        'UniformOutput', false);
    % unique years
    Ts = cellfun(@(ncfile) nc_varget(ncfile, 'time'), ncfiles,...
        'uniformoutput', false);
    years = cellfun(@(T) year(T + datenum(1970,1,1)), Ts,...
        'uniformoutput', false);
    uniqueyears = unique(cell2mat(years'));
    uniqueyears = uniqueyears(ismember(uniqueyears, jarkus_year));
    
    [xvl, yvl] = cellfun(@(ncfile) deal(nc_varget(ncfile, 'x'), nc_varget(ncfile, 'y')), ncfiles,...
        'uniformoutput', false);
    for iyear = 1:length(uniqueyears)
        % pre-allocate z
        zvl = cellfun(@(X,Y) NaN(length(Y), length(X)), xvl, yvl,...
            'uniformoutput', false);
        for ii = 1:length(ncfiles)
            tidx = find(ismember(years{ii}, uniqueyears(iyear)));
            if ~isempty(tidx)
                ncfile = ncfiles{ii};
                if length(tidx) < 3
                    stt = tidx(1)-1; % start t
                    ctt = length(tidx); % count t
                    sdt = 1; % stride t
                    if length(tidx) == 2
                        sdt = diff(tidx); % stride t
                    end
                    ztmp  = nc_varget(ncfile, 'z', [stt 0 0], [ctt -1 -1], [sdt 1 1]);
                else
                    ztmp = cell(0);
                    for it = 1:length(tidx)
                        stt = tidx(it)-1;
                        ztmp{it} = nc_varget(ncfile, 'z', [stt 0 0], [1 -1 -1]);
                    end
                    ztmp = permute(cat(3, ztmp{:}), [3 1 2]);
                end
                if ndims(ztmp) == 3
                    % index to pick only one z-value for each point, giving
                    % preference to higher slices (earlier in time) an filling
                    % up with missings at the lowest slice (independent from
                    % this slice containing nans)
                    idx = diff(cat(1,...
                        zeros(1,size(ztmp,2), size(ztmp,3)),...
                        ~isnan(ztmp(1:end-1,:,:)),...
                        ones(1,size(ztmp,2), size(ztmp,3))),...
                        1,1) == 1;
                    zvl{ii} = ztmp(idx);
                else
                    zvl{ii} = ztmp;
                end
            end
        end
        % merge grids
        [X, Y, Z] = xb_grid_merge('x', xvl, 'y', yvl, 'z', zvl, 'maxsize', 'max');
        
        for jj = find(cellfun(@(rs) isequal(rs, kbgroups(ig,:)), num2cell(rect_select,2))')
            ze(ismember(jarkus_year, uniqueyears(iyear)),jj,:) = interp2(X, Y, Z, xe(jj,:), ye(jj,:));
        end
    end
    
    
    
end
tmask = ~any(any(~isnan(ze), 3), 2); % time mask
amask = ~any(any(~isnan(ze), 3), 1); % alongshore mask
nnid = squeeze(any(any(~isnan(ze), 1), 2));
cmask = true(size(cse));
cmask(find(nnid, 1, 'first'):find(nnid, 1, 'last')) = false;

trvk = struct(...
    'id', tr.id(~amask),...
    'time', datenum(jarkus_year(~tmask),7,1) - datenum(1970,1,1),...
    'x', xe(~amask,~cmask),...
    'y', ye(~amask,~cmask),...
    'cross_shore', cse(~cmask),...
    'altitude', ze(~tmask, ~amask, ~cmask));