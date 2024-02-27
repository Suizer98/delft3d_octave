function varargout=EHY_simulationStatus(varargin)
%% EHY_simulationStatus(varargin)
%
% This function returns the status of a D-FLOW FM, Delft3D and SIMONA simulation.
%
% Example1: EHY_simulationStatus
% Example2: percentage = EHY_simulationStatus('D:\run1\model.mdu');
%
% created by Julien Groenenboom, August 2017
%%
if nargin == 0
    disp('Open a .mdu, .mdf or SIMONA file as input')
    [filename, pathname] = uigetfile({'*.mdu';'*.mdf';'*siminp*';'*.*'},'Open a .mdu, .mdf or SIMONA file as input');
    if isnumeric(filename); disp('EHY_simulationStatus stopped by user.'); return; end
    mdFile = [pathname filename];
elseif nargin == 1
    mdFile = varargin{1};
end

%%
mdFile = EHY_getMdFile(mdFile);
if isempty(mdFile)
    error('No .mdu, .mdf or siminp found in this folder')
end
modelType = EHY_getModelType(mdFile);

[refdate,tunit,tstart,tstop] = EHY_getTimeInfoFromMdFile(mdFile,modelType);
simPeriod_S = (tstop-tstart)*timeFactor(tunit,'S');
simPeriod_D = (tstop-tstart)*timeFactor(tunit,'D');

switch modelType
    case 'dfm'
        [pathstr, name, ext] = fileparts(mdFile);
        outputDir = EHY_getOutputDirFM(mdFile);
        mdu = dflowfm_io_mdu('read',mdFile);
        
        if isfield(mdu.output,'StatsInterval') && ~isempty(mdu.output.StatsInterval) && mdu.output.StatsInterval > 0
            if exist([outputDir name '_0001.dia'],'file')
                diaFile = [outputDir name '_0001.dia'];
            else
                error('to be implemented')
            end
            
            fid = fopen(diaFile,'r');
            out = textscan(fid,'%s','delimiter','\n','CommentStyle','** INFO   :  Solver converged in');
            out = out{1,1};
            fclose(fid);
            
            % Sim. time done   Sim. time left   Real time used   Real time left Steps left Complete% Interval-averaged time step
            wantedLine2 = regexptranslate('wildcard','** INFO   :*d*:*:*d*:*:*d*:*:*d*:*:*%');
            ind = find(~cellfun(@isempty,regexp(out,wantedLine2)),1,'last');
            StatsIntervalLine = out{ind};
            
            d_ind = strfind(StatsIntervalLine,'d');
            runPeriod_S = str2num(StatsIntervalLine(d_ind(1)-4:d_ind-1)) * timeFactor('d','s');
            
        elseif ~isempty(dir([outputDir '*_timings.txt'])) % try to get the runPeriod from the timings file
            D = dir([outputDir '*_timings.txt']);
            timingsFile = [outputDir filesep D(1).name];
            fid = fopen(timingsFile,'r');
            while feof(fid) ~= 1
                line = fgetl(fid);
            end
            fclose(fid);
            line = regexp(line,'\s+','split');
            runPeriod_S = str2num(line{2})-tstart*timeFactor(tunit,'S');
            
            if mod((tstop-tstart)*timeFactor(tunit,'S'),mdu.output.TimingsInterval) ~= 0
                if exist([outputDir name '_0001.dia'],'file')
                    fid = fopen([outputDir name '_0001.dia'],'r');
                elseif exist([pathstr 'out.txt'],'file')
                    fid = fopen([pathstr 'out.txt'],'r');
                else
                    error('debug needed')
                end
                l = fgetl(fid);
                while feof(fid) ~= 1
                    if isempty(strfind(l,'Computation finished at'))
                        l = fgetl(fid);
                    else
                        runPeriod_S = simPeriod_S; % 100% completed!
                        break
                    end
                end
                fclose(fid);
                
            end
        else % get the runPeriod from the his nc file
            disp('Simulation status can be determined (much) faster when specifying StatsInterval > 0 and/or TimingsInterval > 0 in the .mdu')
            hisncfiles = dir([outputDir '*his*.nc']);
            if ~isempty(hisncfiles)
                hisncfile = [outputDir hisncfiles(1).name];
            else
                disp('No output (*_his.nc) file available yet, model has not started or not finished initializing yet')
                return
            end
            infonc = ncinfo(hisncfile);
            indNC = strmatch('time',{infonc.Dimensions.Name},'exact');
            no_times = infonc.Dimensions(indNC).Length;
            nctimesEnd = nc_varget(hisncfile,'time',no_times-1,1); % sec from ref date
            runPeriod_S = nctimesEnd-tstart*timeFactor(tunit,'S');
        end
        runPeriod_D = runPeriod_S/3600/24;
        
    case 'd3d'
        [pathstr, name, ext] = fileparts(mdFile);
        D = dir([pathstr '\*.o*']);
        [~,order] = sort([D.datenum]);
        runFile = [pathstr filesep D(order(end)).name];
        fid = fopen(runFile,'r');
        while feof(fid) ~= 1
            line = fgetl(fid);
            if ~isempty(strfind(line,'Time to finish'))
                line2 = line;
            end
        end
        fclose(fid);
        line2 = regexp(line2,'\s+','split');
        indexPerc = find(~cellfun('isempty',strfind(line2,'%')));
        runperiod_perc = str2num(strrep((line2{indexPerc}),'%',''))/100;
        
        runPeriod_S = simPeriod_S*runperiod_perc;
        runPeriod_D = runPeriod_S*timeFactor('S','D');
    case 'simona'
        [pathstr, name, ext] = fileparts(mdFile);
        D = dir([pathstr '\waqpro-m.*']);
        [~,order] = sort([D.datenum]);
        runFile = [pathstr filesep D(order(end)).name];
        fid = fopen(runFile,'r');
        while feof(fid) ~= 1
            line = fgetl(fid);
            if ~isempty(strfind(line,'Corresponding date & time'))
                line2 = line;
            end
        end
        fclose(fid);
        line2 = regexp(line2,'\s+','split');
        runPeriod_D = datenum(strtrim(sprintf('%s ',line2{end-1:end})))-refdate-tstart*timeFactor('M','D');
        runPeriod_S = runPeriod_D*timeFactor('D','S');
end

percentage = runPeriod_S/simPeriod_S*100;

disp(['Status of ' name ext ': ' num2str(round(runPeriod_D)) '/' num2str(round(simPeriod_D)) ' of simulation days - ',...
    sprintf('%0.1f',percentage) '%']);

if percentage < 100 && strcmp(modelType,'dfm')
    ETAline = '';
    try
        if exist('StatsIntervalLine','var')
            ETAline = ETA(mdFile,percentage,StatsIntervalLine);
        else
            ETAline = ETA(mdFile,percentage);
        end
        disp(ETAline)
    end
end

if nargout == 1
    varargout{1} = percentage;
elseif nargout == 2
    varargout{1} = percentage;
    varargout{2} = ETAline;
end

end

%% ETA
function ETAline = ETA(mdFile,percentage,StatsIntervalLine)
% Estimated time of arrival (when is simulation expected to be done?)

if exist('StatsIntervalLine','var')
    % Sim. time done   Sim. time left   Real time used   Real time left Steps left Complete% Interval-averaged time step
    d_ind = strfind(StatsIntervalLine,'d');
    line = StatsIntervalLine(d_ind(4)-3:d_ind(4)+9);
    days = str2num(StatsIntervalLine(d_ind(4)-3:d_ind(4)-1));
    time = str2num(StatsIntervalLine(d_ind(4)+2:d_ind(4)+3))/24 + str2num(StatsIntervalLine(d_ind(4)+5:d_ind(4)+6))/1440;
    
    timeNeededToFinish = days + time;
else
    outFile = [fileparts(mdFile) filesep 'out.txt'];
    
    if exist(outFile,'file')
        % datenumStart is in out.txt
        str2find = '* File creation date:';
        fID = fopen(outFile,'r');
        found = false;
        while ~feof(fID) && ~found
            line = fgetl(fID);
            if length(line)>22 && strcmp(line(1:22),'* File creation date: ')
                found = true;
                datenumStart = datenum(line(23:end),'HH:MM:ss, dd-mm-yyyy');
            end
        end
        fclose(fID);
    end
    
    % datenumStart is not in out.txt but in *.o*-file
    if ~exist('datenumStart','var')
        oFile = dir([fileparts(mdFile) filesep '*.o*']);
        if isempty(oFile) % one more folder up if coupled with D-Waves
            oFile = dir([fileparts(fileparts(mdFile)) filesep '*.o*']);
        end
        oFile = [oFile(end).folder filesep oFile(end).name]; % (end) to take the last run (highest number)
        fID = fopen(oFile,'r');
        found = false;
        while ~feof(fID) && ~found
            line = fgetl(fID);
            if length(line)>26 && strcmp(line(1:6),'Dimr [')
                found = true;
                datenumStart = datenum(line(7:25),'yyyy-mm-dd HH:MM:ss');
            end
        end
        fclose(fID);
    end
    
    timeNeededToFinish = (now-datenumStart)/percentage*(100-percentage);
end

datenumEnd = datestr(now + timeNeededToFinish);
if timeNeededToFinish > 1
    ETAline = ['Simulation is expected to be finished in ' sprintf('%.2f',timeNeededToFinish) ' days at ' datenumEnd];
elseif timeNeededToFinish*24 > 1
    timeNeededToFinish = timeNeededToFinish*timeFactor('d','h');
    ETAline = ['Simulation is expected to be finished in ' sprintf('%.2f',timeNeededToFinish) ' hours at ' datenumEnd];
else
    timeNeededToFinish = timeNeededToFinish*timeFactor('d','m');
    ETAline = ['Simulation is expected to be finished in ' sprintf('%.2f',timeNeededToFinish) ' minutes at ' datenumEnd];
end

end
