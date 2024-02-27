function mdu = d3d2dflowfm_initial(mdf,mdu, name_mdu)

% d3d2dflowfm_initial : Writes initial conditions for waterlevel and salinity to D-Flow FM input files

filgrd          = [mdf.pathd3d filesep mdf.filcco];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filini_wl   = '';
mdu.Filini_sal  = '';
mdu.Filini_tem  = '';

%% Reads initial conditions from file (space varying)
if simona2mdf_fieldandvalue(mdf,'filic') || simona2mdf_fieldandvalue(mdf,'restid')
    mdu.geometry.WaterLevIni      = -999.999;
    mdu.Filini_wl                 = [nameshort '_ini_wlev.xyz'];
    if simona2mdf_fieldandvalue(mdf,'filic')
        filic                         = [mdf.pathd3d filesep mdf.filic ];
        type                          = 'initial';
    else
        filic                         = [mdf.pathd3d filesep 'tri-rst.' mdf.restid];
        type                          = 'rst';
    end

    if ~mdu.physics.Salinity && mdu.physics.Temperature == 0
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz']);
    elseif mdu.physics.Salinity && mdu.physics.Temperature == 0
        mdu.Filini_sal                     = [nameshort '_ini_sal.xyz'];
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz'], ...
                               'filic_sal',[name_mdu '_ini_sal.xyz']    , ...
                               'kmax'     ,mdf.mnkmax(3)                , ...
                               'type'     ,type                         );
    elseif mdu.physics.Salinity && mdu.physics.Temperature> 0
        % ic temperature to implement yet
        mdu.Filini_sal                     = [nameshort '_ini_sal.xyz'];
        mdu.Filini_tem                     = [nameshort '_ini_tem.xyz'];
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz'], ...
                               'filic_sal',[name_mdu '_ini_sal.xyz']    , ...
                               'filic_tem',[name_mdu '_ini_tem.xyz']    , ...
                               'kmax'     ,mdf.mnkmax(3)                , ...
                               'type'     ,type                         );
    elseif ~mdu.physics.Salinity && mdu.physics.Temperature> 0
        % ic temperature to implement yet
        mdu.Filini_tem                     = [nameshort '_ini_tem.xyz'];
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz'], ...
                               'filic_tem',[name_mdu '_ini_tem.xyz']    , ...
                               'kmax'     ,mdf.mnkmax(3)                , ...
                               'type'     ,type                         );
    end
else

    %% Constant values from mdf file; for salinity and temperature, take average value
    mdu.geometry.WaterLevIni = mdf.zeta0;
    if mdu.physics.Salinity
        mdu.physics.InitialSalinity    = mean(mdf.s0);
    end
    if mdu.physics.Temperature > 0
        mdu.physics.InitialTemperature = mean(mdf.t0);
    end
end
