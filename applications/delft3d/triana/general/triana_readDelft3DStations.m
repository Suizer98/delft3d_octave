function s = triana_readDelft3DStations(s);
    

s.model.data.statsAll = {};
s.model.data.XAll = [];
s.model.data.YAll = [];
s.model.data.fileNr = [];
s.model.data.obsNrFile = [];

for ff = 1:length(s.model.file)
    
    trih = qpfopen(s.model.file{ff});
    
    newStats = qpread(trih,'water level','stations');
    
    s.model.data.statsAll = [s.model.data.statsAll;newStats];
    s.model.data.fileNr = [s.model.data.fileNr;zeros(size(newStats))+ff];
    s.model.data.obsNrFile = [s.model.data.obsNrFile;(1:length(newStats))'];
    
    
    % workaround: dummy = qpread(trih,'water level','griddata',1,0); doesn't seem the return the right X,Y coordinates
    
    [flowDir,trihFileName] = fileparts(s.model.file{ff});
    mdfName = trihFileName(6:end);
    
    mdfData = delft3d_io_mdf('read',[flowDir,filesep,mdfName,'.mdf']);
    grd = delft3d_io_grd('read',[flowDir,filesep,mdfData.keywords.filcco]);
    obs = delft3d_io_obs('read',[flowDir,filesep,mdfData.keywords.filsta],grd);
    
    s.model.data.XAll = [s.model.data.XAll;obs.x'];
    s.model.data.YAll = [s.model.data.YAll;obs.y'];
    
end