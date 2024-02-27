function xb_gui_loaddata(obj, event)
%XB_GUI_LOADDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_loaddata(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_loaddata
%
%   See also

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

% $Id: xb_gui_loaddata.m 18424 2022-10-10 14:37:22Z l.w.m.roest.x $
% $Date: 2022-10-10 22:37:22 +0800 (Mon, 10 Oct 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 18424 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_loaddata.m $
% $Keywords: $

%% load data

pobj = findobj('tag', 'xb_gui');

S = xb_gui_struct;

if exist('obj', 'var')
    switch get(obj, 'tag')
        case 'button_new'

            % create new model
            S.model = xb_generate_model;
            set(pobj, 'userdata', S);

            xb_gui_loadmodel;

        case 'button_open'
            [fname fpath] = uigetfile({'*.mat' 'Saved model setup (*.mat)'}, 'Open Model Setup');

            if fname
                S = load(fullfile(fpath, fname));
                set(pobj, 'userdata', S);
            end

        case 'button_load'
            [fname fpath] = uigetfile({'*.txt' 'XBeach parameter file (*.txt)'}, 'Load Model');

            if fname
                S.model = xb_read_input(fullfile(fpath, fname));
                set(pobj, 'userdata', S);
                xb_gui_loadmodel;
            end
    end
end

S = get(pobj, 'userdata');

%% enable gui

if xs_check(S.model)
    xb_gui_enable(pobj);
else
    return;
end

%% fill model setup tab

% empty setup tab
cla(findobj(pobj, 'tag', 'ax_1'));
cla(findobj(pobj, 'tag', 'ax_2'));

set(findobj(pobj, 'tag', 'wavesettings'), 'data', {});
set(findobj(pobj, 'tag', 'surgesettings'), 'data', {});
set(findobj(pobj, 'tag', 'settings'), 'data', {});

% bathy
cobj = findobj(pobj, 'tag', 'ax_1');
bathy = S.modelsetup.bathy;
[x y z] = deal(bathy.x, bathy.y, bathy.z);
if min(size(z)) <= 3
    plot(cobj, mean(x, 1), mean(z, 1), '-k');

    set(cobj, 'xlim', [min(min(x)) max(max(x))], 'ylim', [min(min(z)) max(max(z))]);

    set(findobj(pobj, 'tag', 'databutton_3'), 'value', false, 'enable', 'off');
else
    if ~isfield(bathy, 'rotated') || isempty(bathy.rotated)
        xori = min(min(x));
        yori = min(min(y));

        alpha = xb_grid_rotation(x-xori, y-yori, z);

        if alpha ~= 0
            [xr yr] = xb_grid_rotate(x, y, alpha, 'origin', [xori yori]);
        end

        bathy.xori = xori;
        bathy.yori = yori;
        bathy.alpha = alpha;
        bathy.rotated = struct('x', xr, 'y', yr);
        S.modelsetup.bathy = bathy;
        set(pobj, 'userdata', S);
    else
        [xr yr] = deal(bathy.rotated.x, bathy.rotated.y);
    end

    pcolor(cobj, xr, yr, z);
    shading(cobj, 'flat');
    colorbar('peer', cobj);

    if ~isempty(bathy.crop)
        pos = bathy.crop;

%         if bathy.alpha ~= 0
%             [pos(1) pos(2)] = xb_grid_rotate(pos(1), pos(2), -bathy.alpha, 'origin', [bathy.xori bathy.yori]);
%         end

        crop = findobj(cobj, 'tag', 'crop');
        if isempty(crop);
            rectangle('position', pos, 'tag', 'crop', 'parent', cobj);
        else
            set(crop, 'position', pos);
        end
    end

    set(cobj, 'xlim', [min(min(xr)) max(max(xr))], 'ylim', [min(min(yr)) max(max(yr))]);

    set(findobj(pobj, 'tag', 'databutton_3'), 'enable', 'on');
end

% waves
cobj = findobj(pobj, 'tag', 'wavesettings');
waves = S.modelsetup.hydro.waves;

if ~isempty(waves)
    waves = rmfield(waves,'type');
    f = fieldnames(waves);
    set(cobj, 'rowname', f);
    nt = max(cellfun('length', struct2cell(waves)));

    data = cell(1, nt);
    for j = 1:length(f)
        v = waves.(f{j});

        if isscalar(v)
            v = repmat(v, 1, nt);
        end

        data(j,:) = num2cell(v);

        waves.(f{j}) = v;
    end

    set(cobj, 'data', data, 'columneditable', [false true(1,nt)]);

    % plot
    t = cumsum(waves.duration); t = t - t(1);
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, t, waves.Hm0, '-og');
    plot(ax, t, waves.Tp, '-ob');
end

% surge
time = 0;
cobj = findobj(pobj, 'tag', 'surgesettings');
surge = S.modelsetup.hydro.surge;

if ~isempty(surge) && ~isempty(surge.tide) && ~all(all(isnan(surge.tide)))
    nt = max(cellfun('length', struct2cell(surge)));

    time = surge.time;
    tide = surge.tide;

    data = num2cell(time);
    data(2:size(tide,1)+1,:) = num2cell(tide);

    set(cobj, 'data', data, 'columneditable', true(1,nt));

    % plot
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, time, tide, '-or');
end

% zs0
zs0 = surge.zs0;

if ~isempty(zs0)
    data = get(cobj, 'data');

    nt = max(1,size(data,2));
    zs0 = num2cell(repmat(zs0, 1, nt));

    if size(data,1) > 1
        data(3,:) = zs0;
    else
        data(2:3,:) = zs0;
    end

    set(cobj, 'data', data, 'columneditable', true(1,nt));

    % plot
    ax = findobj(pobj, 'tag', 'ax_2'); hold on;
    plot(ax, time, [zs0{:}], '-or');
end

% fill settings tab
settings = S.modelsetup.settings;
fields = fieldnames(settings);
for i = 1:length(fields)
    if ~ismember(fields{i}, {'xfile', 'yfile', 'depfile', 'nx', 'ny', 'vardx', ...
            'posdwn', 'alfa', 'xori', 'yori', 'instat', 'swtable', 'dtbc', ...
            'rt', 'bcfile', 'zs0', 'zs0file'})
        cobj = findobj(pobj, 'tag', 'settings');

        data = get(cobj, 'data');
        data(size(data,1)+1,:) = {fields{i} settings.(fields{i})};
        set(cobj, 'data', data);
    end
end

%% fill model tab

if xs_check(S.model)
    [x y z] = xb_input2bathy(S.model);

    cobj = findobj(pobj, 'tag', 'preview_bathy'); cla(cobj);
    if min(size(z)) <= 3
        plot(cobj, mean(x, 1), mean(z, 1), '-k');
    else
        pcolor(cobj, x, y, z);
        shading(cobj, 'flat');
        colorbar('peer', cobj);
    end

    set(cobj, 'xlim', [min(x(:)) max(x(:))], 'ylim', [min(y(:)) max(y(:))]);
end

%% fill run tab

cobj = findobj(pobj, 'tag', 'run_history');

data = {};

c = 1;
for i = 1:length(S.runs)
    if xs_check(S.runs{i})
        r = S.runs{i};

        data(c,:) = { ...
            xs_get(r, 'id'), ...
            r.date, ...
            xs_get(r, 'name'), ...
            xs_get(r, 'path'), ...
            xs_get(r, 'nodes'), ...
            xs_get(r, 'binary'), ...
            xs_exist(r, 'ssh')
        };

        c = c + 1;
    end
end

set(cobj, 'data', data);
