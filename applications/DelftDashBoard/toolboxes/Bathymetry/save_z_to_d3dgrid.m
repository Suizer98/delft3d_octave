function save_z_to_d3dgrid(out_file,z_grid,lat,lon,d_lat,d_lon,n_layers,wb_h,pct_h,datum_type,msl_offset)
%
% Saving vertical data to Delt3D Grid
%
% originally written in March 2010(?)
%
% Inputs: (order matters) 
% OUTFILE -- output file name
%
% Z_GRID -- bathymetry data (full grid)
%
% LAT -- latitude data (full grid)
%
% LON -- longitude data (full grid)
%
% D_LAT -- latitude spacing between grid points
%
% D_LON -- longitude spacing between grid points
%
% N_LAYERS -- number of layers for gridding (makes display easier/quicker)
%
% WB_H -- handle of the wait bar (progress update figure window)
%
% PCT_H -- range and progress to display in the progress window/wait bar
%
% DATUM_TYPE -- User definition of the data type (mean sea level, 
%               low water level, etc.)
%
% MSL_OFFSET -- offset from mean sea level
%

% strip out the directory from the file name as well as the extension
if ispc
    out_dir = regexprep(out_file,'[^\\]*$','');
    file_pre = regexprep(out_file,'^.*\\','');
else
    out_dir = regexprep(out_file,'[^/]*$','');
    file_pre = regexprep(out_file,'^.*/','');
end
file_pre = regexprep(file_pre,'\.[^\.]*$','');

% get the size of the bathy data
[nlon,nlat]=size(z_grid);


if nargin < 7
    n_layers = 5;
end
if nargin < 5
    d_lat = lat(2)-lat(1);
    d_lon = lon(2)-lon(1);
end

% initialize tile data
delta_x = zeros(n_layers,1);
delta_y = zeros(n_layers,1);

delta_x(1)=d_lon;
delta_y(1)=d_lat;

lat_origin=lat(1)+zeros(n_layers,1);
lon_origin=lon(1)+zeros(n_layers,1);

ntiles_x = zeros(n_layers,1);
ntiles_y = zeros(n_layers,1);

nr_avail_inputs=cell(3*n_layers,1);
pixels_per_tile = 300+zeros(n_layers,1);

i_avail_list = cell(6*n_layers,1);
j_avail_list = cell(6*n_layers,1);


% files are stored in 300x300 blocks
for c_layer = 1:n_layers
    % update wait bar
    wb_label = sprintf('Saving layer %d of %d\n',c_layer,n_layers);
    pct_ratio = (c_layer-1)/n_layers;
    pct_v = pct_h(1) + pct_ratio*(diff(pct_h));
    nxt_pct_ratio = c_layer/n_layers;
    nxt_pct_v = pct_h(1) + nxt_pct_ratio*(diff(pct_h));
    
    waitbar(pct_v,wb_h,wb_label)
    if c_layer > 1
        z_grid = contract_z_grid(z_grid);
        [nlon,nlat] = size(z_grid);
        delta_x(c_layer)=2*delta_x(c_layer-1);
        delta_y(c_layer)=2*delta_y(c_layer-1);

    end
    
    % calculate the number of tiles in this layer:
    n_r = ceil(nlat/300);
    n_c = ceil(nlon/300);

    % keep the tile structure for future use
    ntiles_x(c_layer) = n_c;
    ntiles_y(c_layer) = n_r;
    
    % create a dimension for the parent NC file
    nr_avail_inputs{(c_layer-1)*3+1}='-dim';
    nr_avail_inputs{(c_layer-1)*3+2}=sprintf('nravailable%d',c_layer);
    nr_avail_inputs{(c_layer-1)*3+3}=n_r*n_c;


    % pad to multiple of 300
    new_n_lat = n_r*300;
    new_n_lon = n_c*300;
    
    % NaN pad the data for the grid
    z_pad = zeros(new_n_lon,new_n_lat);
    z_pad(1:nlon,1:nlat)= z_grid;
    
    % make a directory for the current grid if there isn't one there
    % already
    layer_dir = sprintf('%szl%.2d%c',out_dir,c_layer,filesep);
    if ~exist(layer_dir,'dir')
        system(['mkdir "',layer_dir,'"'])
    end
    
    
    
    for c_r = 1:n_r
        % looping over rows of tiles
        
        % update the wait bar:
        inc_val = (c_r-1)/n_r;
        waitbar((1-inc_val)*pct_v+inc_val*nxt_pct_v,wb_h,wb_label)

        
        
        cur_lat = lat(1)+(0:299)*delta_y(c_layer);
        fprintf(1,'Writing chip row %d of %d\n',c_r,n_r);
        for c_c = 1:n_c
            % looping over a single column of tiles
            
            cur_lon = lon(1)+(0:299)*delta_x(c_layer);
            cur_file = sprintf('%s%s.zl%.2d.%.5d.%.5d.nc',layer_dir,file_pre,c_layer,c_c,c_r);
            cur_chip = z_pad((c_c-1)*300+(1:300),(c_r-1)*300+(1:300));
            
            cur_chip(cur_chip==0)=NaN;
            %             pcolor(cur_lon,cur_lat,cur_chip);
            %             shading flat
            %             drawnow
            
            % save the current tile of bathy data
            % The depth data will be stored in the "DEPTH" variable
            % ** it's offset from mean sea level is saved in msl_offset
            save_to_netcdf(cur_file,'-dim','lat',300,...
                '-dim','lon',300,...
                '-dim','info',1,...
                '-var','lat','float','degrees_north',{'lat'},cur_lat,...
                '-att','standard_name','latitude',...
                '-att','long_name','latitude',...
                '-var','lon','float','degrees_east',{'lon'},cur_lon,...
                '-att','standard_name','longitude',...
                '-att','long_name','longitude',...
                '-var','depth','float','m',{'lat','lon'},cur_chip,...
                '-att','_FillValue',NaN,...
                '-att','fill_value',NaN,...
                '-att','msl_offset',msl_offset,...
                '-var','grid_size_x','double','delta_lon',{'info'},delta_x(c_layer),...
                '-var','grid_size_y','double','delta_lat',{'info'},delta_y(c_layer));
            
        end
    end
    
    % save grid tile information for the current layer
    i_avail_list{(c_layer-1)*6+1}='-var';
    i_avail_list{(c_layer-1)*6+2}=sprintf('iavailable%d',c_layer);
    i_avail_list{(c_layer-1)*6+3}='int';
    i_avail_list{(c_layer-1)*6+4}=' ';
    i_avail_list{(c_layer-1)*6+5}={nr_avail_inputs{(c_layer-1)*3+2}};
    i_avail_list{(c_layer-1)*6+6}=ceil((1:n_r*n_c)/n_r);
    
    j_avail_list{(c_layer-1)*6+1}='-var';
    j_avail_list{(c_layer-1)*6+2}=sprintf('javailable%d',c_layer);
    j_avail_list{(c_layer-1)*6+3}='int';
    j_avail_list{(c_layer-1)*6+4}=' ';
    j_avail_list{(c_layer-1)*6+5}={nr_avail_inputs{(c_layer-1)*3+2}};
    j_avail_list{(c_layer-1)*6+6}=rem((0:n_r*n_c-1),n_r)+1;
    
    

    
end

% update the waitbar
waitbar((pct_h(2)+pct_v)/2,wb_h,'Saving global information for the grid.')

% create the parent NC file that defines all the tilings for each layer
% *** put all the grid information into the parent file 
% *** save the vertical datum type and the offset from MEAN SEA LEVEL
save_to_netcdf(out_file,'-dim','zoomlevels',n_layers,...
    '-global','title',upper(file_pre),...
    nr_avail_inputs{:},...
    '-global','vertical_datum',datum_type,...
    '-global','msl_offset',msl_offset,...
    '-var','crs','int','Coordinate Reference System',{},4326,...
    '-att','coord_ref_sys_name','WGS 84',...
    '-att','coord_ref_sys_kind','geographic 2d',...
    '-att','difference_with_msl',0,...
    '-var','grid_size_x','double','Delta lon',{'zoomlevels'},delta_x,...
    '-var','grid_size_y','double','Delta lat',{'zoomlevels'},delta_y,...
    '-var','x0','double','lon origin',{'zoomlevels'},lon_origin,...
    '-var','y0','double','lat origin',{'zoomlevels'},lat_origin,...
    '-var','nx','int','pixels per tile',{'zoomlevels'},pixels_per_tile,...
    '-var','ny','int','number of tiles (lat)',{'zoomlevels'},pixels_per_tile,...
    '-var','ntilesx','int','number of tiles (lon)',{'zoomlevels'},ntiles_x,...
    '-var','ntilesy','int','number of tiles (lat)',{'zoomlevels'},ntiles_y,...
    i_avail_list{:},...
    j_avail_list{:});
   
% update the wait bar
waitbar(pct_h(2),wb_h,'Done writing netCDF files.');



return

% contract the grid USING the Delftares technique
function z_grid = contract_z_grid(z_grid)

% convolution kernel for contracting the grid.
% each grid point is a convex combination of the surrounding pixels from
% the higher resolution data.
conv_kernel=[1,2,1;2,4,2;1,2,1];

buffer_grid = 1-isnan(z_grid);

% since we dilate this data, in C or FORTRAN, this would be much faster,
% but MATLAB's convolution is faster than making a loop, so it's better to
% do it this way:
new_grid = conv2(z_grid,conv_kernel,'same');
denom_grid = conv2(buffer_grid,conv_kernel,'same');

z_grid = new_grid(1:2:end,1:2:end)./denom_grid(1:2:end,1:2:end);
buffer_grid = buffer_grid(1:2:end,1:2:end);

z_grid(buffer_grid~=1)=nan;

return

