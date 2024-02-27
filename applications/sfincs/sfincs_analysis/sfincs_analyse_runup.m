function [times, zs_swash, xs_swash] = sfincs_determine_runup(eps_runup, delete_nc)

% Function that determine runup based on high frequency netcdf map output from SFINCS
% eps_runup is the rugdepth used for runup analyis
% delete_nc is a logical 1 = delete netcdf and 0 = do not delete
% note that the nc can be very large

% Settings
debug       = 0 ;
save_map    = 0;
times       = NaN;
zs_swash    = NaN;
xs_swash    = NaN;

% Read data
if exist('sfincs_map.nc') == 2
    
    % Read netcdf
    inp     = sfincs_read_input('sfincs.inp',[]);
    times   = nc_varget('sfincs_map.nc', 'time');
    try
        sbg = sfincs_read_binary_subgrid_tables_v8([pwd, '/']);
        zb  = sbg.z_zmin;
    catch
        zb      = nc_varget('sfincs_map.nc', 'zb')';
    end
    zsmax   = squeeze( nanmax(nc_varget('sfincs_map.nc', 'zsmax')));
    range   = zsmax - zb;
    idfind  = find(range>0);
    if isempty(idfind)
        disp([' weird results: ' pwd])
        erorr   = 'error';
        save('error.txt', 'erorr', '-ascii');
    else
        x       = nc_varget('sfincs_map.nc', 'x', [0, 0], [idfind(end) 1]);
        zs      = squeeze(nc_varget('sfincs_map.nc', 'zs', [0 0 0], [Inf idfind(end) 1]));
        zb      = nc_varget('sfincs_map.nc', 'zb', [0, 0], [idfind(end) 1]);
        sim_time= nc_varget('sfincs_map.nc', 'total_runtime');

        % Determine runup
        rugdepth  = eps_runup;
        timesteps = size(zs,1);
        zs_swash  = NaN(timesteps, 1);
        for xx=1:timesteps
            zs_temp         = zs(xx,:)';
            swash           = (zs_temp - zb) ;
            swash_temp      = swash > rugdepth;
            last            = find(swash_temp==1, 1, 'last');
            if isempty(last); last = 1; end
            if last < 1 ; last = 1; end;
            zs_swash(xx)    = zs_temp(last);
            xs_swash(xx)    = x(last);
        end

        % Save
        save('sfincs_processed_runup.mat', 'times', 'zs_swash', 'xs_swash')
        if save_map == 1
            save('sfincs_mapoutput.mat', 'times', 'x', 'zs', 'zb', '-v7.3')
        end
    end
    if delete_nc == 1
        delete('sfincs_map.nc')
    end

else
    try
        load('sfincs_processed_runup.mat');
    catch
        if exist('error.txt') ~= 2
            error('help!');
        end
    end
end

% TMP video
if debug == 1
    close all
    figure; hold on;
    plot(x, zb, 'k')
    for tt =  1600:3200% length(times)
        hplot1  = plot(x,zs(tt,:), 'b');
        hplot2 = plot(xs_swash(tt), zs_swash(tt), 'ro');
        pause(0.01)
        delete(hplot1)
        delete(hplot2)
        title(num2str(tt))
    end
end

% TMP
if debug == 1
    close all
    figure; hold on;
    plot(x, zb, 'k')
    tt = 3600;
    hplot = plot(x,zs(tt,:), 'b');
    plot(xs_swash(tt), zs_swash(tt), 'ro')
end

end