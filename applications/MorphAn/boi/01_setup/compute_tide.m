function [xbtime,WL_xb,WLland_xb] = compute_tide(INPUT,Zland)
    
    spinuptime  	= 0;  	


    time            = [0: INPUT.dt :INPUT.simlength]';
    
    % --- tide
    WL_tide   = calc_WL_tide(INPUT,time);
    
    % -- surge
    WL_surge  = calc_WL_surge_trapezium(INPUT,time,WL_tide);

    % --- combine
    WL              = WL_tide + WL_surge;
    [WLmax,itmax]	= max(WL);
    t_stormpeak     = time(itmax);
    
    % --- shorten
    [time,WL] = shorten_timeseries_HR(time,WL);
    
    % --- WLland is the waterlevel at the back side
    WLland      = min(Zland-0.5, min(WL)) * ones(size(WL));

    % --- add spinup time
    xbtime      = time*3600;            % [s]


    xbtime      = [0;xbtime+spinuptime];
    WL_xb       = [WL(1);WL];
    WLland_xb   = [WLland(1);WLland];
end

