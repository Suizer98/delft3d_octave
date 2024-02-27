function [succes] = determine_fourier(reftime,starttime, stoptime, spinup, latitude, dt_user, components, output)

try
    %% Inputs
    %reftime     = datenum(2009,9,1);  % datenum
    %starttime   = datenum(2009,10,1); % datenum
    %stoptime    = datenum(2010,9,1);  % datenum
    %spinup      = 7;                  % days
    %latitude    = 39.996;             % degrees
    %dt_user     = 60;                 % seconds     (time step in Delft3D-4 or dtuser in FM)
    %components  ={'M2','S2','N2','K2','K1','O1','P1','Q1'};
    %output      = 'f:\Alameda\03_modelsetup\version015\SFBD2.fou';

    %% Get reference consitents
    tfac        = 86400;              % seconds in 1 day
    tt          = t_getconsts;
    names       = tt.name;
    freqs       = tt.freq;
    for i=1:size(names,1)
        cnsts{i}=deblank(names(i,:));
    end

    %% Loop over all components
    fid=fopen(output,'wt');
    
    % Write header
    frmt = repmat('%s ',1,length(components));
    str = sprintf(['* ',frmt],components{:});
    fprintf(fid,'%s\n',str);
    
    for i=1:length(components)

        % Get nearest
        ii                  = strmatch(components{i},cnsts,'exact');
        freq                = freqs(ii);

        % Determine nodal amplifcation
        [v,u,f]             = t_vuf('nodal',0.5*(starttime+stoptime),ii,latitude);
        [vref,uref,fref]    = t_vuf('nodal',reftime,ii,latitude);
        u                   = (vref+u)*360;
        u                   = mod(u,360);

        % Total time
        ttot                = stoptime-starttime-spinup;
        period              = 1/freq/24;
        ncyc                = floor(ttot/period);
        ttot                = ncyc*period;
        ntimesteps          = round(tfac*ttot/dt_user);
       
        % Write
        startime_wanted     = stoptime-ntimesteps*dt_user/tfac;
        t0str               = num2str((startime_wanted-reftime)*tfac,'%10.2f');
        t0str               = [repmat(' ',1,12-length(t0str)) t0str];
        t1str               = num2str((stoptime-reftime)*tfac,'%10.2f');
        t1str               = [repmat(' ',1,12-length(t1str)) t1str];
        nrstr               = num2str(ncyc);
        nrstr               = [repmat(' ',1,6-length(nrstr)) nrstr];
        ampstr              = num2str(f,'%10.5f');
        ampstr              = [repmat(' ',1,12-length(ampstr)) ampstr];
        argstr              = num2str(u,'%10.5f');
        argstr              = [repmat(' ',1,12-length(argstr)) argstr];
        str                 = ['wl ' t0str ' ' t1str nrstr ampstr argstr];
        str                 = deblank(str);
        fprintf(fid,'%s\n',str);
    end

    % Add mean, min and max
    for ii = 1:5

        % 3 options wl
        if ii == 1; wanted = ''; end            % mean water level
        if ii == 2; wanted = ' min'; end        % minimum water level
        if ii == 3; wanted = ' max'; end        % maximum water level
        
        % 3 options umag
        if ii == 4; wanted = ''; end            % mean depth-averaged flow velocity
        if ii == 5; wanted = ' max'; end        % maximum (min = 0...)
        
        % Write
        t0str               = num2str((starttime+spinup-reftime)*tfac,'%10.2f');
        t0str               = [repmat(' ',1,12-length(t0str)) t0str];
        t1str               = num2str((stoptime-reftime)*tfac,'%10.2f');
        t1str               = [repmat(' ',1,12-length(t1str)) t1str];
        nrstr               = num2str(0,'%10.0f');
        nrstr               = [repmat(' ',1,6-length(nrstr)) nrstr];
        ampstr              = num2str(1,'%10.0f');
        ampstr              = [repmat(' ',1,12-length(ampstr)) ampstr];
        argstr              = num2str(0,'%10.0f');
        argstr              = [repmat(' ',1,12-length(argstr)) argstr];
        if ii < 4
            str                 = ['wl ' t0str ' ' t1str nrstr ampstr argstr wanted];
        else
            str                 = ['uc ' t0str ' ' t1str nrstr ampstr argstr '           1', wanted];  % only for depth-averaged flow
        end
        str                 = deblank(str);
        fprintf(fid,'%s\n',str);
    end
    fclose(fid);
    %%
    succes = 1;
catch
    succes = 0;
end

