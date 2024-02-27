function ddb_initialize(varargin)
%DDB_INITIALIZE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_initialize(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_initialize
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
switch lower(varargin{1})
    
    case{'startup'}
        
        tic
        disp('Finding coordinate systems ...');
        ddb_getCoordinateSystems;
        toc
        
        handles=getHandles;

        if handles.configuration.include_tide_models
            tic
            disp('Finding tide models ...');
            ddb_findTideModels;
            toc
        else
            disp('Skipping tide models ...');
            handles=getHandles;
            handles.tideModels.longNames = {''};
            handles.tideModels.names     = {''};
            handles.tideModels.nrModels  = 0;
            setHandles(handles);
        end
        
        tic
        disp('Finding bathymetry datasets ...');
        handles=getHandles;
        handles.bathymetry=ddb_findBathymetryDatabases(handles.bathymetry,handles.configuration.include_bathymetry);
        setHandles(handles);
        toc
        
        tic
        disp('Finding shorelines ...');
        ddb_findShorelines;
        toc
        
        tic
        disp('Finding toolboxes ...');
        ddb_findToolboxes;
        toc
        
        tic
        disp('Finding models ...');
        ddb_findModels;
        toc
        
        ddb_setModelSettings('initialize');
        ddb_setProxySettings('initialize');
        ddb_setSNCSettings('initialize');
                
        tic
        disp('Initializing screen parameters ...');
        ddb_initializeScreenParameters;
        toc
 
        tic
        disp('Initializing figure ...');
        ddb_initializeFigure;
        toc

        tic
        disp('Initializing models ...');
        ddb_initializeModels;
        toc

        tic
        disp('Initializing toolboxes ...');
        ddb_initializeToolboxes;
        toc

%        set(handles.GUIHandles.mainWindow,'visible','off');
        disp('Adding model tabpanels ...');
        ddb_addModelTabPanels;
        
        disp('Loading additional map data ...');
        ddb_loadMapData;
        
        disp('Initializing screen ...');
        ddb_makeMapPanel;
        
        % Toolbox is selected in ddb_selectModel
        handles=getHandles;
        ddb_selectModel(handles.activeModel.name);
        
        % Refresh domains in menu
        ddb_refreshDomainMenu;
        
        handles=getHandles;
        try
            set(handles.GUIHandles.mainWindow,'WindowScrollWheelFcn',@ddb_zoomScrollWheel);
        end
        
        set(handles.GUIHandles.mainWindow,'ResizeFcn',@ddb_resize);
        
        ddb_setWindowButtonUpDownFcn;
        ddb_setWindowButtonMotionFcn;
        
        handles=getHandles;
        handles.GUIHandles.anchorhandle=[];
        setHandles(handles);
       
    case{'all'}
        ddb_initializeModels;
        ddb_initializeToolboxes;
        ddb_refreshDomainMenu;
        
        handles=getHandles;
        if ~isempty(handles.GUIHandles.anchorhandle)
            try
                delete(handles.GUIHandles.anchorhandle);
            end
            handles.GUIHandles.anchorhandle=[];
        end
        setHandles(handles);

        
    otherwise
        
end

