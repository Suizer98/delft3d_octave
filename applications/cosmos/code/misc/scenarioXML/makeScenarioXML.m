clear all;close all;

hm=ReadOMSMainConfigFile;

hm.name    ='forecasts';
hm.longName='Forecasts';
hm.startTime = floor(now);
hm.stopTime = floor(now)+3;

UpdateScenarioXML(hm);

hm.name    ='elnino1982';
hm.longName='El Nino 1982';
hm.startTime = datenum(1982,2,15);
hm.stopTime = datenum(1982,2,18);

UpdateScenarioXML(hm);

hm.name    ='winter2003';
hm.longName='Winter 2003';
hm.startTime = datenum(2003,2,15);
hm.stopTime = datenum(2003,2,18);

UpdateScenarioXML(hm);

hm.name    ='storm500y';
hm.longName='500-year storm';
hm.startTime = datenum(2015,4,12);
hm.stopTime = datenum(2015,4,15);

UpdateScenarioXML(hm);
