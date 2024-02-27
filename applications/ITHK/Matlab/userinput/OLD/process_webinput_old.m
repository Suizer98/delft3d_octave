function S = process_webinput(lat,lon,mag,time,name,measure,implementation)

%% Preprocessing Unibest Interactive Tool
% Leon de Jongste, Witteveen+Bos
% last edited: 13-05-2011

%% Process input from Viewer
% Scenario information
S.name = name;
S.duration = min(100,str2double(time));
%S.implementation = min(S.duration,str2double(implementation));
S.implementation = implementation;
S.Nmeasures = length(measure);

% Measures information
id_lat = find(lat==0);
id_contsupp = find(measure==0);
id_singlesupp = find(measure==1);
id_gro = find(measure==2);
id_rev = find(measure==3);
id_distrsupp = find(measure==4);
aa=0;% lat/lon counter total
su=0;gr=0;be=0;rev=0;distr=0;% counters per measure
if ~isempty(measure)
    for ii = 1:length(measure)
        if ismember(ii,id_contsupp)||ismember(ii,id_singlesupp)
            aa=aa+1;
            su = su+1;
            bb=0; % lat/lon counter for measure
            S.nourishment(su).start = implementation(ii);
            S.nourishment(su).magnitude = mag(ii);
            if ismember(ii,id_contsupp)
                S.nourishment(su).category = 'cont';
                S.nourishment(su).stop = S.duration;
            else
                S.nourishment(su).category = 'single';
                S.nourishment(su).stop = implementation(ii)+1;
            end
            while aa<id_lat(ii)
                bb = bb+1;
                S.nourishment(su).lat(bb) = lat(aa);
                S.nourishment(su).lon(bb) = lon(aa);
                aa = aa+1;
           end
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
            aa=aa+1;
            gr=gr+1;
            bb=0; % lat/lon counter for measure
            S.groyne(gr).start = implementation(ii);
            S.groyne(gr).stop = S.duration;
            S.groyne(gr).magnitude = mag(ii);
            while aa<id_lat(ii)
               bb = bb+1;
               S.groyne(gr).lat(bb) = lat(aa);
               S.groyne(gr).lon(bb) = lon(aa);
               aa = aa+1;
            end
        end
        if ismember(ii,id_rev)
            aa=aa+1;
            rev=rev+1;
            bb=0; % lat/lon counter for measure
            S.revetment(rev).start = implementation(ii);
            S.revetment(rev).stop = S.duration;
            S.revetment(rev).magnitude = mag(ii);
            while aa<id_lat(ii)
               bb = bb+1;
               S.revetment(rev).lat(bb) = lat(aa);
               S.revetment(rev).lon(bb) = lon(aa);
               aa = aa+1;
            end
        end
        if ismember(ii,id_distrsupp)
            aa=aa+1;
            distr=distr+1;
            bb=0; % lat/lon counter for measure
            S.distrsupp(distr).start = implementation(ii);
            S.distrsupp(distr).stop = S.duration;
            S.distrsupp(distr).magnitude = mag(ii);
            while aa<id_lat(ii)
               bb = bb+1;
               S.distrsupp(distr).lat(bb) = lat(aa);
               S.distrsupp(distr).lon(bb) = lon(aa);
               aa = aa+1;
            end
        end
    end
end
% Number of phases
yrstop = [];
if  isfield(S,'nourishment')
    for jj = 1:length(S.nourishment)
        if  strcmp(S.nourishment(jj).category,'single')==1
            yrstop = [yrstop S.nourishment(jj).stop];
        end
    end
end
if length(implementation(:,1))>1
     implementation =  implementation';
end
S.phases = unique([0 implementation yrstop]);
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
    idssup = find(ismember(supstart,S.phases(ii)));
    idsgro = find(ismember(grostart,S.phases(ii)));
    idsrev = find(ismember(revstart,S.phases(ii)));
    if ~isempty(idssup)
        S.phase(ii).SOSfile = ['1HOTSPOTS',num2str(ii),'IT.sos'];
        S.phase(ii).supids = idssup;
        for jj=1:length(idssup)
            S.nourishment(idssup(jj)).filename = ['1HOTSPOTS',num2str(ii),'IT.sos'];
        end
    else
        S.phase(ii).SOSfile = ['BASIS.sos'];
    end
    if ~isempty(idsgro)
        S.phase(ii).GROfile = ['BRIJN90A' num2str(ii) '.GRO'];
        S.phase(ii).groids = idsgro;
        for jj=1:length(idsgro)
            S.groyne(idsgro(jj)).filename = ['BRIJN90A' num2str(ii) '.GRO'];
        end
    else
        S.phase(ii).GROfile = ['BASIS.GRO'];
    end
    if ~isempty(idsrev)
        S.phase(ii).REVfile = ['HOLLANDCOAST' num2str(ii) '.REV'];
        S.phase(ii).revids = idsrev;
        for jj=1:length(idsrev)
            S.revetment(idsrev(jj)).filename = ['HOLLANDCOAST' num2str(ii) '.REV'];
        end
    else
        S.phase(ii).REVfile = ['BASIS.REV'];
    end
end   

% % Directory information
% S.inputdir = inputDir;
% S.outputdir = outputDir;