function [total_bathy,out_message] = merge_bathy_data(handles,file_list,lat_range,lon_range,dlat,dlon)

nf = length(file_list);

if nf < 1
    total_bathy = [];
    out_message = 'Need more than one file to merge';
    return
end

% create the grid based on the lat/lon ranges and the resolution
% in each direction:
lat_val = lat_range(1):dlat:lat_range(2);
lon_val = lon_range(1):dlon:lon_range(2);

n_lat_val = length(lat_val);
n_lon_val = length(lon_val);

total_bathy = nan(n_lat_val,n_lon_val);
for lat_0 = 1:300:n_lat_val
    cur_lat_val = lat_val(lat_0+(0:299));
    fprintf('%d of %d\n',lat_0,n_lat_val);
    for lon_0 = 1:300:n_lon_val
        cur_lon_val = lon_val(lon_0+(0:299));
        
        %%% try to do this one 300x300 block at a time:
        [lon_grid,lat_grid]=meshgrid(cur_lon_val,cur_lat_val);
        
        bathy = nan(size(lon_grid));
        dx = min(dlat,dlon);
        for c_f = 1:nf
            % map the next bathy to the grid
            next_file = file_list{c_f};
            
            % get the data from "file" (bathymetry name)
            [lon_cur,lat_cur,z_cur,~]=ddb_getBathymetry(handles.bathymetry,lon_range,lat_range,...
                'bathymetry',next_file,...
                'maxcellsize',dx);
            
            % interpolate the data onto the new bathy grid
            bathy_cur = interp2(lon_cur,lat_cur,z_cur,lon_grid,lat_grid);
            
            % merge the new grid with the existing grid
            idx = ~isnan(bathy_cur);
            bathy(idx) = bathy_cur(idx);
            %%%% NOTE: for now, the order of preference is from first to last in
            %%%% the file. In other words, the any multiply defined pixels will
            %%%% tend to the last file in the list that has data for that pixel. I
            %%%% may change this later to track the pixel resolution and supercede
            %%%% that requirement with this. But first, I jst want to get this
            %%%% working.
            total_bathy(lat_0+(0:299),lon_0+(0:299))=bathy;
        end
    end
end
    

out_message = 'ok';


return

