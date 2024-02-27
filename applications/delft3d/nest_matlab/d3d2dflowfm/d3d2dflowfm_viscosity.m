function mdu = d3d2dflowfm_viscosity(mdf,mdu,name_mdu)

% d3d2dflowfm_viscosity : Writes viscosity/diffusvity information to D-Flow FM input files

%% Horizontal
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filvico     = '';
mdu.Fildico     = '';

%% If space varying:
if simona2mdf_fieldandvalue(mdf,'filedy')
    mdu.physics.Vicouv       = 0; % Freek Scheel: Must be set within the range 0 to Inf, else DS will not run
    mdu.physics.Dicouv       = 0; % Freek Scheel: Must be set within the range 0 to Inf, else DS will not run
    mdu.Filvico              = [nameshort '_vico.xyz'];
    filgrd                   = [mdf.pathd3d filesep mdf.filcco];
    filedy                   = [mdf.pathd3d filesep mdf.filedy];

    % Derive and write values to file
    if ~mdu.physics.Salinity
        d3d2dflowfm_viscosity_xyz(filgrd,filedy,[name_mdu '_vico.xyz']);
    else
        mdu.Fildico  = [nameshort '_dico.xyz'];
        d3d2dflowfm_viscosity_xyz(filgrd,filedy,[name_mdu '_vico.xyz'],[name_mdu '_dico.xyz']);
    end
else

    % Constant values from mdf file
    mdu.physics.Vicouv = mdf.vicouv;
    mdu.physics.Dicouv = mdf.dicouv;
end

%% Vertical
if mdu.geometry.Kmx > 1
    mdu.physics.Vicoww = mdf.vicoww;
    mdu.physics.Dicoww = mdf.dicoww;
end

%% Fill additonal parameters releated to viscosity
mdu.physics.Smagorinsky = 0.0;
mdu.physics.Elder       = 0;
mdu.physics.irov        = 0;
mdu.physics.wall_ks     = 0; % not used so make clear in the input --> Freek Scheel: Must be set within the range 0 to Inf, else DS will not run
