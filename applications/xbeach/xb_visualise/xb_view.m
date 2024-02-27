function xb_view(data, varargin)
%XB_VIEW  Generic GUI to visualize XBeach input and output
%
%   Graphical User Interface to visualize input and output. The viewer is
%   *complementary* to the Delft3D QuickPlot (QP) viewer. Most options you
%   find in this viewer are lacking in QP and vise versa.
%
%   This viewer accepts XBeach input, output and run structures or a path
%   string to an XBeach output directory. In case no input is given, the
%   current directory is assumed to contain XBeach output. It is also
%   possible to provide a cell array with different datasources. These
%   sources can be a mix of types (structures and paths), but need to have
%   the same spatial grid and equal timestep.
%
%   The most important options are:
%       * 1D, 2D and 3D plots
%       * Multiple variable selection
%       * Time sliders and animation
%       * Time difference plots
%       * Time comparison plots
%       * Multiple datasource comparison plots
%       * Transect view for 2D models with transect slider
%       * Fixation and alignment of caxis
%       * Measurement tool
%
%   Syntax:
%   xb_view(data, varargin)
%
%   Input:
%   data      = XBeach structure (input, output or run) or path to XBeach
%               output directory or file
%   varargin  = width:  Width of window at startup (inf = screensize)
%               height: Height of window at startup (inf = screensize)
%               model:  Boolean indicating modal state
%
%   Output:
%   none
%
%   Example
%   xbi = xb_generate_model;
%   xbr = xb_run(xbi, 'path', 'path/to/output/dir');
%   xbo = xb_read_output('path/to/output/dir');
%
%   xb_view;
%   xb_view(xbi);
%   xb_view(xbr);
%   xb_view(xbo);
%   xb_view('path/to/output/dir');
%   xb_view(pwd, 'width', 1024, 'height', 768, 'modal', true);
%   
%   See also xb_plot_profile

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
% Created: 18 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_view.m 8391 2013-03-29 08:49:41Z hoonhout $
% $Date: 2013-03-29 16:49:41 +0800 (Fri, 29 Mar 2013) $
% $Author: hoonhout $
% $Revision: 8391 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_view.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'width',inf,...
    'height',inf, ...
    'modal', false ...
);

OPT = setproperty(OPT, varargin{:});

if ~exist('data', 'var')
    data = pwd;
end

if ~iscell(data)
    data = {data};
end

%% make gui

sz = get(0, 'screenSize');
winsize = [min(.9*sz(3), OPT.width) min(.9*sz(4), OPT.height)];
winpos = (sz(3:4)-winsize)/2-[0 30];

fig = figure('Position', [winpos winsize], ...
    'Tag', 'xb_view', ...
    'Toolbar','figure',...
    'InvertHardcopy', 'off', ...
    'UserData', struct('input', {data}), ...
    'ResizeFcn', @ui_resize);

if OPT.modal; set(fig, 'WindowStyle', 'modal'); end;

ui_build(fig);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_build(obj)
    ui_read(obj);
    
    % get info
    pobj = get_pobj(obj);
    info = get_info(obj);
    
    if length(info.t)<1
        close(obj);
        error('No data');
    end
    
    sliderstep = [1 5]/(length(info.t)-1);
    if length(info.t) == 1
        sliderstep = [1 1];
    end
    
    % plot area
    uipanel(pobj, 'Tag', 'PlotPanel', 'Title', 'plot', 'Unit', 'pixels');

    % sliders
    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider1', ...
        'Min', 1, 'Max', length(info.t), 'Value', 1, 'SliderStep', sliderstep, ...
        'Enable', 'off', ...
        'Callback', @ui_plot);

    uicontrol(pobj, 'Style', 'slider', 'Tag', 'Slider2', ...
        'Min', 1, 'Max', length(info.t), 'Value', length(info.t), 'SliderStep', sliderstep, ...
        'Callback', @ui_plot);
    
    uicontrol(pobj, 'Style', 'slider', 'Tag', 'SliderTransect', ...
        'Min', 1, 'Max', size(info.y,1), 'Value', 1, 'SliderStep', min(1,max(0,[1 5]/(size(info.y,1)-1))), ...
        'Enable', 'off', ...
        'Callback', @ui_settransect);

    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider', ...
        'String', num2str(info.t(end)), 'HorizontalAlignment', 'center');
    
    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider1', ...
        'String', num2str(info.t(1)), 'HorizontalAlignment', 'left');

    uicontrol(pobj, 'Style', 'text', 'Tag', 'TextSlider2', ...
        'String', num2str(info.t(end)), 'HorizontalAlignment', 'right');

    % variable selector
    uicontrol(pobj, 'Style', 'listbox', 'Tag', 'SelectVar', ...
        'String', info.varlist, 'Min', 1, 'Max', length(info.vars), ...
        'Callback', @ui_plot);

    % options
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleDiff', ...
        'String', 'diff', ...
        'Callback', @ui_togglediff);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleCompare', ...
        'String', 'compare', ...
        'Callback', @ui_togglediff);

    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleSurf', ...
        'String', 'surf', ...
        'Enable', 'off', ...
        'Callback', @ui_togglesurf);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleCAxisFix', ...
        'String', 'fix caxis', ...
        'Enable', 'off', ...
        'Callback', @ui_togglecaxis);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleTransect', ...
        'String', 'transect', ...
        'Enable', 'off', ...
        'Callback', @ui_toggletransect);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAuto', ...
        'String', 'auto update', ...
        'Value', 1);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleMeasure', ...
        'String', 'measure', ...
        'Callback', @ui_togglemeasure);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleEqual', ...
        'String', 'equal axes', ...
        'Callback', @ui_equal);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAlign', ...
        'String', 'align caxis', ...
        'Enable', 'off', ...
        'Callback', @ui_align);
    
    % buttons
    uicontrol(pobj, 'Style', 'pushbutton', 'Tag', 'ButtonUpdate', ...
        'String', 'update', ...
        'Callback', @ui_plot);
    
    uicontrol(pobj, 'Style', 'pushbutton', 'Tag', 'ButtonReload', ...
        'String', 'reload', ...
        'Callback', @ui_reload);
    
    uicontrol(pobj, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
        'String', 'animate', ...
        'Callback', @ui_animate);

    set(findobj(pobj, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);
    set(findobj(pobj, 'Type', 'uipanel'), 'BackgroundColor', [.8 .8 .8]);
    
    % set exceptions
    if info.ndims == 2
        set_enable(obj, '2d');
    else
        set_enable(obj, '1d');
    end
    
    if strcmpi(info.type, 'input')
        set_enable(obj, 'input');
    end
    
    % indicators
    uicontrol(pobj, 'Style', 'text', 'Tag', 'ReadIndicator', ...
        'String', 'READING', 'HorizontalAlignment', 'center', ...
        'BackgroundColor', 'red', 'FontWeight', 'bold', 'Visible', 'off');
    
    uicontrol(pobj, 'Style', 'text', 'Tag', 'MeasureIndicator', ...
        'String', {'d=0.0' 'x=0.0' 'y=0.0'}, 'HorizontalAlignment', 'center', ...
        'BackgroundColor', 'green', 'FontWeight', 'bold');
    
    ui_resize(pobj, []);
    
    ui_plot(pobj, []);
end

function ui_reload(obj, event)
    ui_read(obj);
    
    % get info
    info = get_info(obj);
    
    sliderstep = [1 5]/(length(info.t)-1);
    
    % sliders
    set(get_obj(obj, 'Slider1'), 'Max', length(info.t), 'SliderStep', sliderstep)
    set(get_obj(obj, 'Slider2'), 'Max', length(info.t), 'SliderStep', sliderstep, 'Value', length(info.t))
    set(get_obj(obj, 'TextSlider1'), 'String', num2str(info.t(1)))
    set(get_obj(obj, 'TextSlider2'), 'String', num2str(info.t(end)))
    
    ui_plot(obj, []);
end

function ui_resize(obj, event)

    pos = get(obj, 'Position');
    winsize = pos(3:4);

    set(get_obj(obj, 'PlotPanel'), 'Position', [[.075 .2].*winsize [.75 .75].*winsize]);
    
    set(get_obj(obj, 'Slider1'), 'Position', [[.1 .125].*winsize [.7 .025].*winsize]);
    set(get_obj(obj, 'Slider2'), 'Position', [[.1 .075].*winsize [.7 .025].*winsize]);
    set(get_obj(obj, 'SliderTransect'), 'Position', [[.85 .91].*winsize [.1 .025].*winsize]);
    
    set(get_obj(obj, 'TextSlider'), 'Position', [[.35 .025].*winsize [.2 .025].*winsize]);
    set(get_obj(obj, 'TextSlider1'), 'Position', [[.1 .025].*winsize [.2 .025].*winsize]);
    set(get_obj(obj, 'TextSlider2'), 'Position', [[.6 .025].*winsize [.2 .025].*winsize]);
    set(get_obj(obj, 'SelectVar'), 'Position', [[.85 .65].*winsize [.1 .25].*winsize]);
    
    set(get_obj(obj, 'ToggleDiff'), 'Position', [[.85 .6].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleCompare'), 'Position', [[.85 .565].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleSurf'), 'Position', [[.85 .53].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleTransect'), 'Position', [[.85 .495].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleMeasure'), 'Position', [[.85 .46].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleCAxisFix'), 'Position', [[.85 .425].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleAlign'), 'Position', [[.85 .39].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleEqual'), 'Position', [[.85 .355].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleAuto'), 'Position', [[.85 .32].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ButtonUpdate'), 'Position', [[.85 .285].*winsize [.1 .035].*winsize]);
    
    set(get_obj(obj, 'ButtonReload'), 'Position', [[.85 .125].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ToggleAnimate'), 'Position', [[.85 .07].*winsize [.1 .035].*winsize]);
    set(get_obj(obj, 'ReadIndicator'), 'Position', [[.4 .955].*winsize [.1 .025].*winsize]);
    set(get_obj(obj, 'MeasureIndicator'), 'Position', [[.85 .19].*winsize [.1 .075].*winsize]);
end

function ui_togglediff(obj, event)
    
    % enable/disable secondary slider
    if get(obj, 'Value')
        set(get_obj(obj, 'Slider1'), 'Enable', 'on');
    else
        set(get_obj(obj, 'Slider1'), 'Enable', 'off');
    end
    
    info = get_info(obj);
    
    switch get(obj, 'Tag')
        case 'ToggleDiff'
            set(get_obj(obj, 'ToggleCompare'), 'Value', 0);
            
            info.update = info.update && ~info.compare;

            info.diff = get(obj, 'Value');
            info.compare = false;
        case 'ToggleCompare'
            set(get_obj(obj, 'ToggleDiff'), 'Value', 0);
            
            info.diff = false;
            info.compare = get(obj, 'Value');
    end
    
    set_info(obj, info);

    ui_plot(obj, []);
end

function ui_togglesurf(obj, event)
    info = get_info(obj);
    if get(obj, 'Value')
        set(get_obj(obj, 'ToggleTransect'), 'Enable', 'off');
        info.surf = true;
    else
        set(get_obj(obj, 'ToggleTransect'), 'Enable', 'on');
        info.surf = false;
    end
    set_info(obj, info);

    cla(get_axis(obj));

    ui_plot(obj, []);
end

function ui_togglecaxis(obj, event)
    info = get_info(obj);
    if get(obj, 'Value')
        info.caxis = flipud(get(get_axis(obj), 'CLim'));
    else
        info.caxis = [];
    end
    set_info(obj, info);
end

function ui_togglemeasure(obj, event)
    if get(obj, 'Value')
        [x y] = ginput;
        L{1} = sprintf('d=%2.1f', sum(sqrt(diff(x).^2+diff(y).^2)));
        L{2} = sprintf('x=%2.1f', sum(abs(diff(x))));
        L{3} = sprintf('y=%2.1f', sum(abs(diff(y))));
        set(get_obj(obj, 'MeasureIndicator'), 'String', L);
    end
    
    set(obj, 'Value', 0);
end

function ui_toggletransect(obj, event)
    info = get_info(obj);
    if get(obj, 'Value')
        set_enable(obj, '1d');
        set(get_obj(obj, 'ToggleTransect'), 'Enable', 'on');
        sobj = get_obj(obj, 'SliderTransect');
        set(sobj, 'Enable', 'on');
        
        ax = get_axis(obj);
        set(gcf,'CurrentAxes',ax(1));
        [x y] = ginput(1);
        [y i] = closest(y, info.y(:,1));
        set(sobj, 'Value', i);
        
        info.transect = [y i];
    else
        set_enable(obj, '2d');
        
        set(get_obj(obj, 'SliderTransect'), 'Enable', 'off');
        
        info.transect = [];
    end
    set_info(obj, info);
    
    cla(get_axis(obj));
    
    ui_plot(obj, []);
end

function ui_settransect(obj, event)
    sobj = get_obj(obj, 'SliderTransect');
    
    info = get_info(obj);
    i = round(get(sobj, 'Value'));
    info.transect = [info.y(i,1) i];
    set_info(obj, info);
    
    ui_plot(obj, []);
end

function ui_align(obj, event)
    ax = get_axis(obj);
    
    clim = get(ax, 'CLim');
    
    if iscell(clim)
        clim = cell2mat(clim);
        clim = [min(clim(:,1)) max(clim(:,2))];
    end
    
    set(ax, 'CLim', clim);
end

function ui_equal(obj, event)
    ax = get_axis(obj);
    
    if get(obj, 'Value')
        axis(ax, 'image');
    else
        axis(ax, 'normal');
    end
end

function ui_read(obj)
    info = get_info(obj);

    if isfield(info, 'input')
        
        for i = 1:length(info.input)
            
            if i > 1
                info0 = info;
            end
        
            if xs_check(info.input{i})
                switch info.input{i}.type
                    case 'input'
                        info.type = 'input';

                        % read variables
                        info.vars = {'bathymetry' 'non-erodible layer' 'water levels' 'wave height' 'wave period'};

                        info.tm = [0 1];
                        info.t  = [0 1];

                        [info.x info.y] = xb_input2bathy(info.input{i});
                        
                        if isempty(info.x) || isempty(info.y)
                            [nx ny dx dy] = xs_get(info.input{i}, 'nx', 'ny', 'dx', 'dy');
                            
                            dx = max([1 dx]);
                            dy = max([1 dy]);
                            
                            [info.x info.y] = meshgrid(1:dx:dx*(nx+1), 1:dy:dy*(ny+1));
                        end
                    case 'output'
                        info.type = 'output_xb';

                        % read dimensions
                        info.dims = xs_get(info.input{i}, 'DIMS');
                        info.dims = cell2struct({info.dims.data.value}, {info.dims.data.name}, 2);

                        % read variables
                        info.vars = {info.input{i}.data.name};
                        info.vars = info.vars(~strcmpi(info.vars, 'DIMS'));

                        % determine grid and time
                        %info.tm = info.dims.meantime_DATA;
                        info.t  = info.dims.globaltime_DATA;
                        info.x  = info.dims.globalx_DATA;
                        info.y  = info.dims.globaly_DATA;
                    case 'run'

                        info.type = 'output_dir';
                        info.fpath{i} = xs_get(info.input{i}, 'path');

                        % read dimensions
                        info.dims = xb_read_dims(info.fpath{i});

                        % read variables
                        info.vars = xb_get_vars(info.fpath{i});

                        % determine grid and time
                        %info.tm = info.dims.meantime_DATA;
                        info.t  = info.dims.globaltime_DATA;
                        info.x  = info.dims.globalx_DATA;
                        info.y  = info.dims.globaly_DATA;
                    otherwise
                        error('Unsupported XBeach strucure supplied');
                end
            elseif ischar(info.input{i}) && (exist(info.input{i}, 'dir') || exist(info.input{i}, 'file'))

                info.type = 'output_dir';
                info.fpath{i} = info.input{i};

                % read dimensions
                info.dims = xb_read_dims(info.fpath{i});

                % read variables
                info.vars = xb_get_vars(info.fpath{i});

                % determine grid and time
                %info.tm = info.dims.meantime_DATA;
                info.t  = info.dims.globaltime_DATA;
                info.x  = info.dims.globalx_DATA;
                info.y  = info.dims.globaly_DATA;
            else
                error('No valid data supplied');
            end
            
            % check consistency
            if exist('info0','var')
                if isfield(info0, 't')
                    tmax    = min(max(info0.t),max(info.t));
                    info0.t = info0.t(info0.t<=tmax);
                    info.t  = info.t(info.t<=tmax);
                    
                    %tmmax   = min(max(info0.tm),max(info.tm));
                    %info0.tm = info0.tm(info0.tm<=tmmax);
                    %info.tm  = info.tm(info.tm<=tmmax);
                    
                    if length(info.t) ~= length(info0.t);           error('Inconsistent time axes length');     end;
                    if ~all(info.t - info0.t == 0);                 error('Inconsistent time axes stepsize');   end;
                end

                if isfield(info0, 'x')
                    if ~all(size(info.x) - size(info0.x) == 0);     error('Inconsistent x axes length');        end;
                    if ~all(all(info.x - info0.x == 0));            error('Inconsistent x coordinates');        end;
                end

                if isfield(info0, 'y')
                    if ~all(size(info.y) - size(info0.y) == 0);     error('Inconsistent y axes length');        end;
                    if ~all(all(info.y - info0.y == 0));            error('Inconsistent y coordinates');        end;
                end

                if isfield(info0, 'varlist')
                    info.varlist = intersect(info.vars, info0.vars);
                end
            end
            
        end
        
        if isvector(info.x)
            info.x = info.x(:)';
            info.y = info.y(:)';
        end

        % generate var list
        info.varlist = sprintf('|%s', info.vars{:});
        info.varlist = info.varlist(2:end);

        % determine plot type
        if min(size(info.x)) <= 3
            info.ndims = 1;
        else
            info.ndims = 2;
        end

        if ~strcmpi(get(obj, 'Tag'), 'ButtonReload')
            info.diff = false;
            info.compare = false;
            info.surf = false;
            info.caxis = [];
            info.transect = [];
            info.update = false;
        end
        
        set_info(obj, info);
    else
        error('No data supplied');
    end
end

function data = ui_getdata(obj, info, vars, slider)
    iobj = get_obj(obj, 'ReadIndicator');
    set(iobj, 'Visible', 'on'); drawnow;
    
    m = length(info.input);
    n = length(vars);
    
    data{1} = nan([1 size(info.x,1) size(info.x,2)]);
    for i = 2:m*n
        data{i} = data{1};
    end
    
    t1 = round(get(get_obj(obj, 'Slider1'), 'Value'));
    t2 = round(get(get_obj(obj, 'Slider2'), 'Value'));
    
    if exist('slider', 'var') && slider == 1
        slider = 1;
        t = t1;
    else
        slider = 2;
        t = t2;
    end
    
    if ~isempty(info.transect)
        ri = info.transect(2);
        rl = 1;
    elseif info.ndims == 1
        ri = round(size(info.x,1)/2);
        rl = 1;
    else
        ri = 1;
        rl = size(info.x,1);
    end
    
    for j = 1:m
        switch info.type
            case 'input'
                for i = 1:n
                    idx = (j-1)*n+i;
                    data{idx}(1,:,:) = get_inputdata(info.input{j}, vars{i});
                    data{idx} = data{idx}(1,ri+[0:rl-1],:);
                end
            case 'output_xb'
                for i = 1:n
                    d = xs_get(info.input{j}, vars{i});
                    data{(j-1)*n+i}(1,:,:) = d(t,ri+[0:rl-1],:);
                end
            case 'output_dir'
                [data{(j-1)*n+[1:n]}] = xs_get( ...
                    xb_read_output(info.fpath{j}, 'vars', vars, 'start', [t-1 ri-1 0], ...
                    'length', [1 rl -1]), vars{:});
        end
    end
    
    if info.diff && slider == 2
        data0 = ui_getdata(obj, info, vars, 1);
        data = cellfun(@minus, data, data0, 'UniformOutput', false);
    end
    
    tobj = get_obj(obj, 'TextSlider');
    if info.diff
        set(tobj, 'String', [num2str(info.t(t2)) ' - ' num2str(info.t(t1))]);
    elseif info.compare
        set(tobj, 'String', [num2str(info.t(t1)) ' -> ' num2str(info.t(t2))]);
    else
        set(tobj, 'String', num2str(info.t(t2)));
    end
    
    set(iobj, 'Visible', 'off');
end

function ui_plot(obj, event)
    info = get_info(obj);
    
    if ismember(get(obj, 'Tag'), {'SelectVar' 'ToggleSurf' 'ToggleCompare' 'ToggleTransect'})
        info.update = false;
    end
    
    if get(get_obj(obj, 'ToggleAuto'), 'Value') || ismember(get(obj, 'Tag'), {'ToggleAnimate' 'ButtonUpdate' 'ToggleTransect', 'ButtonReload'})
        
        if ~info.update
            delete(get_axis(obj));
        end

        vars = selected_vars(obj);
        data = ui_getdata(obj, info, vars, 2);

        if info.compare
            data0 = ui_getdata(obj, info, vars, 1);
            data = cat(2, data0, data);
        end

        if info.ndims == 1 || ~isempty(info.transect)
            plot_1d(obj, info, data, vars);
        else
            plot_2d(obj, info, data, vars);
        end
        
        if get(get_obj(obj, 'ToggleAlign'), 'Value')
            ui_align(obj, event);
        end
        
        if get(get_obj(obj, 'ToggleEqual'), 'Value')
            ui_equal(obj, event);
        end
        
        info.update = true;
        
    end
    
    set_info(obj, info);
end

function ui_animate(obj, event)
    
    % get minimum, maximum and current time
    tmin = get(get_obj(obj, 'Slider2'), 'Min');
    tmax = get(get_obj(obj, 'Slider2'), 'Max');
    t = round(get(get_obj(obj, 'Slider2'), 'Value'));

    % update time
    t = min(tmax, ceil(t+(tmax-tmin)/20));
    set(get_obj(obj, 'Slider2'), 'Value', t);

    % reload data
    ui_plot(obj, event); drawnow;

    % start new loop if maximum is not reached
    if t < tmax
        if get(get_obj(obj, 'ToggleAnimate'), 'Value')
            pause(.1)
            ui_animate(obj, event)
        end
    else
        set(get_obj(obj, 'ToggleAnimate'), 'Value', 0);
    end
end

function plot_1d(obj, info, data, vars)
    ax = get_axis(obj);
    
    if ~info.update
        ax = axes('Parent', get_obj(obj, 'PlotPanel')); hold on;
    end
    
    lines = flipud(findobj(ax, 'Type', 'line'));
    
    n  = numel(data);
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    type = '-:';
    color = 'rgbcymk';
    for i1 = 1:n1
        for i2 = 1:n2
            for i3 = 1:n3
                ii = i3+(i2-1)*n3+(i1-1)*n2*n3;

                name = strrep(get_name(obj, info, n, ii), '_', '\_');
                
                if info.update
                    set(lines(ii),...
                        'XData', info.x(1,:),...
                        'YData', squeeze(data{ii}(:,1,:)),...
                        'DisplayName', name);
                else
                    plot(ax,...
                        info.x(1,:), squeeze(data{ii}(:,1,:)), ...
                        [type(n1-i1+1) color(mod(i3-1,length(color))+1)], 'LineWidth', i2, ...
                        'DisplayName', name);
                end
            end
        end
    end
    
    if ~isempty(info.transect)
        title(sprintf('y = %3.2f m (i = %d)', info.transect(1), info.transect(2)), 'Interpreter', 'none');
    end
    
    % include legend at the 'Best' location
    legend('show',...
        'Location', 'Best')
end

function plot_2d(obj, info, data, vars)
    ax = get_axis(obj);
    
    surface = flipud(findobj(ax, 'Type', 'surface'));
    
    n  = numel(data);
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    sx = ceil(sqrt(n));
    sy = ceil(n/sx);
    
    sp = nan(1,n);
    for i1 = 1:n1
        for i2 = 1:n2
            for i3 = 1:n3
                ii = i3+(i2-1)*n3+(i1-1)*n2*n3;

                sp(ii) = subplot(sy, sx, ii, 'Parent', get_obj(obj, 'PlotPanel'));

                data{ii} = squeeze(data{ii});

                if all(size(info.x) == size(data{ii})) && all(size(info.y) == size(data{ii}))
                    if info.update
                        set(surface(ii), 'XData', info.x, 'YData', info.y, ...
                            'ZData', data{ii}, 'CData', data{ii});
                    else
                        if info.surf
                            surf(sp(ii), info.x, info.y, data{ii});
                        else
                            pcolor(sp(ii), info.x, info.y, data{ii});
                        end
                    end

                    shading flat; colorbar;
                end

                if iscell(info.caxis)
                    caxis = info.caxis{min(ii, length(info.caxis))};
                else
                    caxis = info.caxis;
                end
                
                if ~isempty(caxis)
                    set(sp(ii), 'CLim', caxis);
                else
                    set(sp(ii), 'CLimMode', 'auto');
                end
                
                title(get_name(obj, info, n, ii), 'Interpreter', 'none');
            end
        end
    end
    
    h = linkprop(sp, {'xlim' 'ylim' 'CameraPosition','CameraUpVector'});
    setappdata(sp(1), 'graphics_linkprop', h);
end

function vars = selected_vars(obj)
    vars = get(get_obj(obj, 'SelectVar'), 'String');
    vars = vars(get(get_obj(obj, 'SelectVar'), 'Value'),:);
    vars = strtrim(num2cell(vars, 2));
end

function ax = get_axis(obj)
    pobj = get_pobj(obj);
    ax = findobj(pobj, 'Type', 'Axes', 'Tag', '');
end

function pobj = get_pobj(obj)
    if strcmpi(get(obj, 'Tag'), 'xb_view')
        pobj = obj;
    else
        pobj = get_pobj(get(obj, 'Parent'));
    end
end

function obj = get_obj(obj, name)
    pobj = get_pobj(obj);
    obj = findobj(pobj, 'Tag', name);
end

function info = get_info(obj)
    pobj = get_pobj(obj);
    info = get(pobj, 'userdata');
end

function set_info(obj, info)
    pobj = get_pobj(obj);
    set(pobj, 'userdata', info);
end

function name = get_name(obj, info, n, i)
    vars = selected_vars(obj);
    
    n2 = length(info.input);
    n3 = length(vars);
    n1 = ceil(n/n3/n2);
    
    i1 = floor((i-1)/n3/n2)+1;
    i2 = floor((i-(i1-1)*n2*n3-1)/n3)+1;
    i3 = floor( i-(i2-1)*n3-(i1-1)*n2*n3-1)+1;
    
    if n1 > 1 && i1 == 1
        t = round(get(get_obj(obj, 'Slider1'), 'Value'));
    else
        t = round(get(get_obj(obj, 'Slider2'), 'Value'));
    end
    
    name = sprintf('%s (file #%d, t = %d)', vars{i3}, i2, info.t(t));
end

function set_enable(obj, opt)
    if ~iscell(opt)
        opt = {opt};
    end
    
    if ismember('1d', opt)
        set(get_obj(obj, 'ToggleSurf'), 'Enable', 'off');
        set(get_obj(obj, 'ToggleCAxisFix'), 'Enable', 'off');
        set(get_obj(obj, 'ToggleTransect'), 'Enable', 'off');
        set(get_obj(obj, 'ToggleAlign'), 'Enable', 'off');
    end
    
    if ismember('2d', opt)
        set(get_obj(obj, 'ToggleSurf'), 'Enable', 'on');
        set(get_obj(obj, 'ToggleCAxisFix'), 'Enable', 'on');
        set(get_obj(obj, 'ToggleTransect'), 'Enable', 'on');
        set(get_obj(obj, 'ToggleAlign'), 'Enable', 'on');
    end
    
    if ismember('input', opt)
        set(get_obj(obj, 'ToggleDiff'), 'Enable', 'off');
        set(get_obj(obj, 'Slider2'), 'Enable', 'off');
        set(get_obj(obj, 'ToggleAnimate'), 'Enable', 'off');
    end
end

function data = get_inputdata(obj, var)
    switch var
        case 'bathymetry'
            data = xs_get(obj, 'depfile.depfile');
        case 'non-erodible layer'
            data = xs_get(obj, 'depfile.depfile') - xs_get(obj, 'ne_layer.ne_layer');
        case {'water levels' 'wave height' 'wave period'}
            data = nan;
    end
end