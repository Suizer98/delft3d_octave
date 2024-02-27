%% Voorbeeldscript voor genereren invoertijdseries van golven en waterstanden voor XBeach-BOI
%
%  Dit script is opgesteld t.b.v. implementatie in Morphan, als onderdeel van het project BOI Zanderige Waterkeringen.
%
%  Versie script:   04-04-2022
%
%  Ontwikkeld door:	Deltares & Arcadis
%  Contactpersonen: Klaas Lenstra / Robbin van Santen (Arcadis)
%

%%
clc
clear all
close all

%% Step 0, input & settings
INPUT      = struct(...
                  'WLmax',            5,        ...             %	[5 m+NAP]               Max. surge level @ peak
                  'Hsmax',            9,        ...             % 	[9 m]                   Sign. wave height @ peak
                  'Tpmax',            12,       ...             % 	[12 s]                  Wave peak period @ peak
                  'tidalampl',        1.,       ...             % 	[1 m]                   Tidal amplitude (assuming M2)
                  'phaseshift',       3.5,      ...             % 	[3.5 hr]        [* ]    Time difference between tidal peak and surge peak (in hours)
                  'stormlength_wl',   44,       ...             % 	[44 hr]         [* ]    Duration of waterlevel from 0 to peak to 0
                  'stormlength_waves',1.25*44,  ...             % 	[1.25*44 hr]	[* ]    Duration of waves from 0 to peak to 0
                  'simlength',        44,       ...             % 	[44 hr]         [* ]    Simulation length (centered around storm peak!) - excl. optional shortening of timeseries
                  'msl',              0.,   	...           	% 	[0 m+NAP]       [**]    Mean sea level (excl. WL_addition) [affects wl_tide]
                  'WL_addition',      0.,       ...             % 	[0 m]           [**]	Addition to `WLmax` & `msl` to account for increased `mean sea level` for future scenarios and/or robustness!
                  'SURGE_addition',   0.,       ...             %	[0 m]           [**]	Addition to `SURGE` to account for increased (maximum) surge height for future scenarios!
                  'Hsmax_increase',   0.,       ...             %	[0 %]           [**]	Percentual increase of `Hsmax` to account for changed waveclimate for future scenarios!
                  'Tpmax_increase',   0.,    	...             %	[0 %]           [**]	Percentual increase of `Tpmax` to account for changes waveclimate for future scenarios!
                  'dt',               0.5,      ...             % 	[0.5 hr]        [**]	Resolution of output timesteps (in hours)
                  'Hsmin',            0.5,      ...             %   [.5 m]          [**]	Minimum allowed Hs-value in timeseries [affects storm tails])
                  'Tpmin',            5.        ...             %   [5 s]           [**]	Minimum allowed Tp-value in timeseries [affects storm tails])
                ); 

surge_shape     = 'trapezium';

% XBeach related settings
spinuptime  	= 1200;  	% [s] Spin-up of simulation     [s]
Zland        	= 5;        % [m+NAP] Most landward bedlevel >> NOTE: in MorphAn this value should be derived from input data (profile)


%%  Step 1, Generate timeseries (offshore WL, Hs, Tp)

    % %  Generate timeseries (WL,Hs,Tp) 
    [time,WL,Hs,Tp,WL_tide,WL_surge,t_stormpeak,t_surgepeak,t_tidepeak]	= timeseries_HR(INPUT,surge_shape);
    
    % %  DEBUG: Plot timeseries
    % plot_timeseries(time,WL,Hs,Tp,WL_tide,WL_surge,t_stormpeak,t_surgepeak,t_tidepeak);

    % %  Set WLland
    WLland      = min(Zland-0.5, min(WL)) * ones(size(WL));


%%  Step 2, Shorten timeseries to reduce computation time
% % The simulation stops after the water level has dropped 2 m below the peak water level: h = hmax – 2 m.

    % % Save original timeseries
    [time0, WL0,Hs0,Tp0, WL_tide0,WL_surge0]	= deal(time, WL,Hs,Tp, WL_tide,WL_surge);
    
    % % Shorten timeseries
    [time,  WL, Hs, Tp,  WL_tide ,WL_surge ]	= shorten_timeseries_HR(time, WL,Hs,Tp, WL_tide,WL_surge);

    % %  DEBUG: Plot timeseries [shortened]
    % plot_timeseries(time,WL,Hs,Tp,WL_tide,WL_surge,t_stormpeak,t_surgepeak,t_tidepeak);
        
    % %  Set WLland
    WLland      = min(Zland-0.5, min(WL)) * ones(size(WL));
    
    
%%  Step 3a, Prepare xbeach input
    
    % % Wave level signal for XBeach
    WL_xb           = WL;
    WLland_xb       = WLland;    

    % % Stepwise wave signal for XBeach
    simlength   = time(end) - time(1);
    nsteps      = simlength/1;
    [time_stepwise,Hs_stepwise,duration,Hs_xb]	=   make_stepwise_BC(time, Hs, nsteps);
    [time_stepwise,Tp_stepwise,duration,Tp_xb]	=   make_stepwise_BC(time, Tp, nsteps);
    
    % Set time from hours to seconds
    xbtime          = time*3600;            % [s]
    duration        = duration*3600;        % [s]
    
    % Set tstart & tstop
    tstart          = spinuptime;
    tstop           = xbtime(end) + spinuptime;
    
    % Add spinup time (if non-zero)
    if spinuptime > 0
        % Add xbeach spinup time (tstart) - TIME
        xbtime          = [0;xbtime+tstart];
        duration        = [spinuptime;duration];

        % Add xbeach spinup time (tstart) - WL,Hs,Tp
        WL_xb           = [WL(1);WL];
        WLland_xb       = [WLland(1);WLland];
        Hs_xb           = [Hs_xb(1);Hs_xb];
        Tp_xb           = [Tp_xb(1);Tp_xb];
    end
    
    
%%  Step 3b, Generate xbeach input (WL)
   
    % % XBeach timeseries WL
    xb_wl       	= [xbtime, WL_xb, WLland_xb];
       
    
%%  Step 3c, Generate xbeach input (WAVES)    

    % % XBeach timeseries WAVES
    xbtime_waves    = [0;cumsum(duration)];
    xbtime_waves    = [xbtime_waves(1:end-1),xbtime_waves(2:end)];
    
    xb_waves        = [xbtime_waves(:,1), duration, Hs_xb, Tp_xb];

    
%%  DEBUG: plot results

    figure();grid on;box on;hold on
    plot(time,WL,'-b')
    plot(time,Hs,'-r')
    plot(time,Tp,'-m')
    plot(time0,WL0,':b')
    plot(time0,Hs0,':r')
    plot(time0,Tp0,':m')
    plot(time_stepwise,Hs_stepwise,'--r')
    plot(time_stepwise,Tp_stepwise,'--m')
    legend({'WL','Hs','Tp'});set(legend,'Location','NorthWest','Box','off')

%%
return




%%
%% LOCAL FUNCTIONS
%%

%%
function [time,WL,Hs,Tp,WL_tide,WL_surge,t_stormpeak,t_surgepeak,t_tidepeak] = timeseries_HR(DATAin,surge_shape)
%
% FUNCTION timeseries_HR
%	Returns timeseries of hydraulic boundary conditions based on peak conditions  
%
%       Input:	`DATAin`  >> type: structure
%
%               Default settings for `DATAin`:
%
%               DATAin      = struct(...
%                   'WLmax',            5,      ...                 %	[5]                Max. surge level @ peak
%                   'Hsmax',            9,      ...                 % 	[9]                Sign. wave height @ peak
%                   'Tpmax',            12,     ...                 % 	[12]               Wave peak period @ peak
%                   'tidalampl',        1., 	...                 % 	[1]                Tidal amplitude (assuming M2)
%                   'phaseshift',       3.5,    ...                 % 	[3.5]       [* ]   Time difference between tidal peak and surge peak (in hours)
%                   'stormlength_wl',   44,     ...                 % 	[44]        [* ]   Duration of waterlevel from 0 to peak to 0
%                   'stormlength_waves',1.25*44,...                 % 	[1.25*44]   [* ]   Duration of waves from 0 to peak to 0
%                   'simlength',        44,     ...                 % 	[44]        [* ]   Simulation length (centered around storm peak!)
%                   'msl',              0.,     ...                 % 	[0]         [**]   Mean sea level (excl. WL_addition) [affects wl_tide]
%                   'WL_addition',      0.,     ...                 % 	[0]         [**]   Addition to `WLmax` & `msl` to account for increased `mean sea level` for future scenarios and/or robustness!
%                   'SURGE_addition',   0.,     ...                 %	[0]         [**]   Addition to `SURGE` to account for increased (maximum) surge height for future scenarios!
%                   'Hsmax_increase',   0.,     ...                 %	[0]         [**]   Percentual increase of `Hsmax` to account for changed waveclimate for future scenarios!
%                   'Tpmax_increase',   0.,     ...                	%	[0]         [**]   Percentual increase of `Tpmax` to account for changes waveclimate for future scenarios!
%                   'dt',               1/60,   ...                 % 	[1/60]      [**]   Resolution of output timesteps (in hours)
%                   'Hsmin',            0.5,    ...                 %   [.5]        [**]   Minimum allowed Hs-value in timeseries [affects storm tails])
%                   'Tpmin',            5.      ...                 %   [5]         [**]   Minimum allowed Tp-value in timeseries [affects storm tails])                               
%                 ); 
%
    %%
    % Set time parameters
    time        = [0: DATAin.dt :DATAin.simlength]';

    % Calculate timeseries of WL (tide only)
    [WL_tide]               = calc_WL_tide(DATAin,time);

    % Calculate timeseries of WL (surge only)
    switch surge_shape
        case {'trapezium'}
            [WL_surge,~]	= calc_WL_surge_trapezium(DATAin,time,WL_tide);
        case {'cos2'}
            [WL_surge,~]	= calc_WL_surge_cos2(DATAin,time,WL_tide);
    end
    
    % Calculate timeseries of WL (combined)  
    [WL,~,t_stormpeak]	= calc_WL_combined(time,WL_tide,WL_surge);
    t_surgepeak         = DATAin.simlength/2;
    t_tidepeak          = DATAin.simlength/2 + DATAin.phaseshift;

    % Calculate timeseries of Hs & Tp (INCL `Hsmax_increase` & `Tpmax_increase`)
    [Hs,Tp]     = calc_waves(DATAin,time);
    
%% END
end

%%
function [time,WL,Hs,Tp,WL_tide,WL_surge] = shorten_timeseries_HR(time,WL,Hs,Tp,WL_tide,WL_surge)
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
    [time,  WL,Hs,Tp,  WL_surge,WL_tide]	= deal(time(it), WL(it),Hs(it),Tp(it), WL_surge(it),WL_tide(it));
    
%% END
end

%%
function [WL_tide] = calc_WL_tide(DATAin,time)
%
%   FUNCTION calc_WL_tide
%       >>  Calculate WL_tide
%
    %%
    % Calculate timeseries of tides (INCL `WL_addition`)
    MSL             = DATAin.msl   + DATAin.WL_addition;                            % incl. WL additions
    TIDE            = DATAin.tidalampl;
    
    t_tidepeak      = DATAin.simlength/2 + DATAin.phaseshift;
    WL_tide         = MSL + TIDE * cos( 2*pi*( time-t_tidepeak  )/ 12.42 );
    
%% END
end

%%
function [WL_surge,SURGE] = calc_WL_surge_cos2(DATAin,time,WL_tide)
%
%   FUNCTION calc_WL_surge_cos2
%       >>  Calculate WL_surge based on cos2-shape
%
%       >>  NOTE:	SURGE_addition forces exact change of max(WL_surge)
%                   max(WL_surge) = max(WL_surge) + SURGE_addition
%                   instead of:
%                   max(WL)       = max(WL)       + SURGE_addition
%           >>  This is only relevant when DATAin.phaseshift unequals 0 !
%
    %%
    % Define normalized surge (shape)
    t_surgepeak     = DATAin.simlength/2;
    WL_surge_unit   = cos( pi*( time-t_surgepeak )/ DATAin.stormlength_wl ).^2;
    
    % Set surge to zero outside of storm duration (only one surge peak allowed)
    nosurgetime     = time < (t_surgepeak - DATAin.stormlength_wl/2) | time > (t_surgepeak + DATAin.stormlength_wl/2);
    WL_surge_unit(nosurgetime) = 0;
    
    % Calculate timeseries of surge (EXCL `SURGE_addition`)
    WLMAX           = DATAin.WLmax + DATAin.WL_addition;
    SURGE           = WLMAX - max(WL_tide);
    WL_surge        = SURGE* WL_surge_unit;
    WL              = WL_tide + WL_surge;
    WLmax           = max(WL);
    
    % Required iteration to calculate surge height (EXCL `SURGE_addition`)  >> only relevant if `phaseshift ~= 0`!
    cnt     = 0;
    while abs(WLmax - WLMAX)>1e-4
        cnt         = cnt+1;    if cnt>100; warning(['Number of required iterations > 100! Check results... dWL = ' num2str(dWL)]); break; end
        dWL         = WLmax - WLMAX;
        
        SURGE    	= SURGE - dWL;
        WL_surge  	= SURGE * WL_surge_unit;
        WL       	= WL_tide + WL_surge;
        WLmax    	= max(WL);
    end
    
    % Calculate timeseries of surge (INCL `SURGE_addition`)
    WLMAX         	= WLMAX + DATAin.SURGE_addition;                            % incl. WL additions; excl. SURGE additions
    SURGE           = SURGE + DATAin.SURGE_addition;
    WL_surge        = SURGE * WL_surge_unit;

%% END
end

%%
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
    WLMAX           = DATAin.WLmax + DATAin.WL_addition;
    SURGE           = WLMAX - max(WL_tide);
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);
    WL              = WL_tide + WL_surge;
    WLmax           = max(WL);

    % Required iteration to calculate surge height (EXCL `SURGE_addition`)  >> only relevant if `phaseshift ~= 0`!
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

    % Calculate timeseries of surge (INCL `SURGE_addition`)
    WLMAX         	= WLMAX + DATAin.SURGE_addition;                            % incl. WL additions; excl. SURGE additions
    SURGE           = SURGE + DATAin.SURGE_addition;
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);

%% END
end

%%
function [WL, WLmax,t_stormpeak] = calc_WL_combined(time,WL_tide,WL_surge)
%
%   FUNCTION calc_WL_combined
%       >>  Calculate WL based on WL_surge & WL_tide 
%
    %%
    WL              = WL_tide + WL_surge;
    [WLmax,itmax]	= max(WL);
    t_stormpeak     = time(itmax);
    
%% END
end

%%
function [Hs,Tp] = calc_waves(DATAin,time,Hsmin,Tpmin)
%
%   FUNCTION calc_waves
%       >>  Calculate Hs & Tp
%
    %%
    % Calculate timeseries of Hs
    t_surgepeak     = DATAin.simlength/2;
    Hs0             = DATAin.Hsmax * cos( pi*( time-t_surgepeak )/(DATAin.stormlength_waves) ).^2;
    
    % Calculate timeseries of Tp
    Tp_option = 'constant steepness';
    switch Tp_option
        case 'cos-shape'
            Tp0    	= DATAin.Tpmax * cos( pi*( time-t_surgepeak )/(DATAin.stormlength_waves) );
            
        case 'constant steepness'
            g    	= 9.81;
            s_peak 	= (2*pi/g)*(DATAin.Hsmax/DATAin.Tpmax^2);
            Tp0   	= sqrt((2*pi/g)*(Hs0./s_peak));
    end
    
    % Add `Hsmax_increase` & `Tpmax_increase`
    Hs              = Hs0 * (1+DATAin.Hsmax_increase/100);
    Tp              = Tp0 * (1+DATAin.Tpmax_increase/100);
        
    % Set surge to zero outside of storm duration (only one surge peak allowed)
    nosurgetime     = time < (t_surgepeak - DATAin.stormlength_waves/2) | time > (t_surgepeak + DATAin.stormlength_waves/2);
    Hs(nosurgetime) = 0;
    Tp(nosurgetime) = 0;
    
    % Apply minimum values for Hs & Tp
    Hs              = max(Hs,DATAin.Hsmin);
    Tp              = max(Tp,DATAin.Tpmin);
    
%% END
end

%%
function [TIMEout,VARout,DURATION,VAR] = make_stepwise_BC(TIMEin, VARin, nstep)

timelength  = TIMEin(end)-TIMEin(1);
dT          = timelength/nstep;     if round(dT)~=dT; disp('  >> WARNING: `(T(end)-T(1))/nstep` is not integer!');  end

for i = 1:nstep
    Ttmp                        = [0:0.01:dT]+(i-1)*dT; 
    DURATION(i)                 = Ttmp(end)-Ttmp(1);
    TIMEout((i-1)*2+1:(i)*2) 	= [Ttmp(1) Ttmp(end)];  
    
    VARtmp                      = interp1(TIMEin,VARin,Ttmp);
    VAR(i)                      = mean(VARtmp);
    VARout((i-1)*2+1:(i)*2)     = [VAR(i) VAR(i)];
end
VARout(VARout == max(VARout))   = max(VARin);
VAR(VAR == max(VAR))            = max(VARin);

%%
TIMEout = TIMEout';
VARout  = VARout';
VAR     = VAR';
DURATION= DURATION';

%%
% figure();hold on;grid on;box on
% plot(TIMEin,VARin,'b')
% plot(TIMEout,VARout,'r')
% plot(mean([TIMEout(1:2:end) TIMEout(2:2:end)],2),VAR,'m')

%%
end

%%
function plot_timeseries(time,WL,Hs,Tp,WL_tide,WL_surge,t_stormpeak,t_surgepeak,t_tidepeak)
%
%   FUNCTION plot_timeseries
% 
    %%
    disp('DEBUG: plotting timeseries');
    
    %% Plot timeseries
    % % Plot #1
        figure();grid on;box on;hold on
        plot(time,WL,time,Hs,time,Tp)
        legend({'WL','Hs','Tp'});set(legend,'Location','NorthWest','Box','off')

    % % Plot #2
        figure; hold on
        subplot(311); grid on;box on;hold on; plot(time,WL,'b',time,WL_tide,'--b',time,WL_surge,'-.b'); ylabel('WL [m]'); axis([time(1) time(end) 0.9*min(WL) 1.1*max(WL)]);
        subplot(312); grid on;box on;hold on; plot(time,Hs,'b'); hold on; ylabel('H_s [m]'); axis([time(1) time(end) 0.9*min(Hs) 1.1*max(Hs)]);
        subplot(313); grid on;box on;hold on; plot(time,Tp,'b'); hold on; xlabel('Time [hours]'); ylabel('T_p [s]'); axis([time(1) time(end) 0.9*min(Tp) 1.1*max(Tp)]);

    % % Plot #3
        figure; hold on; grid on; box on; hold on
        plot([time(1) time(end)],[1 1]*max(WL),'b')
        plot([1 1]*t_stormpeak,[-5 10],':b')
        plot([1 1]*t_tidepeak, [-5 10],'--b')
        plot([1 1]*t_surgepeak,[-5 10],'-.b')    
        plot(time,WL,'b')
        plot(time,WL_tide,'--b')
        plot(time,WL_surge,'-.b'); 
        ylabel('Water level [m]'); axis([time(1) time(end) floor(min(WL_tide)-.5) ceil(max(WL)+.5)]);

%% END
end

%%

