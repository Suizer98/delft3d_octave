function mdu = d3d2dflowfm_thd(mdf,mdu, name_mdu)

% d3d2dflowfm_dry : Writes drypoints to dflowfm dry points file

filgrd = [mdf.pathd3d filesep mdf.filcco];
fildry = '';
if simona2mdf_fieldandvalue (mdf,'fildry') fildry = [mdf.pathd3d filesep mdf.fildry]; end

if ~isempty(fildry)
    mdu.geometry.DryPointsFile = [name_mdu '_dry.xyz'];
    d3d2dflowfm_dry_xyz(filgrd,fildry,mdu.geometry.DryPointsFile);
    mdu.geometry.DryPointsFile = simona2mdf_rmpath(mdu.geometry.DryPointsFile);
end
