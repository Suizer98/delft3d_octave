function [OPT,msize,nsize] = EHY_getmodeldata_mn_index(OPT,fName)

if ~isempty(OPT.gridFile)
    fName = OPT.gridFile; % get grid info from corresponding grid-file
end
gridInfo = EHY_getGridInfo(fName,{'dimensions'});

% size
msize = gridInfo.MNKmax(1);
nsize = gridInfo.MNKmax(2);

% replace empty-indices or 0 by all
if isempty(OPT.m) || all(OPT.m==0)
    OPT.m=1:msize; 
end
if isempty(OPT.n) || all(OPT.n==0)
    OPT.n=1:nsize; 
end
