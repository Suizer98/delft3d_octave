function [WL_surge,SURGE] = calc_WL_surge_trapezium(DATAin,time,WL_tide)
%
%   FUNCTION calc_WL_surge_trapezium
%       >>  Calculate WL_surge based on trapezium-shape
%
%       >>  NOTE:	SURGE_addition forces exact change of max(WL_surge)
%                   max(WL_surge) = max(WL_surge) + SURGE_addition
%                   instead of:
%                   max(WL)       = max(WL)       + SURGE_addition
%           >>  This is only relevant when DATAin.phaseshift unequals 0 !
%
    %%
    % Set trapezium parameters
    nearpeak_dur    = 2;    % hr  [2hr]
    nearpeak_dz     = 0.1;  % m   [0.1m]  (= height difference between peak surgelvl and nearpeak surgelvl)
    nosurgelvl      = 0;
    
    % Define time (local var only)
    t_surgepeak     = DATAin.simlength/2;
    t               = t_surgepeak + [-DATAin.stormlength_wl/2, nearpeak_dur*[-0.5:0.5:0.5], +DATAin.stormlength_wl/2];

    % Calculate timeseries of surge (EXCL `SURGE_addition`) 
    WLMAX           = DATAin.WLmax;
    SURGE           = WLMAX - max(WL_tide);
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);
    WL              = WL_tide + WL_surge;
    WLmax           = max(WL);

    % Required iteration to calculate surge height  >> only relevant if `phaseshift ~= 0`!
    cnt     = 0;
    while abs(WLmax - WLMAX)>1e-4
        cnt         = cnt+1;    if cnt>100; warning(['Number of required iterations > 100! Check results... dWL = ' num2str(dWL)]); break; end
        dWL         = WLmax - WLMAX;
        SURGE    	= SURGE - dWL;
        s        	= [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
        WL_surge  	= interp1(t,s,time,'linear',nosurgelvl);
        WL        	= WL_tide + WL_surge;
        WLmax    	= max(WL);
    end

    % Calculate timeseries of surge
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);

%% END
end