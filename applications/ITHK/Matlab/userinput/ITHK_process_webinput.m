function S = ITHK_process_webinput(measure,lat,lon,implementation,len,vol,fill,time,name,slr,coast,eco,dunes,costs,economy,safety,recreation,residency,CLRdata)

% %% Add info from default files
% D = dir([S.settings.outputdir '*.GRO']);
% if ~isempty(D)
%     GROdata = ITHK_io_readGRO([S.settings.outputdir D(1).name]);
%     S.phase(1).GROfile
% end
% D = dir([S.settings.outputdir '*.REV']);
% if ~isempty(D)
%     REVdata = ITHK_io_readGRO([S.settings.outputdir D(1).name]);
% end
% D = dir([S.settings.outputdir '*.SOS']);
% if ~isempty(D)
%     SOSdata = ITHK_io_readSOS([S.settings.outputdir D(1).name]);
% end
% D = dir([S.settings.outputdir '*.OBW']);
% if ~isempty(D)
%     OBWdata = ITHK_io_readSOS([S.settings.outputdir D(1).name]);
% end

%% Process input from Viewer
%% Scenario information
S.name = name;
S.duration = min(95,str2double(time));
%S.implementation = min(S.duration,str2double(implementation));
S.implementation = implementation;
S.Nmeasures = length(measure);

%% Measures information
%id_lat = find(lat==0);
id_contsupp = find(measure==0);
id_singlesupp = find(measure==1);
id_gro = find(measure==2);
id_rev = find(measure==3);
id_distrsupp = find(measure==4);
id_distrsupp_single = find(measure==5);
su=0;gr=0;rev=0;
%be=0;distr=0;% counters per measure
if ~isempty(measure)
    for ii = 1:length(measure)
        if ismember(ii,id_contsupp)||ismember(ii,id_singlesupp)||ismember(ii,id_distrsupp)||ismember(ii,id_distrsupp_single)
            su = su+1;
            S.nourishment(su).start = implementation(ii);
            S.nourishment(su).volume = vol(ii);
            S.nourishment(su).width = len(ii);
            S.nourishment(su).volperm = vol(ii)/len(ii);
            if ismember(ii,id_contsupp)
                S.nourishment(su).category = 'cont';
                S.nourishment(su).stop = S.duration;
            elseif ismember(ii,id_singlesupp)
                S.nourishment(su).category = 'single';
                S.nourishment(su).stop = implementation(ii)+1;
            elseif ismember(ii,id_distrsupp)
                S.nourishment(su).category = 'distr';
                S.nourishment(su).stop = S.duration;
            else
                S.nourishment(su).category = 'distrsupp_single';
                S.nourishment(su).stop = implementation(ii)+1;
            end
            S.nourishment(su).lat = lat(ii);
            S.nourishment(su).lon = lon(ii);
        end
%         if ismember(ii,id_beach)
%             aa=aa+1;
%             be=be+1;
%             bb=0; % lat/lon counter for measure
%             S.beachextension(be).magnitude = mag(ii);
%             S.beachextension(be).magnitude = mag(ii);
%             while aa<id_lat(ii)
%                 bb = bb+1;
%                 S.beachextension(be).lat(bb) = lat(aa);
%                 S.beachextension(be).lon(bb) = lon(aa);
%                 aa = aa+1;
%            end
%         end
        if ismember(ii,id_gro)
            gr=gr+1;
            S.groyne(gr).start = implementation(ii);
            S.groyne(gr).stop = S.duration;
            S.groyne(gr).length = len(ii);
            S.groyne(gr).lat = lat(ii);
            S.groyne(gr).lon = lon(ii);
        end
        if ismember(ii,id_rev)
            rev=rev+1;
            S.revetment(rev).start = implementation(ii);
            S.revetment(rev).stop = S.duration;
            S.revetment(rev).length = len(ii);
            S.revetment(rev).fill = fill(ii);
            S.revetment(rev).lat = lat(ii);
            S.revetment(rev).lon = lon(ii);
        end
%         if ismember(ii,id_distrsupp)
%             distr=distr+1;
%             S.distrsupp(distr).start = implementation(ii);
%             S.distrsupp(distr).stop = S.duration;
%             S.distrsupp(distr).volume = vol(ii);
%             S.distrsupp(distr).width = len(ii);
%             S.distrsupp(distr).lat = lat(ii);
%             S.distrsupp(distr).lon = lon(ii);
%         end
    end
end

%% Number of phases
% Number of phases is based on implementation of measures and type of
% nourishments
yrstop = [];
if  isfield(S,'nourishment')
    for jj = 1:length(S.nourishment)
        if  strcmp(S.nourishment(jj).category,'single')==1 || strcmp(S.nourishment(jj).category,'distrsupp_single')==1
            yrstop = [yrstop S.nourishment(jj).stop];
        end
    end
end
if ~isempty(implementation)
    if length(implementation(:,1))>1
         implementation =  implementation';
    end
    S.phases = unique([0 implementation yrstop CLRdata.to-CLRdata.from(1)]);
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
    for ii=1:length(S.nourishment)
        supstart(ii) = S.nourishment(ii).start; 
    end
end
if  isfield(S,'groyne')
    for ii=1:length(S.groyne)
        grostart(ii) = S.groyne(ii).start; 
    end
end
if  isfield(S,'revetment')
    for ii=1:length(S.revetment)
        revstart(ii) = S.revetment(ii).start; 
    end
end
idssup = [];idsgro = [];idsrev = [];
for ii = 1:length(S.phases)
    S.phase(ii).SOSfile = '';S.phase(ii).GROfile = '';S.phase(ii).REVfile = '';
end
S.userdefined = [];

start = S.phases;
stop = [S.phases(2:end) S.duration];
% Add measures to phases based on start times
for ii = 1:length(S.phases)
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
        for kk=ii:length(S.phases)
            S.phase(kk).GROfile = ['groyne' num2str(ii) '.GRO'];
            S.phase(kk).groids = idsgro;
        end
        for rr=1:length(idsgro)
            S.groyne(idsgro(rr)).filename = ['groyne' num2str(ii) '.GRO'];
        end
    elseif isempty(S.phase(ii).GROfile)
        S.phase(ii).GROfile = [CLRdata.GRO{1} '.GRO'];  
    end
    if ~isempty(idsrev)
        for kk=ii:length(S.phases)
            S.phase(kk).REVfile = ['revetment' num2str(ii) '.REV'];
            S.phase(kk).revids = idsrev;
        end
        for rr=1:length(idsrev)
            S.revetment(idsrev(rr)).filename = ['revetment' num2str(ii) '.REV'];
        end
    elseif isempty(S.phase(ii).REVfile)
        S.phase(ii).REVfile = [CLRdata.REV{1} '.REV']; 
    end
end

%% Process indicators
S.indicators.coast = str2double(coast);
S.indicators.dunes = str2double(dunes);
S.indicators.eco = str2double(eco);
S.indicators.costs = str2double(costs);
S.indicators.economy = str2double(economy);
S.indicators.safety = str2double(safety);
S.indicators.recreation = str2double(recreation);
S.indicators.residency = str2double(residency);
S.indicators.slr = str2double(slr);