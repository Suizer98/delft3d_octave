function mdu = d3d2dflowfm_crs(mdf,mdu, name_mdu)

% d3d2dflowfm_crs : Converts cross section information and fill mdu struct

filgrd = [mdf.pathd3d filesep mdf.filcco];

if simona2mdf_fieldandvalue(mdf,'filcrs')

    filcrs             = [mdf.pathd3d filesep mdf.filcrs];
    mdu.output.CrsFile = [name_mdu '_crs.pli'];
    d3d2dflowfm_crs_xy   (filgrd,filcrs,mdu.output.CrsFile);
    mdu.output.CrsFile = simona2mdf_rmpath(mdu.output.CrsFile);

end
