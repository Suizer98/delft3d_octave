function UpdateScenarioXML(hm)

dr=[hm.webDir 'scenarios\' hm.name '\'];

scenarios(1).scenario.name=hm.name;
scenarios(1).scenario.longname=hm.longName;
scenarios(1).scenario.starttime=datestr(hm.startTime,'yyyymmdd HHMMSS');
scenarios(1).scenario.stoptime=datestr(hm.stopTime,'yyyymmdd HHMMSS');
scenarios(1).scenario.timestring=[datestr(hm.startTime,0) ' - ' datestr(hm.stopTime,0)];

xml_save([dr 'scenario.xml'],scenarios,'off');
