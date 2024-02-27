function ddb_BathymetryToolbox_import(varargin)
%ddb_BathymetryToolbox_import  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_BathymetryToolbox_import(varargin)
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
%   Copyright (C) 2014 Deltares
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

% $Id: ddb_BathymetryToolbox_import.m 17727 2022-02-03 10:45:45Z ormondt $
% $Date: 2022-02-03 18:45:45 +0800 (Thu, 03 Feb 2022) $
% $Author: ormondt $
% $Revision: 17727 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Bathymetry/ddb_BathymetryToolbox_import.m $
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
ii=strmatch(handles.toolbox.bathymetry.import.rawDataFormat,handles.toolbox.bathymetry.import.rawDataFormats,'exact');
handles.toolbox.bathymetry.import.rawDataFormatExtension=handles.toolbox.bathymetry.import.rawDataFormatsExtension{ii};
handles.toolbox.bathymetry.import.rawDataFormatSelectionText=['Select Data File (' handles.toolbox.bathymetry.import.rawDataFormatsText{ii} ')'];
handles.toolbox.bathymetry.import.rawDataType=handles.toolbox.bathymetry.import.rawDataFormatsType{ii};        
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

try
    switch lower(handles.toolbox.bathymetry.import.rawDataFormat)
        case{'arcinfogrid'}
            wb = waitbox('Reading data file ...');
            [ncols,nrows,x0,y0,cellsz]=readArcInfo(handles.toolbox.bathymetry.import.dataFile,'info');
            dx=cellsz;
            dy=cellsz;
        case{'arcbinarygrid'}
            wb = waitbox('Reading data file ...');
            [x,y,z,m] = arc_info_binary([fileparts(handles.toolbox.bathymetry.import.dataFile) filesep]);
            x0=m.X(1);
            y0=m.Y(end);
            dx=x(2)-x(1);
            dy=y(2)-y(1);
            clear x y z
        case{'matfile'}
            wb = waitbox('Reading data file ...');
            s=load(handles.toolbox.bathymetry.import.dataFile);
            x0=s.x(1);
            y0=s.y(1);
            dx=s.x(2)-s.x(1);
            dy=s.y(2)-s.y(1);
        case{'netcdf'}
            wb = waitbox('Reading data file ...');
%            x=nc_varget(handles.toolbox.bathymetry.import.dataFile,'x');
%            y=nc_varget(handles.toolbox.bathymetry.import.dataFile,'y');
            x=nc_varget(handles.toolbox.bathymetry.import.dataFile,'lon');
            y=nc_varget(handles.toolbox.bathymetry.import.dataFile,'lat');
%             x=nc_varget(handles.toolbox.bathymetry.import.dataFile,'COLUMNS');
%             y=nc_varget(handles.toolbox.bathymetry.import.dataFile,'LINES');
            x0=x(1);
            y0=y(1);
            dx=x(2)-x(1);
            dy=y(2)-y(1);
        case{'adcircgrid'}
            % unstructured data
            % Read metadata
            wb_h = waitbar(0,'Reading the adcirc data');
            [x,y,z,n1,n2,n3]=import_adcirc_fort14(handles.toolbox.bathymetry.import.dataFile,wb_h,[0,1/6]);
            close(wb_h);
            x0=min(x);
            y0=min(y);
            x1=max(x);
            y1=max(y);
            % Compute average distance of xyz points
            dataarea=(x1-x0)*(y1-y0);
            dx=sqrt(dataarea/length(x));
            dy=dx;
        case{'xyzregular'}
            wb = waitbox('Reading data file ...');
            [xg,yg,zg]=xyz2regulargrid(handles.toolbox.bathymetry.import.dataFile);
            x0=min(xg);
            y0=min(yg);
            dx=xg(2)-xg(1);
            dy=yg(2)-yg(1);
        case{'geotiff'}
            wb = waitbox('Reading data file ...');
%            [A,x,y,I] = ddb_geoimread(handles.toolbox.bathymetry.import.dataFile,'info');
            [A,x,y,I] = geoimread(handles.toolbox.bathymetry.import.dataFile,'info');
            x0=min(x);
            y0=min(y);
            dx=abs(x(2)-x(1));
            dy=abs(y(2)-y(1));
    end
    try
        close(wb);
    end
    try
        close(wb_h);
    end
catch
    ddb_giveWarning('error','An error occured while reading the data file! See command window for details.');
    try
        close(wb);
    end
    try
        close(wb_h);
    end
    return
end

% Determine default values for this dataset
handles.toolbox.bathymetry.import.x0=x0;
handles.toolbox.bathymetry.import.y0=y0;
handles.toolbox.bathymetry.import.dx=dx;
handles.toolbox.bathymetry.import.dy=dy;

setHandles(handles);

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',handles.toolbox.bathymetry.import.EPSGname,'type','both','defaulttype',handles.toolbox.bathymetry.import.EPSGtype);

if ok
    handles.toolbox.bathymetry.import.EPSGname=cs;
    handles.toolbox.bathymetry.import.EPSGtype=type;
    handles.toolbox.bathymetry.import.EPSGcode=nr;
    
    switch lower(handles.toolbox.bathymetry.import.EPSGtype)
        case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
            handles.toolbox.bathymetry.import.radioGeo=1;
            handles.toolbox.bathymetry.import.radioProj=0;
        otherwise
            handles.toolbox.bathymetry.import.radioGeo=0;
            handles.toolbox.bathymetry.import.radioProj=1;
    end
    setHandles(handles);

end

%%
function editAttributes
handles=getHandles;
attr=handles.toolbox.bathymetry.import.attributes;
attr=ddb_editTilingAttributes(attr);
handles.toolbox.bathymetry.import.attributes=attr;
setHandles(handles);

%%
function generateTiles

handles=getHandles;

OPT.EPSGcode                     = handles.toolbox.bathymetry.import.EPSGcode;
OPT.EPSGname                     = handles.toolbox.bathymetry.import.EPSGname;
OPT.EPSGtype                     = handles.toolbox.bathymetry.import.EPSGtype;
OPT.VertCoordName                = handles.toolbox.bathymetry.import.vertCoordName;
OPT.VertCoordLevel               = handles.toolbox.bathymetry.import.vertCoordLevel;
OPT.VertUnits                    = handles.toolbox.bathymetry.import.vertUnits;
OPT.nc_library                   = handles.toolbox.bathymetry.import.nc_library;
OPT.tp                           = handles.toolbox.bathymetry.import.type;
OPT.positiveup                   = handles.toolbox.bathymetry.import.positiveUp;

f=fieldnames(handles.toolbox.bathymetry.import.attributes);

for i=1:length(f);
    OPT.(f{i})=handles.toolbox.bathymetry.import.attributes.(f{i});
end

fname=handles.toolbox.bathymetry.import.dataFile;
dr=[handles.toolbox.bathymetry.import.dataDir filesep handles.toolbox.bathymetry.import.dataName filesep];
dataname=deblank(handles.toolbox.bathymetry.import.dataName);
datasource=deblank(handles.toolbox.bathymetry.import.datasource);
dataformat=handles.toolbox.bathymetry.import.rawDataFormat;
datatype=handles.toolbox.bathymetry.import.rawDataType;
%nrzoom=handles.toolbox.bathymetry.import.nrZoom;
nx=handles.toolbox.bathymetry.import.nx;
ny=handles.toolbox.bathymetry.import.ny;
x0=handles.toolbox.bathymetry.import.x0;
y0=handles.toolbox.bathymetry.import.y0;
dx=handles.toolbox.bathymetry.import.dx;
dy=handles.toolbox.bathymetry.import.dy;

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
if strcmpi(handles.toolbox.bathymetry.import.attributes.title,'Name of data set')
    ddb_giveWarning('text','Please enter proper title of dataset in attributes.');
    return;
end
if ~isempty(strmatch(lower(dataname),lower(handles.bathymetry.datasets),'exact'))
    ddb_giveWarning('text','A dataset with this name already exists. Please remove that one first or change the name of the dataset.');
    return;
end
if ~isempty(strmatch(handles.toolbox.bathymetry.import.attributes.title,handles.bathymetry.longNames,'exact'))
    ddb_giveWarning('text','A dataset with this title already exists. Please change the title in attributes.');
    return;
end

zrange=[handles.toolbox.bathymetry.import.minElevation handles.toolbox.bathymetry.import.maxElevation];

switch lower(handles.toolbox.bathymetry.import.vertUnits)
    case{'m'}
    case{'cm'}
        zrange=zrange/0.01;
    case{'mm'}
        zrange=zrange/0.001;
    case{'ft'}
        zrange=zrange/0.3048;
end


multiple_files=0;
[pathstr,name,ext] = fileparts(fname);
if multiple_files
    if ~isempty(pathstr)
        flist=dir([pathstr filesep '*' ext]);
    else
        flist=dir(['*' ext]);
    end
    fname=[];
    for ii=1:length(flist)
        fname{ii}=[pathstr filesep flist(ii).name];
    end
end
ddb_makeBathymetryTiles(fname,dr,dataname,dataformat,datatype,nx,ny,x0,y0,dx,dy,zrange,OPT);

% Now add data to data xml
fname = [handles.bathymetry.dir 'bathymetry.xml'];
xmldata = xml2struct(fname);
nd=length(xmldata.dataset)+1;
xmldata.dataset(nd).dataset.name=dataname;
xmldata.dataset(nd).dataset.longName=handles.toolbox.bathymetry.import.attributes.title;
xmldata.dataset(nd).dataset.version='1';
xmldata.dataset(nd).dataset.type='netCDFtiles';
xmldata.dataset(nd).dataset.edit='0';
xmldata.dataset(nd).dataset.URL=[handles.toolbox.bathymetry.import.dataDir handles.toolbox.bathymetry.import.dataName];
xmldata.dataset(nd).dataset.useCache='1';
xmldata.dataset(nd).dataset.source=datasource;
struct2xml(fname,xmldata,'structuretype','short');

% Find all bathymetries again
handles.bathymetry=ddb_findBathymetryDatabases(handles.bathymetry);

% Select dataset that was just created
handles.screenParameters.backgroundBathymetry=dataname;
set(handles.GUIHandles.textBathymetry,'String',['Bathymetry : ' handles.bathymetry.longNames{nd} '   -   Datum : ' handles.bathymetry.dataset(nd).verticalCoordinateSystem.name]);

% And finally add it to the menu
ddb_updateBathymetryMenu(handles);

setHandles(handles);

ddb_updateDataInScreen;
