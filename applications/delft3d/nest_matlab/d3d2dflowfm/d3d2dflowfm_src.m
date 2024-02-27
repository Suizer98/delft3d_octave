function mdu = d3d2dflowfm_thd(mdf,mdu, name_mdu)

% d3d2dflowfm_thd : Writes the sources information to the pli or plz file and belonging tim file
% TODO: coupled intake outlets
%       momentum
%       block function

mdu.Filsrc = '';

if simona2mdf_fieldandvalue(mdf,'filsrc')
    %% Set necessary files
    filgrd = [mdf.pathd3d filesep mdf.filcco];
    fildep = [mdf.pathd3d filesep mdf.fildep];
    filsrc = [mdf.pathd3d filesep mdf.filsrc];
    fildis = [mdf.pathd3d filesep mdf.fildis];

    %% convert the discharge data
    zmodel = 'n'; if simona2mdf_fieldandvalue(mdf,'zmodel') zmodel=mdf.zmodel;end
    zbot   = NaN; if simona2mdf_fieldandvalue(mdf,'zbot'  ) zbot  =mdf.zbot  ;end
    ztop   = NaN; if simona2mdf_fieldandvalue(mdf,'ztop'  ) ztop  =mdf.ztop  ;end
    mdu.Filsrc = d3d2dflowfm_src_xyz(filgrd,filsrc,fildis,fildep,mdu.pathmdu,'thick',mdf.thick,'zmodel',zmodel,'zbot',zbot,'ztop',ztop);
    mdu.Filsrc = simona2mdf_rmpath(mdu.Filsrc);
end
