function xb_plot(xb, varargin)
%XB_PLOT  Basic visualisation tool for XBeach output structure
%
%   Creates a basic interface to visualise contents of a XBeach output
%   structure. The function is meant to be basic and provide first
%   visualisations of model results.
%
%   Syntax:
%   varargout = xb_plot(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   xb_plot(xb)
%
%   See also xb_read_dat

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 07 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_plot.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot.m $
% $Keywords: $

%% read options

warning('OET:xbeach:deprecated', 'The features of the xb_plot function are also part of the xb_view function. However, xb_view is actively maintained, while this function is not. Please consider switching to xb_view.')

if ~xs_check(xb); error('Invalid XBeach structure'); end;

if ~xs_exist(xb, 'DIMS')
    % input struct
    for i = 1:length(xb.data)
        if xs_check(xb.data(i).value)
            xb = xs_join(xb, xb.data(i).value);
        end
    end
end

OPT = struct( ...
    'width',800,...
    'height',600 ...
);

OPT = setproperty(OPT, varargin{:});

%% create gui

winsize = [OPT.width OPT.height];

fig = figure('Position', [100 100 winsize], ...
    'Toolbar','figure',...
    'InvertHardcopy', 'off', ...
    'ResizeFcn', @ui_resize);

axes('Position', [.1 .2 .7 .7], 'Tag', 'Axes');

ui_build(fig, [], xb);

% show data
ui_loaddata(findobj(fig, 'Tag', 'SelectVar'), [], xb);

end
%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info = get_info(xb)

info = struct();

% get time
if xs_exist(xb, 'DIMS')
    info.t = xs_get(xb,'DIMS.globaltime_DATA');
end

if ~isfield(info, 't') || info.t(1) >= info.t(end)
    info.t = [0 1];
end

% get variable list
vars = {};
for i = 1:length(xb.data)
    if isnumeric(xb.data(i).value) && ~isscalar(xb.data(i).value)
        vars = [vars {xb.data(i).name}];
    end
end
info.vars = vars;

varlist = sprintf('|%s', info.vars{:});
info.varlist = varlist(2:end);

end
%% uicontrol functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ui_build(hObj, event, xb)

info = get_info(xb);

ax = findobj(hObj, 'Type','Axes','-not','Tag','Colorbar','-not','Tag','legend','-not','Tag','legenddynamic');
title(ax,['t = ' num2str(info.t(1)) ' (s)']);

% sliders
uicontrol(hObj, 'Style', 'slider', 'Tag', 'Slider1', ...
    'Min', 1, 'Max', length(info.t), 'Value', 1, 'SliderStep',[1 max([1 floor(length(info.t)/10)])]/(length(info.t)-1), ...
    'Enable', 'off', ...
    'Callback', {@ui_loaddata, xb});

uicontrol(hObj, 'Style', 'slider', 'Tag', 'Slider2', ...
    'Min', 1, 'Max', length(info.t), 'Value', length(info.t), 'SliderStep',[1 max([1 floor(length(info.t)/10)])]/(length(info.t)-1), ...
    'Callback', {@ui_loaddata, xb});

uicontrol(hObj, 'Style', 'text', 'Tag', 'TextSlider1', ...
    'String', num2str(info.t(1)), 'HorizontalAlignment', 'left');

uicontrol(hObj, 'Style', 'text', 'Tag', 'TextSlider2', ...
    'String', num2str(info.t(end)), 'HorizontalAlignment', 'right');

% variable selector
uicontrol(hObj, 'Style', 'listbox', 'Tag', 'SelectVar', ...
    'String', info.varlist, 'Min', 1, 'Max', length(info.vars), ...
    'Callback', {@ui_loaddata, xb});

% options
uicontrol(hObj, 'Style', 'checkbox', 'Tag', 'ToggleDiff', ...
    'String', 'diff', ...
    'Callback', {@ui_togglediff, xb});

uicontrol(hObj, 'Style', 'checkbox', 'Tag', 'ToggleSurf', ...
    'String', 'surf', ...
    'Enable', 'off', ...
    'Callback', {@ui_togglesurf, xb});

% animate button
uicontrol(hObj, 'Style', 'togglebutton', 'Tag', 'ToggleAnimate', ...
    'String', 'Animate', ...
    'Callback', {@ui_animate, xb});

ui_resize(hObj, event);

set(findobj(hObj, 'Type', 'uicontrol'), 'BackgroundColor', [.8 .8 .8]);
end

function ui_resize(hObj, event)

pos = get(hObj, 'Position');
winsize = pos(3:4);

set(findobj(hObj, 'Tag', 'Slider1'), 'Position', [[.1 .125].*winsize [.7 .025].*winsize]);
set(findobj(hObj, 'Tag', 'Slider2'), 'Position', [[.1 .075].*winsize [.7 .025].*winsize]);
set(findobj(hObj, 'Tag', 'TextSlider1'), 'Position', [[.1 .025].*winsize [.3 .025].*winsize]);
set(findobj(hObj, 'Tag', 'TextSlider2'), 'Position', [[.5 .025].*winsize [.3 .025].*winsize]);
set(findobj(hObj, 'Tag', 'SelectVar'), 'Position', [[.85 .65].*winsize [.1 .25].*winsize]);
set(findobj(hObj, 'Tag', 'ToggleDiff'), 'Position', [[.85 .6].*winsize [.1 .05].*winsize]);
set(findobj(hObj, 'Tag', 'ToggleSurf'), 'Position', [[.85 .55].*winsize [.1 .05].*winsize]);
set(findobj(hObj, 'Tag', 'ToggleAnimate'), 'Position', [[.85 .07].*winsize [.1 .035].*winsize]);

end

function ui_togglediff(hObj, event, xb)

pObj = get(hObj, 'Parent');

% enable/disable secondary slider
if get(hObj, 'Value')
    set(findobj(pObj, 'Tag', 'Slider1'), 'Enable', 'on');
else
    set(findobj(pObj, 'Tag', 'Slider1'), 'Enable', 'off');
end

% reload data
ui_loaddata(hObj, event, xb)
end

function ui_togglesurf(hObj, event, xb)

pObj = get(hObj, 'Parent');

% clear plot axes
cla(findobj(pObj, 'Type', 'Axes','-not','Tag','Colorbar','-not','Tag','legend','-not','Tag','legenddynamic'));

% reload data
ui_loaddata(hObj, event, xb)
end

function ui_loaddata(hObj, event, xb)

pObj = get(hObj, 'Parent');

% get data
vars = get(findobj(pObj, 'Tag', 'SelectVar'), 'String');
vars = vars(get(findobj(pObj, 'Tag', 'SelectVar'), 'Value'),:);

colors = 'rgbcymk';

% get time
t1 = round(get(findobj(pObj, 'Tag', 'Slider1'), 'Value'));
t2 = round(get(findobj(pObj, 'Tag', 'Slider2'), 'Value'));

hold off;

for i = 1:size(vars,1)
    var = strtrim(vars(i,:));
    data = xs_get(xb, var);
    
    if numel(data) > 1 || ~isnan(data)
        
        idx1 = num2cell(ones(1, 5)); idx1(2:3) = {':' ':'};
        idx2 = idx1;
        
        % determine indices
        if ndims(data) > 2
            idx1 = [{t1} idx1{2:end}];
            idx2 = [{t2} idx2{2:end}];
            has_time = true;
        else
            set(findobj(pObj, 'Tag', 'Slider1'), 'Enable', 'off');
            set(findobj(pObj, 'Tag', 'Slider2'), 'Enable', 'off');
            set(findobj(pObj, 'Tag', 'ToggleDiff'), 'Enable', 'off');
            set(findobj(pObj, 'Tag', 'ToggleAnimate'), 'Enable', 'off');
            
            idx1 = idx1(2:end);
            idx2 = idx2(2:end);
            has_time = false;
        end
        
        % get 2D array
        if get(findobj(pObj, 'Tag', 'ToggleDiff'), 'Value')
            data = data(idx2{:})-data(idx1{:});
        else
            data = data(idx2{:});
        end
        
        data = squeeze(data);
        
        if has_time
            data = data';
        end
        
        % get grid
        x = xs_get(xb, 'DIMS.globalx_DATA');
        y = xs_get(xb, 'DIMS.globaly_DATA');
        [y x] = meshgrid(y, x);
        
        if isnan(x); x = xs_get(xb, 'xfile'); end;
        if isnan(y); y = xs_get(xb, 'yfile'); end;
        
        has_grid = false;
        if size(x,1) == size(data,1) && size(x,2) == size(data,2) && ...
                size(y,1) == size(data,1) && size(y,2) == size(data,2) && ...
                ~(isscalar(x) && isnan(x)) && ~(isscalar(y) && ~isnan(y))
            has_grid = true;
        end
        
        if any(strcmpi(var, {'x', 'y', 'xfile', 'yfile'}))
            has_grid = false;
        end
        
        % lengend
        if ~isempty(findobj(pObj,'Tag','legend'))
            try % dynamic legend not available pre Matlab 7.1
                delete(findobj(pObj,'Tag','legend'));
                legend('-DynamicLegend');
                set(findobj(pObj,'Tag','legend'),'Tag','legenddynamic');
            end
        end
        
        % plot data
        aObj = findobj(pObj, 'Type','Axes','-not','Tag','Colorbar','-not','Tag','legend','-not','Tag','legenddynamic');
        if min(size(data)) <= 3
            set(findobj(pObj, 'Tag', 'ToggleSurf'), 'Enable', 'off')
            
            [m mi] = min(size(data));
            idx = num2cell(repmat(':', 1, ndims(data)));
            idx{mi} = 1;
            data = data(idx{:});
            
            % 1D data
            sObj = findobj(aObj, 'Type', 'line');
            if length(sObj) >= i
                if has_grid
                    xdata = x(idx{:});
                else
                    xdata = 1:length(data);
                end
                
                set(sObj(i), 'XData', xdata, 'YData', data, ...
                    'Color', colors(mod(i-1,length(colors))+1),'DisplayName',var);
            else
                if has_grid
                    plot(x(idx{:}), data, ['-' colors(mod(i-1,length(colors))+1)],'DisplayName',var);
                else
                    plot(data, ['-' colors(mod(i-1,length(colors))+1)],'DisplayName',var);
                end
            end
        else
            set(findobj(pObj, 'Tag', 'ToggleSurf'), 'Enable', 'on')
            
            if has_grid
                xdata = x;
                ydata = y;
            else
                [xdata ydata] = meshgrid(1:size(data, 2), 1:size(data, 1));
            end
            
            % 2D data
            if get(findobj(pObj, 'Tag', 'ToggleSurf'), 'Value')
                sObj = findobj(aObj, 'Type', 'surface');
                
                if length(sObj) >= i
                    set(sObj(i), 'XData', xdata, 'YData', ydata, 'ZData', data, ...
                        'CData', data, 'DisplayName',var);
                else
                    if has_grid
                        h = surf(x, y, data,'DisplayName',var);
                    else
                        h = surf(data,'DisplayName',var);
                    end
                    set(h, 'DisplayName', var);
                end
            else
                sObj = findobj(aObj, 'Type', 'surface');
                
                if length(sObj) >= i
                    set(sObj(i), 'XData', xdata, 'YData', ydata, 'ZData', 0*data, ...
                        'CData', data, 'DisplayName',var);
                else
                    if has_grid
                        h = pcolor(x, y, data);
                    else
                        h = pcolor(data);
                    end
                    set(h, 'DisplayName', var);
                end
            end
            
            shading interp;
        end
    end
    
    hold on;
end

% set time in title
if strcmpi(get(findobj(pObj, 'Tag', 'Slider2'), 'Enable'), 'on')
    info = get_info(xb);
    if  t2 <= length(info.t)
        title(aObj, ['t = ' num2str(info.t(t2)) ' (s)']);
    end
else
    title('');
end

% clear items without use
sObj = get(aObj, 'Children');
for i = size(vars,1)+1:length(sObj)
    delete(sObj(i));
end
end

function ui_animate(hObj, event, xb)

pObj = get(hObj, 'Parent');

% get minimum, maximum and current time
tmin = get(findobj(pObj, 'Tag', 'Slider2'), 'Min');
tmax = get(findobj(pObj, 'Tag', 'Slider2'), 'Max');
t = round(get(findobj(pObj, 'Tag', 'Slider2'), 'Value'));

% update time
t = min(tmax, ceil(t+(tmax-tmin)/100));
set(findobj(pObj, 'Tag', 'Slider2'), 'Value', t);

% reload data
ui_loaddata(hObj, event, xb)

if t < tmax
    pause(.1);
    
    % start new loop if maximum is not reached
    if get(findobj(pObj, 'Tag', 'ToggleAnimate'), 'Value')
        ui_animate(hObj, event, xb)
    end
else
    
    % stop animation if maximum is reached
    set(findobj(pObj, 'Tag', 'ToggleAnimate'), 'Value', 0);
end
end