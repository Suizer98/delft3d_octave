function handles = ddb_initializeTiling(handles, varargin)
%DDB_INITIALIZETILING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTiling(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTiling
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

% $Id: ddb_initializeTiling.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-25 06:26:17 +0800 (Tue, 25 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/ddb_initializeTiling.m $
% $Keywords: $

%% Tiling

handles.toolbox.tiling.import.x0=0;
handles.toolbox.tiling.import.y0=0;
handles.toolbox.tiling.import.nx=300;
handles.toolbox.tiling.import.ny=300;
handles.toolbox.tiling.import.dx=0;
handles.toolbox.tiling.import.dy=0;
handles.toolbox.tiling.import.nrZoom=5;

handles.toolbox.tiling.import.dataFile='';
handles.toolbox.tiling.import.dataName='';
handles.toolbox.tiling.import.datasource='';
handles.toolbox.tiling.import.dataDir=[handles.bathymetry.dir];

% Raw data formats
handles.toolbox.tiling.import.rawDataFormats{1}='arcinfogrid';
handles.toolbox.tiling.import.rawDataFormatsText{1}='ArcInfo ASCII grid';
handles.toolbox.tiling.import.rawDataFormatsExtension{1}='*.asc';
handles.toolbox.tiling.bathymetry.rawDataFormatsType{1}='regulargrid';        

handles.toolbox.tiling.import.rawDataFormats{2}='arcbinarygrid';
handles.toolbox.tiling.import.rawDataFormatsText{2}='Arc Binary Grid';
handles.toolbox.tiling.import.rawDataFormatsExtension{2}='*.adf';
handles.toolbox.tiling.import.rawDataFormatsType{2}='regulargrid';        

handles.toolbox.tiling.import.rawDataFormats{3}='matfile';
handles.toolbox.tiling.import.rawDataFormatsText{3}='Mat File';
handles.toolbox.tiling.import.rawDataFormatsExtension{3}='*.mat';
handles.toolbox.tiling.import.rawDataFormatsType{3}='regulargrid';        

handles.toolbox.tiling.import.rawDataFormats{4}='netcdf';
handles.toolbox.tiling.import.rawDataFormatsText{4}='netCDF File';
handles.toolbox.tiling.import.rawDataFormatsExtension{4}='*.nc';
handles.toolbox.tiling.bathymetry.rawDataFormatsType{4}='regulargrid';        

handles.toolbox.tiling.import.rawDataFormats{5}='adcircgrid';
handles.toolbox.tiling.import.rawDataFormatsText{5}='ADCIRC grid';
handles.toolbox.tiling.import.rawDataFormatsExtension{5}='*.grd';
handles.toolbox.tiling.import.rawDataFormatsType{5}='unstructured';        

% handles.toolbox.tiling.import.rawDataFormats{6}='xyz';
% handles.toolbox.tiling.import.rawDataFormatsText{6}='XYZ File';
% handles.toolbox.tiling.import.rawDataFormatsExtension{6}='*.xyz';
% handles.toolbox.tiling.import.rawDataFormatsType{6}='unstructured';        

handles.toolbox.tiling.import.rawDataFormat=handles.toolbox.tiling.import.rawDataFormats{1};
handles.toolbox.tiling.import.rawDataFormatExtension=handles.toolbox.tiling.import.rawDataFormatsExtension{1};
handles.toolbox.tiling.import.rawDataFormatSelectionText=['Select Data File (' handles.toolbox.tiling.import.rawDataFormatsText{1} ')'];
handles.toolbox.tiling.import.rawDataType=handles.toolbox.tiling.bathymetry.rawDataFormatsType{1};

handles.toolbox.tiling.import.EPSGcode                     = 4326;
handles.toolbox.tiling.import.EPSGname                     = 'WGS 84';
handles.toolbox.tiling.import.EPSGtype                     = 'geographic';
handles.toolbox.tiling.import.vertCoordName                = 'MSL';
handles.toolbox.tiling.import.vertCoordLevel               = 0.0;
handles.toolbox.tiling.import.vertUnits                    = 'm';
handles.toolbox.tiling.import.nc_library                   = 'matlab';
handles.toolbox.tiling.import.type                         = 'float';
handles.toolbox.tiling.import.positiveUp                   = 1;

handles.toolbox.tiling.import.radioGeo                     = 1;
handles.toolbox.tiling.import.radioProj                    = 0;

handles.toolbox.tiling.import.attributes.conventions                  = 'CF-1.4';
handles.toolbox.tiling.import.attributes.CF_featureType               = 'grid';
handles.toolbox.tiling.import.attributes.title                        = 'Name of data set';
handles.toolbox.tiling.import.attributes.institution                  = 'Institution';
handles.toolbox.tiling.import.attributes.source                       = 'Source';
handles.toolbox.tiling.import.attributes.history                      = 'created by : ';
handles.toolbox.tiling.import.attributes.references                   = 'No reference material available';
handles.toolbox.tiling.import.attributes.comment                      = 'none';
handles.toolbox.tiling.import.attributes.email                        = 'Your email here';
handles.toolbox.tiling.import.attributes.version                      = '1.0';
handles.toolbox.tiling.import.attributes.terms_for_use                = 'Use as you like';
handles.toolbox.tiling.import.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.toolbox.tiling.shoreline.x0=0;
handles.toolbox.tiling.shoreline.y0=0;

handles.toolbox.tiling.shoreline.nrCellsX=0;
handles.toolbox.tiling.shoreline.nrCellsY=0;

handles.toolbox.tiling.shoreline.dataFile='';
handles.toolbox.tiling.shoreline.dataName='';
handles.toolbox.tiling.shoreline.dataDir=[handles.bathymetry.dir];

handles.toolbox.tiling.shoreline.EPSGcode                     = 4326;
handles.toolbox.tiling.shoreline.EPSGname                     = 'WGS 84';
handles.toolbox.tiling.shoreline.EPSGtype                     = 'geographic';
handles.toolbox.tiling.shoreline.conventions                  = 'CF-1.4';
handles.toolbox.tiling.shoreline.CF_featureType               = 'polyline';
handles.toolbox.tiling.shoreline.title                        = 'Name of data set';
handles.toolbox.tiling.shoreline.institution                  = 'Institution';
handles.toolbox.tiling.shoreline.source                       = 'Source';
handles.toolbox.tiling.shoreline.history                      = 'created by';
handles.toolbox.tiling.shoreline.references                   = 'No reference material available';
handles.toolbox.tiling.shoreline.comment                      = 'Comments';
handles.toolbox.tiling.shoreline.email                        = 'Your email here';
handles.toolbox.tiling.shoreline.version                      = '1.0';
handles.toolbox.tiling.shoreline.terms_for_use                = 'Use as you like';
handles.toolbox.tiling.shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.toolbox.tiling.shoreline.nc_library                   = 'matlab';
handles.toolbox.tiling.shoreline.type                         = 'float';
