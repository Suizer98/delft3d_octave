function varargout=EHY_runTimeInfo(varargin)
%% runTimeInfo=EHY_runTimeInfo(varargin)
%
% Based on an D-FLOW FM, Delft3D or SIMONA input file (.mdu / .mdf /
% siminp) the simulation period, calculation time and corresponding
% computational time is computed.
%
% Example1: EHY_runTimeInfo
% Example2: runTimeInfo=EHY_runTimeInfo('D:\model.mdu')
%
% created by Julien Groenenboom, March 2017
%%
if nargin>0
    mdFile=varargin{1};
else
    disp('Open a .mdu / .mdf / siminp file')
    [filename, pathname]=uigetfile({'*.mdu';'*.mdf';'*siminp*';'*.*'},'Open a .mdu / .mdf / siminp file');
    if isnumeric(filename); disp('EHY_runTimeInfo stopped by user.'); return; end
    mdFile=[pathname filename];
end
mdFile=EHY_getMdFile(mdFile);
if isempty(mdFile)
    error('No .mdu, .mdf or siminp found in this folder')
end
modelType=EHY_getModelType(mdFile);
[pathstr,name,ext]=fileparts(mdFile);
[refdate,tunit,tstart,tstop]=EHY_getTimeInfoFromMdFile(mdFile);

% startDate
factor=timeFactor(tunit,'D');
startDate=refdate+tstart*factor;

% simPeriod_S
factor=timeFactor(tunit,'S');
simPeriod_S=(tstop-tstart)*factor;

try % if simulation has finished
    switch modelType
        case 'dfm'
            % mdu
            mdu=dflowfm_io_mdu('read',mdFile);
            
            % grid info
            gridInfo=EHY_getGridInfo(mdFile,{'no_layers','dimensions'});
            noLayers=gridInfo.no_layers;
            
            % out.txt or .dia (when running via dimr)
            outputDir = EHY_getOutputDirFM(mdFile);
            outFile = [pathstr filesep 'out.txt'];
            if exist([pathstr filesep 'out.txt'])
                outFileDetails = dir(outFile);
            end
            if ~exist(outFile) || outFileDetails.bytes<1000
                % look for .dia file
                if exist([outputDir name '_0000.dia'])
                    outFile=[outputDir name '_0000.dia'];
                elseif exist([outputDir name '.dia'])
                    outFile=[outputDir name '.dia'];
                end
            end
                            
            fid = fopen(outFile,'r');
            fseek(fid, 0, 'eof'); % set position indicator to end of file
            fileSize = ftell(fid);
            charperline = 88;
            out = {};
            fseek(fid, 0, 'bof'); % set position indicator to begin of file
            if fileSize < 10*10^7 % small file
                out = textscan(fid,'%s','delimiter','\n','CommentStyle','** INFO   :  Solver converged in');
                out = out{1,1};
            else % big file
                while length(out)<200 && fileSize/charperline>2 %minimum of read lines at end of file is 200, add safety for short files
                    %length(out)
                    HeaderLines = round(fileSize/charperline); % skip big part of out.txt/*.dia.
                    fseek(fid, 0, 'bof'); % set position indicator to begin of file
                    out = textscan(fid,'%s','delimiter','\n','HeaderLines',HeaderLines,'CommentStyle','** INFO   :  Solver converged in');
                    out = out{1,1};
                    charperline = charperline+1;
                end
            end
            fclose(fid);

            % partitions
            mduFiles = dir([pathstr filesep name '_*.mdu']);
            noPartitions = max([1 length(mduFiles)]);
            
            % number of netnodes and netelements
            noNetNodes = gridInfo.no_NetNode;
            if isfield(gridInfo,'no_NetElem') && ~isnan(gridInfo.no_NetElem)
                noNetElem =  gridInfo.no_NetElem;
            end

            % average timestep
            wantedLine=regexptranslate('wildcard','** INFO   : average timestep * (s)  :');
            outInd=find(~cellfun(@isempty,regexp(out,wantedLine)));
            line2=regexp(out{outInd(1)},'\s+','split');
            aveTimeStep_S=str2double(line2{end});
            
            % max time step
            maxTimeStep_S=mdu.time.DtMax;
            
            % initTime_S
            wantedLine=regexptranslate('wildcard','** INFO   : time modelinit * (s)  :');
            outInd=find(~cellfun(@isempty,regexp(out,wantedLine)));
            line2=regexp(out{outInd(1)},'\s+','split');
            initTime_S=str2double(line2{end});
            
            % realTime_S
            wantedLine=regexptranslate('wildcard','** INFO   : time steps*+ plots*  (s)  :');
            outInd=find(~cellfun(@isempty,regexp(out,wantedLine)));
            line2=regexp(out{outInd(1)},'\s+','split');
            realTime_S=str2double(line2{end});
            
            % initextforcTime_S
            wantedLine=regexptranslate('wildcard','** INFO   : time iniexternalforc. * (s)  :');
            outInd=find(~cellfun(@isempty,regexp(out,wantedLine)));
            if ~isempty(outInd)
                line2=regexp(out{outInd(1)},'\s+','split');
                initextforcTime_S=str2double(line2{end});
            end

        case 'd3d'
            % mdf
            mdf=delft3d_io_mdf('read',mdFile);
            
            % layers
            noLayers=mdf.keywords.mnkmax(3);
            
            % dia
            if exist([pathstr filesep 'tri-diag.' name ],'file') % first check if run was done in parallel
                diaFile=[pathstr filesep 'tri-diag.' name ];
            else %  not in parallel
                diaFile=[pathstr filesep 'tri-diag.' name '-001'];
            end
            % partitions
            shFiles=dir([pathstr filesep '*.sh']);
            if ~isempty(shFiles)
                fid=fopen([pathstr filesep shFiles(1).name],'r');
                lineNodes=findLineOrQuit(fid,'#$ -pe distrib ');
                fclose(fid);
                fid=fopen([pathstr filesep shFiles(1).name],'r');
                lineCores=findLineOrQuit(fid,'export processes_per_node=');
                fclose(fid);
                if ~isempty(lineCores)
                    noPartitions=str2num(strrep(lineNodes,'#$ -pe distrib ',''))*str2num(strrep(lineCores,'export processes_per_node=',''));
                end
            else
                noPartitions=1;
            end
            
            % realTime_S
            fid=fopen(diaFile,'r');
            line=findLineOrQuit(fid,'|Total                |');
            line2=regexp(line,'\s+','split');
            realTime_S=str2double(line2{3});
            
        case 'simona'
            % dia
            directory=dir([pathstr filesep 'waqpro-m*']);
            diaFile=[pathstr filesep directory(1).name];
            fid=fopen(diaFile,'r');
            
            % partitions
            line=findLineOrQuit(fid,'PARTMETHOD'); line=fgetl(fid);
            noPartitions=str2num(strrep(line,'NPART',''));
            
            % realTime_S
            line=findLineOrQuit(fid,'Simulation started at date:');
            line2=regexp(line,'\s+','split');
            while length(line2{8})<6;  line2{8}=['0' line2{8}]; end % 6 digits
            while length(line2{10})<6; line2{10}=['0' line2{10}]; end % 6 digits
            t0=datenum([line2{8} line2{10}],'yyyymmddHHMMSS');
            line=findLineOrQuit(fid,'Simulation ended   at date:');
            line2=regexp(line,'\s+','split');
            while length(line2{8})<6;  line2{8}=['0' line2{8}]; end % 6 digits
            while length(line2{10})<6; line2{10}=['0' line2{10}]; end % 6 digits
            tend=datenum([line2{8} line2{10}],'yyyymmddHHMMSS');
            realTime_S=(tend-t0)*24*60*60;
    end
end
fclose all;

%% Store all data in struct
% path
runTimeInfo.mdFile = fullfile(mdFile);
[~,name,ext] = fileparts(mdFile);
runTimeInfo.mdName=[name ext];

% number of layers
if exist('noLayers','var')
    if noLayers==0; noLayers=1; end
    runTimeInfo.noLayers=noLayers;
end
    
% simulation period
runTimeInfo.startDate=datestr(startDate);
runTimeInfo.endDate=datestr(datenum(startDate)+simPeriod_S/3600/24);

runTimeInfo.simPeriod_S=simPeriod_S;
runTimeInfo.simPeriod_M=runTimeInfo.simPeriod_S/60;
runTimeInfo.simPeriod_H=runTimeInfo.simPeriod_S/3600;
runTimeInfo.simPeriod_D=runTimeInfo.simPeriod_H/24;
runTimeInfo.simPeriod_Y=runTimeInfo.simPeriod_D/365.25;

if exist('aveTimeStep_S','var')
    runTimeInfo.aveTimeStep_S=aveTimeStep_S;
end
if exist('maxTimeStep_S','var')
    runTimeInfo.maxTimeStep_S=maxTimeStep_S;
end

if exist('realTime_S','var') % if simulation has finished
    % runtime
    runTimeInfo.realTime_S=realTime_S;
    runTimeInfo.realTime_M=runTimeInfo.realTime_S/60;
    runTimeInfo.realTime_H=runTimeInfo.realTime_S/3600;
    runTimeInfo.realTime_D=runTimeInfo.realTime_H/24;
    
    % computational time
    runTimeInfo.compTime_minPerDay=(runTimeInfo.realTime_S/60)/(runTimeInfo.simPeriod_S/3600/24);
    runTimeInfo.compTime_dayPerYear=runTimeInfo.compTime_minPerDay/60/24*365;
    
    %initialisation time
    if exist('initTime_S','var')
        runTimeInfo.initTime_S=initTime_S;
        runTimeInfo.initTime_M=runTimeInfo.initTime_S/60;
    end
    
    %initialisation of external forcing time
    if exist('initextforcTime_S','var')
        runTimeInfo.initextforcTime_S=initextforcTime_S;
        runTimeInfo.initextforcTime_M=runTimeInfo.initextforcTime_S/60;
    end
    
    % partitions
    if exist('noPartitions','var')
        runTimeInfo.numberOfPartitions = noPartitions;
    end
    % noNetNodes
    if exist('noNetNodes','var')
        runTimeInfo.numberOfNetNodes = noNetNodes;
    end
    % noNetElem
    if exist('noNetElem','var')
        runTimeInfo.numberOfNetElem = noNetElem;
    end
    
else
    runTimeInfo.comment='Simulation has probably not finished yet or crashed';
    try 
        [percentage,ETAline] = EHY_simulationStatus(mdFile);
        runTimeInfo.status=[num2str(percentage,'%0.1f') '%'];
        if ~isempty(ETAline)
           runTimeInfo.ETA = ETAline;
        end
    end
    
end
runTimeInfo % disp struct with info
if nargout==1
    varargout{1}=runTimeInfo;
end

end
%%
function line=findLineOrQuit(fid,wantedLine)
line=fgetl(fid);
wantedLine2=regexptranslate('wildcard',wantedLine);
while ischar(line) && isempty(regexp(line,wantedLine2))
    line=fgetl(fid);
end

if ~ischar(line) && line==-1
    line=[];
end
end
