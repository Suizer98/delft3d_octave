function [times,values] = EHY_getMapCMEMSData(inputFile,start,count,OPT)

allFiles   = dir([fileparts(inputFile) filesep OPT.varName '*.nc']);
fileNames  = char({allFiles(:).name}');
startTimes = datenum(fileNames(:,end-41:end-26),'yyyy-mm-dd_HH-MM');

if isempty(OPT.t0) && isempty(OPT.tend)
    idFs = 1:length(allFiles);
    OPT.t0 = startTimes(1);
    OPT.tend = startTimes(end)+6;
else
    idF_start = max([1 find(startTimes<OPT.t0,1,'last')]);
    idF_stop  = min([length(startTimes) find(startTimes>OPT.tend,1,'first')]);
    idFs = idF_start:idF_stop;
end

% values = NaN([OPT.tend-OPT.t0+1,count(2:end)]); % which times are available is not completely sure based on file name. For now, don't allocate.
times = [];
values = [];
for iF = 1:length(idFs)
    idF = idFs(iF);
    tic
    
    nc_time  = nc_cf_time([allFiles(idF).folder filesep allFiles(idF).name]);
    idKeep = nc_time>=OPT.t0 & nc_time<=OPT.tend;
    times = [times; nc_time(idKeep)];
    tmp    = nc_varget([allFiles(idF).folder filesep allFiles(idF).name],OPT.varName,start-1,[inf count(2:end)]);
    values = [values; tmp(idKeep,:,:,:)];
    if OPT.disp
        disp(['Finished reading CMEMS data ' num2str(iF,'%03.f') '/' num2str(length(idFs),'%03.f') ' (' datestr(min(nc_time(idKeep)),'yyyy-mm-dd HH:MM') ' till ' datestr(max(nc_time(idKeep)),'yyyy-mm-dd HH:MM') ') in ' num2str(toc,'%.2f') 's']);
    end
end

if size(values,1) == 1
    values = squeeze(values);
end
values = flipud(values);
