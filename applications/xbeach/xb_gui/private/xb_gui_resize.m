function xb_gui_resize(obj, event)
%XB_GUI_RESIZE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_resize(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_resize
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

% $Id: xb_gui_resize.m 3918 2011-01-19 11:05:07Z hoonhout $
% $Date: 2011-01-19 19:05:07 +0800 (Wed, 19 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3918 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_resize.m $
% $Keywords: $

%% reposition elements in gui

p = get(obj, 'position');
s = p(3:4); p = [s s];

%% main window

objs = flipud(findobj(obj, '-regexp', 'tag', '^tab_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.02 .94-.06*(i-1) .1 .04].*p);
end

objs = findobj(obj, '-regexp', 'tag', '^panel_\d+$');
set(objs, 'position', [.14 .02 .84 .96]);

objs = findobj(obj, '-regexp', 'tag', '^button_\w+$');
for i = 1:length(objs)
    set(objs(i), 'position', [.02 .02+.06*(i-1) .1 .04].*p);
end

%% model setup

objs = flipud(findobj(obj, '-regexp', 'tag', '^tab_1_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.02+.12*(i-1) .88 .1 .04].*p);
end

objs = findobj(obj, 'tag', 'generate');
set(objs, 'position', [.71 .88 .1 .04].*p);

objs = findobj(obj, '-regexp', 'tag', '^panel_1_\d+$');
set(objs, 'position', [.02 .02 .96 .88]);

%% model setup -> bathy

set(findobj(obj, 'tag', 'ax_1'), 'position', [.05 .05 .78 .90]);

objs = flipud(findobj(obj, '-regexp', 'tag', '^databutton_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.69 .73-.06*(i-1) .1 .04].*p);
end

objs = flipud(findobj(obj, '-regexp', 'tag', '^gridfinalise_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.69 .55-.04*(i-1) .1 .02].*p);
end

%% model setup -> hydro

set(findobj(obj, 'tag', 'ax_2'), 'position', [.05 .40 .78 .55]);

objs = flipud(findobj(obj, '-regexp', 'tag', '^hydrobutton_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.69 .73-.06*(i-1) .1 .04].*p);
end

set(findobj(obj, 'tag', 'wavesettings'), 'position', [.03 .02 .31 .25].*p);
set(findobj(obj, 'tag', 'surgesettings'), 'position', [.36 .02 .31 .25].*p);

%% model setup -> settings

set(findobj(obj, 'tag', 'settings'), 'position', [.02 .02 .76 .76].*p);

%% model

set(findobj(obj, 'tag', 'preview_bathy'), 'position', [.05 .05 .78 .90]);

%% run
    
set(findobj(obj, 'tag', 'rundir_label'), 'position', [.02 .87 .05 .04].*p);
set(findobj(obj, 'tag', 'rundir_text'), 'position', [.09 .88 .34 .04].*p);
set(findobj(obj, 'tag', 'rundir_button'), 'position', [.45 .88 .05 .04].*p);

objs = flipud(findobj(obj, '-regexp', 'tag', '^run_\d+$'));
for i = 1:length(objs)
    set(objs(i), 'position', [.09+.12*(i-1) .82 .1 .04].*p);
end

set(findobj(obj, 'tag', 'run_history'), 'position', [.09 .08 .74 .72].*p);

set(findobj(obj, 'tag', 'showresult'), 'position', [.73 .02 .1 .04].*p);

%% result
