function [time,WL,Hs,Tp,WL_tide,WL_surge] = shorten_timeseries_HR(time,WL)
%
% FUNCTION shorten_timeseries_HR
%	Returns shortened timeseries of hydraulic boundary conditions
%   >> Simulation ends shortly after storm peak, when WL < WLmax - 2m 
%
    %%
    % % Find storm peak
    [WLmax,itmax]	= max(WL);
    
    % % Stop simulation shortly after storm peak, when WL <= WLmax - 2m 
    WLstop          = WLmax - 2;
    
    % % Find end time
    itend0          = find(time>time(itmax) & WL<=WLstop,1,'first');
    endtime0        = time(itend0);
    
    % % Find end time in hourly steps 
    itend           = find(time>=ceil(time(itend0)),1,'first');
    endtime         = time(itend);

    % % Cutoff timeseries
    it              = 1:itend;
    [time,  WL]	= deal(time(it), WL(it));
    
%% END
end