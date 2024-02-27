function cosmos_updateScenarioXML(hm,m)
% Updates scenario xml file for present scenario on all websites

for iw=1:length(hm.models(m).webSite)

    wbdir=hm.models(m).webSite(iw).name;

    dr=[hm.webDir wbdir filesep 'scenarios' filesep hm.scenarioShortName filesep];

    fname=[dr hm.scenarioShortName '.xml'];

    scenario=[];

    scenario.name.name.value=hm.scenarioShortName;
    scenario.name.name.ATTRIBUTES.type.value='char';

    scenario.longname.longname.value=hm.scenarioLongName;
    scenario.longname.longname.ATTRIBUTES.type.value='char';
    
    scenario.type.type.value=hm.scenarioType;
    scenario.type.type.ATTRIBUTES.type.value='char';
    
    t0=hm.cycle;
    t1=hm.cycle+hm.runTime/24;
    
    scenario.starttime.starttime.value=t0;
    scenario.starttime.starttime.ATTRIBUTES.type.value='date';

    scenario.stoptime.stoptime.value=t1;
    scenario.stoptime.stoptime.ATTRIBUTES.type.value='date';

    scenario.timestring.timestring.value=[datestr(t0) ' - ' datestr(t1)];
    scenario.timestring.timestring.ATTRIBUTES.type.value='char';

    for iw2=1:length(hm.website)
        if strcmpi(hm.website(iw2).name,wbdir)

            scenario.longitude.longitude.value=hm.website(iw2).longitude;
            scenario.longitude.longitude.ATTRIBUTES.type.value='real';
            
            scenario.latitude.latitude.value=hm.website(iw2).latitude;
            scenario.latitude.latitude.ATTRIBUTES.type.value='real';
            
            scenario.elevation.elevation.value=hm.website(iw2).elevation;
            scenario.elevation.elevation.ATTRIBUTES.type.value='real';
        end
    end
    
    scenario.models=[];
    im=0;
%     for ii=1:length(find(iorder~=0))
%         i=find(iorder==ii);

    for i=1:hm.nrModels

        model=hm.models(i);
        
        % Check if model should be included in website
        incl=0;
        for iw2=1:length(model.webSite)
            if strcmpi(model.webSite(iw2).name,wbdir)
                incl=1;
                break;
            end
        end

        if hm.models(i).run && incl
            if hm.models(i).webSite(iw2).positionToDisplay>=0
                im=hm.models(i).webSite(iw2).positionToDisplay;
            else
                im=im+1;            
            end
            scenario.models.models.model(im).model.shortname.shortname.value=model.name;
            scenario.models.models.model(im).model.shortname.shortname.ATTRIBUTES.type.value='char';
        end
        
    end

    struct2xml(fname,scenario,'includeattributes',1,'structuretype','long');

end
