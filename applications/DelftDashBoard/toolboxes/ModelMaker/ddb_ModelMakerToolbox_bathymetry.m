function ddb_ModelMakerToolbox_bathymetry(varargin)
%DDB_MODELMAKERTOOLBOX_BATHYMETRY master function for bathy in DDB
%
%   When generateBathymetry is used first handles are loaded
%   1) A specific 'bathy generate' per model is applied
%   2) All these functions came back to ddb_ModelMakerToolbox_generateBathymetry
%   3) Bathys in the order presented and interpolation to model grid
%   4) End with diffusion and model offset

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

% $Id: ddb_ModelMakerToolbox_bathymetry.m 18438 2022-10-12 16:23:14Z ormondt $
% $Date: 2022-10-13 00:23:14 +0800 (Thu, 13 Oct 2022) $
% $Author: ormondt $
% $Revision: 18438 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_bathymetry.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
    ddb_plotModelMaker('activate');
%     if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
%         setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
%             'Right-click and drag RED markers to rotate box)', 'Note: make sure origin is offshore and x direction is cross-shore'});
%     end
else
    
    %Options selected
    opt=lower(varargin{1});
    
    switch opt
        case{'usedataset'}
            useDataset;
        case{'showinfo'}
            showInfo;
        case{'removedataset'}
            removeDataset;
        case{'datasetup'}
            datasetUp;
        case{'datasetdown'}
            datasetDown;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'pickselecteddataset'}
%            selectDataset;
    end
    
end

%%
function showInfo
handles=getHandles;
iac=handles.toolbox.modelmaker.bathymetry.activeDataset;
ddb_showBathyInfo(handles,iac);

%%
function useDataset

handles=getHandles;
iac=handles.toolbox.modelmaker.bathymetry.activeDataset;
% Check if dataset is already selected
usedd=1;
for i=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
    if handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).number==iac
        usedd=0;
        break
    end
end
if usedd
    handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets+1;
    n=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets;
    
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).number=handles.toolbox.modelmaker.bathymetry.activeDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).name=handles.bathymetry.datasets{iac};
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).type=handles.bathymetry.dataset(iac).type;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).verticalDatum=handles.bathymetry.dataset(iac).verticalCoordinateSystem.name;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).verticalLevel=handles.bathymetry.dataset(iac).verticalCoordinateSystem.level;

    % Default values
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).zMax=1e4;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).zMin=-1e4;

    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).startDate=floor(now);
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).searchInterval=-1e5;

    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames{n}=handles.bathymetry.longNames{iac};
    
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=n;
    
    setHandles(handles);
end

%%
function removeDataset
% Remove selected dataset
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;    
    handles.toolbox.modelmaker.bathymetry.selectedDatasets = removeFromStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac);
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames = removeFromCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames, iac);
    handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets-1;
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=max(min(handles.toolbox.modelmaker.bathymetry.activeSelectedDataset,handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets),1);
    if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets==0
        handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).type='unknown';
    end    
    setHandles(handles);
end

%%
function datasetUp
% Move selected dataset up
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames,iac,'up');
    [handles.toolbox.modelmaker.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac, 'up');
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
end

%%
function datasetDown

% Move selected dataset down
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames,iac,'down');
    [handles.toolbox.modelmaker.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac, 'down');
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
end

%% 
function generateBathymetry

handles=getHandles;

for ii=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
    nr=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).number;
    datasets(ii).name=handles.bathymetry.datasets{nr};
    datasets(ii).startdates=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).startDate;
    datasets(ii).searchintervals=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).searchInterval;
    datasets(ii).zmin=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMin;
    datasets(ii).zmax=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMax;
    datasets(ii).verticaloffset=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).verticalLevel;
end

switch lower(handles.activeModel.name)
    case{'delft3dflow'}
        handles=ddb_ModelMakerToolbox_Delft3DFLOW_generateBathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);
    case{'delft3dwave'}
        handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateBathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);
    case{'dflowfm'}
        handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);
    case{'xbeach'}
        
        % Check: no geographic coordinate systems
        coord=handles.screenParameters.coordinateSystem;
        iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
        dataCoord.name=handles.screenParameters.coordinateSystem.name;
        dataCoord.type=handles.screenParameters.coordinateSystem.type;
        if ~strcmpi(lower(dataCoord.type), 'geographic')
            
            try
                tmp = handles.toolbox.modelmaker.xb_trans.X;
                xbeach1d = 1;
            catch
                xbeach1d = 0;
            end
            
            % Make XBeach in 1D
            if xbeach1d == 1
                
            else
                wb =   waitbox('XBeach model is being created');
                handles=ddb_ModelMakerToolbox_XBeach_generateModel(handles, datasets);
                close(wb);
                
                % Plotting -> no, because there are already windows open
                %handles=ddb_initializeXBeach(handles,1,'xbeach1');% Check
                %pathname = pwd; filename='\params.txt';
                %handles.model.xbeach.domain(handles.activeDomain).params_file=[pathname filename];
                %handles=ddb_readParams(handles,[pathname filename],1);
                %handles=ddb_readAttributeXBeachFiles(handles,[pathname,'\'],1); % need to add all files
                %ddb_plotXBeach('plot','domain',ad); % make
                setHandles(handles);
                
                %ddb_updateDataInScreen;
                % gui_updateActiveTab;
                % ddb_refreshDomainMenu;
                
                % Overview
                ddb_ModelMakerToolbox_XBeach_modelsetup(handles)
            end
        else
            ddb_giveWarning('text',['XBeach models are ALWAYS in cartesian coordinate systems. Change your coordinate system to make a XBeach model']);
        end
        
    case{'ww3'}
        handles=ddb_ModelMakerToolbox_ww3_generate_bathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);
    case{'sfincs'}
        handles=ddb_ModelMakerToolbox_sfincs_generateBathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);        
    case{'hurrywave'}
        handles=ddb_ModelMakerToolbox_hurrywave_generateBathymetry(handles,ad,datasets,'modeloffset',handles.toolbox.modelmaker.bathymetry.verticalDatum);        
end

setHandles(handles);

