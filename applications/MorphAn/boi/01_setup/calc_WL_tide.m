function [WL_tide] = calc_WL_tide(DATAin,time)
%
%   FUNCTION calc_WL_tide
%       >>  Calculate WL_tide
%
    %%
    % Calculate timeseries of tides (INCL `WL_addition`)
    MSL             = DATAin.msl;
    TIDE            = DATAin.tidalampl;
    
    t_tidepeak      = DATAin.simlength/2 + DATAin.phaseshift;
    WL_tide         = MSL + TIDE * cos( 2*pi*( time-t_tidepeak  )/ 12.42 );
    
%% END
end