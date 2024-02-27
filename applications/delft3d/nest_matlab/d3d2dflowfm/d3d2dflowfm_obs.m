function mdu = d3d2dflowfm_obs(mdf,mdu, name_mdu)

% d3d2dflowfm_obs : Writes station informations to D-Flow FM input files

if simona2mdf_fieldandvalue(mdf,'filsta')

    mdu.output.ObsFile = [name_mdu '.xyn'];
    d3d2dflowfm_obs_xy   ([mdf.pathd3d filesep mdf.filcco],[mdf.pathd3d filesep mdf.filsta], mdu.output.ObsFile);
    mdu.output.ObsFile = simona2mdf_rmpath(mdu.output.ObsFile);

end
