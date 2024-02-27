function mdu = d3d2dflowfm_friction(mdf,mdu, name_mdu)

% d3d2dflwfm_friction: Writes friction information to D-Flow FM input files

[~,nameshort,~] = fileparts(name_mdu);
mdu.Filrgh      = '';

%% Determine friction type
if strcmpi(mdf.roumet,'c') mdu.physics.UnifFrictType = 0;end
if strcmpi(mdf.roumet,'m') mdu.physics.UnifFrictType = 1;end
if strcmpi(mdf.roumet,'w') mdu.physics.UnifFrictType = 2;end
if strcmpi(mdf.roumet,'z') mdu.physics.UnifFrictType = 3;end

%% Reads roughness values from file

if simona2mdf_fieldandvalue(mdf,'filrgh')
    mdu.physics.UnifFrictCoef = 0; % Freek Scheel: Must be set within the range 0 to Inf, else DS will not run
    mdu.Filrgh               = [nameshort '_rgh.xyz'];
    
    filgrd = [mdf.pathd3d filesep mdf.filcco];
    filrgh = [mdf.pathd3d filesep mdf.filrgh];
    d3d2dflowfm_friction_xyz(filgrd,filrgh,[name_mdu '_rgh.xyz']);
else

    % Constant values from mdf file
    mdu.physics.UnifFrictCoef = 0.5*(mdf.ccofu + mdf.ccofv);
end
