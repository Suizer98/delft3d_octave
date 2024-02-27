function [xbtime,Hs_xb, Tp_xb] = compute_waves(INPUT)
% compute wave boundary signal for xbeach
    
    spinuptime  = 0;
    time        = [0: 1 :INPUT.simlength]';
    
    % Calculate timeseries of Hs
    t_surgepeak     = INPUT.simlength/2;
    Hs0             = INPUT.Hsmax * cos( pi*( time-t_surgepeak )/(INPUT.stormlength_waves) ).^2;
    
    % Calculate timeseries of Tp

    g    	= 9.81;
    s_peak 	= (2*pi/g)*(INPUT.Hsmax/INPUT.Tpmax^2);
    Tp0   	= sqrt((2*pi/g)*(Hs0./s_peak));

    
    % 
    Hs              = Hs0;
    Tp              = Tp0;
        
    % Set surge to zero outside of storm duration (only one surge peak allowed)
    nosurgetime     = time < (t_surgepeak - INPUT.stormlength_waves/2) | time > (t_surgepeak + INPUT.stormlength_waves/2);
    Hs(nosurgetime) = 0;
    Tp(nosurgetime) = 0;
    
    % Apply minimum values for Hs & Tp
    Hs              = max(Hs,INPUT.Hsmin);
    Tp              = max(Tp,INPUT.Tpmin);
    
    % ---
    xbtime      = time*3600;            % [s]


    xbtime      = [xbtime+spinuptime];
    Hs_xb       = [Hs];
    Tp_xb       = [Tp];


end