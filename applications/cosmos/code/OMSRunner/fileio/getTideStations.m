function hm=getTideStations(hm)

flist=dir([hm.dataDir 'tidestations' filesep '*.mat']);

for i=1:length(flist)
    fname=[hm.dataDir 'tidestations' filesep flist(i).name];
    load(fname);
    hm.tideStations{i}=s;
    hm.tideDatabases{i}=lower(s.DatabaseName);
end
