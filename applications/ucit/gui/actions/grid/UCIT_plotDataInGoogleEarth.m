function UCIT_plotDataInGoogleEarth
%UCIT_PLOTDATAINGOOGLEEARTH  plots data of selected polygon in Google Earth
%
%       UCIT_plotDataInGoogleEarth
%
%   Input in UCIT GUI
%
%
%   Output:
%       temporary KML-file
%
%   Example:
%
%
%
% See also: grid_2D_orthogonal, grid_2D_orthogonal

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

warningstate = warning;
warning off

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Select in grid overview plot

mapW = findobj('tag','gridPlot');
if isempty(mapW)
    if isempty(findobj('tag','gridOverview')) %|| ~any(ismember(get(axes, 'tag'), {datatype}))
        fh = UCIT_plotGridOverview(datatype,'refreshonly',0);
    else
        fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
    end
else
    fhs = findobj('tag','gridPlot');
    fh = figure(fhs(1)); figure(fh);
end

d    = UCIT_getMetaData(2);

%% get data from right netcdf files

[X, Y, Z, Ztime] = grid_orth_getDataInPolygon(...
    'dataset'       , d.catalog, ...
    'urls'          , d.urls, ...
    'x_ranges'      , d.x_ranges, ...
    'y_ranges'      , d.y_ranges, ...
    'tag'           , datatype, ...
    'starttime'     ,        datenum(UCIT_getInfoFromPopup('GridsName'), 'yyyy-mm-dd'), ...
    'searchinterval', -365/12*str2double(UCIT_getInfoFromPopup('GridsInterval')), ...
    'datathinning'  ,     str2double(UCIT_getInfoFromPopup('GridsSoundingID')),...
    'cellsize'      , d.cellsize,...
    'plotresult'    ,0);


%% workaround
Ztime(Z>1e10) = nan;
Z    (Z>1e10) = nan;

%% plot results
if ~all(all(isnan(Z)))

   %% Make kml file
   filename = gettmpfilename(getenv('TEMP'),'grid','.kml');% plot results
   
   %% Thin out if needed
   matrix_size = round(size(X,1)*size(X,2));
    if matrix_size > 20000
       thinning = max(1,round(matrix_size / 600000));
    else 
       thinning = 1;
    end
    
   %% Convert coordinates
   
   if ~all(isnan(Z(:)))
       [lat,lon] = convertCoordinates(X(1:thinning:end,1:thinning:end),Y(1:thinning:end,1:thinning:end),'CS1.name','Amersfoort / RD New','CS2.code',4326);
       KMLsurf(lon,lat,Z(1:thinning:end,1:thinning:end),'fileName',[filename '.kml'],...
        'zScaleFun',@(z)(z+50)*4,...
         'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),...
       'colorSteps',200,...
             'cLim',[-50 25],...
          'kmlName',mktex(mfilename));
   else
       warndlg('No data found for these search criteria');
   end
   
   %% Run kml file in Google Earth
   eval(['!', filename '.kml']);

   disp(['Saved Google Earth file as ',filename])

end

warning(warningstate)

%% EOF



