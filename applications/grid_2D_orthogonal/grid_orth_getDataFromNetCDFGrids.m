function varargout = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, varargin)
%GRID_ORTH_GETDATAFROMNETCDFGRIDS Get data in fixed orthogonal grid from bundle of netCDF files.
%
%   [X, Y, Z, Ztime,<Ztile>] = grid_orth_getDataFromNetCDFGrids(mapurls, minx, maxx, miny, maxy, <keyword,value>)
%
% extracts data from a series of netCDF files to fill a defined orthogonal grid.
% Only data at grid intersection lines is read, no min/max/mean is performed.
%
% Example: set of tiles from THREDDS catalog
%
%    url     = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml'
%    mapurls = opendap_catalog(url);
%
%    [X, Y, Z, Ztime,Ztile] = grid_orth_getDataFromNetCDFGrids(mapurls, 90e3, 100e3, 300e3, 400e3,'dx',200,'dy',200);
%
% Example: 2 manually specified netCDF files covering Marsdiep
%
%    mapurls = {'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2120.nc',...
%               'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2120.nc'};
%
%    mapurls = {'F:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\vaklodingen\vaklodingenKB121_2120.nc',...
%               'F:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\vaklodingen\vaklodingenKB122_2120.nc'};
%
%    [X, Y, Z, Ztime,Ztile] = grid_orth_getDataFromNetCDFGrids(mapurls, 108010, 112010, 551010, 558010,...
%                                                              'dx',100,'dy',100,'searchinterval',-3.6e3);
%
%   subplot(1,3,1);pcolorcorcen(X,Y,Z    ,[.5 .5 .5]);axis equal;colorbarwithhtext('z [m]','horiz')
%   subplot(1,3,2);pcolorcorcen(X,Y,Ztime,[.5 .5 .5]);axis equal;colorbarwithhtext('t [t]','horiz')
%   subplot(1,3,3);pcolorcorcen(X,Y,Ztile,[.5 .5 .5]);axis equal,colorbarwithhtext('f [#]','horiz')
%
% For additional keywords see: grid_orth_getDataFromNetCDFGrid
%
% Note that grid_orth_getDataFromNetCDFGrids returns only data at the original grid
% vertices or integer increments thereof. For interpolation to an independent grid
% choose nc_cf_gridset_getData.
%
% See also: nc_cf_gridset_getData, grid_2D_orthogonal, grid_orth_getDataFromNetCDFGrid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_getDataFromNetCDFGrids.m 12800 2016-07-06 06:21:37Z nederhof $
% $Date: 2016-07-06 14:21:37 +0800 (Wed, 06 Jul 2016) $
% $Author: nederhof $
% $Revision: 12800 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_getDataFromNetCDFGrids.m $
% $Keywords: $

OPT.dataset         = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
OPT.catalognc       = [];                               % is the catalog nc file if it exists
OPT.tag             = [];
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = pwd;
OPT.polygondir      = [];
OPT.polygon         = [];    % search polygon (default: [] use entire grid)
OPT.cellsize        = [];    % cellsize is assumed to be regular in x and y direction and is determined automatically
OPT.datathinning    = 1;     % stride with which to skip through the data

%???% 
OPT.inputtimes      = [];    % starting points (in Matlab epoch time)
%???% 

OPT.starttime       = now;   % this is a datenum of the starting time to search
OPT.searchinterval  = -730;  % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
OPT.min_coverage    = .25;   % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;     % 0 = off; 1 = on;
OPT.plotoverview    = 1;     % 0 = off; 1 = on;
OPT.warning         = 1;     % 0 = off; 1 = on;
OPT.postProcessing  = 1;     % 0 = off; 1 = on;
OPT.whattodo(1)     = 1;     % volume plots
OPT.type            = 1;
OPT.counter         = 0;
OPT.urls            = [];
OPT.x_ranges        = [];
OPT.y_ranges        = [];
OPT.x               = [];
OPT.y               = [];

OPT.dx             = [];
OPT.dy             = [];

OPT = setproperty(OPT,varargin{:});

if nargin==0
   varargout = {OPT};
   return
end


% get cell size
%urls      = grid_orth_getFixedMapOutlines(OPT.dataset);
x            = nc_varget(mapurls{1}, nc_varfind(mapurls{1}, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate')); 
y            = nc_varget(mapurls{1}, nc_varfind(mapurls{1}, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate')); 
dx = unique(diff(x));
dy = unique(diff(y));
if abs(dx)==abs(dy)
   OPT.cellsize = dx;
else
   error(['dx ',num2str(dx),' is not equal to dy ',num2str(dx)])
end

if isempty(OPT.dx)
    OPT.dx = OPT.cellsize*OPT.datathinning;
end

if isempty(OPT.dy)
    OPT.dy = OPT.cellsize*OPT.datathinning;
end

if mod(min(x)-minx,OPT.cellsize) > 0; error(['requested minx = ',num2str(minx),' does not overlap with x vector: ',num2str(var2evalstr(x))]);end
if mod(min(x)-maxx,OPT.cellsize) > 0; error(['requested maxx = ',num2str(maxx),' does not overlap with x vector: ',num2str(var2evalstr(x))]);end
if mod(min(y)-miny,OPT.cellsize) > 0; error(['requested miny = ',num2str(miny),' does not overlap with y vector: ',num2str(var2evalstr(y))]);end
if mod(min(y)-maxy,OPT.cellsize) > 0; error(['requested maxy = ',num2str(maxy),' does not overlap with y vector: ',num2str(var2evalstr(y))]);end

% generate x and y vectors spanning the fixed map extents
x         = minx : OPT.dx  : maxx;
x         = roundoff(x,2); maxx =  roundoff(maxx,2);
if x(end)~= maxx; x = [x maxx];end % make sure maxx is included as a point

if dy < 0
    % define y from max to min according to old style
    y         = maxy : -OPT.dy : miny; % thinning runs from the lower left corner upward and right
    y         = roundoff(y,2); miny =  roundoff(miny,2);
    if y(end)~=miny; y = [y miny];end % make sure miny is included as a point
else
    % regular y from min to max
    y         = miny : OPT.dy : maxy; % thinning runs from the lower left corner upward and right
    y         = roundoff(y,2); maxy =  roundoff(maxy,2);
    if y(end)~=maxy; y = [y maxy];end % make sure maxy is included as a point
end

nrcols    = max(size(x));
nrofrows  = max(size(y));

% create the dummy X, Y, Z and Ztemps grids
X      = ones(nrofrows,1); X=X*x;      %X = roundoff(X, 6); - no longer needed if roundoff is already called above
Y      = ones(1,nrcols);   Y=y'*Y;     %Y = roundoff(Y, 6); - no longer needed if roundoff is already called above 
Z      = ones(size(X));    Z(:,:)=nan;
Ztime  = Z;
if nargout>4
Ztile  = Z;
end

% clear unused variables to save memory
clear x y minx maxx miny maxy

% no one by one 
for i = 1:length(mapurls)
    % report on progress
    disp(' ')
    [pathstr, name, ext] = fileparts(mapurls{i}); %#ok<*NASGU>
    disp(['Processing (' num2str(i) '/' num2str(length(mapurls)) ') : ' name ext])
    
    % get data and plot
    [x, y, z, zt] = grid_orth_getDataFromNetCDFGrid('ncfile', mapurls{i},...
                                                 'starttime',OPT.starttime,...
                                            'searchinterval',OPT.searchinterval,...
                                                   'polygon',OPT.polygon,...
                                                    'stride',[1 1 1]);

% TO DO: do not read full array from netCDF but only data depending on thinning
% TO DO: use spatial mean, min, max in addition to nearest

    % convert vectors to grids
    x = repmat(x',size(z,1),1);
    y = repmat(y, 1, size(z,2));

    idsLargeGrid = ismember(X,x) & ismember(Y,y);
    idsSmallGrid = ismember(x,X) & ismember(y,Y);
    
    
    % clear unused variables to save memory
    clear x y
    
    % add values to Z matrix
    Z(idsLargeGrid) = z(idsSmallGrid);
    
    % add values to Ztemps matrix
    Ztime(idsLargeGrid) = zt(idsSmallGrid); 
    
    if nargout>4
    % add values to lineage matrix
    Ztile(idsLargeGrid) = i;
    end
    
    % clear unused variables to save memory
    clear z zt
end

if nargout<5
   varargout = {X, Y, Z, Ztime};
elseif nargout==5
   varargout = {X, Y, Z, Ztime, Ztile};
end