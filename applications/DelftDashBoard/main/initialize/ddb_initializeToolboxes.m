function ddb_initializeToolboxes
%DDB_INITIALIZETOOLBOXES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_initializeToolboxes
%
%   Input:

%
%
%
%
%   Example
%   ddb_initializeToolboxes
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_initializeToolboxes.m 17881 2022-03-31 12:28:55Z ormondt $
% $Date: 2022-03-31 20:28:55 +0800 (Thu, 31 Mar 2022) $
% $Author: ormondt $
% $Revision: 17881 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_initializeToolboxes.m $
% $Keywords: $

%%
handles=getHandles;

toolboxnames=fieldnames(handles.toolbox);
for k=1:length(toolboxnames)
    name=toolboxnames{k};
    if isfield(handles.toolbox.(name),'longName')
        longname=handles.toolbox.(name).longName;
        try
            disp(['Initializing toolbox ' longname ' ...']);
            f=handles.toolbox.(name).iniFcn;
            handles=f(handles);
        catch
            disp(['An error occured while initializing ' longname ' toolbox. Toolbox will be made inactive!']);
            p=findobj(gcf,'Tag','menutoolbox');
            ch=findobj(p,'Tag',name);
            set(ch,'Enable','off');
        end
    end
end

if isdeployed
    dr=[ctfroot filesep 'DelftDashBoa' filesep 'ddbsettings' filesep 'toolboxes']; % Changed back MvO (2017-4-20)
else
    ddb_root = fileparts(which('delftdashboard.ini'));
    dr=[ddb_root filesep 'toolboxes'];
end

% Initialize requested toolboxes that will not be in the GUI
for k=1:length(handles.configuration.include_toolboxes_no_gui)

    name = handles.configuration.include_toolboxes_no_gui{k};
    nm   = lower(name);

    disp(['Initializing ' name ' ...']);

    handles.toolbox.(nm).iniFcn=str2func(['ddb_initialize' name]);
    if isdeployed
        % Executable
        handles.toolbox.(nm).dir=[dr filesep nm filesep];
        handles.toolbox.(nm).xmlDir=[handles.settingsDir filesep 'toolboxes' filesep nm filesep 'xml' filesep];
        handles.toolbox.(nm).dataDir=[handles.toolBoxDir nm filesep];
    else
        % From Matlab
        handles.toolbox.(nm).dir=[dr filesep nm filesep];
        handles.toolbox.(nm).xmlDir=[handles.toolbox.(nm).dir 'xml' filesep];
        handles.toolbox.(nm).dataDir=[handles.toolBoxDir nm filesep];
    end
    
    f=handles.toolbox.(nm).iniFcn;
    handles=f(handles);
    
end

setHandles(handles);
