function [RD maxRD Z result WL_t] = getDuneErosion_Prob2B(PD50, PWL_t, PHsig_t, PTp_t, PProfileFluct, PDuration, PGust, PAccuracy, maxRD, CaseNr, varargin) %#ok<INUSL,STOUT>
%GETDUNEEROSION_PROB2B  routine to calculate dune erosion based on Prob2B input

testrun = any(strcmpi(varargin, 'test'));

%% get info from ini-file
global basepath resultpath CaseNr_old Globals

newCase = isempty(CaseNr_old) || CaseNr_old ~= CaseNr;

ST = dbstack;
CalledFromProb2B = strcmp(ST(2).name, 'prob2bcalc');

if newCase
    if CalledFromProb2B
        dbstate off
    end
    if isempty(basepath)
        basepath = cd;
    end
    CaseNr_old = CaseNr;
    if ~strcmp(basepath(end), filesep)
        basepath(end+1) = filesep;
    end
    resultpath = [basepath 'Case_' num2str(CaseNr) filesep];
    INIfname = [resultpath 'Case_' num2str(CaseNr) '.ini'];
    if ~isempty(maxRD)
        if ~isempty(findstr(Globals, ' maxRD ')) % predefined maxRD (from Prob2B or testfile)
            Globals = strrep(Globals, ' maxRD ', ' ');
        end
        maxRDpredef = maxRD;
    end
    clear maxRD
    clear global Globals
    global Globals
    [str, Globals] = getProb2bINI(INIfname);
    eval(['clear ' Globals]); %#ok<NODEF> % clear all global variables which are to be used in the present Case
    eval(Globals); %#ok<NODEF> % create empty global variables
    if ~exist('maxRDpredef', 'var') % no predefined maxRD
        global maxRD
        for i = 1 : length(str) % evaluate all
            eval(str{i}) %fill those variables by evaluating the statements in the INI file
        end
    else % predefined maxRD (from Prob2B or testfile)
        Globals = strrep(Globals, ' maxRD ', ' ');
        for i = 1 : length(str)
            if isempty(findstr(str{i}, 'maxRD')) % evaluate all, except maxRD
                eval(str{i}) %fill those variables by evaluating the statements in the INI file
            end
        end
        maxRD = maxRDpredef;
    end
%     save(['WS' num2str(CaseNr) '.mat']) % save the workspace for checking purposes
else
    if isempty(maxRD)
        clear maxRD
        global maxRD
    end
    eval(Globals); %#ok<NODEF>
end

%% STEP 1; get input parameters
Nrcommands = size(command); %#ok<USENS>
for i = 1 : Nrcommands(1)
    if ~isempty(command{i,1})
        eval(command{i,1})
    else
        break
    end
end

%% STEP 2; get DUROS erosion
writemessage('init')
DuneErosionSettings('set','ProfileFluct', ProfileFluct);
writemessage(11,'Start first step: Get and fit DUROS profile');
[result, Volume, x00min, x0max, x0except] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t);

%% STEP 3; get input additional erosion
Erosion = -Volume; %#ok<NASGU>

for i = i : Nrcommands(1)
    if ~isempty(command{i,2})
        eval(command{i,2})
    end
end

%% STEP 4; get additional erosion
writemessage(13,'Start third step: get Additional erosion');
if TargetVolume < 0 %#ok<NODEF>
    x = [result(1).xLand; result(1).xActive; result(1).xSea];
    z = [result(1).zLand; result(1).z2Active; result(1).zSea];
    x2 = [WL_t-max(zInitial) 0 x0max-x00min]'; 
    z2 = [max(zInitial) WL_t WL_t]';
    result(end+1) = getDuneErosion_additional(x, z, x2, z2, WL_t, x00min, result(1).info.x0, x0except, TargetVolume, []);
elseif TargetVolume > 0 % tric to also be able to deal with positive TargetVolumes (effectively reducing the erosion)
    x = [result(1).xLand; result(1).xActive; result(1).xSea];
    z = [result(1).zLand; result(1).zActive; result(1).zSea];
    x2 = [WL_t-max(zInitial) 0 x0max-x00min]'; 
    z2 = [max(zInitial) WL_t WL_t]';
    TargetVolume = Volume + TargetVolume;
    result(end+1) = getDuneErosion_additional(x, z, x2, z2, WL_t, result(1).info.x0, x0max, x0except, TargetVolume, []);
end
%% STEP 5; process messages
messages=writemessage('get');
for i=1:length(result)
    ids=find([messages{:,1}]==10+i,1,'last');
    ids_next=find([messages{:,1}]==10+i+1,1,'first');
    if isempty(ids_next)
        ids_next=size(messages,1)+1;
    end
    result(i).info.messages=messages(ids+1:ids_next-1,:);
end

RD = xRef - result(end).xActive(1);

Z = maxRD - RD;

if maxRD == round(maxRD)
    maxRDstr = num2str(maxRD,'%03i');
else
    maxRDstr = num2str(maxRD,'%05.1f');
end

runflag = true;

%% write realisation info to file (last set of data will be the designpoint)
% filename = [resultpath 'DP_Case_' num2str(CaseNr,'%g') '_maxRD=' maxRDstr '.txt'];
variables = strread('D50, WL_t, Hsig_t, Tp_t, ProfileFluct, Duration, Gust, Accuracy', '%s', 'delimiter', ',');
% fid = fopen(filename, 'a');
% fprintf(fid, '\n%15s%15s%15s\n', '%', 'P', 'value');
for i = 1:length(variables)
    if strcmp(variables{i}, 'Duration')
        Duration = getNormDist(PDuration, muDuration, sigmaDuration);
    elseif strcmp(variables{i}, 'Gust')
        Gust = getNormDist(PGust, muGust, sigmaGust);
    elseif strcmp(variables{i}, 'Accuracy')
        Accuracy = getNormDist(PAccuracy, muAccuracy, sigmaAccuracy);
    end
%     fprintf(fid, '%15s%15e%15e\n', variables{i}, eval(['P' char(variables{i})]), eval(char(variables{i})));
end
% fclose(fid);
%     save(['WS' num2str(CaseNr) '.mat']) % save the workspace for checking purposes

% %% STEP 5; write P-values in file
% ST = dbstack;
% writeResults2file = strcmp(ST(2).name, 'prob2bcalc');
% if writeResults2file
%     filename = [resultpath 'Pvalues_Case_' num2str(CaseNr,'%g') '_maxRD=' maxRDstr '.txt'];
%     if exist(filename, 'file')
%         fileinfo = dir(filename);
%         maxfileage = datenum([0 0 0 0 10 0]); % no older than 10 minutes
%         clearFile = diff([fileinfo.datenum now]) > maxfileage; % clearFile is true when file is older than maxfileage
%         if clearFile
%             permission = 'w';
%         else
%             permission = 'a';
%         end
%     else
%         permission = 'w';
%     end
%     fid = fopen(filename, permission);
%     if strcmp(permission, 'w')
%         fprintf(fid, '%%%s\n', 'PD50, PWL_t, PHsig_t, PTp_t, PProfileFluct, PDuration, PGust, PAccuracy');
%     end
%     fprintf(fid, '%e %e %e %e %e %e %e %e\n', [PD50, PWL_t, PHsig_t, PTp_t, PProfileFluct, PDuration, PGust, PAccuracy]);
%     fclose(fid);
% end
% 
% %% STEP 6; write values in file
% if writeResults2file
%     filename = [resultpath 'Values_Case_' num2str(CaseNr,'%g') '_maxRD=' maxRDstr '.txt'];
%     if exist(filename, 'file')
%         fileinfo = dir(filename);
%         maxfileage = datenum([0 0 0 0 10 0]); % no older than 10 minutes
%         clearFile = diff([fileinfo.datenum now]) > maxfileage; % clearFile is true when file is older than maxfileage
%         if clearFile
%             permission = 'w';
%         else
%             permission = 'a';
%         end
%     else
%         permission = 'w';
%     end
%     fid = fopen(filename, permission);
%     if strcmp(permission, 'w')
%         fprintf(fid, '%%%s\n', 'D50, WL_t, Hsig_t, Tp_t, ProfileFluct, Duration, Gust, Accuracy, Erosion, RD');
%     end
%     fprintf(fid, '%e %e %e %e %e %e %e %e %e %e\n', [D50, WL_t, Hsig_t, Tp_t, ProfileFluct, Duration, Gust, Accuracy, Erosion, RD]);
%     fclose(fid);
% end

%% STEP 5; write P-values in file
variables = getInputVariables(mfilename);
reportvariableNrs = [1:4 6 8];
reportPvariables = cell2mat(cellfun(@(x) [x ', '], {variables{reportvariableNrs}}, 'UniformOutput', false));
reportPvariables = reportPvariables(1:end-2);
reportvariables = cell2mat(cellfun(@(x) strrep([' ' x ','], ' P', ' '), {variables{reportvariableNrs}}, 'UniformOutput', false));
reportvariables = strtrim(reportvariables(1:end-1));
for i = reportvariableNrs
    if strcmp(variables{i}(2:end), 'Duration')
        Duration = getNormDist(PDuration, muDuration, sigmaDuration);
    elseif strcmp(variables{i}(2:end), 'Gust')
        Gust = getNormDist(PGust, muGust, sigmaGust);
    elseif strcmp(variables{i}(2:end), 'Accuracy')
        Accuracy = getNormDist(PAccuracy, muAccuracy, sigmaAccuracy);
    end
end

Z = maxRD - RD;

persistent cnt
if isempty(cnt)
    cnt = 0;
end

ST = dbstack;
writeResults2file = strcmp(ST(2).name, 'prob2bcalc'); % write to file if called from prob2bcalc
if writeResults2file
    filename1 = [resultpath 'Pvalues_Case_' num2str(CaseNr,'%g') '_maxRD=' maxRDstr '.txt'];
    filename2 = [resultpath 'Values_Case_' num2str(CaseNr,'%g') '_maxRD=' maxRDstr '.txt'];
    if exist(filename1, 'file')
        fileinfo = dir(filename1);
        maxfileage = datenum([0 0 0 0 10 0]); % no older than 10 minutes
        clearFile = diff([fileinfo.datenum now]) > maxfileage; % clearFile is true when file is older than maxfileage
        if clearFile
            permission = 'w';
        else
            permission = 'a';
        end
        cnt = cnt + 1;
    else
        permission = 'w';
        cnt = 1;
    end
    if ~testrun
        fid1 = fopen(filename1, permission);
        fid2 = fopen(filename2, permission);
    else
        [fid1 fid2] = deal(1);
    end
    if strcmp(permission, 'w')
        fprintf(fid1, '%s\n', sprintf('%% runflag, #, %s', reportPvariables));
        fprintf(fid2, '%s\n', sprintf('%% runflag, #, %s, RD ', reportvariables));
    end
    format1 = '%1.0f %03i';
    for i = 1:length(reportvariableNrs)
        format1 = [format1 sprintf('%s', ' %e')]; %#ok<AGROW>
    end
    fprintf(fid1, [format1 '\n'], runflag, cnt, eval(['[' reportPvariables ']']));
    fprintf(fid2, [format1 ' %e\n'], runflag, cnt, eval(['[' reportvariables ']']), RD);
    if ~testrun
        fclose(fid1);
        fclose(fid2);
    end
end

if ~testrun
%     filename = [cd '\Case_' num2str(CaseNr, '%02i') '\maxRD=' maxRDstr '\result' num2str(cnt, '%03i') '.mat'];
%     if ~exist(fileparts(filename), 'dir')
%         mkdir(fileparts(filename));
%     end
%     save(filename, 'D', 'RD', 'CaseNr', 'maxRD')
else
    filename = tempname;
    save(filename, 'RD', 'CaseNr', 'maxRD', 'result')
    disp(['<a href="matlab: load(''' filename ''');">load ' filename '</a>'])
end
