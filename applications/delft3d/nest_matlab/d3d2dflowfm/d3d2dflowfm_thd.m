function mdu = d3d2dflowfm_thd(mdf,mdu, name_mdu)

% d3d2dflowfm_thd : Writes thin dams to D-Flow FM input file

%% Set input files
filgrd = [mdf.pathd3d filesep mdf.filcco];
filtd  = '';
if simona2mdf_fieldandvalue(mdf,'filtd') filtd = [mdf.pathd3d filesep mdf.filtd]; end

%% If thindams file exist, convert
if ~isempty(filtd)
    mdu.geometry.ThinDamFile = [name_mdu '_thd.pli'];
    d3d2dflowfm_thd_xyz(filgrd,'',filtd,mdu.geometry.ThinDamFile)
    mdu.geometry.ThinDamFile = simona2mdf_rmpath(mdu.geometry.ThinDamFile);
end
