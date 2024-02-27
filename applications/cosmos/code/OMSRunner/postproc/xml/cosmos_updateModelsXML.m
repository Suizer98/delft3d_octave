function cosmos_updateModelsXML(hm,m)

% Updates model xml file for all websites

model=hm.models(m);

for iw=1:length(model.webSite)

    wbdir=model.webSite(iw).name;

    dr=[hm.webDir wbdir filesep 'scenarios' filesep hm.scenario filesep];

    if ~exist(dr,'dir')
        mkdir(dr);
    end

    fname=[dr model.name '.xml'];

    switch lower(hm.models(m).type)
        case{'xbeachcluster'}
            cluster=1;
        otherwise
            cluster=0;
    end

    mdl=[];

    mdl.name.name.value=model.name;
    mdl.name.name.ATTRIBUTES.type.value='char';

    mdl.longname.longname.value=model.longName;
    mdl.longname.longname.ATTRIBUTES.type.value='char';

    mdl.continent.continent.value=model.continent;
    mdl.continent.continent.ATTRIBUTES.type.value='char';
    
    %% Location

    % First try to determine distance between corner points of model limits    
    if ~cluster
        % Get value from xml
        xlim=model.xLim;
        ylim=model.yLim;
    else
        % Take average of start and end profile
        for i=1:length(model.profile)
            xloc(i)=model.profile(i).originX;
            yloc(i)=model.profile(i).originY;
        end
        xlim(1)=min(xloc);
        xlim(2)=max(xloc);
        ylim(1)=min(yloc);
        ylim(2)=max(yloc);
    end
    
    if ~cluster
        % Get value from xml
        if isempty(model.webSite(iw).location)
            xloc=0.5*(xlim(1)+xlim(2));
            yloc=0.5*(ylim(1)+ylim(2));            
        else
            xloc=model.webSite(iw).location(1);
            yloc=model.webSite(iw).location(2);
        end
    else
        % Take average of start and end profile
        xloc=0.5*(model.profile(1).originX+model.profile(end).originX);
        yloc=0.5*(model.profile(1).originY+model.profile(end).originY);  
    end

    if ~strcmpi(model.coordinateSystem,'wgs 84')
        [lon,lat]=convertCoordinates(xloc,yloc,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    else
        lon=xloc;
        lat=yloc;
    end

    mdl.longitude.longitude.value=lon;
    mdl.longitude.longitude.ATTRIBUTES.type.value='real';
    
    mdl.latitude.latitude.value=lat;
    mdl.latitude.latitude.ATTRIBUTES.type.value='real';
    
    %% Elevation
    if isempty(model.webSite(iw).elevation)
        if ~strcmpi(model.coordinateSystem,'wgs 84')
            [xlim,ylim]=convertCoordinates(xlim,ylim,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
        end
        dstx=111111*(xlim(2)-xlim(1))*cos(mean(ylim)*pi/180);
        dsty=111111*(ylim(2)-ylim(1));
        dst=sqrt(dstx^2+dsty^2);
        
        % Elevation is distance times 2
        dst=dst*1.5;
        dst=min(dst,10000000);
        mdl.elevation.elevation.value=dst;
        mdl.elevation.elevation.ATTRIBUTES.type.value='real';
    else
        mdl.elevation.elevation.value=min(hm.models(m).webSite(iw).elevation,10000000);
        mdl.elevation.elevation.ATTRIBUTES.type.value='real';
    end
    
    %% Overlay
    if ~isempty(model.webSite(iw).overlayFile)
        mdl.overlay.overlay.value=model.webSite(iw).overlayFile;
        mdl.overlay.overlay.ATTRIBUTES.type.value='char';
    end
    
    %% Types and size

    mdl.type.type.value=model.type;
    mdl.type.type.ATTRIBUTES.type.value='char';
    
    mdl.size.size.value=model.size;
    mdl.size.size.ATTRIBUTES.type.value='int';
    
    mdl.starttime.starttime.value=model.tOutputStart;
    mdl.starttime.starttime.ATTRIBUTES.type.value='date';
    
    mdl.stoptime.stoptime.value=model.tStop;
    mdl.stoptime.stoptime.ATTRIBUTES.type.value='date';

    mdl.timestep.timestep.value=3;
    mdl.timestep.timestep.ATTRIBUTES.type.value='real';

    %% Duration

    mdl.simstart.simstart.value=[datestr(model.simStart,0) ' (CET)'];
    mdl.simstart.simstart.ATTRIBUTES.type.value='char';

    mdl.simstop.simstop.value=[datestr(model.simStop,0) ' (CET)'];
    mdl.simstop.simstop.ATTRIBUTES.type.value='char';

    mins=floor(model.runDuration/60);
    secs=floor(model.runDuration-mins*60);
    mdl.runduration.runduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.runduration.runduration.ATTRIBUTES.type.value='char';

    mins=floor(model.moveDuration/60);
    secs=floor(model.moveDuration-mins*60);
    mdl.moveduration.moveduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.moveduration.moveduration.ATTRIBUTES.type.value='char';

    mins=floor(model.extractDuration/60);
    secs=floor(model.extractDuration-mins*60);
    mdl.extractduration.extractduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.extractduration.extractduration.ATTRIBUTES.type.value='char';

    mins=floor(model.plotDuration/60);
    secs=floor(model.plotDuration-mins*60);
    mdl.plotduration.plotduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.plotduration.plotduration.ATTRIBUTES.type.value='char';

    mins=floor(model.uploadDuration/60);
    secs=floor(model.uploadDuration-mins*60);
    mdl.uploadduration.uploadduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.uploadduration.uploadduration.ATTRIBUTES.type.value='char';

    mins=floor(model.processDuration/60);
    secs=floor(model.processDuration-mins*60);
    mdl.processduration.processduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.processduration.processduration.ATTRIBUTES.type.value='char';

    mdl.cycle.cycle.value=hm.cycStr;
    mdl.cycle.cycle.ATTRIBUTES.type.value='char';

    mdl.lastupdate.lastupdate.value=[datestr(now,0) ' (CET)'];
    mdl.lastupdate.lastupdate.ATTRIBUTES.type.value='char';

    if ~isempty(model.timeZone)
        mdl.timezone.timezone.value=model.timeZone;
        mdl.timezone.timezone.ATTRIBUTES.type.value='char';
    end

%    if model.timeShift~=0
        mdl.timeshift.timeshift.value=model.timeShift;
        mdl.timeshift.timeshift.ATTRIBUTES.type.value='int';
%     else
%         mdl.timezone.timeshift.value='UTC';
%         mdl.timezone.timeshift.ATTRIBUTES.type.value='char';
%    end

    %% Profiles

    if cluster
        for j=1:model.nrProfiles
            locx=model.profile(j).originX;
            locy=model.profile(j).originY;

            cosa=cos(pi*model.profile(j).alpha/180);
            sina=sin(pi*model.profile(j).alpha/180);

            locx2=locx+model.profile(j).length*cosa;
            locy2=locy+model.profile(j).length*sina;

            [locx,locy]=convertCoordinates(locx,locy,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            [locx2,locy2]=convertCoordinates(locx2,locy2,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');

            mdl.stations.stations.station(j).station.name.name.value          = model.profile(j).name;
            mdl.stations.stations.station(j).station.name.name.ATTRIBUTES.type.value           = 'char';

            mdl.stations.stations.station(j).station.longname.longname.value      = ['MOP ' model.profile(j).name];
            mdl.stations.stations.station(j).station.longname.longname.ATTRIBUTES.type.value           = 'char';

            mdl.stations.stations.station(j).station.longitude.longitude.value     = locx;
            mdl.stations.stations.station(j).station.longitude.longitude.ATTRIBUTES.type.value      = 'real';

            mdl.stations.stations.station(j).station.latitude.latitude.value      = locy;
            mdl.stations.stations.station(j).station.latitude.latitude.ATTRIBUTES.type.value       = 'real';

            mdl.stations.stations.station(j).station.longitude_end.longitude_end.value = locx2;
            mdl.stations.stations.station(j).station.longitude_end.longitude_end.ATTRIBUTES.type.value  = 'real';

            mdl.stations.stations.station(j).station.latitude_end.latitude_end.value  = locy2;
            mdl.stations.stations.station(j).station.latitude_end.latitude_end.ATTRIBUTES.type.value   = 'real';

            mdl.stations.stations.station(j).station.type.type.value          = 'profile';
            mdl.stations.stations.station(j).station.type.type.ATTRIBUTES.type.value           = 'char';

            mdl.stations.stations.station(j).station.html.html.value          = [model.profile(j).name '.html'];
            mdl.stations.stations.station(j).station.html.html.ATTRIBUTES.type.value           = 'char';

%            fnamexml=[model.archiveDir hm.cycStr filesep 'hazards' filesep model.profile(j).name filesep model.profile(j).name '.xml'];
%            if exist(fnamexml,'file')
%                h=xml_load(fnamexml);
%                mdl.stations.stations.station(j).station.hazards=h.profile.proc;
%            end

            % Plots
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.parameter.parameter.value = 'beachprofile';
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.parameter.parameter.ATTRIBUTES.type.value  = 'char';
            
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.type.type.value      = 'beachprofile';
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.type.type.ATTRIBUTES.type.value       = 'char';
            
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.imgname.imgname.value   = [model.profile(j).name '.png'];
            mdl.stations.stations.station(j).station.plots.plots.plot(1).plot.imgname.imgname.ATTRIBUTES.type.value    = 'char';

        end
    end

    %% Stations
    j=0;

    for ist=1:model.nrStations
        
        station=model.stations(ist);
        
        j=j+1;
        
        mdl.stations.stations.station(j).station.name.name.value = station.name;
        mdl.stations.stations.station(j).station.name.name.ATTRIBUTES.type.value  = 'char';
        
        mdl.stations.stations.station(j).station.longname.longname.value = station.longName;
        mdl.stations.stations.station(j).station.longname.longname.ATTRIBUTES.type.value  = 'char';
        
        if ~strcmpi(model.coordinateSystem,'wgs 84')
            [lon,lat]=convertCoordinates(station.location(1),station.location(2),'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
        else
            lon=station.location(1);
            lat=station.location(2);
        end
        
        mdl.stations.stations.station(j).station.longitude.longitude.value = lon;
        mdl.stations.stations.station(j).station.longitude.longitude.ATTRIBUTES.type.value  = 'real';
        
        mdl.stations.stations.station(j).station.latitude.latitude.value  = lat;
        mdl.stations.stations.station(j).station.latitude.latitude.ATTRIBUTES.type.value   = 'real';
        
        mdl.stations.stations.station(j).station.type.type.value      = station.type;
        mdl.stations.stations.station(j).station.type.type.ATTRIBUTES.type.value       = 'char';
        
        mdl.stations.stations.station(j).station.html.html.value      = [station.name '.html'];
        mdl.stations.stations.station(j).station.html.html.ATTRIBUTES.type.value       = 'char';
        
    end
    
    %% Maps

    k=0;
    for j=1:model.nrMapPlots
        if model.mapPlots(j).plot
            
            k=k+1;
            
            switch lower(model.mapPlots(j).type)
                case{'kmz'}
                    mapfilename=[model.mapPlots(j).name '.' model.name '.kmz'];
                case{'vectorxml'}
                    mapfilename=[model.mapPlots(j).name '.' model.name '.xml'];
            end
            
            mdl.maps.maps.map(k).map.filename.filename.value     = mapfilename;
            mdl.maps.maps.map(k).map.filename.filename.ATTRIBUTES.type.value      = 'char';

            mdl.maps.maps.map(k).map.parameter.parameter.value    = model.mapPlots(j).name;
            mdl.maps.maps.map(k).map.parameter.parameter.ATTRIBUTES.type.value     = 'char';

            mdl.maps.maps.map(k).map.longname.longname.value      = model.mapPlots(j).longName;
            mdl.maps.maps.map(k).map.longname.longname.ATTRIBUTES.type.value     = 'char';

            mdl.maps.maps.map(k).map.type.type.value      = model.mapPlots(j).type;
            mdl.maps.maps.map(k).map.type.type.ATTRIBUTES.type.value       = 'char';

            mdl.maps.maps.map(k).map.starttime.starttime.value = hm.cycle;
            mdl.maps.maps.map(k).map.starttime.starttime.ATTRIBUTES.type.value  = 'date';

            mdl.maps.maps.map(k).map.stoptime.stoptime.value  = hm.cycle+model.runTime/1440;
            mdl.maps.maps.map(k).map.stoptime.stoptime.ATTRIBUTES.type.value   = 'date';

            if ~isempty(model.mapPlots(j).timeStep)
                mdl.maps.maps.map(k).map.nrsteps.nrsteps.value   = (model.runTime)/(model.mapPlots(j).timeStep/60)+1;
                mdl.maps.maps.map(k).map.nrsteps.nrsteps.ATTRIBUTES.type.value    = 'int';                
                mdl.maps.maps.map(k).map.timestep.timestep.value  = model.mapPlots(j).timeStep/3600;
                mdl.maps.maps.map(k).map.timestep.timestep.ATTRIBUTES.type.value   = 'real';
            else
                mdl.maps.maps.map(k).map.nrsteps.nrsteps.value   = 1;
                mdl.maps.maps.map(k).map.nrsteps.nrsteps.ATTRIBUTES.type.value    = 'int';
            end

        end
    end

    if cluster
        kmlpar={'hmax','max_runup','beachprofile_change','flood_duration','shoreline'};
        lname={'Maximum wave height','Maximum run up','Beach profile change','Flood duration','Shoreline'};
        for i=1:length(kmlpar)

            k=k+1;

            mdl.maps.maps.map(k).map.filename.filename.value  = [kmlpar{i} '.' model.name '.kmz'];
            mdl.maps.maps.map(k).map.filename.filename.ATTRIBUTES.type.value   = 'char';

            mdl.maps.maps.map(k).map.parameter.parameter.value = kmlpar{i};
            mdl.maps.maps.map(k).map.parameter.parameter.ATTRIBUTES.type.value   = 'char';

            mdl.maps.maps.map(k).map.longname.longname.value  = lname{i};
            mdl.maps.maps.map(k).map.longname.longname.ATTRIBUTES.type.value   = 'char';

            mdl.maps.maps.map(k).map.shortname.shortname.value = kmlpar{i};
            mdl.maps.maps.map(k).map.shortname.shortname.ATTRIBUTES.type.value   = 'char';

            mdl.maps.maps.map(k).map.type.type.value      = 'kmz';
            mdl.maps.maps.map(k).map.type.type.ATTRIBUTES.type.value   = 'char';
        end
    end

    %% Hazards
    hazarchdir=model.cycledirhazards;
    flist=dir([hazarchdir '*.xml']);
    for ih=1:length(flist)
        s=xml2struct([hazarchdir flist(ih).name],'structuretype','long','includeattributes',1);
        mdl.warnings.warnings.warning(ih).warning=s;
    end
    
    struct2xml(fname,mdl,'includeattributes',1,'structuretype','long');

end
