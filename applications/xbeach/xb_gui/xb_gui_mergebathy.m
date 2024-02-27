function varargout = xb_gui_mergebathy()
%XB_GUI_MERGEBATHY  Merge bathymetries
%
%   Select JARKUS transects and Vaklodingen from a map, possible add some
%   ArcGIS files and XBeach bathymetries to this selection and generate a
%   merged bathymetry from these sources.
%
%   Syntax:
%   varargout = xb_gui_mergebathy
%
%   Input:
%   none
%
%   Output:
%   varargout = x:  x-coordinates
%               y:  y-coordinates
%               z:  z-coordinates
%
%   Example
%   [x y z] = xb_gui_mergebathy
%
%   See also xb_gui_normconditions, xb_gui_dragselect

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_gui_mergebathy.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/xb_gui_mergebathy.m $
% $Keywords$

%% create gui

    sz = get(0, 'screenSize');

    winsize = [800 600];
    winpos = (sz(3:4)-winsize)/2;

    pobj = figure( ...
        'name', 'Bathymetry select tool', ...
        'numbertitle', 'off', ...
        'color', [0.8314 0.8157 0.7843], ...
        'position', [winpos winsize], ...
        'inverthardcopy', 'off', ...
        'resize', 'off');

    uicontrol(pobj, 'units', 'normalized', 'style', 'edit', 'tag', 'name', ...
        'position', [.05 .93 .60 .04], 'fontsize', 14, 'backgroundcolor', 'w', 'callback', @setloc);
    uicontrol(pobj, 'units', 'normalized', 'style', 'pushbutton', 'tag', 'merge', ...
        'position', [.88 .02 .10 .04], 'string', 'Merge', 'callback', @mergedata);

    uicontrol(pobj, 'units', 'normalized', 'style', 'popupmenu', 'tag', 'type', ...
        'position', [.68 .93 .23 .04], 'string', 'ARCGIS file|XBeach grid files', 'backgroundcolor', 'w');
    uicontrol(pobj, 'units', 'normalized', 'style', 'pushbutton', 'tag', 'add', ...
        'position', [.93 .93 .05 .04], 'string', 'Add', 'callback', @addfile);
    uitable(pobj, 'units', 'normalized', 'tag', 'table', 'position', [.68 .14 .30 .75], ...
        'columnname', {'type', 'value'}, 'columnwidth', {75 150});

    % create axes
    ax1 = axes('position', [.05 .14 .60 .75]); hold on; box on;

    hl = nc_plot_coastline; axis equal;
    set(hl, 'Color', [.8 .8 .8]);

    ax3 = axes('position', get(ax1, 'position'), 'tag', 'map2', 'color', 'none', ...
        'xticklabel', {}, 'yticklabel', {}); hold on;

    % get jarkus transects
    j = jarkus_transects('cross_shore', [0 5000], 'output', {'id' 'x' 'y' 'cross_shore'});
    for i = 1:length(j.id)
        plot(j.x(i,:), j.y(i,:), '-g', 'tag', num2str(j.id(i)));
    end

    % get vaklodingen areas
%     urls = vaklodingen_url;
%     url = urls{strfilter(urls, '/vaklodingen.nc$')};
    url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/vaklodingen/vaklodingen.nc';
    ids = nc_varget(url, 'id');
    rectangles = nc_varget(url, 'rectangle');
    for i = 1:size(rectangles, 1)
        rectangle('position', rectangles(i,:), 'tag', strtrim(ids(i,:)), 'edgecolor', 'b');
    end

    ax2 = axes('position', get(ax1, 'position'), 'tag', 'map', 'color', 'none', ...
        'xticklabel', {}, 'yticklabel', {}); hold on;

    linkaxes([ax1 ax2 ax3], 'xy');

    xb_gui_dragselect(ax2, 'fcn', @addselect);

    uiwait(pobj);

    varargout = get(pobj, 'UserData');

    close(pobj);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function type = gettype()
    cobj = findobj(gcf, 'tag', 'type');
    types = get(cobj, 'string');
    type = strtrim(types(get(cobj, 'value'), :));
end

function file = getfile()

end

function addfile(obj, event)
    pobj = get(obj, 'parent');

    type = gettype;
    switch type
        case 'ARCGIS file'
            [fname fpath] = uigetfile({'*.asc', 'ArcGIS ASCII file (*.asc)'}, 'Select bathymetry file');
            file = fullfile(fpath, fname);
        case 'XBeach grid files'
            [fname fpath] = uigetfile({'*.grd', 'X coordinate file (*.grd)'}, 'Select bathymetry file');
            xfile = fullfile(fpath, fname);

            [fname fpath] = uigetfile({'*.grd', 'Y coordinate file (*.grd)'}, 'Select bathymetry file', fpath);
            yfile = fullfile(fpath, fname);

            [fname fpath] = uigetfile({'*.dep', 'Z coordinate file (*.dep)'}, 'Select bathymetry file', fpath);
            zfile = fullfile(fpath, fname);

            file = [xfile '|' yfile '|' zfile];
    end

    if ~isempty(file)
        cobj = findobj(pobj, 'tag', 'table');
        data = get(cobj, 'data');

        if ~isempty(data)
            i = size(data, 1)+1;
            data(i,:) = {type file};
        else
            data = {type file};
        end

        set(cobj, 'data', data);
    end
end

function addselect(obj, event, aobj, polx, poly)
    dobj = findobj(obj, 'tag', 'map2');

    data = cell(0,2);

    % add jarkus
    lobjs = findobj(dobj, 'type', 'line');
    x = get(lobjs, 'xdata'); x = [x{:}];
    y = get(lobjs, 'ydata'); y = [y{:}];

    i = inpolygon(x, y, polx, poly);
    if any(i)
        idx = i(1:2:end)|i(2:2:end);
        ids = str2double(get(lobjs(idx), 'tag'));

        idx = abs(diff(ids))>25;
        idx(end) = true; idx = [true;idx];
        idx = find(idx);

        for i = 1:length(idx)-1
            mn = min(ids(idx(i)), ids(idx(i+1)-1));
            mx = max(ids(idx(i)), ids(idx(i+1)-1));
            datai = {'jarkus' [num2str(mn) ':' num2str(mx)]};
            data = [data{:} datai];
        end
    end

    % add vaklodingen
    robjs = findobj(dobj, 'type', 'rectangle');
    p = get(robjs, 'position'); p = [p{:}];
    x = nan(size(p)); y = nan(size(p));
    x(1:4:end) = p(1:4:end); y(1:4:end) = p(2:4:end);
    x(2:4:end) = p(1:4:end); y(2:4:end) = p(2:4:end)+p(4:4:end);
    x(3:4:end) = p(1:4:end)+p(3:4:end); y(3:4:end) = p(2:4:end)+p(4:4:end);
    x(4:4:end) = p(1:4:end)+p(3:4:end); y(4:4:end) = p(2:4:end);

    idx = [];
    for i = 1:4:length(x)
        [xi yi] = polyintersect(x(i:i+3), y(i:i+3), polx, poly);
        if ~isempty(xi) && ~isempty(yi)
            idx = [idx (i-1)/4+1];
        end
    end

    if ~isempty(idx)
        ids = get(robjs(idx), 'tag');

        if ~iscell(ids); ids = {ids}; end;

        for i = 1:length(ids)
            datai = {'vaklodingen' ids{i}};
            data = [data{:} datai];
        end
    end

    % add to table
    if ~isempty(data)
        tobj = findobj(obj, 'tag', 'table');
        tdata = get(tobj, 'data')';

        if ~isempty(tdata)
            tdata = [{tdata{:}} {data{:}}];
        else
            tdata = data;
        end

        tdata = reshape(tdata, 2, numel(tdata)/2)';
        set(tobj, 'data', tdata);
    else
        errordlg('The selection did not contain any data. Please select an area containing either an end point of a JARKUS transect or a point within a Vaklodingen map.','No data selected')
    end
end

function setloc(obj, event)
    pobj = get(obj, 'parent');
    mobj = findobj(pobj, 'tag', 'map');

    [x y] = str2coord([get(obj, 'string') ', nederland']);

    if ~isempty(x) && ~isempty(y)
        lobj = findobj(mobj, 'tag', 'loc');
        if isempty(lobj)
            zoom(10);
            zoom('reset');

            plot(mobj, x, y, 'or', 'tag', 'loc');
        else
            set(lobj, 'xdata', x, 'ydata', y);
        end

        xlim = get(mobj, 'xlim');
        ylim = get(mobj, 'ylim');
        set(mobj, 'xlim', x+[-1 1]*diff(xlim)/2);
        set(mobj, 'ylim', y+[-1 1]*diff(ylim)/2);
    else
        errordlg(['The location "' get(obj, 'string') '" could not be found in the Netherlands. Please check the name.'],'Location not found')
    end
end

function mergedata(obj, event)
    pobj = get(obj, 'parent');
    tobj = findobj(pobj, 'tag', 'table');
    tdata = get(tobj, 'data');

    x = {}; y = {}; z = {};

    wb = waitbar(0, 'Reading grids...');
    for i = 1:size(tdata, 1)
        switch tdata{i,1}
            case 'jarkus'
                j = jarkus_transects('id', eval(tdata{i,2}), 'year', 2008, 'output', {'id','time','x','y','cross_shore','altitude','angle'});
                j = jarkus_interpolatenans(j);
                j = jarkus_merge(j, 'dim', 'time');
                [x{i} y{i} z{i}] = xb_transects2grid(j);
            case 'vaklodingen'
                urls = vaklodingen_url;
                idx = strfilter(urls, ['*' tdata{i,2} '.nc']);
                info = nc_info(urls{idx});
                nt = info.Dimension(strcmpi('time', {info.Dimension.Name})).Length-1;

                x{i} = nc_varget(urls{idx}, 'x');
                y{i} = nc_varget(urls{idx}, 'y');
                zta  = nc_varget(urls{idx}, 'z');
                
                while ndims(zta)<3
                    zta = reshape(zta,[1 size(zta)]);
                end
                
                z{i} = squeeze(zta(end,:,:));

                for t = size(zta,1):-1:1
                    ii = isnan(z{i});
                    zt = squeeze(zta(t,:,:));
                    z{i}(ii) = zt(ii);
                end
            case 'ARCGIS file'
                [x{i} y{i} z{i}] = arc_asc_read(tdata{i,2}, 'zscale', 100);
            case 'XBeach grid files'
                files = regexp(tdata{i,2}, '\|', 'split');
                xb = xb_read_bathy('xfile', files{1}, 'yfile', files{2}, 'depfile', files{3});
                [x{i} y{i} z{i}] = xs_get(xb, 'xfile', 'yfile', 'depfile');
        end

        waitbar(i/size(tdata, 1), wb);
    end
    waitbar(1, wb, 'Merging grids...');

    [x y z] = xb_grid_merge('x', x, 'y', y, 'z', z, 'maxsize', 'max');

    close(wb);

    set(pobj, 'UserData', {x y z});

    uiresume(pobj);
end