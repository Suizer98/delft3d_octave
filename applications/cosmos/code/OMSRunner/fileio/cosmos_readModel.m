function [model,ok]=cosmos_readModel(hm,fname,dr)

ok=0;

% Read Model

xml=xml2struct(fname);

model.run=1;
if isfield(xml,'run')
    if str2double(xml.run)==0
        % Skip this model
        return
    end
end

%% Stations, maps and profiles
model.nrStations=0;
model.nrMaps=0;
model.nrProfiles=0;

%% Names
model.longName=xml.longname;
model.name=xml.name;
model.continent=xml.continent;
model.dir=[hm.scenarioDir 'models' filesep xml.continent filesep xml.name filesep];

% % Website
% if isfield(xml,'websites')
%     for j=1:length(xml.websites)
%         model.webSite(j).name=xml.websites(j).website.name;
%         model.webSite(j).Location=[];
%         model.webSite(j).elevation=[];
%         model.webSite(j).overlayFile=[];
%         model.webSite(j).positionToDisplay=[];
%         if isfield(xml.websites(j).website,'locationx') && isfield(xml.websites(j).website,'locationy')
%             model.webSite(j).Location(1)=str2double(xml.websites(j).website.locationx);
%             model.webSite(j).Location(2)=str2double(xml.websites(j).website.locationy);
%         elseif isfield(xml.websites(j).website,'longitude') && isfield(xml.websites(j).website,'latitude')
%             model.webSite(j).Location(1)=str2double(xml.websites(j).website.longitude);
%             model.webSite(j).Location(2)=str2double(xml.websites(j).website.latitude);
%         end
%         if isfield(xml.websites(j).website,'elevation')
%             model.webSite(j).elevation=str2double(xml.websites(j).website.elevation);
%         end
%         if isfield(xml.websites(j).website,'overlay')
%             model.webSite(j).overlayFile=xml.websites(j).website.overlay;
%         end
%         if isfield(xml.websites(j).website,'positiontodisplay')
%             model.webSite(j).positionToDisplay=str2double(xml.websites(j).website.positiontodisplay);
%         else
%             model.webSite(j).positionToDisplay=-1;
%         end
%     end
% else
%     model.webSite(1).name=xml.website;
%     model.webSite(1).Location(1)=str2double(xml.locationx);
%     model.webSite(1).Location(2)=str2double(xml.locationy);
%     model.webSite(1).overlayFile=[];
% end

model.archiveDir=[hm.archiveDir xml.continent filesep xml.name filesep 'archive' filesep];
model.type=xml.type;
model.coordinateSystem=xml.coordsys;
model.coordinateSystemType=xml.coordsystype;
model.runid=xml.runid;

%% Roller model
model.roller=0;
if isfield(xml,'roller')
    model.roller=str2double(xml.roller);
end

%% Time zone
if isfield(xml,'timezone')
    model.timeZone=xml.timezone;
else
    model.timeZone=[];
end

% if isfield(xml,'runenv')
%     model.runEnv=xml.runenv;
% else
    model.runEnv=hm.runEnv;
% end
if isfield(xml,'numcores')
    model.numCores=xml.numcores;
else
    model.numCores=hm.numCores;
end

%% BeachWizard
model.beachWizard=[];
if isfield(xml,'beachwizard')
    model.beachWizard=xml.beachwizard;
end

model.figureURL='';

%% Domain

if isfield(xml,'thick')
    fname=xml.thick;
    fname=[dr 'input' filesep fname];
    thck=load(fname);
    model.KMax=length(thck);
    model.thick=thck;
else
    model.KMax=1;
    model.thick(1)=100;
end

if isfield(xml,'ztop')
    model.zTop=str2double(xml.ztop);
else
    model.zTop=0;
end

if isfield(xml,'zbot')
    model.zBot=str2double(xml.zbot);
else
    model.zBot=0;
end

if isfield(xml,'layertype')
    model.layerType=xml.layertype;
else
    model.layerType='sigma';
end

%% Initial conditions
if isfield(xml,'zeta0')
    model.zeta0=str2double(xml.zeta0);
else
    model.zeta0=0;
end

%% Time
if isfield(xml,'timestep')
    model.timeStep=str2double(xml.timestep);
else
    model.timeStep=0;
end
if isfield(xml,'runtime')
    model.runTime=str2double(xml.runtime);
else
    model.runTime=999;
end
if isfield(xml,'starttime')
    model.startTime=str2double(xml.starttime);
else
    model.startTime=0;
end
if isfield(xml,'wavetimestep')
    model.waveTimeStep=str2double(xml.wavetimestep);
else
    model.waveTimeStep=30;
end
model.flowSpinUp=str2double(xml.flowspinup);
model.waveSpinUp=str2double(xml.wavespinup);
if isfield(xml,'histimestep')
    model.hisTimeStep=str2double(xml.histimestep);
else
    model.hisTimeStep=1;
end
if isfield(xml,'maptimestep')
    model.mapTimeStep=str2double(xml.maptimestep);
else
    model.mapTimeStep=60;
end
if isfield(xml,'comtimestep')
    model.comTimeStep=str2double(xml.comtimestep);
else
    model.comTimeStep=0;
end
if isfield(xml,'maptimestep')
    model.wavmTimeStep=str2double(xml.maptimestep);
else
    model.wavmTimeStep=0;
end
if isfield(xml,'priority')
    model.priority=str2double(xml.priority);
else
    model.priority=0;
end

model.deleterestartfiles=1;
if isfield(xml,'deleterestartfiles')
    if strcmpi(xml.deleterestartfiles(1),'n') || strcmpi(xml.deleterestartfiles(1),'0')
        model.deleterestartfiles=0;
    end
end

%% Parameters

if isfield(xml,'roumet')
    model.RouMet=xml.roumet;
else
    model.RouMet='M';
end
if isfield(xml,'ccofu')
    model.ccofu=str2double(xml.ccofu);
else
    model.ccofu=0.022;
end
if isfield(xml,'dpsopt')
    model.DpsOpt=xml.dpsopt;
else
    model.DpsOpt='MAX';
end
if isfield(xml,'dpuopt')
    model.DpuOpt=xml.dpuopt;
else
    model.DpuOpt='MEAN';
end
if isfield(xml,'vicouv')
    model.VicoUV=str2double(xml.vicouv);
else
    model.VicoUV=1;
end
if isfield(xml,'dicouv')
    model.DicoUV=str2double(xml.dicouv);
else
    model.DicoUV=1;
end
if isfield(xml,'filedy')
    model.Filedy=xml.filedy;
else
    model.Filedy=[];    
end
if isfield(xml,'momsol')
    model.momSol=xml.momsol;
else
    model.momSol='Cyclic';
end
if isfield(xml,'cstbnd')
    model.cstBnd=str2double(xml.cstbnd);
else
    model.cstBnd=0;
end
model.SMVelo='euler';
if isfield(xml,'smvelo')
    if strcmpi(xml.smvelo,'glm')
        model.SMVelo='GLM';
    end
end

model.sigcor=0;
if isfield(xml,'sigcor')
    if strcmpi(xml.sigcor(1),'y') || strcmpi(xml.sigcor(1),'1')
        model.sigcor=1;
    end
end

model.nonstationary=1;
if isfield(xml,'stationary')
    if strcmpi(xml.stationary(1),'y') || strcmpi(xml.stationary(1),'1')
        model.nonstationary=0;
    end
end

model.dirSpace='circle';
model.nDirBins=36;

if isfield(xml,'dirspace')
    model.dirSpace=xml.dirspace;
end
if isfield(xml,'ndirbins')
    model.nDirBins=str2double(xml.ndirbins);
end
if isfield(xml,'startdir')
    model.startDir=str2double(xml.startdir);
end
if isfield(xml,'enddir')
    model.endDir=str2double(xml.enddir);
end

if isfield(xml,'flowwaterlevel')
    model.flowWaterLevel=str2double(xml.flowwaterlevel);
else
    model.flowWaterLevel=2;
end
if isfield(xml,'flowvelocity')
    model.flowVelocity=str2double(xml.flowvelocity);
else
    model.flowVelocity=0;
end
if isfield(xml,'flowbedlevel')
    model.flowBedLevel=str2double(xml.flowbedlevel);
else
    model.flowBedLevel=2;
end
if isfield(xml,'flowwind')
    model.flowWind=str2double(xml.flowwind);
else
    model.flowWind=2;
end
if isfield(xml,'maxiter')
    model.maxIter=str2double(xml.maxiter);
else
    model.maxIter=2;
end
if isfield(xml,'morfac')
    model.morFac=str2double(xml.morfac);
else
    model.morFac=1;
end
if isfield(xml,'wavebedfric')
    model.waveBedFric=xml.wavebedfric;
else
    model.waveBedFric='jonswap';
end
if isfield(xml,'wavebedfriccoef')
    model.waveBedFricCoef=str2double(xml.wavebedfriccoef);
else
    model.waveBedFricCoef=0.038;
end

if isfield(xml,'whitecapping')
    model.whiteCapping=xml.whitecapping;
else
    model.whiteCapping='Westhuysen';
end

model.windStress=[1.0000000e-003  0.0000000e+000  2.5000000e-003  3.0000000e+001];

if isfield(xml,'windstress')
    model.windStress=str2num(xml.windstress);
end

model.useDtAirSea=0;
if isfield(xml,'dtairsea')
    if strcmpi(xml.dtairsea(1),'y')
        model.useDtAirSea=1;
    end
end

model.useTidalForces=0;
if isfield(xml,'tidalforces')
    if strcmpi(xml.tidalforces(1),'y')
        model.useTidalForces=1;
    end
end

model.tmzRad=[];
model.includeTemperature=0;
model.includeHeatExchange=0;
if isfield(xml,'temperature')
    if strcmpi(xml.temperature(1),'y')
        model.includeTemperature=1;
        model.includeHeatExchange=1;
    end
    if isfield(xml,'tmzrad')
        model.tmzRad=str2double(xml.tmzrad);
    end
end
if isfield(xml,'heatexchange')
    if strcmpi(xml.heatexchange(1),'y')
        model.includeHeatExchange=1;
    else        
        model.includeHeatExchange=0;
    end
end

if isfield(xml,'secchidepth')
    model.secchidepth=str2double(xml.secchidepth);
else
    model.secchidepth=3;
end
    
model.includeAirPressure=1;
if isfield(xml,'airpressure')
    if strcmpi(xml.airpressure(1),'n')
        model.includeAirPressure=0;
    end
end

model.includeSalinity=0;
if isfield(xml,'salinity')
    if strcmpi(xml.salinity(1),'y')
        model.includeSalinity=1;
    end
end

model.nudge=0;
if isfield(xml,'nudge')
    if strcmpi(xml.nudge(1),'y')
        model.nudge=1;
    end
end

% Discharges
model.discharge=[];
if isfield(xml,'discharges')
    for j=1:length(xml.discharges)
        % defaults
        model.discharge(j).interpolation='linear';
        model.discharge(j).type='regular';
        
        model.discharge(j).name=xml.discharges(j).discharge.name;
        model.discharge(j).m=str2double(xml.discharges(j).discharge.m);
        model.discharge(j).N=str2double(xml.discharges(j).discharge.n);
        model.discharge(j).K=str2double(xml.discharges(j).discharge.k);
        
        if isfield(xml.discharges(j).discharge,'interpolation')
            model.discharge(j).interpolation=xml.discharges(j).discharge.interpolation;
        end
        
        model.discharge(j).q=str2double(xml.discharges(j).discharge.q);
        if isfield(xml.discharges(j).discharge,'salinity')
            model.discharge(j).salinity.constant=str2double(xml.discharges(j).discharge.salinity);
        end
        if isfield(xml.discharges(j).discharge,'temperature')
            model.discharge(j).temperature.constant=str2double(xml.discharges(j).discharge.temperature);
        end
        if isfield(xml.discharges(j).discharge,'tracer1')
            model.discharge(j).tracer(1).constant=str2double(xml.discharges(j).discharge.tracer1);
        end
        if isfield(xml.discharges(j).discharge,'tracer2')
            model.discharge(j).tracer(2).constant=str2double(xml.discharges(j).discharge.tracer2);
        end
        if isfield(xml.discharges(j).discharge,'tracer3')
            model.discharge(j).tracer(3).constant=str2double(xml.discharges(j).discharge.tracer3);
        end
        
    end
end

% Tracers
model.tracer=[];
if isfield(xml,'tracers')
    for j=1:length(xml.discharges)
        model.tracer(j).name=xml.tracers(j).tracer.name;
        model.tracer(j).decay=0;
        if isfield(xml.tracers(j).tracer,'decay')
            model.tracer(j).decay=str2double(xml.tracers(j).tracer.decay);
        end
    end
end


%% Locations
model.size=str2double(xml.size);
try
    model.xLim(1)=str2double(xml.xlim1);
end
try
    model.xLim(2)=str2double(xml.xlim2);
end
try
    model.yLim(1)=str2double(xml.ylim1);
end
try
    model.yLim(2)=str2double(xml.ylim2);
end
try
    model.xLimPlot=model.xLim;
end
try
    model.yLimPlot=model.yLim;
end

if isfield(xml,'xlimplot1')
    model.xLimPlot(1)=str2double(xml.xlimplot1);
    model.xLimPlot(2)=str2double(xml.xlimplot2);
    model.yLimPlot(1)=str2double(xml.ylimplot1);
    model.yLimPlot(2)=str2double(xml.ylimplot2);
end

if isfield(xml,'zlevel')
    model.zLevel=str2double(xml.zlevel);
else
    model.zLevel=0;
end

if isfield(xml,'zslr')
    model.zSeaLevelRise=str2double(xml.zslr);
else
    model.zSeaLevelRise=0;
end

%% XBeach

model.gridform='xbeach';

if isfield(xml,'gridform')
    model.gridform=xml.gridform;
end

if isfield(xml,'xori')
    model.xOri=str2double(xml.xori);
end
if isfield(xml,'yori')
    model.yOri=str2double(xml.yori);
end
if isfield(xml,'dx')
    model.dX=str2double(xml.dx);
end
if isfield(xml,'dy')
    model.dY=str2double(xml.dy);
end
if isfield(xml,'nx')
    model.nX=str2double(xml.nx);
end
if isfield(xml,'ny')
    model.nY=str2double(xml.ny);
end
if isfield(xml,'alpha')
    model.alpha=str2double(xml.alpha);
end

%% Nesting

% Flow
if isfield(xml,'flownested')
    model.flowNestModel=xml.flownested;
    if strcmpi(xml.flownested,'none')
        model.flowNested=0;
    else
        model.flowNested=1;
    end
else
    model.flowNestModel='';
    model.flowNested=0;
end

% model.oceanModel='';
% if isfield(xml,'oceanmodel')
%     model.oceanModel=xml.oceanmodel;
% end

model.oceanmodelnesttypewl='file+astro';
model.oceanmodelnesttypecur='file+astro';

if isfield(xml,'oceanmodelnesttype')
    model.oceanmodelnesttypewl=xml.oceanmodelnesttype;
    model.oceanmodelnesttypecur=xml.oceanmodelnesttype;
end

if isfield(xml,'oceanmodelnesttypewl')
    model.oceanmodelnesttypewl=xml.oceanmodelnesttypewl;
end

if isfield(xml,'oceanmodelnesttypecur')
    model.oceanmodelnesttypecur=xml.oceanmodelnesttypecur;
end

model.wlboundarycorrection=0;
if isfield(xml,'wlboundarycorrection')
    model.wlboundarycorrection=str2double(xml.wlboundarycorrection);
end
if isfield(xml,'flownesttype')
    model.flowNestType=xml.flownesttype;
else
    model.flowNestType='regular';
end

if isfield(xml,'flownestxml')
    model.flowNestXML=xml.flownestedxml;
else
    model.flowNestXML=[];
end

% Wave
model.waveNestNr=0;
if isfield(xml,'wavenested')
    model.waveNestModel=xml.wavenested;
    if strcmpi(xml.wavenested,'none')
        model.waveNested=0;
    else
        model.waveNested=1;
        if isfield(xml,'wavenestnr')
            model.waveNestNr=str2double(xml.wavenestnr);
        end
    end
else
    model.waveNestModel='';
    model.waveNested=0;
end

%% Initial conditions
model.makeIniFile=0;
if isfield(xml,'makeinifile')
    if strcmpi(xml.makeinifile(1),'y')
        model.makeIniFile=1;
    end
end

%% Meteo
% if isfield(xml,'usemeteo')
%     model.useMeteo=xml.usemeteo;
% else
%     model.useMeteo='none';
% end
% if isfield(xml,'meteobackup1')
%     model.backupMeteo=xml.meteobackup1;
% else
%     model.backupMeteo='none';
% end
if isfield(xml,'prcorr')
    model.prCorr=str2double(xml.prcorr);
else
    model.prCorr=101200.0;
end
if isfield(xml,'applypressurecorrection')
    model.applyPressureCorrection=str2double(xml.applypressurecorrection);
else
    model.applyPressureCorrection=0;
end
if isfield(xml,'dxmeteo')
    model.dXMeteo=str2double(xml.dxmeteo);
else
    model.dXMeteo=5000.0;
end
model.dYMeteo=model.dXMeteo;

%% XBeach
if isfield(xml,'morfac')
    model.morFac=xml.morfac;
else
    model.morFac=0;
end


%% Stations
if isfield(xml,'stations')
    j=0;
    switch lower(xml.type)
        case{'delft3dflow','delft3dflowwave'}
            GRID = wlgrid('read', [dr 'input' filesep model.name '.grd']);
            GRID.Z = -10*zeros(size(GRID.X));
    end
    for istat=1:length(xml.stations.stations.station)
        iac=1;
        if isfield(xml.stations.stations.station(istat).station,'active')
            iac=str2double(xml.stations.stations.station(istat).station.active);
        end
                
        if iac
            switch lower(xml.type)
                case{'delft3dflow','delft3dflowwave'}
                    if ~isfield(xml.stations.stations.station(istat).station,'locationm')
                        [m n iindex] = ddb_findStations(str2double(xml.stations.stations.station(istat).station.locationx),...
                            str2double(xml.stations.stations.station(istat).station.locationy),GRID.X,GRID.Y,GRID.Z);
                        if isempty(m)
                            iac=0;
                        else
                            xml.stations.stations.station(istat).station.locationm=num2str(m);
                            xml.stations.stations.station(istat).station.locationn=num2str(n);
                        end
                    end
            end
        end
        
        if iac
            
            j=j+1;
            model.nrStations=j;
            
            model.stations(j).name=xml.stations.stations.station(istat).station.name;
            model.stations(j).longName=xml.stations.stations.station(istat).station.longname;
            model.stations(j).location(1)=str2double(xml.stations.stations.station(istat).station.locationx);
            model.stations(j).location(2)=str2double(xml.stations.stations.station(istat).station.locationy);
            if isfield(xml.stations.stations.station(istat).station,'locationm')
                model.stations(j).m=str2double(xml.stations.stations.station(istat).station.locationm);
                model.stations(j).n=str2double(xml.stations.stations.station(istat).station.locationn);
            end
            model.stations(j).type=xml.stations.stations.station(istat).station.type;
            if isfield(xml.stations.stations.station(istat).station,'toopendap')
                model.stations(j).toOPeNDAP=str2double(xml.stations.stations.station(istat).station.toopendap);
            else
                model.stations(j).toOPeNDAP=0;
            end
            
            if isfield(xml.stations.stations.station(istat).station,'toOPeNDAP')
                model.stations(j).toOPeNDAP=str2double(xml.stations.stations.station(istat).station.toOPeNDAP);
            else
                model.stations(j).toOPeNDAP=0;
            end
            
            if isfield(xml.stations.stations.station(istat).station,'timezone')
                % Use time zone specified in station
                model.stations(j).timeZone=xml.stations.stations.station(istat).station.timezone;
            else
                % Use model time
                model.stations(j).timeZone=model.timeZone;
            end
            
            %% Time-series datasets
            model.stations(j).nrDatasets=0;
            if isfield(xml.stations.stations.station(istat).station,'datasets')
                model.stations(j).nrDatasets=length(xml.stations.stations.station(istat).station.datasets.datasets.dataset);
                for k=1:model.stations(j).nrDatasets
                    model.stations(j).datasets(k).parameter=xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset.parameter;
                    model.stations(j).datasets(k).layer=[];
                    model.stations(j).datasets(k).sp2id=model.stations(j).name;
                    model.stations(j).datasets(k).toOPeNDAP=model.stations(j).toOPeNDAP;
                    if isfield(xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset,'layer')
                        model.stations(j).datasets(k).layer=str2double(xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset.layer);
                    end
                    if isfield(xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset,'sp2id')
                        model.stations(j).datasets(k).sp2id=xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset.sp2id;
                    end
                    if isfield(xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset,'toopendap')
                        model.stations(j).datasets(k).toOPeNDAP=str2double(xml.stations.stations.station(istat).station.datasets.datasets.dataset(k).dataset.toopendap);
                    end
                end
            end
            
            model.stations(j).plots=[];
            model.stations(j).nrPlots=0;
            %% Time-series plots
            if isfield(xml.stations.stations.station(istat).station,'plots')
                model.stations(j).nrPlots=length(xml.stations.stations.station(istat).station.plots.plots.plot);
                for k=1:model.stations(j).nrPlots
                    model.stations(j).plots(k).type='timeseries';
                    if isfield(xml.stations.stations.station(istat).station.plots.plots.plot(k).plot,'type')
                        model.stations(j).plots(k).type=xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.type;
                    end
                    model.stations(j).plots(k).nrDatasets=length(xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset);
                    for id=1:model.stations(j).plots(k).nrDatasets
                        model.stations(j).plots(k).datasets(id).parameter=xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset.parameter;
                        model.stations(j).plots(k).datasets(id).type=xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset.type;
                        model.stations(j).plots(k).datasets(id).source=[];
                        model.stations(j).plots(k).datasets(id).id=[];
                        if isfield(xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset,'source')
                            model.stations(j).plots(k).datasets(id).source=xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset.source;
                        end
                        if isfield(xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset,'id')
                            model.stations(j).plots(k).datasets(id).id=xml.stations.stations.station(istat).station.plots.plots.plot(k).plot.datasets.datasets.dataset(id).dataset.id;
                        end
                    end
                    model.stations(j).storeSP2=0;
                end
            end
        end
    end
end

% model.stations(j).nrParameters=length(xml.stations(j).station.parameters);
%
%         %% Parameters
%         model.stations(j).nrParameters=length(xml.stations(j).station.parameters);
%         for k=1:model.stations(j).nrParameters
%
%             % Defaults
%             model.stations(j).parameters(k).plotCmp=0;
%             model.stations(j).parameters(k).plotObs=0;
%             model.stations(j).parameters(k).plotPrd=0;
%             model.stations(j).parameters(k).obsCode='';
%             model.stations(j).parameters(k).prdCode='';
%             model.stations(j).parameters(k).obsID='';
%             model.stations(j).parameters(k).prdID='';
%             model.stations(j).parameters(k).layer=[];
%             model.stations(j).parameters(k).toOPeNDAP=0;
%
%             model.stations(j).parameters(k).name=xml.stations(j).station.parameters(k).parameter.name;
%
%             if isfield(xml.stations(j).station.parameters(k).parameter,'plotcmp')
%                 model.stations(j).parameters(k).plotCmp=str2double(xml.stations(j).station.parameters(k).parameter.plotcmp);
%             end
%
%             if isfield(xml.stations(j).station.parameters(k).parameter,'plotobs')
%                 model.stations(j).parameters(k).plotObs=str2double(xml.stations(j).station.parameters(k).parameter.plotobs);
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'obssrc')
%                 model.stations(j).parameters(k).obsSrc=xml.stations(j).station.parameters(k).parameter.obssrc;
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'obsid')
%                 model.stations(j).parameters(k).obsID=xml.stations(j).station.parameters(k).parameter.obsid;
%             end
%
%             if isfield(xml.stations(j).station.parameters(k).parameter,'plotprd')
%                 model.stations(j).parameters(k).plotPrd=str2double(xml.stations(j).station.parameters(k).parameter.plotprd);
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'prdsrc')
%                 model.stations(j).parameters(k).prdSrc=xml.stations(j).station.parameters(k).parameter.prdsrc;
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'prdid')
%                 model.stations(j).parameters(k).prdID=xml.stations(j).station.parameters(k).parameter.prdid;
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'layer')
%                 model.stations(j).parameters(k).layer=str2double(xml.stations(j).station.parameters(k).parameter.layer);
%             end
%             if isfield(xml.stations(j).station.parameters(k).parameter,'toopendap')
%                 model.stations(j).parameters(k).toOPeNDAP=str2double(xml.stations(j).station.parameters(k).parameter.toopendap);
%             end
%
%         end
%     end
% end

%% Map Datasets
model.nrMapDatasets=0;
model.fourier=0;
if isfield(xml,'mapdatasets')
    model.nrMapDatasets=length(xml.mapdatasets.mapdatasets.dataset);
    for j=1:model.nrMapDatasets
        model.mapDatasets(j).name=xml.mapdatasets.mapdatasets.dataset(j).dataset.name;
        model.mapDatasets(j).layer=[];
        if isfield(xml.mapdatasets.mapdatasets.dataset(j).dataset,'layer')
            model.mapDatasets(j).layer=str2double(xml.mapdatasets.mapdatasets.dataset(j).dataset.layer);
        end
        switch lower(xml.mapdatasets.mapdatasets.dataset(j).dataset.name)
            case{'peak_water_level','peak_surge'}
                model.fourier=1;
        end
    end
end

%% Map plots
model.nrMapPlots=0;
model.mapPlots=[];
if isfield(xml,'mapplots')
    model.nrMapPlots=length(xml.mapplots.mapplots.mapplot);
    for j=1:model.nrMapPlots
        
        model.mapPlots(j).name=xml.mapplots.mapplots.mapplot(j).mapplot.name;
        model.mapPlots(j).longName=xml.mapplots.mapplots.mapplot(j).mapplot.longname;
        
        model.mapPlots(j).timeStep=[];
        if isfield(xml.mapplots.mapplots.mapplot(j).mapplot,'timestep')
            model.mapPlots(j).timeStep=str2double(xml.mapplots.mapplots.mapplot(j).mapplot.timestep);
        end
        
        model.mapPlots(j).plot=1;
        if isfield(xml.mapplots.mapplots.mapplot(j).mapplot,'plot')
            model.mapPlots(j).plot=str2double(xml.mapplots.mapplots.mapplot(j).mapplot.plot);
        end

        model.mapPlots(j).type='kmz';
        if isfield(xml.mapplots.mapplots.mapplot(j).mapplot,'type')
            model.mapPlots(j).type=xml.mapplots.mapplots.mapplot(j).mapplot.type;
        end

        if isfield(xml.mapplots.mapplots.mapplot(j).mapplot,'datasets')
            
            model.mapPlots(j).nrDatasets=length(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset);
            
            for k=1:model.mapPlots(j).nrDatasets
                
                model.mapPlots(j).datasets(k).name=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.name;
                
                model.mapPlots(j).datasets(k).plotRoutine='patches';
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'plotroutine')
                    model.mapPlots(j).datasets(k).plotRoutine=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.plotroutine;
                end
                
                model.mapPlots(j).datasets(k).plot=1;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'plot')
                    model.mapPlots(j).datasets(k).plot=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.plot);
                end
                
                model.mapPlots(j).datasets(k).component='magnitude';
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'component')
                    model.mapPlots(j).datasets(k).component=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.component;
                end
                
                model.mapPlots(j).datasets(k).arrowLength=3600;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'arrowlength')
                    model.mapPlots(j).datasets(k).arrowLength=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.arrowlength);
                end
                
                model.mapPlots(j).datasets(k).spacing=10000;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'spacing')
                    model.mapPlots(j).datasets(k).spacing=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.spacing);
                end
                
                model.mapPlots(j).datasets(k).thinning=1;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'thinning')
                    model.mapPlots(j).datasets(k).thinning=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.thinning);
                end
                
                model.mapPlots(j).datasets(k).thinningX=1;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'thinningx')
                    model.mapPlots(j).datasets(k).thinningX=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.thinningx);
                end
                
                model.mapPlots(j).datasets(k).thinningY=1;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'thinningy')
                    model.mapPlots(j).datasets(k).thinningY=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.thinningy);
                end
                
                model.mapPlots(j).datasets(k).cLim=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'clim')
                    model.mapPlots(j).datasets(k).cLim=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.clim);
                end

                model.mapPlots(j).datasets(k).cMinCutOff=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'cmincutoff')
                    model.mapPlots(j).datasets(k).cMinCutOff=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.cmincutoff);
                end
                
                model.mapPlots(j).datasets(k).cMaxCutOff=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'cmaxcutoff')
                    model.mapPlots(j).datasets(k).cMaxCutOff=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.cmaxcutoff);
                end
                
                model.mapPlots(j).datasets(k).polygon=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'polygon')
                    model.mapPlots(j).datasets(k).polygon=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.polygon;
                end
                
                model.mapPlots(j).datasets(k).relativeSpeed=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'relativespeed')
                    model.mapPlots(j).datasets(k).relativeSpeed=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.relativespeed);
                end
                
                model.mapPlots(j).datasets(k).scaleFactor=0.001;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'scalefactor')
                    model.mapPlots(j).datasets(k).scaleFactor=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.scalefactor);
                end
                
                model.mapPlots(j).datasets(k).colorBarDecimals=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'colorbardecimals')
                    model.mapPlots(j).datasets(k).colorBarDecimals=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.colorbardecimals);
                end
                
                model.mapPlots(j).datasets(k).colorMap=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'colormap')
                    model.mapPlots(j).datasets(k).colorMap=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.colormap;
                end
                
                model.mapPlots(j).datasets(k).barLabel=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'barlabel')
                    model.mapPlots(j).datasets(k).barLabel=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.barlabel;
                end

                % Argus merged image
                model.mapPlots(j).datasets(k).argusstation=[];
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'argusstation')
                    model.mapPlots(j).datasets(k).argusstation=xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.argusstation;
                end
                model.mapPlots(j).datasets(k).argusxorigin=0;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'argusxorigin')
                    model.mapPlots(j).datasets(k).argusxorigin=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.argusxorigin);
                end
                model.mapPlots(j).datasets(k).argusyorigin=0;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'argusyorigin')
                    model.mapPlots(j).datasets(k).argusyorigin=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.argusyorigin);
                end
                model.mapPlots(j).datasets(k).arguswidth=0;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'arguswidth')
                    model.mapPlots(j).datasets(k).arguswidth=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.arguswidth);
                end
                model.mapPlots(j).datasets(k).argusheight=0;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'argusheight')
                    model.mapPlots(j).datasets(k).argusheight=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.argusheight);
                end
                model.mapPlots(j).datasets(k).argusrotation=0;
                if isfield(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset,'argusrotation')
                    model.mapPlots(j).datasets(k).argusrotation=str2num(xml.mapplots.mapplots.mapplot(j).mapplot.datasets.datasets.dataset(k).dataset.argusrotation);
                end
                
                
                
            end
        end
    end
end

%% Hazards
model.nrHazards=0;
model.hazards=[];
if isfield(xml,'hazards')
    model.nrHazards=length(xml.hazards.hazards.hazard);
    for j=1:model.nrHazards
        model.hazards(j).type=xml.hazards.hazards.hazard(j).hazard.type;
        model.hazards(j).name=xml.hazards.hazards.hazard(j).hazard.name;
        model.hazards(j).longName=xml.hazards.hazards.hazard(j).hazard.longname;
        model.hazards(j).location(1)=str2double(xml.hazards.hazards.hazard(j).hazard.locationx);
        model.hazards(j).location(2)=str2double(xml.hazards.hazards.hazard(j).hazard.locationy);
        model.hazards(j).wlStation=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'wlstation')
            model.hazards(j).wlStation=xml.hazards.hazards.hazard(j).hazard.wlstation;
        end
        model.hazards(j).geoJpgFile=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'geojpgfile')
            model.hazards(j).geoJpgFile=xml.hazards.hazards.hazard(j).hazard.geojpgfile;
        end
        model.hazards(j).geoJgwFile=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'geojgwfile')
            model.hazards(j).geoJgwFile=xml.hazards.hazards.hazard(j).hazard.geojgwfile;
        end
        model.hazards(j).x0=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'x0')
            model.hazards(j).x0=str2double(xml.hazards.hazards.hazard(j).hazard.x0);
        end
        model.hazards(j).y0=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'y0')
            model.hazards(j).y0=str2double(xml.hazards.hazards.hazard(j).hazard.y0);
        end
        model.hazards(j).coastOrientation=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'orientation')
            model.hazards(j).coastOrientation=str2double(xml.hazards.hazards.hazard(j).hazard.orientation);
        end
        model.hazards(j).length1=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'length1')
            model.hazards(j).length1=str2double(xml.hazards.hazards.hazard(j).hazard.length1);
        end
        model.hazards(j).length2=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'length2')
            model.hazards(j).length2=str2double(xml.hazards.hazards.hazard(j).hazard.length2);
        end
        model.hazards(j).width1=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'width1')
            model.hazards(j).width1=str2double(xml.hazards.hazards.hazard(j).hazard.width1);
        end
        model.hazards(j).width2=[];
        if isfield(xml.hazards.hazards.hazard(j).hazard,'width2')
            model.hazards(j).width2=str2double(xml.hazards.hazards.hazard(j).hazard.width2);
        end
    end
end

% model.mapPlots(j).plot=str2double(xml.maps(j).map.plot);
%         model.mapPlots(j).colorMap=xml.maps(j).map.colormap;
%         model.mapPlots(j).longName=xml.maps(j).map.longname;
%         model.mapPlots(j).shortName=xml.maps(j).map.shortname;
%         model.mapPlots(j).Unit=xml.maps(j).map.unit;
%         if isfield(xml.maps(j).map,'barlabel')
%             model.mapPlots(j).BarLabel=xml.maps(j).map.barlabel;
%         else
%             model.mapPlots(j).BarLabel='';
%         end
%         if isfield(xml.maps(j).map,'dtanim')
%             model.mapPlots(j).dtAnim=str2double(xml.maps(j).map.dtanim);
%         else
%             % Default animation time step is 3 hrs
%             model.mapPlots(j).dtAnim=10800;
%         end
%         model.mapPlots(j).Dataset.parameter=xml.maps(j).map.parameter;
%         model.mapPlots(j).Dataset.type=xml.maps(j).map.type;
%
%         if isfield(xml.maps(j).map,'dxcurvec')
%             model.mapPlots(j).Dataset.DxCurVec=str2double(xml.maps(j).map.dxcurvec);
%             model.mapPlots(j).Dataset.DtCurVec=str2double(xml.maps(j).map.dtcurvec);
%         end
%         model.mapPlots(j).Dataset.DdtCurVec=3600;
%         if isfield(xml.maps(j).map,'ddtcurvec')
%             model.mapPlots(j).Dataset.DdtCurVec=str2double(xml.maps(j).map.ddtcurvec);
%         end
%
%         if isfield(xml.maps(j).map,'plotroutine')
%             model.mapPlots(j).Dataset.plotRoutine=xml.maps(j).map.plotroutine;
%         else
%             model.mapPlots(j).Dataset.plotRoutine='PlotPatches';
%         end
%         if isfield(xml.maps(j).map,'layer')
%             model.mapPlots(j).Dataset.layer=str2double(xml.maps(j).map.layer);
%         else
%             model.mapPlots(j).Dataset.layer=[];
%         end
%         model.mapPlots(j).Dataset.cLim=[];
%         if isfield(xml.maps(j).map,'clim')
%             model.mapPlots(j).Dataset.cLim=str2num(xml.maps(j).map.clim);
%         end
%         model.mapPlots(j).Dataset.polygon=[];
%         if isfield(xml.maps(j).map,'polygon')
%             model.mapPlots(j).Dataset.polygon=xml.maps(j).map.polygon;
%         end
%         model.mapPlots(j).colorBarDecimals=1;
%         if isfield(xml.maps(j).map,'colorbardecimals')
%             model.mapPlots(j).colorBarDecimals=str2num(xml.maps(j).map.colorbardecimals);
%         end
%         model.mapPlots(j).thinning=1;
%         if isfield(xml.maps(j).map,'thinning')
%             model.mapPlots(j).thinning=str2num(xml.maps(j).map.thinning);
%         end
%         model.mapPlots(j).thinningX=[];
%         if isfield(xml.maps(j).map,'thinningx')
%             model.mapPlots(j).thinningX=str2num(xml.maps(j).map.thinningx);
%         end
%         model.mapPlots(j).thinningY=[];
%         if isfield(xml.maps(j).map,'thinningy')
%             model.mapPlots(j).thinningY=str2num(xml.maps(j).map.thinningy);
%         end
%         model.mapPlots(j).scaleFactor=0.1;
%         if isfield(xml.maps(j).map,'scalefactor')
%             model.mapPlots(j).scaleFactor=str2num(xml.maps(j).map.scalefactor);
%         end
%
% %         if ~isempty(model.webSite)
% %             model.mapPlots(j).Url=['http://dtvirt5.deltares.nl/~ormondt/' model.webSite '/scenarios/' hm.scenario '/' model.continent '/' model.name '/figures/'];
% %         else
%             model.mapPlots(j).Url='';
% %         end
%     end
% end
%
%% X-Beach Profiles
if isfield(xml,'profiles')
    model.nrProfiles=length(xml.profiles.profiles.profile);
    for j=1:model.nrProfiles
        model.profile(j).name=xml.profiles.profiles.profile(j).profile.name;
        model.profile(j).Location(1)=str2double(xml.profiles.profiles.profile(j).profile.originx);
        model.profile(j).Location(2)=str2double(xml.profiles.profiles.profile(j).profile.originy);
        model.profile(j).originX=str2double(xml.profiles.profiles.profile(j).profile.originx);
        model.profile(j).originY=str2double(xml.profiles.profiles.profile(j).profile.originy);
        model.profile(j).alpha=str2double(xml.profiles.profiles.profile(j).profile.alpha);
        model.profile(j).length=str2double(xml.profiles.profiles.profile(j).profile.length);
        model.profile(j).nX=str2double(xml.profiles.profiles.profile(j).profile.nx);
        model.profile(j).nY=str2double(xml.profiles.profiles.profile(j).profile.ny);
        model.profile(j).dX=str2double(xml.profiles.profiles.profile(j).profile.dx);
        model.profile(j).dY=str2double(xml.profiles.profiles.profile(j).profile.dy);
        model.profile(j).DistBluff=str2double(xml.profiles.profiles.profile(j).profile.distbluff);
        model.profile(j).run=str2double(xml.profiles.profiles.profile(j).profile.run);
        if isfield(xml.profiles.profiles.profile(j).profile,'dtheta')
            model.profile(j).dTheta=str2double(xml.profiles.profiles.profile(j).profile.dtheta);
        else
            model.profile(j).dTheta=5;
        end
        if isfield(xml.profiles.profiles.profile(j).profile,'xgrid')
            model.profile(j).xGrid = xml.profiles.profiles.profile(j).profile.xgrid;
        else
            model.profile(j).xGrid = '';
        end
        if isfield(xml.profiles.profiles.profile(j).profile,'ygrid')
            model.profile(j).yGrid = xml.profiles.profiles.profile(j).profile.ygrid;
        else
            model.profile(j).yGrid = '';
        end
        if isfield(xml.profiles.profiles.profile(j).profile,'zgrid')
            model.profile(j).zGrid = xml.profiles.profiles.profile(j).profile.zgrid;
        else
            model.profile(j).zGrid = '';
        end
        if isfield(xml.profiles.profiles.profile(j).profile,'negrid')
            model.profile(j).neGrid = xml.profiles.profiles.profile(j).profile.negrid;
        else
            model.profile(j).neGrid = '';
        end
    end
end
%% Forecast plots
if isfield(xml,'forecastplot')
    
    model.forecastplot.timeStep=[];
    if isfield(xml.forecastplot,'timestep')
        model.forecastplot.timeStep=str2double(xml.forecastplot.timestep);
    end
    
    if isfield(xml.forecastplot,'xlims')
        model.forecastplot.xlims=str2num(xml.forecastplot.xlims);
    end
    
    if isfield(xml.forecastplot,'ylims')
        model.forecastplot.ylims=str2num(xml.forecastplot.ylims);
    end
    
    if isfield(xml.forecastplot,'clims')
        model.forecastplot.clims=str2num(xml.forecastplot.clims);
    end
    
    if isfield(xml.forecastplot,'scalefactor')
        model.forecastplot.scalefactor=str2num(xml.forecastplot.scalefactor);
    end
    
    if isfield(xml.forecastplot,'thinning')
        model.forecastplot.thinning=str2num(xml.forecastplot.thinning);
    end
    
    if isfield(xml.forecastplot,'ldb')
        model.forecastplot.ldb=xml.forecastplot.ldb;
    end
    
    if isfield(xml.forecastplot,'name')
        model.forecastplot.name=xml.forecastplot.name;
    end
    
    if isfield(xml.forecastplot,'wlstation')
        model.forecastplot.wlstation=xml.forecastplot.wlstation;
    end
    
    if isfield(xml.forecastplot,'weatherstation')
        model.forecastplot.weatherstation=xml.forecastplot.weatherstation;
    end
    
    if isfield(xml.forecastplot,'windstation')
        model.forecastplot.windstation=str2num(xml.forecastplot.windstation);
    end
    
    if isfield(xml.forecastplot,'wavestation')
        model.forecastplot.wavestation=xml.forecastplot.wavestation;
    end
    
    if isfield(xml.forecastplot,'waterstation')
        model.forecastplot.waterstation=xml.forecastplot.waterstation;
    end
    
    if isfield(xml.forecastplot,'kmaxis')
        model.forecastplot.kmaxis=str2num(xml.forecastplot.kmaxis);
    end
    
    if isfield(xml.forecastplot,'archive')
        model.forecastplot.archive=str2double(xml.forecastplot.archive);
    else
        model.forecastplot.archive=0;
    end
    
    model.forecastplot.plot=1;
    if isfield(xml.forecastplot,'plot')
        model.forecastplot.plot=str2double(xml.forecastplot.plot);
    end
else
    model.forecastplot.plot=0;
    model.forecastplot.archive=0;
end

%% Mobile application
if isfield(xml,'mobileapp')
    
    model.mobileapp.timeStep=[];
    if isfield(xml.mobileapp,'timestep')
        model.mobileapp.timeStep=str2double(xml.mobileapp.timestep);
    end
    
    if isfield(xml.mobileapp,'xlims')
        model.mobileapp.xlims=str2num(xml.mobileapp.xlims);
    end
    
    if isfield(xml.mobileapp,'ylims')
        model.mobileapp.ylims=str2num(xml.mobileapp.ylims);
    end
    
    if isfield(xml.mobileapp,'clims')
        model.mobileapp.clims=str2num(xml.mobileapp.clims);
    end
    
    if isfield(xml.mobileapp,'scalefactor')
        model.mobileapp.scalefactor=str2num(xml.mobileapp.scalefactor);
    end
    
    if isfield(xml.mobileapp,'thinning')
        model.mobileapp.thinning=str2num(xml.mobileapp.thinning);
    end
    
    if isfield(xml.mobileapp,'ldb')
        model.mobileapp.ldb=xml.mobileapp.ldb;
    end
    
    if isfield(xml.mobileapp,'name')
        model.mobileapp.name=xml.mobileapp.name;
    end
    
    if isfield(xml.mobileapp,'wlstation')
        model.mobileapp.wlstation=xml.mobileapp.wlstation;
    end
    
    if isfield(xml.mobileapp,'weatherstation')
        model.mobileapp.weatherstation=xml.mobileapp.weatherstation;
    end
    
    if isfield(xml.mobileapp,'windstation')
        model.mobileapp.windstation=str2num(xml.mobileapp.windstation);
    end
    
    if isfield(xml.mobileapp,'wavestation')
        model.mobileapp.wavestation=xml.mobileapp.wavestation;
    end
    
    if isfield(xml.mobileapp,'waterstation')
        model.mobileapp.waterstation=xml.mobileapp.waterstation;
    end
    
    if isfield(xml.mobileapp,'kmaxis')
        model.mobileapp.kmaxis=str2num(xml.mobileapp.kmaxis);
    end
    
    if isfield(xml.mobileapp,'archive')
        model.mobileapp.archive=str2double(xml.mobileapp.archive);
    else
        model.mobileapp.archive=0;
    end
    
    model.mobileapp.plot=1;
    if isfield(xml.mobileapp,'plot')
        model.mobileapp.plot=str2double(xml.mobileapp.plot);
    end
    
    model.mobileapp.thresholdvel=1;
    if isfield(xml.mobileapp,'thresholdvel')
        model.mobileapp.thresholdvel=str2double(xml.mobileapp.thresholdvel);
    end
       
    if isfield(xml.mobileapp,'colormapvel')
        model.mobileapp.colormapvel=xml.mobileapp.colormapvel;
    end
    
    if isfield(xml.mobileapp,'delay')
        model.mobileapp.delay=round(str2double(xml.mobileapp.delay));
    end
else
    model.mobileapp.plot=0;
    model.mobileapp.archive=0;
end
ok=1;
