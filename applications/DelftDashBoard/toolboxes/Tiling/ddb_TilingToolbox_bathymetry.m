function ddb_TilingToolbox_bathymetry(varargin)
%DDB_TILINGTOOLBOX_BATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TilingToolbox_bathymetry(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TilingToolbox_bathymetry
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

% $Id: ddb_TilingToolbox_bathymetry.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-25 06:26:17 +0800 (Tue, 25 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_TilingToolbox_bathymetry.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'selectcs'}
            selectCS;
        case{'editattributes'}
            editAttributes;
        case{'generatetiles'}
            generateTiles;
        case{'selectrawdataformat'}
            selectRawDataFormat;
    end    
end


%%
function selectRawDataFormat

handles=getHandles;
% Set raw data file extension and selection text
ii=strmatch(handles.toolbox.tiling.import.rawDataFormat,handles.toolbox.tiling.import.rawDataFormats,'exact');
handles.toolbox.tiling.import.rawDataFormatExtension=handles.toolbox.tiling.import.rawDataFormatsExtension{ii};
handles.toolbox.tiling.import.rawDataFormatSelectionText=['Select Data File (' handles.toolbox.tiling.import.rawDataFormatsText{ii} ')'];
handles.toolbox.tiling.import.rawDataType=handles.toolbox.tiling.import.rawDataFormatsType{ii};        
setHandles(handles);

%%
function selectDataset

handles=getHandles;

% First read data file to get meta data:

% For regular grids, we read (but make not editable):
% x0, y0, dx, dy
% For unstructured data, we determine (and make not editable):
% x0, y0, dx, dy

% Nr zoom steps is determined automatically by the tiling function

switch lower(handles.toolbox.tiling.import.rawDataFormat)
    case{'arcinfogrid'}
        [ncols,nrows,x0,y0,cellsz]=readArcInfo(handles.toolbox.tiling.import.dataFile,'info');
        dx=cellsz;
        dy=cellsz;
    case{'arcbinarygrid'}
        [x,y,z,m] = arc_info_binary([fileparts(handles.toolbox.tiling.import.dataFile) filesep]);
        clear x y z
        x0=m.X(1);
        y0=m.Y(end);
        dx=x(2)-x(1);
        dy=y(2)-y(1);
    case{'matfile'}
        s=load(handles.toolbox.tiling.import.dataFile);
        x0=s.x(1);
        y0=s.y(1);
    case{'netcdf'}
        x=nc_varget(handles.toolbox.tiling.import.dataFile,'x');
        y=nc_varget(handles.toolbox.tiling.import.dataFile,'y');
        x0=x(1);
        y0=y(1);
        nrows=length(y);
        ncols=length(x);
    case{'adcircgrid'}
        % unstructured data
        % Read metadata
        wb_h = waitbar(0,'Reading the adcirc data');
        [x,y,z,n1,n2,n3]=import_adcirc_fort14(handles.toolbox.tiling.import.dataFile,wb_h,[0,1/6]);   
        close(wb_h);
        x0=min(x);
        y0=min(y);
        x1=max(x);
        y1=max(y);
        % Compute average distance of xyz points
        dataarea=(x1-x0)*(y1-y0);
        dx=sqrt(dataarea/length(x));
        dy=dx;        
    case{'xyz'}
        xyz=load(handles.toolbox.tiling.import.dataFile);
        x0=min(xyz(:,1));
        y0=min(xyz(:,2));
        x1=max(xyz(:,1));
        y1=max(xyz(:,2));
        % Compute average distance of xyz points
        dataarea=(x1-x0)*(y1-y0);
        dx=sqrt(dataarea/size(xyz,1));
        dy=dx;        
end

% Determine default values for this dataset
handles.toolbox.tiling.import.x0=x0;
handles.toolbox.tiling.import.y0=y0;
handles.toolbox.tiling.import.dx=dx;
handles.toolbox.tiling.import.dy=dy;

setHandles(handles);

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',handles.toolbox.tiling.import.EPSGname,'type','both','defaulttype',handles.toolbox.tiling.import.EPSGtype);

if ok
    handles.toolbox.tiling.import.EPSGname=cs;
    handles.toolbox.tiling.import.EPSGtype=type;
    handles.toolbox.tiling.import.EPSGcode=nr;
    
    switch lower(handles.toolbox.tiling.import.EPSGtype)
        case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
            handles.toolbox.tiling.import.radioGeo=1;
            handles.toolbox.tiling.import.radioProj=0;
        otherwise
            handles.toolbox.tiling.import.radioGeo=0;
            handles.toolbox.tiling.import.radioProj=1;
    end
    setHandles(handles);

end

%%
function editAttributes
handles=getHandles;
attr=handles.toolbox.tiling.import.attributes;
attr=ddb_editTilingAttributes(attr);
handles.toolbox.tiling.import.attributes=attr;
setHandles(handles);

%%
function generateTiles

handles=getHandles;

OPT.EPSGcode                     = handles.toolbox.tiling.import.EPSGcode;
OPT.EPSGname                     = handles.toolbox.tiling.import.EPSGname;
OPT.EPSGtype                     = handles.toolbox.tiling.import.EPSGtype;
OPT.VertCoordName                = handles.toolbox.tiling.import.vertCoordName;
OPT.VertCoordLevel               = handles.toolbox.tiling.import.vertCoordLevel;
OPT.VertUnits                    = handles.toolbox.tiling.import.vertUnits;
OPT.nc_library                   = handles.toolbox.tiling.import.nc_library;
OPT.tp                           = handles.toolbox.tiling.import.type;
OPT.positiveup                   = handles.toolbox.tiling.import.positiveUp;

f=fieldnames(handles.toolbox.tiling.import.attributes);

for i=1:length(f);
    OPT.(f{i})=handles.toolbox.tiling.import.attributes.(f{i});
end

fname=handles.toolbox.tiling.import.dataFile;
dr=[handles.toolbox.tiling.import.dataDir filesep handles.toolbox.tiling.import.dataName filesep];
dataname=deblank(handles.toolbox.tiling.import.dataName);
datasource=deblank(handles.toolbox.tiling.import.datasource);
dataformat=handles.toolbox.tiling.import.rawDataFormat;
datatype=handles.toolbox.tiling.import.rawDataType;
%nrzoom=handles.toolbox.tiling.import.nrZoom;
nx=handles.toolbox.tiling.import.nx;
ny=handles.toolbox.tiling.import.ny;
x0=handles.toolbox.tiling.import.x0;
y0=handles.toolbox.tiling.import.y0;
dx=handles.toolbox.tiling.import.dx;
dy=handles.toolbox.tiling.import.dy;

% Check data name
if isempty(dataname)
    ddb_giveWarning('text','Please first enter a data name.');
    return;
end
if isempty(datasource)
    ddb_giveWarning('text','Please first enter a data source.');
    return;
end
if ~isempty(find(dataname==' ', 1))
    ddb_giveWarning('text','Data name cannot have spaces in it.');
    return;
end
if strcmpi(handles.toolbox.tiling.import.attributes.title,'Name of data set')
    ddb_giveWarning('text','Please enter proper title of dataset in attributes.');
    return;
end
if exist(dr,'dir')
    ddb_giveWarning('text','A dataset with this name already exists. Please remove it first.');
    return;
end
if ~isempty(strmatch(handles.toolbox.tiling.import.attributes.title,handles.bathymetry.longNames))
    ddb_giveWarning('text','A dataset with this title already exists. Please change the title in attributes.');
    return;
end

ddb_makeBathymetryTiles(fname,dr,dataname,dataformat,datatype,nx,ny,x0,y0,dx,dy,OPT);

% Now add data to data xml
fname = [handles.bathymetry.dir 'bathymetry.xml'];
xmldata = xml_load(fname);
nd=length(xmldata)+1;
xmldata(nd).dataset.name=dataname;
xmldata(nd).dataset.longName=handles.toolbox.tiling.import.attributes.title;
xmldata(nd).dataset.version='1';
xmldata(nd).dataset.type='netCDFtiles';
xmldata(nd).dataset.edit='0';
xmldata(nd).dataset.URL=[handles.toolbox.tiling.import.dataDir handles.toolbox.tiling.import.dataName];
xmldata(nd).dataset.useCache='1';
xmldata(nd).dataset.source=datasource;
xml_save(fname,xmldata,'off');

% Find all bathymetries again
handles.bathymetry=ddb_findBathymetryDatabases(handles.bathymetry);

% Select dataset that was just created
handles.screenParameters.backgroundBathymetry=dataname;
set(handles.GUIHandles.textBathymetry,'String',['Bathymetry : ' handles.bathymetry.longNames{nd} '   -   Datum : ' handles.bathymetry.dataset(nd).verticalCoordinateSystem.name]);

% And finally add it to the menu
ddb_updateBathymetryMenu(handles);

setHandles(handles);

ddb_updateDataInScreen;
