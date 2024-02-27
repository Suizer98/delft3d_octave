function EHY_simulationInputTimes(varargin)
%% EHY_simulationInputTimes
%
% This function calculates the start and stop time w.r.t. the reference date
% of D-FLOW FM, Delft3D and SIMONA models.
% As input, one of the corresponding input files (.mdu / .mdf / siminp) can
% be provided
%
% Example1: EHY_simulationInputTimes
% Example2: EHY_simulationInputTimes('D:\model.mdu')
%
% created by Julien Groenenboom, April 2017

%% general settings
format{1}='yyyymmdd';
format{2}='yyyymmdd HHMMSS';

%% get time info from mdFile
if nargin==0
    option=listdlg('PromptString','Choose between:','SelectionMode','single','ListString',...
        {'Open a .mdu / .mdf or SIMONA file as input','Start with blank fields'},'ListSize',[300 50]);
    if option==1
        disp('Open a .mdu / .mdf / siminp file')
        [filename, pathname]=uigetfile({'*.mdu';'*.mdf';'*siminp*';'*.*'},'Open a .mdu / .mdf / siminp file');
        if isnumeric(filename); disp('EHY_simulationInputTimes stopped by user.'); return; end
        mdFile=[pathname filename];
    elseif option==2
        mdInput={};
        option=  listdlg('PromptString','modelType :','SelectionMode','single','ListString',...
            {'Delft3D','Delft3D-FM','SIMONA'},'ListSize',[300 50]);
        if option==1
            modelType='d3d';HisMapUnit='M';
        elseif option==2
            modelType='dfm';HisMapUnit='S';
        elseif option==3
            modelType='simona';HisMapUnit='M';
        end
        SMH={'S','M','H'};
        option=  listdlg('PromptString','time unit for start/stop date :','SelectionMode','single','ListString',...
            SMH,'ListSize',[300 50]);
        mdInput{2}=SMH{option};
        mdInput{1}=input(['Reference time in format [' format{2} ']: '],'s');
    end
elseif nargin==1
    mdFile=varargin{1};
end

if exist('mdFile','var')
    mdFile=EHY_getMdFile(mdFile);
    modelType=EHY_getModelType(mdFile);
    [pathstr,name,ext]=fileparts(mdFile);
    E=struct;
    [E.refdate,E.tunit,E.tstart,E.tstop]=EHY_getTimeInfoFromMdFile(mdFile);
    
    mdInput{1}=datestr(E.refdate,format{1});
    mdInput{2}=E.tunit;
    mdInput{3}=E.tstart;
    mdInput{5}=E.tstop;
    
    HisMapUnit='M';
    switch modelType
        case 'd3d'
            mdf=delft3d_io_mdf('read',mdFile);
            if isempty(mdf.keywords.flhis)
                mdInput{7}='';mdInput{9}='';mdInput{10}='';
            else
                mdInput{7}=mdf.keywords.flhis(1);
                mdInput{9}=mdf.keywords.flhis(2);
                mdInput{10}=mdf.keywords.flhis(3);
            end
            if isempty(mdf.keywords.flmap)
                mdInput{12}='';mdInput{14}='';mdInput{15}='';
            else
                mdInput{12}=mdf.keywords.flmap(1);
                mdInput{14}=mdf.keywords.flmap(2);
                mdInput{15}=mdf.keywords.flmap(3);
            end
        case 'dfm'
            mdu=dflowfm_io_mdu('read',mdFile);
            if length(mdu.output.HisInterval)==1
                mdInput{9}=mdu.output.HisInterval;
            elseif length(mdu.output.HisInterval)==3
                mdInput{9}=mdu.output.HisInterval(1);
                mdInput{7}=mdu.output.HisInterval(2);
                mdInput{10}=mdu.output.HisInterval(3);
            else
                try
                    mdu.output.HisInterval = cellfun(@str2num,regexp(mdu.output.HisInterval,'\s+','split'));
                    mdInput{9}=mdu.output.HisInterval(1);
                    mdInput{7}=mdu.output.HisInterval(2);
                    mdInput{10}=mdu.output.HisInterval(3);
                end
            end
            if length(mdu.output.MapInterval)==1
                mdInput{14}=mdu.output.MapInterval;
            elseif length(mdu.output.MapInterval)==3
                mdInput{14}=mdu.output.MapInterval(1);
                mdInput{12}=mdu.output.MapInterval(2);
                mdInput{15}=mdu.output.MapInterval(3);
            else
                try
                    mdu.output.MapInterval = cellfun(@str2num,regexp(mdu.output.MapInterval,'\s+','split'));
                    mdInput{14}=mdu.output.MapInterval(1);
                    mdInput{12}=mdu.output.MapInterval(2);
                    mdInput{15}=mdu.output.MapInterval(3);
                end
            end
            HisMapUnit='S';
        case 'simona'
            [pathstr,name,ext]=fileparts(mdFile);
            siminp=readsiminp(pathstr,[name ext]);
            siminp.File=lower(siminp.File);
            keywords={'tfhis','tihis','tlhis','tfmap','timap','tlmap'};
            mdInputInd=[7 9 10 12 14 15];
            for iK=1:length(keywords)
                try
                    lineInd=find(~cellfun(@isempty,strfind(siminp.File,keywords{iK})));
                    line=regexp(siminp.File(lineInd),'\s+','split');
                    lineInd2=find(~cellfun(@isempty,strfind(line{1,1},keywords{iK})));
                    mdInput{mdInputInd(iK)}=str2num(line{1,1}{lineInd2+1});
                catch
                    mdInput{mdInputInd(iK)}=[];
                end
            end
    end
    mdInput=mdInput';
end

duos=[3 4;5 6;7 8;10 11;12 13; 15 16];

%% Keep looping till user stops the script
keepLooping=1;
while keepLooping
    % complement the mdInput
    mdInput=EHY_simulationInputTimes_calc(mdInput,format,HisMapUnit,duos);
    
    prompt={['RefDate (' format{1} '): '],'Tunit (H, M or S): ',...
        ['TStart: Start time w.r.t. RefDate (in TUnit (' mdInput{2} '))'],['TStart: Start time as date (' format{2} ')'],...
        ['TStop: Stop time w.r.t. RefDate (in TUnit (' mdInput{2} '))'],['TStop: Stop time as date (' format{2} ')'],...
        ['His output: Start time w.r.t. RefDate (in ' HisMapUnit '))'],['His output: Start time as date (' format{2} ')'],...
        ['His output - interval in ' HisMapUnit],...
        ['His output: Stop time w.r.t. RefDate (in ' HisMapUnit '))'],['His output: Stop time as date (' format{2} ')'],...
        ['Map output: Start time w.r.t. RefDate (in ' HisMapUnit '))'],['Map output: Start time as date (' format{2} ')'],...
        ['Map output - interval in ' HisMapUnit],...
        ['Map output: Stop time w.r.t. RefDate (in ' HisMapUnit '))'],['Map output: Stop time as date (' format{2} ')']};
    
    % show the mdInput
    
    userInput=inputdlg(prompt,'Input',1,mdInput);
    
    changedLine=[];
    if ~isempty(userInput)
        for ii=1:length(userInput)
            if ~strcmp(mdInput{ii},userInput{ii})
                changedLine=[changedLine; ii];
            end
        end
    elseif isempty(userInput)
        disp([char(10) '* * * EHY_simulationInputTimes was stopped by user * * *' char(10)])
        return
    end
    
    % if RefDate was changed
    if ismember(1,changedLine); userInput([3 5 7 10 12 15])={''}; end
    % if TUnit was changed
    if ismember(2,changedLine); userInput{2}=upper(userInput{2}); userInput([3 5 7 10 12 15])={''}; end
    % if TStart was changed
    if ismember(3,changedLine); userInput{4}=''; elseif ismember(4,changedLine); userInput{3}='';  end
    % if TStop was changed
    if ismember(5,changedLine); userInput{6}=''; elseif ismember(6,changedLine); userInput{5}='';  end
    % ...
    if ismember(7,changedLine); userInput{8}=''; elseif ismember(8,changedLine); userInput{7}='';  end
    if ismember(10,changedLine); userInput{11}=''; elseif ismember(11,changedLine); userInput{10}='';  end
    if ismember(12,changedLine); userInput{13}=''; elseif ismember(13,changedLine); userInput{12}='';  end
    if ismember(15,changedLine); userInput{16}=''; elseif ismember(16,changedLine); userInput{15}='';  end
    
    % complement the userInput
    if keepLooping
        userInput=EHY_simulationInputTimes_calc(userInput,format,HisMapUnit,duos);
    end
    
    changedLine=[];
    for ii=1:length(userInput)
        if ~strcmp(mdInput{ii},userInput{ii})
            changedLine=[changedLine; ii];
        end
    end
    
    % display changes made and effects on other parameters to user
    if ~isempty(changedLine); disp([ char(10) '========================EHY_simulationInputTimes========================']); end
    for iL=1:length(changedLine)
        if ismember(changedLine(iL),duos(:,2))
            disp(['Corresponding ''' prompt{changedLine(iL)} ''': ' num2str(userInput{changedLine(iL)})])
        else
            disp(['Change ''' prompt{changedLine(iL)} ''' to: ' num2str(userInput{changedLine(iL)})])
        end
    end
    if ~isempty(changedLine); disp(['========================================================================' char(10)]); end
    
    if keepLooping
        mdInput=userInput;
    end
    
    [YesNoID,~]=  listdlg('PromptString','Show al (new) relevant master definition file settings?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 50]);
    if YesNoID==1
        switch modelType
            case 'dfm'
                disp(['RefDate = ' mdInput{1}])
                disp(['Tunit = ' mdInput{2}])
                disp(['Tstart = ' mdInput{3} ])
                disp(['Tstop = ' mdInput{5} ])
                disp(['HisInterval = ' mdInput{9} '   ' mdInput{7} '   ' mdInput{10} ])
                disp(['MapInterval = ' mdInput{14} '   ' mdInput{12} '   ' mdInput{15} ])
            case 'd3d'
                disp(['Itdate = #' mdInput{1}(1:4) '-' mdInput{1}(5:6) '-' mdInput{1}(7:8)  '#'])
                disp(['Tunit = #' mdInput{2} '#'])
                disp(['Tstart = ' mdInput{3} ])
                disp(['Tstop = ' mdInput{5} ])
                disp(['Flhis = ' mdInput{7} '   ' mdInput{9} '   ' mdInput{10} ])
                disp(['Flmap = ' mdInput{12} '   ' mdInput{14} '   ' mdInput{15} ])
            case 'simona'
                disp(['DATE = ''' datestr(datenum(mdInput{1},format{1}),'dd mmm yyyy') ''''])
                disp(['TSTART = ' mdInput{3}])
                disp(['TSTOP = ' mdInput{5} ])
                disp(['TFHIS = ' mdInput{7} ])
                disp(['TIHIS = ' mdInput{9} ])
                disp(['TLHIS = ' mdInput{10} ])
                disp(['TFMAP = ' mdInput{12} ])
                disp(['TIMAP = ' mdInput{14} ])
                disp(['TLMAP = ' mdInput{15} ])
        end
    end
end
end
%% calculate missing fields
function A=EHY_simulationInputTimes_calc(A,format,HisMapUnit,duos)
while length(A)<16
    A{end+1}=[];
end
refdate=datenum(A{1},format{1});
tunitUser=A{2};
A(duos(:,1))=cellfun(@num2str,A(duos(:,1)),'uniformoutput',0);
for ii=1:length(duos)
    if duos(ii,1)>6
        tunit=HisMapUnit;
    else
        tunit=tunitUser;
    end
    if isempty(A{duos(ii,1)}) && ~isempty(A{duos(ii,2)})
        A{duos(ii,1)}=(datenum(A{duos(ii,2)},format{2})-refdate)*timeFactor('D',tunit);
    elseif ~isempty(A{duos(ii,1)}) && isempty(A{duos(ii,2)})
        A{duos(ii,2)}=datestr(refdate+str2num(A{duos(ii,1)})*timeFactor(tunit,'D'),format{2});
    end
end
A=cellfun(@num2str,A,'UniformOutput',0);
end

function line=findLineOrQuit(fid,wantedLine)
line=fgetl(fid);
while isempty(strfind(line,wantedLine)) && ischar(line)
    line=fgetl(fid);
end
if ~ischar(line) && line==-1
    error('Could not find the requested line')
end
end