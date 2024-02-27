function UpdateModelsXML(hm,m)

dr=[hm.webDir 'forecasts\'];

models=xml_load([dr 'models.xml']);

ifound = 0;

for i=1:length(models)
    if strcmpi(models(i).model.name,hm.models(m).Abbr)
        ifound=i;
        break;
    end
end

if ifound>0
    ii=ifound;
else
    ii=length(models)+1;
end

models(ii).model.name=hm.models(m).Abbr;
models(ii).model.longname=hm.models(m).name;
models(ii).model.continent=hm.models(m).continent;
models(ii).model.longitude=hm.models(m).Location(1);
models(ii).model.latitude=hm.models(m).Location(2);
models(ii).model.type=hm.models(m).type;
models(ii).model.size=hm.models(m).size;
% models(ii).model.starttime=datestr(hm.models(m).startTime);
% models(ii).model.stoptime =datestr(hm.models(m).stopTime);
% models(ii).model.starttime=datestr(now-3,'yyyymmdd HHMMSS');
% models(ii).model.stoptime =datestr(now,'yyyymmdd HHMMSS');
models(ii).model.starttime='20090329 120000';
models(ii).model.stoptime ='20090401 120000';
models(ii).model.timestep ='3';
models(ii).model.lastupdate=[datestr(now) ' (CET)'];
for j=1:hm.models(m).nrStations
    models(ii).model.stations(j).station.name      = hm.models(m).stations(j).name1;
    models(ii).model.stations(j).station.longname  = hm.models(m).stations(j).name2;
    models(ii).model.stations(j).station.longitude = hm.models(m).stations(j).Location(1);
    models(ii).model.stations(j).station.latitude  = hm.models(m).stations(j).Location(2);
    models(ii).model.stations(j).station.type      = hm.models(m).stations(j).type;
end

xml_save([dr 'models.xml'],models,'off');
