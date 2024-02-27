function xb_gui(varargin)
%XB_GUI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui
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
% Created: 05 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_gui.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/xb_gui.m $
% $Keywords: $

%% create gui

    % read options
    OPT = struct( ...
    );

    OPT = setproperty(OPT, varargin{:});

    % create gui
    if isempty(findobj('tag', 'xb_gui'))
        sz = get(0, 'screenSize');

        winsize = sz(3:4)-[200 200];
        winpos = (sz(3:4)-winsize)/2;

        fig = figure( ...
            'tag', 'xb_gui', ...
            'name', 'XBeach Toolbox GUI', ...
            'numbertitle', 'off', ...
            'position', [winpos winsize], ...
            'color', [0.8314 0.8157 0.7843], ...
            'toolbar', 'figure', ...
            'inverthardcopy', 'off', ...
            'resizefcn', @xb_gui_resize);

        build(fig, []);
        
        warndlg('This functionality is under construction. Only a few basic tools from the XBeach toolbox are available via the GUI at this moment. Please use the command-line functions for full access to the toolbox','Under construction')
        
        % load model from varargin
        if ~isempty(varargin) && xs_check(varargin{1})
            S = xb_gui_struct;  S.model = varargin{1};
            set(fig, 'userdata', S);
            xb_gui_loadmodel;
            xb_gui_loaddata;
        end
    else
        error('XBeach GUI instance already opened');
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function build(obj, event)

    % build tabs
    tabs = [];
    tabs(1) = uicontrol(obj, 'tag', 'tab_1', 'string', 'Model setup');
    tabs(2) = uicontrol(obj, 'tag', 'tab_2', 'string', 'Model');
    tabs(3) = uicontrol(obj, 'tag', 'tab_3', 'string', 'Run');
    %tabs(4) = uicontrol(obj, 'tag', 'tab_4', 'string', 'Result');
    
    set(tabs(:), {'style', 'units', 'enable', 'value', 'callback'}, ...
        {'toggle', 'pixels', 'off', false, @xb_gui_toggletab});
    
    % build panels
    panels = [];
    panels(1) = uipanel(obj, 'tag', 'panel_1', 'title', get(tabs(1), 'string'), 'visible', 'off');
    panels(2) = uipanel(obj, 'tag', 'panel_2', 'title', get(tabs(2), 'string'), 'visible', 'off');
    panels(3) = uipanel(obj, 'tag', 'panel_3', 'title', get(tabs(3), 'string'), 'visible', 'off');
    %panels(4) = uipanel(obj, 'tag', 'panel_4', 'title', get(tabs(4), 'string'), 'visible', 'off');
    
    % add content
    xb_gui_tab_modelsetup(obj);
    xb_gui_tab_model(obj);
    xb_gui_tab_run(obj);
    xb_gui_tab_result(obj);
    
    % build window buttons
    buttons = [];
    buttons(1) = uicontrol(obj, 'tag', 'button_new', 'string', 'New', 'callback', @xb_gui_loaddata);
    buttons(2) = uicontrol(obj, 'tag', 'button_open', 'string', 'Open', 'callback', @xb_gui_loaddata);
    buttons(3) = uicontrol(obj, 'tag', 'button_load', 'string', 'Load model', 'callback', @xb_gui_loaddata);
    buttons(4) = uicontrol(obj, 'tag', 'button_save', 'string', 'Save', 'callback', @winsave, 'enable', 'off');
    buttons(5) = uicontrol(obj, 'tag', 'button_exit', 'string', 'Exit', 'callback', @winclose);
    
    % resize objects in window
    xb_gui_resize(obj, event);
end

function winclose(obj, event)

    close(get(obj, 'parent'));
    
end

function winsave(obj, event)
    pobj = findobj('tag', 'xb_gui');

    [fname fpath] = uiputfile('*.mat', 'Save Model Setup');
    
    if fpath
        S = get(pobj, 'userdata');
        save(fullfile(fpath, fname), '-struct', 'S');
    end
end