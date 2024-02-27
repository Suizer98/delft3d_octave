function jarkus_transect2netcdf(filename, transectStruct)
%jarkus_TRANSECT2NETCDF converts Jarkus transect struct to netCDF-CF file
%
%    jarkus_transect2netcdf(filename, transect)
%
% to be called after JARKUS_GRID2NETCDF.
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

% TODO: define the function header here ...
function transect = mergetransects(transects)
    % mergetransects combines several transects of the same period to one
    % transect. 
    %
    %    mergetransects(transects)
    %
    % 
    % See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
    % See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
    %           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 
    % 
    
%     % exceptions:
%     if transects(1).year == 1970 && transects(1).areaCode == 9 && transects(1).alongshoreCoordinate == 10713
%         % Delfland 1970 transect 10713
%         % overlapping bathy and topo lead to zigzag pattern due different
%         % grids and vertical difference of more than 0.5m
%         % Inspection by John de Ronde and Kees den Heijer (2013-02-20) by
%         % comparing with adjacent years led to the conclusion that the
%         % bathy in that area is not reliable. It is deleted here
%         [~, idxlw] = sort(arrayfun(@(x) (-max(x.crossShoreCoordinate)), transects), 'descend');
%         idx = transects(idxlw(1)).crossShoreCoordinate < 100;
%         transects(idxlw(1)).crossShoreCoordinate = transects(idxlw(1)).crossShoreCoordinate(idx);
%         transects(idxlw(1)).origin = transects(idxlw(1)).origin(idx);
%         transects(idxlw(1)).altitude = transects(idxlw(1)).altitude(idx);
%         transects(idxlw(1)).n = sum(idx);
%     end
    
    % create sorting columns, most precise data at the end
    col1 = arrayfun(@(x) (-max(x.crossShoreCoordinate)), transects); % most landward maximum seaward last
    col2 = arrayfun(@(x) (x.timeBathy), transects); % latest dates at the end
    col3 = arrayfun(@(x) (x.timeTopo),  transects); % latest dates at the end
    col4 = arrayfun(@(x) (x.n),         transects); % largest at the end
    
    [~, ia]   = sortrows([col1(:) col2(:) col3(:) col4(:)]);
    transects = transects(ia); % re-order transects
    transect  = transects(1); % take the new first one as basis
    newX      = unique([transects.crossShoreCoordinate]); % unique includes sorting
    
    
    % create a temporary altitude array (H) that includes interpolated
    % values per individual original transect to fill possible gaps
    tmpH = cell2mat(cellfun(@(x,z) interp1(x,z,newX), {transects.crossShoreCoordinate}, {transects.altitude},...
        'uniformoutput', false)');
    % derive cross-shore distance between points
    crossshorespacing = cellfun(@diff, {transects.crossShoreCoordinate}, 'uniformoutput', false);
    settonan = false(size(tmpH));
    % set H values to nan if gap is larger than 100 m
    for k = find(cellfun(@max, crossshorespacing) > 100)
        for ii = find(crossshorespacing{k} > 100)
            settonan(k, newX > transects(k).crossShoreCoordinate(ii) & newX < transects(k).crossShoreCoordinate(ii+1)) = true;
        end
    end
    tmpH(settonan) = NaN;
    % pre-allocate tmpOrigin with zeros
    tmpOrigin = zeros(size(tmpH));
    for k = 1 : length(transects)
        % get the indices of the cross-shore points avaible per transect
        [~, ia, ib]   = intersect(newX , transects(k).crossShoreCoordinate); % find ids transect k
        % fill row of concern in the tmpOrigin array
        tmpOrigin(k,ia) = transects(k).origin(ib);
    end
    % assuming that the order is right, find for each cross-shore point the
    % index to be used
    usedidx = diff([zeros(size(tmpH(1,:))); ~isnan(tmpH)]) == 1 & cumsum(~isnan(tmpH),1) == 1;
    % transform H and Origin arrays to vectors of the values to be used
    newH = tmpH(usedidx);
    newOrigin = tmpOrigin(usedidx);
    % create a mask at the cross-shore locations where the origin was not
    % defined (=0)
    mask = newOrigin == 0;
    transect.crossShoreCoordinate = newX(~mask); % assign new grid
    transect.altitude             = newH(~mask); % assign new altitudes
    transect.origin               = newOrigin(~mask); % assign new origins
    transect.n                    = sum(~mask); % assign new n
    transect.nsources             = sum(sum(usedidx,2)>0);
end

%% Lookup variables
% This assumes a grid already has been saved to the file
yearArray                 = nc_varget(filename, 'time');
transectIdArray           = nc_varget(filename, 'id');
crossShoreCoordinateArray = nc_varget(filename, 'cross_shore');
try
    missing = nc_attget(filename, 'altitude', '_FillValue');
catch
    missing = -9999;
end
%% Write data to file
% Loop over time first, this is most efficient if it's the slowest
% moving dimension.
for i = 1 : length(yearArray)
    year = yearArray(i);
    %block to store to netcdf. Storing more data at once is faster. But
    %it will require more memory.
    transectsForYearStruct = transectStruct([transectStruct.time] == year);
     altitudeBlock = repmat(missing, length(transectIdArray), length(crossShoreCoordinateArray));
       originBlock = nan(length(transectIdArray), length(crossShoreCoordinateArray)); % use nan for missing here (only a short)
     minCrossBlock = nan(size(transectIdArray)); % defaults to nan
     maxCrossBlock = nan(size(transectIdArray)); % defaults to nan
     minAltitBlock = nan(size(transectIdArray)); % defaults to nan
     maxAltitBlock = nan(size(transectIdArray)); % defaults to nan
     timeTopoBlock = nan(size(transectIdArray)); % write 1 per transect
    timeBathyBlock = nan(size(transectIdArray)); % write 1 per transect
    nsources = zeros(size(transectIdArray));
    
    for j = 1 : length(transectIdArray)
        id = transectIdArray(j);
        transect = transectsForYearStruct([transectsForYearStruct.id] == id);
        if isempty(transect)
            continue
        elseif length(transect) > 1 % if more than one dataset per year and per ray is present, the data is merged
            if length(unique(transect(1).crossShoreCoordinate)) ~= length(transect(1).crossShoreCoordinate) || ...
                length(unique(transect(2).crossShoreCoordinate)) ~= length(transect(2).crossShoreCoordinate)
                
                % waiting for a fix from RWS, then delete this if-loop
                warning('Measurement type 1, 3 or 5 might be present for the same cross-shore coordinate')
                continue
            end
            transect = mergetransects(transect);
        end
        [c, ia, ib] = intersect(crossShoreCoordinateArray, transect.crossShoreCoordinate);
         altitudeBlock(j, ia) = transect.altitude(ib);
         minCrossBlock(j)     = min(ia);
         maxCrossBlock(j)     = max(ia);
         minAltitBlock(j)     = min(transect.altitude(ib));
         maxAltitBlock(j)     = max(transect.altitude(ib));
           originBlock(j, ia) = transect.origin(ib);
         timeTopoBlock(j)     = transect.timeTopo;
        timeBathyBlock(j)     = transect.timeBathy;
        nsources(j)           = transect.nsources;
    end
    % should this be in jarkus_transect
    nc_varput(filename, 'min_cross_shore_measurement', minCrossBlock , [i-1, 0], [1, length(minCrossBlock)])
    nc_varput(filename, 'max_cross_shore_measurement', maxCrossBlock , [i-1, 0], [1, length(maxCrossBlock)])
    %nc_varput(filename, 'has_data',      int8(~isnan(maxCrossBlock)) , [i-1, 0], [1, length(maxCrossBlock)])
    nc_varput(filename, 'nsources',                         nsources , [i-1, 0], [1, length(nsources)])
    nc_varput(filename, 'min_altitude_measurement', minAltitBlock , [i-1, 0], [1, length(minAltitBlock)])
    nc_varput(filename, 'max_altitude_measurement', maxAltitBlock , [i-1, 0], [1, length(maxAltitBlock)])
    nc_varput(filename, 'time'      , year          , [i-1      ], [1                        ]);
    nc_varput(filename, 'time_topo' , timeTopoBlock , [i-1, 0   ], [1, length(timeTopoBlock) ]);
    nc_varput(filename, 'time_bathy', timeBathyBlock, [i-1, 0   ], [1, length(timeBathyBlock)]);
    nc_varput(filename, 'altitude'  , altitudeBlock , [i-1, 0, 0], [1,   size(altitudeBlock) ]); % (/i-1, 0, 0/) -> in fortran
    nc_varput(filename, 'origin'    , originBlock   , [i-1, 0, 0], [1,   size(originBlock)   ]); % (/i-1, 0, 0/) -> in fortran
    
    % update actual ranges of altitude variables
    minaltrange = nc_attget(filename, 'min_altitude_measurement', 'actual_range');
    minaltrange = [nanmin([minaltrange  nanmin(minAltitBlock)])...
        nanmax([minaltrange  nanmax(minAltitBlock)])];
    nc_attput(filename, 'min_altitude_measurement', 'actual_range', minaltrange);
    
    maxaltrange = nc_attget(filename, 'max_altitude_measurement', 'actual_range');
    maxaltrange = [nanmin([maxaltrange  nanmin(maxAltitBlock)])...
        nanmax([maxaltrange  nanmax(maxAltitBlock)])];
    nc_attput(filename, 'max_altitude_measurement', 'actual_range', maxaltrange);
    
    % altrange = minmax([minaltrange maxaltrange]) % Matlab R2019a: minmax is in the DL library
    altrange = [min([minaltrange maxaltrange]), max([minaltrange maxaltrange])];
    
    nc_attput(filename, 'altitude', 'actual_range', altrange);
end
nc_attput( filename, nc_global, 'geospatial_vertical_min', min(altrange))
nc_attput( filename, nc_global, 'geospatial_vertical_max', max(altrange))
datefmt = 'yyyy-mm-ddTHH:MMZ'; % date format
nc_attput( filename, nc_global, 'date_modified', datestr(nowutc, datefmt))
nc_attput( filename, nc_global, 'date_issued', datestr(nowutc, datefmt))
% include time coverage info in comment attribute
dv = datevec(yearArray+datenum(1970,1,1)); % date vector matrix (first column contains the years)
missing_years = 'None';
all_years = colon(min(dv(:,1)), max(dv(:,1)));
missing_year_ids = ~ismember(all_years, dv(:,1));
if any(missing_year_ids)
    missing_years = sprintf('%i, ', all_years(missing_year_ids));
    missing_years = missing_years(1:end-2);
end
comment_str = nc_attget(filename, nc_global, 'comment');
nc_attput( filename, nc_global, 'comment', sprintf('%s\nYears covered: %i-%i (%s missing)', comment_str, all_years(1), all_years(end), missing_years))
nc_attput( filename, nc_global, 'time_coverage_start', datestr(datenum(min(all_years),1,1), datefmt))
nc_attput( filename, nc_global, 'time_coverage_end', datestr(datenum(max(all_years),12,31, 23,59,59), datefmt))
nc_attput( filename, nc_global, 'time_coverage_resolution', 'year')



end % jarkus_transect2netcdf