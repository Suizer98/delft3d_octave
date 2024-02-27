
function DelftDashBoard(varargin)
%DELFTDASHBOARD.
%
%   Compile with ddcompile
%
%   See also MUPPET, DETRAN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 14 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: DelftDashBoard.m 17753 2022-02-10 16:57:45Z l4217046 $
% $Date: 2022-02-11 00:57:45 +0800 (Fri, 11 Feb 2022) $
% $Author: l4217046 $
% $Revision: 17753 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/DelftDashBoard.m $
% $Keywords: $

%%

global figureiconfile

% get revision number
warning('off','all')
Revision = '$Revision: 17753 $';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

handles.delftDashBoardVersion=['2.03.' num2str(Revision)];
handles.matlabVersion=version;
handles.debugMode=0;

if isempty(varargin)
    handles.xml_config_file='delftdashboard.xml';
else
    handles.xml_config_file=varargin{1};
end

% Add java paths for snc tools
if isdeployed
    setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
    setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse
%    setpref('SNCTOOLS','USE_NETCDF_JAVA',true);
    setenv('MCR_CACHE_SIZE','64M');
end

%setpref('SNCTOOLS','USE_NETCDF_JAVA',true);

% Turn off annoying warnings
warning('off','all');

disp(['Delft DashBoard v' handles.delftDashBoardVersion]);
disp(['Matlab v' version]);

disp('Finding directories ...');
[handles,ok]=ddb_getDirectories(handles);
if ~ok
    return
end

% Read in delftdashboard xml file to determine which models,
% toolboxes etc. to include. Store data in handles.configuration
handles.configuration=ddb_read_configuration_xml([handles.xmlConfigDir handles.xml_config_file]);

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        
figureiconfile=[handles.settingsDir 'icons' filesep 'deltares.gif'];

% Open Splash Screen
frame=splash([handles.settingsDir 'icons' filesep handles.configuration.splash_screen],20);

try
    
    setHandles(handles);
    
    ddb_initialize('startup');
    
    handles=getHandles;
    
    % screenSize=get(0,'ScreenSize');
    % pos=[1 29 screenSize(3) screenSize(4)-95];
    % set(handles.GUIHandles.mainWindow,'Position',pos,'Visible','off');    
    %set(handles.GUIHandles.mainWindow,'Visible','on');
    
    set(gcf,'Renderer','zbuffer');
    
    % Make Figure Visible
    drawnow;
        
    %maximizeWindow('Delft Dashboard');
    set(gcf,'WindowState','maximized');
    
    pause(0.1);
    
    ddb_resize;
    
    set(handles.GUIHandles.mainWindow,'Visible','on');

    drawnow;
    
    ddb_changeCoordinateSystem; % This will also update data in the map panel
    
    if ~isempty(handles.configuration.xlim) && ~isempty(handles.configuration.ylim)
        % Zoom to predefined area
        handles=getHandles;
        handles=ddb_zoomTo(handles,handles.configuration.xlim,handles.configuration.ylim,0.1);    
        setHandles(handles);
    end
    ddb_updateDataInScreen;
    
    % Maximize Figure
    %maximize(handles.GUIHandles.MainWindow);
    
    % Close Splash Screen
    frame.hide;
    
catch exception   
    frame.hide;    
    disp(exception.getReport);
end
