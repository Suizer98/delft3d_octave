function hm=getObservationStations(hm)

flist=dir([hm.dataDir 'observations' filesep '*.mat']);

for i=1:length(flist)
    fname=[hm.dataDir 'observations' filesep flist(i).name];
    load(fname);
    hm.observationStations{i}=s;
    hm.observationDatabases{i}=lower(s.DatabaseName);
end
