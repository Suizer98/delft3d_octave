function [datatypes] = UCIT_getDatatypes;
%UCIT_GETDATATYPES  gets urls of selected datatypes in UCIT
%
%      [datatypes] = UCIT_getDatatypes()
%
%   returns a cellstr with the base paths/OPeNDAP urls or netCDF files of 
%   each of the four UCIT datatypes (transects, grids, lines, points)
%
%   Input: none
%   
%
%   Output: structure with datatypes
%   
%
%   Example: [datatypes] = UCIT_getDatatypes
%
%   See here how to get a local data cache: http://publicwiki.deltares.nl/display/OET/OPeNDAP+caching+on+a+local+machine
%
%   See also: UCIT_getMetaData, UCIT_plotLandboundary 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
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

% TO DO: save as datatypes.transect(i).names instead of datatypes.transect.names{i}
% add data type

%% Transect data
%  names are a unique tag, datatype governs the actions

   i = 0;

   %% Jarkus

   i = i + 1;
   datatypes.transect.names  {i}  =  'Jarkus Data';
   datatypes.transect.urls   {i}  =  'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';
   datatypes.transect.areas  {i}  =  ''; % set by UCIT_loadRelevantInfo2Popup(1,2)
   datatypes.transect.catalog{i}  =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/profiles/catalog.xml';
   datatypes.transect.ldbs{i}     =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.transect.axes{i}     =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.transect.datatype{i} =  'Jarkus Data'; % defines functionality

   %% Jarkus (test)

   i = i + 1;
   datatypes.transect.names  {i}  =  'Jarkus Data (test/next release)';
   datatypes.transect.urls   {i}  =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';
   datatypes.transect.areas  {i}  =  ''; % set by UCIT_loadRelevantInfo2Popup(1,2)
   datatypes.transect.catalog{i}  =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/jarkus/profiles/catalog.xml';
   datatypes.transect.ldbs{i}     =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
   datatypes.transect.axes{i}     =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.transect.datatype{i} =  'Jarkus Data'; % defines functionality
   
   %% Jarkus (local)
if 0 % set this to 1 to activate the local cache, and download it with OPENDAP_GET_CACHE
   i = i + 1;
   datatypes.transect.names  {i}  =  'Jarkus Data (local)';
   datatypes.transect.urls   {i}  =  '';
   datatypes.transect.areas  {i}  =  ''; % set by UCIT_loadRelevantInfo2Popup(1,2)
   datatypes.transect.catalog{i}  =  '';
   datatypes.transect.ldbs{i}     =  '';
   datatypes.transect.axes{i}     =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.transect.datatype{i} =  'Jarkus Data'; % defines functionality
end

   %% Lidar USA
if 0 % link to Netcdf file is not working anymore
   i = i + 1;
   datatypes.transect.names{i}    =  'Lidar Data US';
   datatypes.transect.urls {i}    = {'http://gam.whoi.edu:8081/thredds/dodsC/usgs/afarris/oregon_7.nc',...
                                     'http://gam.whoi.edu:8081/thredds/dodsC/usgs/afarris/washington_1.nc'};
   datatypes.transect.areas{i}    = {'Oregon',...
                                     'Washington'};
   datatypes.transect.catalog{i}  =  'http://gam.whoi.edu:8081/thredds/dodsC/usgs/afarris/catalog.xml';
   datatypes.transect.ldbs{i}     = {'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/usgs/landboundaries/OR_fillable.nc',...
                                     'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/usgs/landboundaries/WA_fillable.nc'};
   datatypes.transect.axes{i}     =  {1E6*[0.3382    0.4796    4.6537    5.1275], ...
                                      1E6*[0.36716 0.446396 5.12516 5.370968]};
   datatypes.transect.extra{i}    =  {'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/usgs/landboundaries/refline_OR.nc',...
                                     ''};
   datatypes.transect.datatype{i} =  'Lidar Data US'; % defines functionality
end
%% Grid data
%  names are a unique tag, datatype governs the actions

   i = 0;

   %% Jarkus

   i = i + 1;
   datatypes.grid.names{i}        =  'Jarkus 20m';
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'Jarkus';

   %% Jarkus (test)

   i = i + 1;
   datatypes.grid.names{i}        =  'Jarkus 20m (test/next release)';
   datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids_r2014/';
   datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids_r2014/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'Jarkus';

%    %% Outer Deltas Zeeland (test)
% 
%    i = i + 1;
%    datatypes.grid.names{i}        =  'Outer Deltas Zeeland 20m (test/next release)';
%    datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/DienstZeeland/outer_deltas/';
%    datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/DienstZeeland/outer_deltas/catalog.xml';
%    datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
%    datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
%    datatypes.grid.cellsize{i}     =  20;
%    datatypes.grid.datatype{i}     =  'Zeeland';
   
   %% Vaklodingen (matlab ncgen, release 2012)

   i = i + 1;
   datatypes.grid.names{i}        =  'Vaklodingen 20m [release 2012]';
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'vaklodingen'; % for rws_*
   
   %% Vaklodingen (test, matlab ncgen, release 2012)

   i = i + 1;
   datatypes.grid.names{i}        =  'Vaklodingen 20m (test/next release r2014)';
   datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';
   datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'vaklodingen'; % for rws_*

   %% Vaklodingen (local) Texel test vaklodingenKB121_2120.nc  vaklodingenKB121_2322.nc
if 0 % set this to 1 to activate the local cache, and download it with OPENDAP_GET_CACHE
   i = i + 1;
   datatypes.grid.names{i}        =  'Vaklodingen 20m (local)';
   datatypes.grid.urls {i}        =  'd:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\kustlidar\';
   datatypes.grid.catalog{i}      =  'd:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\kustlidar\';
   datatypes.grid.ldbs{i}         =  'd:\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\';
   datatypes.grid.axes{i}         =  1E5*[ 0.9797    1.2919    5.3083    5.6847];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'vaklodingen'; % for rws_*
end   
   
%    %% Zeeland outer deltas (test, matlab ncgen, release 2013)
% 
%    i = i + 1;
%    datatypes.grid.names{i}        =  'Zeeland outer deltas 20m (test/next release r2013)';
%    datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/DienstZeeland/outer_deltas/';
%    datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/outer_deltas/catalog.xml';
%    datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
%    datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
%    datatypes.grid.cellsize{i}     =  20;
%    datatypes.grid.datatype{i}     =  'vaklodingen'; % for rws_*

   %% Kustlidar

   i = i + 1;
   datatypes.grid.names{i}        =  'AHN Kusthoogte 5m';
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  5;
   datatypes.grid.datatype{i}     =  'kustlidar'; % for rws_*
   
   %% Kustlidar (test)

   i = i + 1;
   datatypes.grid.names{i}        =  'AHN Kusthoogte 5m (test/next release 2012)';
   datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/kusthoogte/';
   datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kusthoogte/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  5;
   datatypes.grid.datatype{i}     =  'kustlidar'; % for rws_*

   %% Dienst zeeland

if 0 % Not working anymore
   i = i + 1;
   datatypes.grid.names{i}        =  'Dienst zeeland 20m';
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/DienstZeeland/';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.21 0.91 3.6 4.3];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'Zeeland';
end
      %% Dienst zeeland (test)
  
   i = i + 1;
   datatypes.grid.names{i}        =  'Dienst zeeland 20m (test/next release)';
   datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/dienstzeeland/';
   datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/dienstzeeland/catalog.html';
   datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
   datatypes.grid.axes{i}         =  1E5*[-0.21 0.91 3.6 4.3];
   datatypes.grid.cellsize{i}     =  20;
   datatypes.grid.datatype{i}     =  'Zeeland';

   %    %% Western Scheldt (Dienst zeeland) (test)
% 
%    i = i + 1;
%    datatypes.grid.names{i}        =  'Westerschelde; Dienst zeeland 20m (test/next release)';
%    datatypes.grid.urls {i}        =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/DienstZeeland/western_scheldt/';
%    datatypes.grid.catalog{i}      =  'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/western_scheldt/catalog.xml';
%    datatypes.grid.ldbs{i}         =  'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';
%    datatypes.grid.axes{i}         =  1E5*[-0.21 0.91 3.6 4.3];
%    datatypes.grid.cellsize{i}     =  20;
%    datatypes.grid.datatype{i}     =  'Zeeland';

   %% AHN100

   i = i + 1;
   datatypes.grid.names{i}        =  'AHN 100m';
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv100.nc';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl/thredds/catalog/opendap/tno/ahn100m/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  100;
   datatypes.grid.datatype{i}     =  'AHN'; % for rws_*

   %% AHN250

   i = i + 1;
   datatypes.grid.names{i}        =  'AHN 250m'; % note 250 is in 100 directory on server
   datatypes.grid.urls {i}        =  'http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv250.nc';
   datatypes.grid.catalog{i}      =  'http://opendap.deltares.nl/thredds/catalog/opendap/tno/ahn100m/catalog.xml';
   datatypes.grid.ldbs{i}         =  'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc'; % this one is broken on opendap.deltares.nl due since TDS 4.2
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  250;
   datatypes.grid.datatype{i}     =  'AHN'; % for rws_*

   %% multibeam_delfland

if 0
   i = i + 1;
   datatypes.grid.names{i}        =  'multibeam_delfland';
   datatypes.grid.urls {i}        =  'D:\checkouts\VO-rawdata\projects\154040_delflandse_kust\nc_files\multibeam\';
   datatypes.grid.catalog{i}      =  '';
   datatypes.grid.ldbs{i}         =  '';
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  nan;
   datatypes.grid.datatype{i}     =  'MB'; % for rws_*

   %% multibeam_delfland2

   i = i + 1;
   datatypes.grid.names{i}        =  'multibeam_delfland2';
   datatypes.grid.urls {i}        =  'D:\checkouts\VO-Delflandsekust\nc_files\multibeam\';
   datatypes.grid.catalog{i}      =  '';
   datatypes.grid.ldbs{i}         =  '';
   datatypes.grid.axes{i}         =  1E5*[-0.239487 2.901701 2.999500 6.787223];
   datatypes.grid.cellsize{i}     =  nan;
   datatypes.grid.datatype{i}     =  'MB'; % for rws_*
end

%% Lines data

%% Point data
   






