function xb_gui_tab_modelsetup_bathy(obj)
%XB_GUI_TAB_MODELSETUP_BATHY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_tab_modelsetup_bathy(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_tab_modelsetup_bathy
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

% $Id: xb_gui_tab_modelsetup_bathy.m 3847 2011-01-11 11:36:36Z hoonhout $
% $Date: 2011-01-11 19:36:36 +0800 (Tue, 11 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3847 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_tab_modelsetup_bathy.m $
% $Keywords: $

%% build tab modelsetup -> bathymetry
    
    build(obj, []);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function build(obj, event)

    % build axes
    ax = axes('tag', 'ax_1'); hold on; box on;
    xb_gui_dragselect(ax, 'select', false, 'cursor', false);
    
    % build data buttons
    databuttons = [];
    databuttons(1) = uicontrol(obj, 'tag', 'databutton_1', 'string', 'Get bathymetry data', ...
        'callback', @xb_gui_modelsetup_bathy_merge);
    databuttons(2) = uicontrol(obj, 'tag', 'databutton_2', 'string', 'Add non-erodable data', ...
        'callback', @xb_gui_modelsetup_bathy_ne, 'enable', 'off');
    databuttons(3) = uicontrol(obj, 'tag', 'databutton_3', 'string', 'Crop', ...
        'callback', @xb_gui_modelsetup_bathy_crop, 'enable', 'off');
    
    set(databuttons, 'style', 'pushbutton');
    set(databuttons(3), 'style', 'toggle');
    
    % build finalise options
    options = [];
    funcs = get_subfunc('xb_grid_finalise');
    for i = 2:length(funcs)
        options(i-1) = uicontrol(obj, 'tag', ['gridfinalise_' num2str(i-1)], 'string', funcs(i).name);
    end
    
    set(options, 'style', 'checkbox');
    
    set([ax(:) ; databuttons(:) ; options(:)], 'parent', findobj(obj, 'tag', 'panel_1_1'));
end