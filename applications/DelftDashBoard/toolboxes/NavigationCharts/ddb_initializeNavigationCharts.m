function handles = ddb_initializeNavigationCharts(handles, varargin)
%DDB_INITIALIZENAVIGATIONCHARTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNavigationCharts(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNavigationCharts
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

ddb_getToolboxData(handles,handles.toolbox.navigationcharts.dataDir,'navigationcharts','NavigationCharts');

handles.toolbox.navigationcharts.longName='Navigation Charts';
handles.toolbox.navigationcharts.databases=[];
handles.toolbox.navigationcharts.charts=[];

% JV: Added case-insensitive checks for directories and filenames
%     necessary for linux/mac
tmpDir=dir(handles.toolBoxDir);
index = find(strcmpi({tmpDir.name},'navigationcharts') == 1, 1);

%if isdir([handles.toolBoxDir 'navigationcharts'])
if ~isempty(index)

    % Read xml file
    %dr=[handles.toolBoxDir 'navigationcharts' filesep'];
    dr=[handles.toolBoxDir tmpDir(index).name filesep'];
    
    % JV: Same fix for xml file
    tmpFiles = dir(dr);
    index = find(strcmpi({tmpFiles.name},'navigationcharts.xml') == 1, 1);
    
    %xml=xml2struct([dr 'NavigationCharts.xml'],'structuretype','short');
    xml=xml2struct([dr tmpFiles(index).name],'structuretype','short');

    n=0;
    for jj=1:length(xml.file)
        if exist([dr xml.file(jj).file.name],'file')
            n=n+1;
            s=load([dr xml.file(jj).file.name]);
            handles.toolbox.navigationcharts.charts(n).name=s.name;
            handles.toolbox.navigationcharts.charts(n).longname=s.longname;
            handles.toolbox.navigationcharts.charts(n).box=s.Box;
            handles.toolbox.navigationcharts.charts(n).url=fileparts(xml.file(jj).file.URL);
            handles.toolbox.navigationcharts.databases{n}=s.longname;            
        end
    end

end

handles.toolbox.navigationcharts.activeDatabase=1;
handles.toolbox.navigationcharts.activeChart=1;
handles.toolbox.navigationcharts.showShoreline=1;
handles.toolbox.navigationcharts.showSoundings=1;
handles.toolbox.navigationcharts.showContours=1;
handles.toolbox.navigationcharts.activeChartName='';
handles.toolbox.navigationcharts.oldChartName='';
handles.toolbox.navigationcharts.selectedChart=1;

if ~isfield(handles.toolbox.navigationcharts,'databases')
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
elseif isempty(handles.toolbox.navigationcharts.databases)
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
end

% Polygon
handles.toolbox.navigationcharts.polygonX=[];
handles.toolbox.navigationcharts.polygonY=[];
handles.toolbox.navigationcharts.polygonLength=0;
handles.toolbox.navigationcharts.polygonhandle=[];
