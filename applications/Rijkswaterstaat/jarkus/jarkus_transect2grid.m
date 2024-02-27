function [grid] = jarkus_transect2grid(transectStruct)
%JARKUS_TRANSECT2GRID converts Jarkus transect struct to Jarkus grid struct
%
%    [grid] = jarkus_transect2grid(transect)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

    % TO DO: define function header here ....
    %        Define a grid to store all transect data on
    % TO DO: Replace this by a transect independent grid structure or better
    %        a classdef if that can be used.
    
 %% we have to determine how much data we want to allocate to store all
 %  transects. find all id's
    
    [transectIdArray, uniqueIdArray] = unique([transectStruct.id]); % unique output is sorted in ascending order
    grid.id = transectIdArray;

 %% find areacodes per id corresponding names (first extract, then sort otherwise all altitudes are copied as well)
 
    % extract
    areaCode              =      [transectStruct.areaCode];
    areaName              = char(cellfun(@(c) char(c{1}), {transectStruct.areaName}, 'uniformoutput', false));
    alongshoreCoordinate  =      [transectStruct.alongshoreCoordinate];
    % unique (== unique + sort)
    grid.areaCode              = areaCode(uniqueIdArray);
    grid.areaName              = areaName(uniqueIdArray,:);
    grid.alongshoreCoordinate  = alongshoreCoordinate(uniqueIdArray);

 %% find all years
    grid.time                  = unique([transectStruct.time]); % unique output is sorted in ascending order
    grid.timelims              = unique([transectStruct.timelims]', 'rows');
    
 %% compute cross-shore grid
    minCrossShoreCoordinate    = min([transectStruct.crossShoreCoordinate]); % cellfun is slow and not needed here: min(cellfun(@min, {transectStruct.crossShoreCoordinate}));
    maxCrossShoreCoordinate    = max([transectStruct.crossShoreCoordinate]); % max(cellfun(@max, {transectStruct.crossShoreCoordinate}));
    grid.crossShoreCoordinate  = minCrossShoreCoordinate:5:maxCrossShoreCoordinate; % what is the 5 doing here ! Finer sampled data is going to be lost
    
 %% display result
    disp(['created a ' num2str(length(grid.crossShoreCoordinate)) ' by ' num2str(length(grid.id)) ' by ' num2str(length(grid.time)) ' grid.']);

end % end function jarkus_transect2grid
