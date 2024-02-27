function xb_gui_tab_modelsetup(obj)
%XB_GUI_TAB_MODELSETUP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_tab_modelsetup(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_tab_modelsetup
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

% $Id: xb_gui_tab_modelsetup.m 3847 2011-01-11 11:36:36Z hoonhout $
% $Date: 2011-01-11 19:36:36 +0800 (Tue, 11 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3847 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_tab_modelsetup.m $
% $Keywords: $

%% build tab modelsetup

    build(obj, []);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function build(obj, event)

    % build tabs
    tabs = [];
    tabs(1) = uicontrol(obj, 'tag', 'tab_1_1', 'string', 'Bathymetry', 'value', true);
    tabs(2) = uicontrol(obj, 'tag', 'tab_1_2', 'string', 'Hydrodynamics', 'value', false);
    tabs(3) = uicontrol(obj, 'tag', 'tab_1_3', 'string', 'Settings', 'value', false);

    set(tabs(:), {'style', 'units', 'enable', 'callback'}, {'toggle', 'pixels', 'on', @xb_gui_toggletab});

    % build panels
    panels = [];
    panels(1) = uipanel(obj, 'tag', 'panel_1_1', 'title', get(tabs(1), 'string'), 'visible', 'on');
    panels(2) = uipanel(obj, 'tag', 'panel_1_2', 'title', get(tabs(2), 'string'), 'visible', 'off');
    panels(3) = uipanel(obj, 'tag', 'panel_1_3', 'title', get(tabs(3), 'string'), 'visible', 'off');
    
    gen = uicontrol(obj, 'style', 'pushbutton', 'units', 'pixels', 'tag', 'generate', ...
        'string', 'Generate model', 'backgroundcolor', 'r', 'fontweight', 'bold', 'callback', @generate);
    
    % add content
    xb_gui_tab_modelsetup_bathy(obj);
    xb_gui_tab_modelsetup_hydro(obj);
    xb_gui_tab_modelsetup_settings(obj);
    
    set([tabs(:) ; panels(:) ; gen], 'parent', findobj(obj, 'tag', 'panel_1'));
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generate(obj, event)
    pobj = findobj('tag', 'xb_gui');
    S = get(pobj, 'userdata');
    
    % bathy
    bathy = { ...
        'x', S.modelsetup.bathy.x, ...
        'y', S.modelsetup.bathy.y, ...
        'z', S.modelsetup.bathy.z, ...
        'ne', S.modelsetup.bathy.ne, ...
        'crop', S.modelsetup.bathy.crop, ...
        'finalise', S.modelsetup.bathy.finalise ...
    };

    % waves
    names = fieldnames(S.modelsetup.hydro.waves);
    values = struct2cell(S.modelsetup.hydro.waves);
    
    waves = cell(1,2*length(names));
    waves(1:2:end) = names;
    waves(2:2:end) = values;
    
    % surge
    time = S.modelsetup.hydro.surge.time;
    tide = S.modelsetup.hydro.surge.tide;
    zs0 = S.modelsetup.hydro.surge.zs0;
    
    switch size(tide, 1)
        case 0
            surge = {'time', 0, 'front', zs0, 'back', zs0};
        case 1
            surge = {'time', time, 'front', tide(1,:), 'back', zs0};
        case 2
            surge = {'time', time, 'front', tide(1,:), 'back', tide(2,:)};
        case 4
            surge = {'time', time, 'front', tide(1:2,:), 'back', tide(3:4,:)};
    end
    
    % settings
    names = fieldnames(S.modelsetup.settings);
    values = struct2cell(S.modelsetup.settings);
    
    settings = cell(1,2*length(names));
    settings(1:2:end) = names;
    settings(2:2:end) = values;
    
    S.model = xb_generate_model( ...
        'bathy', bathy, ...
        'tide', surge, ...
        'waves', waves, ...
        'settings', settings ...
    );
    
    set(pobj, 'userdata', S);
    
    xb_gui_loaddata;
    
    xb_gui_toggletab(findobj(pobj, 'tag', 'tab_2'), []);
end