function xb_gui_tab_modelsetup_hydro(obj)
%XB_GUI_TAB_MODELSETUP_HYDRO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_tab_modelsetup_hydro(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_tab_modelsetup_hydro
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

% $Id: xb_gui_tab_modelsetup_hydro.m 3847 2011-01-11 11:36:36Z hoonhout $
% $Date: 2011-01-11 19:36:36 +0800 (Tue, 11 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3847 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_tab_modelsetup_hydro.m $
% $Keywords: $

%% build tab modelsetup -> hydrodynamics
    
    build(obj, []);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function build(obj, event)

    % build axes
    ax = axes('tag', 'ax_2'); hold on;
    
    % build data buttons
    hydrobuttons = [];
    hydrobuttons(1) = uicontrol(obj, 'tag', 'hydrobutton_1', 'string', 'Get normative conditions', ...
        'callback', @xb_gui_modelsetup_hydro_norm);
    hydrobuttons(2) = uicontrol(obj, 'tag', 'hydrobutton_2', 'string', 'Make Vellinga surge', ...
        'callback', @makesurge);
    
    set(hydrobuttons, 'style', 'pushbutton');
    
    % build settings tables
    settings = [];
    settings(1) = uitable(obj, 'tag', 'wavesettings', 'columneditable', [false true]);
    settings(2) = uitable(obj, 'tag', 'surgesettings', 'columneditable', [false true], ...
        'rowname', {'time', 'tide #1', 'tide #2', 'tide #3', 'tide #4'});
    
    set([ax ; hydrobuttons(:) ; settings(:)], 'parent', findobj(obj, 'tag', 'panel_1_2'));
end

function makesurge(obj, event)
    pobj = findobj('tag', 'xb_gui');

    S = get(pobj, 'userdata');
    hydro = S.modelsetup.hydro;
    
    if ~isempty(hydro.surge.tide) && ~all(all(isnan(hydro.surge.tide)))
        h = hydro.surge.tide(1,:);
    else
        h = hydro.surge.zs0;
    end
    
    [Hs Tp] = deal(hydro.waves.Hm0, hydro.waves.Tp);
    
    [t h duration Hs Tp] = bc_stormsurge('h_max', max(h), 'Hm0_max', max(Hs), ...
        'Tp_max', max(Tp), 'nwaves', 32);
    
    hydro.surge.time = t;
    hydro.surge.tide = [h ; h];
    hydro.surge.zs0 = [];
    
    hydro.waves.Hm0 = Hs;
    hydro.waves.Tp = Tp;
    hydro.waves.duration = duration;
    
    S.modelsetup.hydro = hydro;
    set(pobj, 'userdata', S);
    
    xb_gui_loaddata;
end