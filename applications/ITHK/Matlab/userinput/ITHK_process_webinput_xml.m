function S = ITHK_process_webinput_xml(xml,CLRdata)

%% Process input from Viewer
if isfield(xml.data,'features')
    features = xml.data.features;
    for ii = 1:size(xml.data.features,1)
        if isfield(features(ii),'properties');
            if ~isempty(features(ii).properties)
                if isfield(features(ii).properties,'name')
                    measure{ii} = features(ii).properties.name;
                    if isfield(features(ii).properties,'type')
                       type(ii) = features(ii).properties.type;
                    else
                       type(ii) = NaN;
                    end
                    lon(ii) = features(ii).properties.lon;
                    lat(ii) = features(ii).properties.lat;
                    S.implementation(ii) = features(ii).properties.year;
                    len(ii) = features(ii).properties.length;
                    volume(ii) = features(ii).properties.volume*1e6;
                    fillup(ii) = features(ii).properties.fillup;
                end
            end
        end
    end
end

%% Scenario information
try
    S.name = [xml.data.features(1).properties.scenarioname '_' xml.uniqueID];
    S.duration = min(95,xml.data.features(1).properties.duration);
catch
    S.name = [xml.data.scenarioname '_' xml.uniqueID];
    S.duration = min(95,xml.data.duration);
end

S.Nmeasures = size(measure,2);

%% Measures information
id_supp = find(strcmp(measure,'Nourishment'));
id_rev = find(strcmp(measure,'Revetment'));
id_gro = find(strcmp(measure,'Groyne'));

% id_lat = find(lat==0);
% id_contsupp = find(measure==0);
% id_singlesupp = find(measure==1);
% id_gro = find(measure==2);
% id_rev = find(measure==3);
% id_distrsupp = find(measure==4);

su=0;gr=0;rev=0;
if ~isempty(measure)
    for ii = 1:size(measure,2)
        if ismember(ii,id_supp)
            su = su+1;
            S.nourishment(su).start = S.implementation(ii);
            S.nourishment(su).volume = volume(ii);
            S.nourishment(su).width = len(ii);
            S.nourishment(su).volperm = volume(ii)/len(ii);
            if type(ii) == 0;
                S.nourishment(su).category = 'cont';
                S.nourishment(su).stop = S.duration;
            elseif type(ii) == 1;
                S.nourishment(su).category = 'single';
                S.nourishment(su).stop = S.implementation(ii)+1;
            elseif type(ii) == 4;
                S.nourishment(su).category = 'distr';
                S.nourishment(su).stop = S.duration;
            elseif type(ii) == 5;
                S.nourishment(su).category = 'distrsupp_single';
                S.nourishment(su).stop = S.implementation(ii)+1;
            end
            S.nourishment(su).lat = lat(ii);
            S.nourishment(su).lon = lon(ii);
        end
        if ismember(ii,id_gro)
            gr=gr+1;
            S.groyne(gr).start = S.implementation(ii);
            S.groyne(gr).stop = S.duration;
            S.groyne(gr).length = len(ii);
            S.groyne(gr).lat = lat(ii);
            S.groyne(gr).lon = lon(ii);
        end
        if ismember(ii,id_rev)
            rev=rev+1;
            S.revetment(rev).start = S.implementation(ii);
            S.revetment(rev).stop = S.duration;
            S.revetment(rev).length = len(ii);
            S.revetment(rev).fill = fillup(ii);
            S.revetment(rev).lat = lat(ii);
            S.revetment(rev).lon = lon(ii);
        end
    end
end

%% Number of phases
% Number of phases is based on implementation of measures and type of
% nourishments
yrstop = [];
if  isfield(S,'nourishment')
    for jj = 1:size(S.nourishment,2)
        if  strcmp(S.nourishment(jj).category,'single')==1 || strcmp(S.nourishment(jj).category,'distrsupp_single')==1
            yrstop = [yrstop S.nourishment(jj).stop];
        end
    end
end
if ~isempty(S.implementation)
    if size(S.implementation,1)>1
         S.implementation =  S.implementation';
    end
    S.phases = unique([0 S.implementation yrstop]);
elseif length(CLRdata.to)>1
    S.phases = [0 CLRdata.to-CLRdata.from(1)];
else
    S.phases = 0;
end
S.initphases = [CLRdata.from-CLRdata.from(1)];

%% Add measures per phase
% Get start times
supstart = []; revstart = []; grostart = [];
if  isfield(S,'nourishment')
    for ii=1:size(S.nourishment,2)
        supstart(ii) = S.nourishment(ii).start; 
    end
end
if  isfield(S,'groyne')
    for ii=1:size(S.groyne,2)
        grostart(ii) = S.groyne(ii).start; 
    end
end
if  isfield(S,'revetment')
    for ii=1:size(S.revetment,2)
        revstart(ii) = S.revetment(ii).start; 
    end
end
idssup = [];idsgro = [];idsrev = [];
for ii = 1:size(S.phases,2)
    S.phase(ii).SOSfile = '';S.phase(ii).GROfile = '';S.phase(ii).REVfile = '';
end
S.userdefined = [];

start = S.phases;
stop = [S.phases(2:end) S.duration];
% Add measures to phases based on start times
for ii = 1:size(S.phases,2)
    phaseid = find(ismember(S.initphases,S.phases(ii)));
    if ~isempty(phaseid)
        S.phase(ii).ini = {CLRdata.GRO{phaseid},CLRdata.SOS{phaseid},CLRdata.REV{phaseid},CLRdata.OBW{phaseid}};
    end  
    S.phase(ii).start = start(ii);
    S.phase(ii).stop = stop(ii);
    idssup = find(ismember(supstart,S.phases(ii)));
    idsgro = find(ismember(grostart,S.phases(ii)));
    idsrev = find(ismember(revstart,S.phases(ii)));
    if ~isempty(idssup)
        for jj=1:length(idssup)
            if strcmp(S.nourishment(idssup(jj)).category,'single')                
                S.phase(ii).supcat{jj} = 'single';
            elseif strcmp(S.nourishment(idssup(jj)).category,'distrsupp_single')                
                S.phase(ii).supcat{jj} = 'distrsupp_single';                
            elseif strcmp(S.nourishment(idssup(jj)).category,'distr')
                % If nourishment is continuous, nourishment should be taken
                % into account in every phase after implementation
                for kk=ii:length(S.phases)
                    S.phase(kk).SOSfilecont = 'nourishment_cont.sos';
                end
                S.phase(ii).supcat{jj} = 'distr';
            else
                % If nourishment is continuous, nourishment should be taken
                % into account in every phase after implementation
                for kk=ii:length(S.phases)
                    S.phase(kk).SOSfilecont = 'nourishment_cont.sos';
                end
                S.phase(ii).supcat{jj} = 'cont';
            end 
            S.phase(ii).SOSfile = ['nourishment',num2str(ii),'.sos'];
            S.phase(ii).supids = idssup;
            %S.nourishment(idssup(jj)).filename = ['1HOTSPOTS',num2str(ii),'IT.sos'];
        end
    elseif isfield(S.phase(ii),'SOSfilecont')
           S.phase(ii).SOSfile ='nourishment_cont.sos';
    else
        S.phase(ii).SOSfile = [CLRdata.SOS{1} '.SOS'];    
    end
    if ~isempty(idsgro)
        for kk=ii:size(S.phases,2)
            S.phase(kk).GROfile = ['groyne' num2str(ii) '.GRO'];
            S.phase(kk).groids = idsgro;
        end
        for jj=1:length(idsgro)
            S.groyne(idsgro(jj)).filename = ['groyne' num2str(ii) '.GRO'];
        end
    elseif isempty(S.phase(ii).GROfile)
        S.phase(ii).GROfile = [CLRdata.GRO{1} '.GRO'];
    end
    if ~isempty(idsrev)
        for kk=ii:size(S.phases,2)
            S.phase(kk).REVfile = ['revetment' num2str(ii) '.REV'];
            S.phase(kk).revids = idsrev;
        end
        for jj=1:length(idsrev)
            S.revetment(idsrev(jj)).filename = ['revetment' num2str(ii) '.REV'];
        end
    elseif isempty(S.phase(ii).REVfile)
        S.phase(ii).REVfile = [CLRdata.REV{1} '.REV'];
    end
end

%% Process indicators
if isfield(xml.data,'settings')
    S.indicators.coast = xml.data.settings.Coastline;
    S.indicators.dunes = xml.data.settings.Dunes;
    S.indicators.eco = xml.data.settings.Ecology;
    S.indicators.costs = xml.data.settings.Costs;
    S.indicators.economy = xml.data.settings.Economy;
    S.indicators.safety = xml.data.settings.Safety;
    S.indicators.recreation = xml.data.settings.Recreation;
    S.indicators.residency = xml.data.settings.Residency;
    S.indicators.slr = xml.data.settings.Sea_level_rise; 
end