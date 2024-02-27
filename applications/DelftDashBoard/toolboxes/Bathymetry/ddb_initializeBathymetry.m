function handles = ddb_initializeBathymetry(handles, varargin)
%DDB_INITIALIZEBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeBathymetry(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeBathymetry
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles.toolbox.bathymetry.activeDataset=1;
handles.toolbox.bathymetry.polyLength=0;
handles.toolbox.bathymetry.polygonFile='';

handles.toolbox.bathymetry.bathyFile='';
handles.toolbox.bathymetry.newbathyName='';
handles.toolbox.bathymetry.newbathyresolution=0;

handles.toolbox.bathymetry.activeZoomLevel=1;
handles.toolbox.bathymetry.zoomLevelText={'1'};
handles.toolbox.bathymetry.resolutionText='1';

handles.toolbox.bathymetry.exportTypes={'xyz'};
handles.toolbox.bathymetry.activeExportType='xyz';

handles.toolbox.bathymetry.activeDirection='up';

handles.toolbox.bathymetry.datum_type='Mean Sea Level';
handles.toolbox.bathymetry.offset_value=0;

handles.toolbox.bathymetry.usedDataset=[];
handles.toolbox.bathymetry.usedDatasets={''};
handles.toolbox.bathymetry.nrUsedDatasets=0;
handles.toolbox.bathymetry.activeUsedDataset=1;

handles.toolbox.bathymetry.newDataset.xmin=0;
handles.toolbox.bathymetry.newDataset.xmax=0;
handles.toolbox.bathymetry.newDataset.dx=0;
handles.toolbox.bathymetry.newDataset.ymin=0;
handles.toolbox.bathymetry.newDataset.ymax=0;
handles.toolbox.bathymetry.newDataset.dy=0;

handles.toolbox.bathymetry.num_merge = 0;
handles.toolbox.bathymetry.add_list = {};
handles.toolbox.bathymetry.bathy_to_cut = 1;
handles.toolbox.bathymetry.add_list_idx = [];

handles.toolbox.bathymetry.rectanglehandle=[];
handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectanglex0=[];
handles.toolbox.bathymetry.rectangledx=[];
handles.toolbox.bathymetry.rectangledy=[];

%% Import

handles.toolbox.bathymetry.import.x0=0;
handles.toolbox.bathymetry.import.y0=0;
handles.toolbox.bathymetry.import.nx=300;
handles.toolbox.bathymetry.import.ny=300;
handles.toolbox.bathymetry.import.dx=0;
handles.toolbox.bathymetry.import.dy=0;
handles.toolbox.bathymetry.import.nrZoom=5;
handles.toolbox.bathymetry.import.maxElevation=15000;
handles.toolbox.bathymetry.import.minElevation=-15000;

handles.toolbox.bathymetry.import.dataFile='';
handles.toolbox.bathymetry.import.dataName='';
handles.toolbox.bathymetry.import.datasource='';
handles.toolbox.bathymetry.import.dataDir=[handles.bathymetry.dir];

% Raw data formats
handles.toolbox.bathymetry.import.rawDataFormats{1}='arcinfogrid';
handles.toolbox.bathymetry.import.rawDataFormatsText{1}='ArcInfo ASCII grid';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{1}='*.asc';
handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{1}='regulargrid';        

handles.toolbox.bathymetry.import.rawDataFormats{2}='arcbinarygrid';
handles.toolbox.bathymetry.import.rawDataFormatsText{2}='Arc Binary Grid';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{2}='*.adf';
handles.toolbox.bathymetry.import.rawDataFormatsType{2}='regulargrid';        

handles.toolbox.bathymetry.import.rawDataFormats{3}='matfile';
handles.toolbox.bathymetry.import.rawDataFormatsText{3}='Mat File';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{3}='*.mat';
handles.toolbox.bathymetry.import.rawDataFormatsType{3}='regulargrid';        

handles.toolbox.bathymetry.import.rawDataFormats{4}='netcdf';
handles.toolbox.bathymetry.import.rawDataFormatsText{4}='netCDF File';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{4}='*.nc';
handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{4}='regulargrid';        

handles.toolbox.bathymetry.import.rawDataFormats{5}='adcircgrid';
handles.toolbox.bathymetry.import.rawDataFormatsText{5}='ADCIRC grid';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{5}='*.grd';
handles.toolbox.bathymetry.import.rawDataFormatsType{5}='unstructured';        

handles.toolbox.bathymetry.import.rawDataFormats{6}='xyzregular';
handles.toolbox.bathymetry.import.rawDataFormatsText{6}='XYZ (regular grid)';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{6}='*.xyz';
handles.toolbox.bathymetry.import.rawDataFormatsType{6}='structured';        

handles.toolbox.bathymetry.import.rawDataFormats{7}='geotiff';
handles.toolbox.bathymetry.import.rawDataFormatsText{7}='GeoTIFF';
handles.toolbox.bathymetry.import.rawDataFormatsExtension{7}='*.tif';
handles.toolbox.bathymetry.import.rawDataFormatsType{7}='structured';        

handles.toolbox.bathymetry.import.rawDataFormat=handles.toolbox.bathymetry.import.rawDataFormats{1};
handles.toolbox.bathymetry.import.rawDataFormatExtension=handles.toolbox.bathymetry.import.rawDataFormatsExtension{1};
handles.toolbox.bathymetry.import.rawDataFormatSelectionText=['Select Data File (' handles.toolbox.bathymetry.import.rawDataFormatsText{1} ')'];
handles.toolbox.bathymetry.import.rawDataType=handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{1};

handles.toolbox.bathymetry.import.EPSGcode                     = 4326;
handles.toolbox.bathymetry.import.EPSGname                     = 'WGS 84';
handles.toolbox.bathymetry.import.EPSGtype                     = 'geographic';
handles.toolbox.bathymetry.import.vertCoordName                = 'MSL';
handles.toolbox.bathymetry.import.vertCoordLevel               = 0.0;
handles.toolbox.bathymetry.import.vertUnits                    = 'm';
handles.toolbox.bathymetry.import.nc_library                   = 'matlab';
handles.toolbox.bathymetry.import.type                         = 'float';
handles.toolbox.bathymetry.import.positiveUp                   = 1;

handles.toolbox.bathymetry.import.radioGeo                     = 1;
handles.toolbox.bathymetry.import.radioProj                    = 0;

handles.toolbox.bathymetry.import.attributes.conventions                  = 'CF-1.4';
handles.toolbox.bathymetry.import.attributes.CF_featureType               = 'grid';
handles.toolbox.bathymetry.import.attributes.title                        = 'Name of data set';
handles.toolbox.bathymetry.import.attributes.institution                  = 'Institution';
handles.toolbox.bathymetry.import.attributes.source                       = 'Source';
handles.toolbox.bathymetry.import.attributes.history                      = 'created by : ';
handles.toolbox.bathymetry.import.attributes.references                   = 'No reference material available';
handles.toolbox.bathymetry.import.attributes.comment                      = 'none';
handles.toolbox.bathymetry.import.attributes.email                        = 'Your email here';
handles.toolbox.bathymetry.import.attributes.version                      = '1.0';
handles.toolbox.bathymetry.import.attributes.terms_for_use                = 'Use as you like';
handles.toolbox.bathymetry.import.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.toolbox.bathymetry.shoreline.x0=0;
handles.toolbox.bathymetry.shoreline.y0=0;

handles.toolbox.bathymetry.shoreline.nrCellsX=0;
handles.toolbox.bathymetry.shoreline.nrCellsY=0;

handles.toolbox.bathymetry.shoreline.dataFile='';
handles.toolbox.bathymetry.shoreline.dataName='';
handles.toolbox.bathymetry.shoreline.dataDir=[handles.bathymetry.dir];

handles.toolbox.bathymetry.shoreline.EPSGcode                     = 4326;
handles.toolbox.bathymetry.shoreline.EPSGname                     = 'WGS 84';
handles.toolbox.bathymetry.shoreline.EPSGtype                     = 'geographic';
handles.toolbox.bathymetry.shoreline.conventions                  = 'CF-1.4';
handles.toolbox.bathymetry.shoreline.CF_featureType               = 'polyline';
handles.toolbox.bathymetry.shoreline.title                        = 'Name of data set';
handles.toolbox.bathymetry.shoreline.institution                  = 'Institution';
handles.toolbox.bathymetry.shoreline.source                       = 'Source';
handles.toolbox.bathymetry.shoreline.history                      = 'created by';
handles.toolbox.bathymetry.shoreline.references                   = 'No reference material available';
handles.toolbox.bathymetry.shoreline.comment                      = 'Comments';
handles.toolbox.bathymetry.shoreline.email                        = 'Your email here';
handles.toolbox.bathymetry.shoreline.version                      = '1.0';
handles.toolbox.bathymetry.shoreline.terms_for_use                = 'Use as you like';
handles.toolbox.bathymetry.shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.toolbox.bathymetry.shoreline.nc_library                   = 'matlab';
handles.toolbox.bathymetry.shoreline.type                         = 'float';

%% Edit

handles.toolbox.bathymetry.edit.samplesfile='';
handles.toolbox.bathymetry.edit.nrsamples=0;
handles.toolbox.bathymetry.edit.samples.x=[];
handles.toolbox.bathymetry.edit.samples.y=[];
handles.toolbox.bathymetry.edit.samples.z=[];

handles.toolbox.bathymetry.edit.uniform_value=0;

handles.toolbox.bathymetry.edit.nrpolygons=0;
handles.toolbox.bathymetry.edit.polygonnames={''};
handles.toolbox.bathymetry.edit.activepolygon=1;
handles.toolbox.bathymetry.edit.polygon(1).length=0;
handles.toolbox.bathymetry.edit.polygon(1).x=[];
handles.toolbox.bathymetry.edit.polygon(1).y=[];
handles.toolbox.bathymetry.edit.polygon(1).handle=[];
handles.toolbox.bathymetry.edit.polygonfile='';

handles.toolbox.bathymetry.edit.depth_change_option_strings{1}='z = uniform value (only missing points)';
handles.toolbox.bathymetry.edit.depth_change_option_strings{2}='z = uniform value (all points)';
handles.toolbox.bathymetry.edit.depth_change_option_strings{3}='z = max(z, uniform value)';
handles.toolbox.bathymetry.edit.depth_change_option_strings{4}='z = min(z, uniform value)';
handles.toolbox.bathymetry.edit.depth_change_option_strings{5}='z = z + uniform value';
handles.toolbox.bathymetry.edit.depth_change_option_strings{6}='z = z * uniform value';
handles.toolbox.bathymetry.edit.depth_change_option_strings{7}='z = NaN';

handles.toolbox.bathymetry.edit.depth_change_options{1}='unif-missing';
handles.toolbox.bathymetry.edit.depth_change_options{2}='unif-all';
handles.toolbox.bathymetry.edit.depth_change_options{3}='max';
handles.toolbox.bathymetry.edit.depth_change_options{4}='min';
handles.toolbox.bathymetry.edit.depth_change_options{5}='plus';
handles.toolbox.bathymetry.edit.depth_change_options{6}='times';
handles.toolbox.bathymetry.edit.depth_change_options{7}='nan';

handles.toolbox.bathymetry.edit.depth_change_option='unif-missing';

