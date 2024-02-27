function [grid, msgpos, nometa_ids] = jarkus_updategrid(grid, raaienfile, tidefile)
%JARKUS_UPDATEGRID   update Jarkus grid struct with jarkus_raaien.txt & jarkus_tideinfo.txt
%
%     [grid] = jarkus_updategrid(grid, raaienfile, tidefile)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF

if nargin < 2
   raaienfile = 'jarkus_raaien.txt';
end
if nargin < 3
   tidefile   = 'jarkus_tideinfo.txt';
end

% TODO: insert function header here

%% First part: update grid with information from jarkus_raaien.txt
    
    disp(['Extracting info from ' raaienfile])
    % create a new transect structure
    transect                      = jarkus_createtransectstruct();

%% read all data except first line
%  replace with function jarkus_raaien
    if ischar(raaienfile)
        transectfiles = {raaienfile};
    else
        transectfiles = raaienfile;
    end
    
    tmp = cell(size(transectfiles));
    for i = 1:length(transectfiles)
        tmp{i} = dlmread(transectfiles{i}, '\t', 1,0);
    end
    data = vertcat(tmp{:});
    
    % the positioning of 19 transects in the areas Voorne (11) and Goeree
    % (12) have been in the years after 1965. The old ones all end at 1,
    % whereas the current ones (and all the others) end at 0. The next
    % lines of code filter the "1" transects from the data, in order to
    % keep only the "0" transects.
    idx1 = mod(data(:,2), 10) ~= 0;
    filteredid = data(idx1,1)*1e6 + floor(data(idx1,2)/10);
    msgpos = sprintf('Due to repositioning of a small number of transects in the period between 1965 and 1970, the position of the following transects can be incorrect in the first years of the measured period:%s', sprintf(' %i', sort(filteredid)));
    data = data(~idx1,:);
    
    transect.areaCode             =                data(:,1);      % kustvak
    transect.alongshoreCoordinate =          floor(data(:,2) / 10);% metrering
    transect.x                    =                data(:,3)./100; % x
    transect.y                    =                data(:,4)./100; % y
    % from 0.1 degrees to radiants and 
    % angle is pos clockwise 0 north
    transect.angle                 =                data(:,5)./100;

    transect.id                   = transect.areaCode*1e6 + transect.alongshoreCoordinate;

%% find points in the transect which are also in the grid
    
    [c, ia, ib] = intersect(transect.id, grid.id);
    if (length(c) ~= length(grid.id))
        warning('JARKUS:inconsistency', 'found grids which are not present in meta information or vice versa'); 
        % assert.m is not compatible
    end
    nondata_ids = setdiff(transect.id, grid.id);
    nnodata = length(nondata_ids);
    if (nnodata)
        msg = sprintf('found %d transects in metadata without data', nnodata);
        warning('JARKUS:inconsistency: %s', msg);
    end
    nometa_ids = setdiff(grid.id, transect.id);
    nnometa = length(nometa_ids);
    if (nnometa)
        msg = sprintf('found %d transects in data without metadata:\n%s', nnometa, sprintf('%8d\n', nometa_ids));
        warning('JARKUS:inconsistency: %s', msg);
    end    
    
%% remove points without metadata
    
    grid.id                   = grid.id(ib);
    grid.areaCode             = grid.areaCode(ib);
    grid.areaName             = grid.areaName(ib,:);
    grid.alongshoreCoordinate = grid.alongshoreCoordinate(ib);
        
%% use the angle to compute the coordinates in projected cartesian
%  coordinates. (for jarkus Amersfoort RD new)
    % use (90-angle) to express it as "pos counterclockwise 0 east"
    relativeX  = cosd(90-transect.angle(ia)) * grid.crossShoreCoordinate;
    relativeY  = sind(90-transect.angle(ia)) * grid.crossShoreCoordinate;
    X          = repmat(transect.x(ia),1,size(relativeX,2)) + relativeX;
    Y          = repmat(transect.y(ia),1,size(relativeY,2)) + relativeY;
    % store all coordinates
    grid.X     = X;
    grid.Y     = Y;
    % and the origins.
    grid.x_0   = transect.x(ia);
    grid.y_0   = transect.y(ia);
    % assign angle of coastline to grid
    grid.angle = transect.angle(ia); 
    
    %% Second part: update grid with information from TIDEINFO.txt
    disp(['Extracting info from ' tidefile])
    tideinfo                      = jarkus_tideinfo(tidefile);
    
%% create a new transect structure
    
    transect                      = jarkus_createtransectstruct();
    transect.areaCode             = tideinfo.areaCode;
    transect.alongshoreCoordinate = tideinfo.alongshoreCoordinate;
    transect.id                   = transect.areaCode*1e6 + transect.alongshoreCoordinate;
    transect.meanHighWater        = tideinfo.MHW;
    transect.meanLowWater         = tideinfo.LMW;
    % find points in the transect which are also in the grid
    [~, ia, ib] = intersect(grid.id, transect.id);

%% assign MHW and MLW to grid

    grid.meanHighWater = nan(size(grid.id));
    grid.meanLowWater  = nan(size(grid.id));
    grid.meanHighWater(ia)            = transect.meanHighWater(ib); 
    grid.meanLowWater(ia)             = transect.meanLowWater(ib); 
    
end % end function jarkus_updategrid
