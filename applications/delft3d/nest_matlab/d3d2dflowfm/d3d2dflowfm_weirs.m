function mdu = d3d2dflowfm_weirs(mdf,mdu, name_mdu)

% d3d2dflowfm_weirs : Writes weir information to D-Flow FM input file

if simona2mdf_fieldandvalue(mdf,'fil2dw') && ~isempty(mdf.fil2dw);
    mdu.geometry.FixedWeirFile = [name_mdu '_2dw.pli'];
    d3d2dflowfm_weirs_xyz       ([mdf.pathd3d filesep mdf.filcco],[mdf.pathd3d filesep mdf.fil2dw], mdu.geometry.FixedWeirFile);
    mdu.geometry.FixedWeirFile = simona2mdf_rmpath( mdu.geometry.FixedWeirFile);
end
