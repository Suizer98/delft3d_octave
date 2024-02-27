function varargout = nc_SetOptions(varargin)
%UNTITLED  One line description goes here.
%
%   This function can be used to collect input settings for the creation of
%   netcdf files and for the KML functions.
%
%
%   See also, nc_multibeam_from_xyz(varargin), nc_multibeam_to_kml_tiled_png(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Boskalis
%      
%      Kees Willem Pruis
%
%      k.w.pruis@boskalis.nl
%
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
% Created: 20 Feb 2012
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id: nc_SetOptions_example.m 7052 2012-07-27 12:44:44Z boer_g $
% $Date: 2012-07-27 20:44:44 +0800 (Fri, 27 Jul 2012) $
% $Author: boer_g $
% $Revision: 7052 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nc_processing/nc_multibeam/nc_SetOptions_example.m $
% $Keywords: $

%%
%% NetCDF
% metadata
% information below 
OPT.nc.title               = '__';
OPT.nc.Conventions         = 'CF-1.4';
OPT.nc.CF_featureType      = 'grid';
OPT.nc.institution         = 'Boskalis';
OPT.nc.source              = 'Topography measured with quad, jetski and survey vessel';
OPT.nc.history             = '';
OPT.nc.references          = 'No reference material available';
OPT.nc.comment             = 'Data surveyed by survey department for the project Sand Engine';
OPT.nc.email               = 'k.w.pruis@boskalis.nl';
OPT.nc.version             = 'Trial';
OPT.nc.terms_for_use       = 'These data is for internal use by Boskalis staff only!';
OPT.nc.disclaimer          = ['These data are made available in the hope that it will be ',...
    'useful, but WITHOUT ANY WARRANTY; without even the implied',...
    'warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.'];

% default directory properties
OPT.nc.basepath_network    = '';
OPT.nc.basepath_local      = '../SandEngine_nc';
OPT.nc.basepath_opendap    = '';
OPT.nc.raw_path            = '../rawdata';
OPT.nc.raw_extension       = '*.xyz';
OPT.nc.nr_fname            = '';                        % if not all rawdata files in directory needs to be transformed fill in the number of the file in the directory list which do need to be transformed.
OPT.nc.netcdf_path         = 'netcdf';
OPT.nc.cache_path          = fullfile(tempdir,'nc_asc');

% NetCDF settings
OPT.nc.netcdfversion       = 3;
OPT.nc.block_size          = 5e6;
OPT.nc.make                = true;
OPT.nc.copy2server         = false;
OPT.nc.EPSGcode            = 28992;
OPT.nc.mapsizex            = 2500;      % size of fixed map in x-direction
OPT.nc.gridsizex           = 2.5;       % x grid resolution
OPT.nc.mapsizey            = 2500;      % size of fixed map in y-direction
OPT.nc.gridsizey           = 2.5;       % y grid resolution
OPT.nc.xoffset             = 1.25;      % zero point of x grid
OPT.nc.yoffset             = 1.25;      % zero point of y grid
OPT.nc.zfactor              = 1;         % scale z by this facto

%% NC SETTINGS, ADJUST AS NEEDED ------------------------------------------------------------------------------------------
OPT.nc.zip                 = false;
OPT.nc.zip_extension       = '*.7z';
OPT.nc.dateFcn             = @(s)datenum(s(17:22),'yymmdd');%@(s) datenum(monthstr_mmm_dutch2eng(s(1:8)),'yyyy-mmm'); % how to extract the date from the filename
OPT.nc.gridFcn             = @(X,Y,Z,XI,YI) griddata_remap(X,Y,Z,XI,YI,'errorCheck',false);
OPT.nc.format              = '%f%f%f';
OPT.nc.delimiter           = ',';
OPT.nc.headerlines         = 0;
OPT.nc.xid                 = 1;
OPT.nc.yid                 = 2;
OPT.nc.zid                 = 3;
OPT.nc.MultipleDelimsAsOne = false;
OPT.nc.datatype            = 'multibeam';


%% kml settings
% directory settings
OPT.kml.make                    = false;
OPT.kml.make_kmz                = false;    % this packs the entire file tree to a sing kmz file, convenient for portability
OPT.kml.copy2server             = false;
OPT.kml.basepath_local          = '_kml';
OPT.kml.basepath_network        = '';
OPT.kml.basepath_www            = '';
OPT.kml.ncpath                  = fullfile(OPT.nc.basepath_local,OPT.nc.netcdf_path);
OPT.kml.ncfile                  = '*.nc';
OPT.kml.relativepath            = OPT.nc. netcdf_path;
OPT.kml.serverURL               = [];       % if a KML file is intended to be placed on the server, the path must be hardcoded in the KML file
OPT.kml.var_name                = 'z';
OPT.kml.referencepath           = [];       % is provided, nc files with are expected here that define a reference plane which is to be subtracted from the data before plotting

% settings
OPT.kml.highestLevel            = 10;
OPT.kml.lowestLevel             = 15;       % integer; Detail level of the highest resultion png tiles to generate. Advised range 12 to 18;
                                            % dimension of individual pixels in Lat and Lon can be calculated as follows:
                                            % 360/(2^OPT.lowestLevel) / OPT.tiledim
                                            % Note that the lowest level should be 22 or lower.
OPT.kml.tiledim                 = 256;      % dimension of tiles in pixels.
OPT.kml.ncfile                  = '*.nc';
OPT.kml.descriptivename         = '_bathymetry';
OPT.kml.CBcolorTitle            = 'Depth in meters';
OPT.kml.description             = OPT.nc. history;
OPT.kml.clim                    = [-50 25]; % limits of color scale
OPT.kml.colorMap                = @(m)colormap_cpt('bathymetry_vaklodingen',m);
OPT.kml.colorSteps              = 500;
OPT.kml.colorbar                = true;
OPT.kml.filledInTime            = false;    % this makes tiles appear in GE for every date until there is a newer tile. If set to off, tiles are only shown on the date they have
OPT.kml.lightAdjust             = [];       % if set to true, the shading/lighting of the figure is scaled to be independant of OPT.lowestLevel.
OPT.kml.quiet                   = true;     % suppress some progress information
OPT.kml.calculate_latlon_local  = false;    % use if x and y data are provided to be converted to lat and lon
OPT.kml.EPSGcode                = OPT.nc.EPSGcode;       % code of coordinate system to convert x and y projection to Lat and Lon
% OPT.kml.dateFcn                 = @(time) (time); % use nc_cf_time so it works with any units
OPT.kml.stride                  = 1;

% add colorbar defualt options
OPT.kml                         = mergestructs(OPT.kml,KMLcolorbar);

OPT = setpropertyInDeeperStruct(OPT,varargin{:});
varargout = {OPT};
end