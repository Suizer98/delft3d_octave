function dflowfm_pli_split(pliFileName)

%% processing
bnds = dflowfm_io_xydata('read',pliFileName);
[outputDir] = fileparts(pliFileName);
for pp = 1:length(bnds)
    dflowfm_io_xydata('write',[outputDir,filesep,bnds(pp).Blckname,'.pli'],bnds(pp));
end