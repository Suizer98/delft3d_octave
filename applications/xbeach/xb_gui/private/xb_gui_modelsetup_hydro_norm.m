function xb_gui_modelsetup_hydro_norm(obj, event)
%XB_GUI_MODELSETUP_HYDRO_NORM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_modelsetup_hydro_norm(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_modelsetup_hydro_norm
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
% Created: 07 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_gui_modelsetup_hydro_norm.m 3918 2011-01-19 11:05:07Z hoonhout $
% $Date: 2011-01-19 19:05:07 +0800 (Wed, 19 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3918 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_modelsetup_hydro_norm.m $
% $Keywords: $

%% create gui

    sz = get(0, 'screenSize');

    winsize = [600 800];
    winpos = (sz(3:4)-winsize)/2;
    
    pobj = figure( ...
        'name', 'Normative storm select tool', ...
        'numbertitle', 'off', ...
        'color', [0.8314 0.8157 0.7843], ...
        'position', [winpos winsize], ...
        'inverthardcopy', 'off', ...
        'resize', 'off', ...
        'windowstyle', 'modal');
    
    uicontrol(pobj, 'units', 'normalized', 'style', 'edit', 'tag', 'name', ...
        'position', [.05 .93 .75 .04], 'fontsize', 14, 'backgroundcolor', 'w', 'callback', @setloc);
    fe = uicontrol(pobj, 'units', 'normalized', 'style', 'edit', 'tag', 'freq', ...
        'position', [.85 .93 .10 .04], 'string', '10000', 'backgroundcolor', 'w');
    uicontrol(pobj, 'units', 'normalized', 'style', 'pushbutton', 'tag', 'pick', ...
        'position', [.88 .02 .1 .04], 'string', 'Pick', 'callback', @pickloc);

    ax1 = axes('position', [.05 .14 .90 .75]); hold on; box on;
    
    hl = nc_plot_coastline; axis equal;
    set(hl, 'Color', [.8 .8 .8]);
    
    ax2 = axes('position', [.05 .14 .90 .75], 'tag', 'map', 'color', 'none'); hold on;
    linkaxes([ax1 ax2], 'xy');
    
    S = get(findobj('tag', 'xb_gui'), 'userdata');
    data = S.modelsetup.hydro.data;
    if ~isempty(data)
        set(fe, 'string', num2str(1/data.freq));
        plot(ax2, data.x, data.y, 'or', 'tag', 'loc');
    end
    
    xb_gui_dragselect(ax2, 'select', false);
    set(ax2, 'buttondownfcn', @setloc);
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function setloc(obj, event)
    pobj = get(obj, 'parent');
    mobj = findobj(pobj, 'tag', 'map');
    
    x = []; y = [];
    
    switch get(obj, 'tag')
        case 'name'
            [x y] = str2coord([get(obj, 'string') ', nederland']);
        otherwise
            cp = get(obj, 'currentpoint');
            x = cp(1,1);
            y = cp(1,2);
    end
    
    if ~isempty(x) && ~isempty(y)
        lobj = findobj(mobj, 'tag', 'loc');
        if isempty(lobj)
            plot(mobj, x, y, 'or', 'tag', 'loc');
        else
            set(lobj, 'xdata', x, 'ydata', y);
        end
    else
        errordlg(['The location "' get(obj, 'string') '" could not be found in the Netherlands. Please check the name.'],'Location not found')
    end
end

function pickloc(obj, event)
    pobj = get(obj, 'parent');
    mobj = findobj(pobj, 'tag', 'map');
    lobj = findobj(mobj, 'tag', 'loc');
    fobj = findobj(pobj, 'tag', 'freq');
    
    if ~isempty(lobj)
        x = get(lobj, 'xdata');
        y = get(lobj, 'ydata');
        freq = 1/str2double(get(fobj, 'string'));

        [h Hs Tp] = bc_normstorm('loc', [x y], 'freq', freq);

        gobj = findobj('tag', 'xb_gui');
        S = get(gobj, 'userdata');
        hydro = S.modelsetup.hydro;

        hydro.surge.time = 0;
        hydro.surge.tide = [];
        hydro.surge.zs0 = h;

        hydro.waves.Hm0 = Hs;
        hydro.waves.Tp = Tp;
        hydro.waves.duration = 1200;

        hydro.data.x = x;
        hydro.data.y = y;
        hydro.data.freq = freq;

        S.modelsetup.hydro = hydro;
        set(gobj, 'userdata', S);

        xb_gui_loaddata;
    end
    
    close(pobj);
end