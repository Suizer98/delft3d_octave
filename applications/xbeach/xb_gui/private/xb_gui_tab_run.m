function xb_gui_tab_run(obj)
%XB_GUI_TAB_RUN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_tab_run(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_tab_run
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

% $Id: xb_gui_tab_run.m 18424 2022-10-10 14:37:22Z l.w.m.roest.x $
% $Date: 2022-10-10 22:37:22 +0800 (Mon, 10 Oct 2022) $
% $Author: l.w.m.roest.x $
% $Revision: 18424 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_tab_run.m $
% $Keywords: $

%% build tab run

    build(obj, []);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function build(obj, event)

    % build directroy selector
    rundir = [];
    rundir(1) = uicontrol(obj, 'tag', 'rundir_label', 'style', 'text', 'string', 'Location: ');
    rundir(2) = uicontrol(obj, 'tag', 'rundir_text', 'style', 'edit', 'string', '');
    rundir(3) = uicontrol(obj, 'tag', 'rundir_button', 'style', 'pushbutton', 'string', '...', ...
        'callback', @getdir);
    
    % build run buttons
    runbuttons = [];
    runbuttons(1) = uicontrol(obj, 'tag', 'run_1', 'string', 'Write', 'callback', {@run, 'write'});
    runbuttons(2) = uicontrol(obj, 'tag', 'run_2', 'string', 'Run local', 'callback', {@run, 'local'});
    runbuttons(3) = uicontrol(obj, 'tag', 'run_3', 'string', 'Run remote', 'callback', {@run, 'remote'});
    
    set(runbuttons, 'style', 'pushbutton');
    
    % build run history
    runtable = uitable(obj, 'tag', 'run_history', ...
        'columnname', {'id', 'date', 'name', 'location', 'nodes', 'binary', 'ssh'}, ...
        'columnwidth', {50 100 200 200 50 200 50}, 'CellSelectionCallback', @getresult);
    
    resultbutton = uicontrol(obj, 'tag', 'showresult', 'string', 'Show result', ...
        'style', 'pushbutton', 'callback', {@getresult});
    
    set([rundir(:) ; runbuttons(:) ; runtable ; resultbutton], 'parent', findobj(obj, 'tag', 'panel_3'));
end

function getresult(obj, event)
    if strcmpi(get(obj, 'tag'), 'run_history')
        idx = event.Indices;
        set(obj, 'userdata', idx);
    else
        pobj = findobj('tag', 'xb_gui');
        cobj = findobj(pobj, 'tag', 'run_history');
        if ~isempty(cobj)
            idx = get(cobj, 'userdata');
            data = get(cobj, 'data');
            fdir = fileparts(data{idx(1),4});
            xb_view(fdir, 'modal', true);
        end
    end
end

function getdir(obj, event)

    pobj = findobj('tag', 'xb_gui');
    
    fpath = uigetdir;
    
    if fpath
        set(findobj(pobj, 'tag', 'rundir_text'), 'string', fpath);
    end
end

function run(obj, event, type)
    
    pobj = findobj('tag', 'xb_gui');
    
    S = get(pobj, 'userdata');
    
    fpath = get(findobj(pobj, 'tag', 'rundir_text'), 'string');
    if exist(fpath,'dir')==0
        mkdir(fpath);
    end
    
    xbr = [];
    switch type
        case 'write'
            xb_write_input(fullfile(fpath, 'params.txt'), S.model);
        case 'local'
            xbr = xb_run(S.model, 'path', fpath);
        case 'remote'
            xbr = xb_run_remote(S.model, 'ssh_prompt', true);
    end
    
    if ~isempty(xbr)
        xb_check_run(xbr, 'repeat', true);

        S.runs = [S.runs {xbr}];

        set(pobj, 'userdata', S);

        xb_gui_loaddata;
    end
end