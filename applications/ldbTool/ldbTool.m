function ldbTool
%LDBTOOL Tool with graphical user interface to edit landboundaries.
%
% This tool can be used for editting landboundaries:
%   - edit single ldb-points (replace/insert/remove);
%   - delete/show/connect ldb-segments;
%   - create new landboundaries
%   - different glue-functions to connect seperate landboundaries segments
%   - option to show georeferenced images together with landboundary
%   - undo-option (max. 5 steps back)
%   - several plot options, e.g. filling, showing indices, layers, etc.
%   - and many more ldb-edit options....
%
% See the manual (accessible via the help-menu) for detailed information
% about this program.
%
% Syntax (to start the graphical environment):
% ldbTool;
%
% See also: disassembleLdb, rebuildLdb, ultraGlueLDB

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017-2018 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%
%
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 30 Jul 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ldbTool.m 14382 2018-05-31 12:28:48Z reijmeri $
% $Date: 2018-05-31 20:28:48 +0800 (Thu, 31 May 2018) $
% $Author: reijmeri $
% $Revision: 14382 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ldbTool/ldbTool.m $
% $Keywords: $

%% Code

basePath=strrep(which('ldbTool.m'),[filesep 'ldbTool.m'],'');

% Paths:
if ~isdeployed
    pathCell = regexp(path, pathsep, 'split');
    if ispc  % Windows is not case-sensitive:
        if ~any(strcmpi(basePath, pathCell))
            addpath(basePath);
        end
        if ~any(strcmpi([basePath filesep 'LT_gui'], pathCell))
            addpath([basePath filesep 'LT_gui']);
        end
        if ~any(strcmpi([basePath filesep 'LT_engines'], pathCell))
            addpath([basePath filesep 'LT_engines']);
        end
    else
        if ~any(strcmp(basePath, pathCell))
            addpath(basePath);
        end
        if ~any(strcmp([basePath 'LT_gui'], pathCell))
            addpath([basePath 'LT_gui']);
        end
        if ~any(strcmp([basePath 'LT_engines'], pathCell))
            addpath([basePath 'LT_engines']);
        end
    end
end

fig=openfig('ldbTool.fig','reuse','invisible');
set(findobj(fig,'tag','LT_openLdbBut'),'enable','on');
set(findobj(fig,'tag','LT_saveMenu'),'enable','off');
set(findobj(fig,'tag','LT_save2Menu'),'enable','off');
set(findobj(fig,'tag','LT_resetMenu'),'enable','off');
set(findobj(fig,'tag','LT_undoMenu'),'enable','off');
set(fig,'Toolbar','figure');
set(findall(fig,'type','uipushtool'),'Separator','off');
set(findall(fig,'type','uitoggletool'),'Separator','off');
delete(findall(fig,'type','uipushtool'));
delete(findall(fig,'tag','figToolRotate3D'));
delete(findall(fig,'tag','ScribeToolBtn'));
delete(findall(fig,'tag','ScribeToolBtn'));
delete(findall(fig,'tag','ScribeToolBtn'));
delete(findall(fig,'tag','ScribeSelectToolBtn'));
delete(findall(fig,'tag','Annotation.InsertLegend'));
delete(findall(fig,'tag','Annotation.InsertColorbar'));
delete(findall(fig,'tag','Exploration.DataCursor'));
delete(findall(fig,'tag','Exploration.Rotate'));
delete(findall(fig,'tag','Standard.EditPlot'));
set(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata',{'''k-'''});
set(findobj(fig,'tag','LT_plotWindow'),'ButtonDownFcn',@LT_mouse_click);
try; set(fig,'SizeChangedFcn',@LT_showAll); catch; set(fig,'ResizeFcn',@LT_showAll); end;
set(findobj(fig,'tag','LT_plotWindow'),'visible','on');
try; set(get(findobj(fig,'tag','LT_plotWindow'),'XAxis'),'Visible','off'); catch; set(findobj(fig,'tag','LT_plotWindow'),'XColor','w'); end;
try; set(get(findobj(fig,'tag','LT_plotWindow'),'YAxis'),'Visible','off'); catch; set(findobj(fig,'tag','LT_plotWindow'),'YColor','w'); end;
% set(findobj(fig,'tag','LT_plotWindow'),'XGrid','on');
% set(findobj(fig,'tag','LT_plotWindow'),'YGrid','on');
ss = get(0,'ScreenSize');
set(fig,'visible','on');
set(fig,'units','pixels','position',ss+[8 47 -16 -131]);
LT_showAll(fig);
set(findobj(fig,'tag','LT_plotWindow'),'xlim',get(findobj(fig,'tag','LT_plotWindow'),'xlim'),'YLim',get(findobj(fig,'tag','LT_plotWindow'),'ylim'));