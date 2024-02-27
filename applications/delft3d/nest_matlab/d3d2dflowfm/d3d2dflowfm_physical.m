function mdu = d3d2dflowfm_physical(mdf, mdu, ~)

% d3d2dflowfm_physical : Get physical information out of the mdf structure and set in the mdu structure

mdu.Filwnd          = '';
mdu.Filwsvp         = [];
mdu.Filtem          = '';
mdu.Fileva          = '';

%% General
mdu.physics.Ag      = mdf.ag;
mdu.physics.Rhomean = mdf.rhow;
mdu.wind.PavBnd     = -999;

%% Salinity
if strcmpi(mdf.sub1(1),'S') 
    mdu.physics.Salinity                   = 1;
    mdu.physics.Backgroundwatertemperature = mdf.tempw;
    mdu.physics.Backgroundsalinity         = -999.999;
end

%% Temperature
if strcmpi(mdf.sub1(2),'T')
    mdu.physics.Backgroundwatertemperature = -999.999;
    mdu.physics.Backgroundsalinity         = mdf.salw;
    
    if mdf.ktemp == 0
        % No heat exchange with the atmosphere
        mdu.physics.Temperature = 1;
    elseif mdf.ktemp == 5
        % Ocean Heat Flux model
        mdu.physics.Temperature  = 5;
        mdu.physics.Secchidepth  = mdf.secchi;
        mdu.physics.Stanton      = mdf.stantn;
        mdu.physics.Dalton       = mdf.dalton;
        if simona2mdf_fieldandvalue(mdf,'filtmp')
            [~,name,~] = fileparts(mdf.filtmp);
            mdu.Filtem = [name '_unstruc.tem'];
        else

            % Space varying forcing to implement yet\
        end
    elseif mdf.ktemp == 3
        mdu.physics.Temperature  = 3;
        if simona2mdf_fieldandvalue(mdf,'filtmp')
            [~,name,~] = fileparts(mdf.filtmp);
            mdu.Filtem = [name '_unstruc.tem'];
        end
    else
        simona2mdf_message('Only Ocean Heat Flux model and Excess model implemented','Window','D3D2DFLOWFM Warning','Close',true,'n_sec',10);
    end
else
    mdu.physics.Temperature = 0;
end

%% Wind
if strcmpi(mdf.sub1(3),'W')

    %% Rhoair and Cd
    mdu.wind.Rhoair  = mdf.rhoa;
    mdu.wind.ICdtyp  = length(mdf.wstres)/2;
    for i_cd = 1:mdu.wind.ICdtyp
        mdu.wind.Cdbreakpoints(i_cd)        = mdf.wstres(i_cd*2 - 1);
        mdu.wind.Windspeedbreakpoints(i_cd) = mdf.wstres(i_cd*2    );
    end

    if strcmpi(mdf.wnsvwp,'N')

        %% Uniform wind
        if simona2mdf_fieldandvalue(mdf,'filwnd')
            [~,name,~] = fileparts(mdf.filwnd);
            mdu.Filwnd = [name '_unstruc.wnd'];
        end
    else

        %% Space varying wind, start with inverse barometer correction
        if simona2mdf_fieldandvalue(mdf,'pcorr')
            if strcmpi(mdf.pcorr,'y')
                mdu.wind.PavBnd = mdf.pavbnd;
            else
                mdu.wind.PavBnd = 0.0;
            end
        end

        %% Files
        if simona2mdf_fieldandvalue(mdf,'fwndgp') mdu.Filwsvp{1} = mdf.fwndgp; end
        if simona2mdf_fieldandvalue(mdf,'fwndgu') mdu.Filwsvp{2} = mdf.fwndgu; end
        if simona2mdf_fieldandvalue(mdf,'fwndgv') mdu.Filwsvp{3} = mdf.fwndgv; end

    end
end

%% Rain and evaporation
if simona2mdf_fieldandvalue(mdf,'fileva')
    [~,name,~] = fileparts(mdf.fileva);
    mdu.Fileva = [name '_unstruc.eva'];
end
