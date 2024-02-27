function this=optiReadSedEroData(this,dataGroup,iType,root,weights)

% OPTIREADSEDERODATA - reads sedimentation/erosion data in optiStruct
%
% Reads sedimentation/erosion data in optiStruct from specified source type
% specified with iType and specified root dir/file.
% 
% Usage:
%     optiStruct=optiReadSedEroData(optiStruct,dataGroup,iType,root,weights(for certain iTypes))
%
% in which iType is numeric and can have the following values:
%   1 - one trim-file with all conditions
%   2 - series of trim-files (one trim per condition); No mormerge
%   3 - series of trim-files (one trim per condition); With mormerge
%   4 - old opti method with map-files
%
% and root is respectively the root directory of opti input (1), a fullpath
% trim-filename for option (2), the root directory with simulation
% directories (one per condition) containing the trim-files or similar to
% (3), but for a simulation with mormerge, including a 'merge' directory
% and *.mm file. 
% For option 1-2 a tekal weight factor file must be supplied as full filename string 
% in weights, or an array sized [Nx1] or [1xN] (N = number of conditions) containing 
% weight factors (0 - 1) in the order of the initial conditions


if ~isfield(this.input(dataGroup), 'trimTimeStep')
    this.input(dataGroup).trimTimeStep=0;
end

if nargin<4
    error('Insufficient input arguments supplied.');
    return
end

if isempty(iType)
    error('iType not recognised.');
    return
end

if nargin==4&(iType==1|iType==2)
    error('Need also a weights tekal file or an array with weight factors.');
    return
end

if ~isempty(this.input(dataGroup).dataTransect)
    warning('Transects are not used in case of sedEroData.');
end
curDir=pwd;

switch iType
    
    case 4
        % for this case, a runall.bat and a opti.inp are required. The map-files should be stored in seperate directories
        % with the folder name equal to the condition number and the map-file name should be 'dif.map'.
        cd(root)
        fid=fopen('opti.inp');
        dum=strtok(fgetl(fid)); % aantal punten in m-richting inlezen
        dum=strtok(fgetl(fid)); % aantal punten in n-richting inlezen
        nc=str2num(char(strtok(fgetl(fid)))); % aantal condities inlezen
        this.optiSettings.maxIter=str2num(char(strtok(fgetl(fid)))); % aantal iteraties inlezen
        fclose(fid);
        
        % read runall.bat
        % namen van condities en bijbehorende weegfactoren inlezen uit runall.bat
        [dum dum cond dum dum dum dum dum dum W0]=textread('runall.bat','%s%s%n%n%n%n%n%n%n%n\n');
        W0=0.01*W0; %omrekenen van procenten naar factoren
        
        if length(cond)~=nc
            error('check number of conditions in input files');
            return
        end
        
        
        
        % inlezen berekende bodemveranderingen per conditie (zc) en
        % gewogen gemiddelde bodemverandering (zm) aan de hand van de initiele weegfactoren (W0)
        hW = waitbar(0,'Reading computed bottom changes for each condition'); %waitbar
        for ic=1:nc
            tek=tekal('open',[num2str(cond(ic)) '\dif.map']);
            if ic==1
                xCoord=tek.Field.Data(:,:,1); 
                yCoord=tek.Field.Data(:,:,2);
                this.input(dataGroup).dataGridInfo=size(xCoord);
                this.input(dataGroup).coord=[xCoord(:) yCoord(:)];
            end
            
            waitbar(ic/nc,hW);
            
            %Stash in this optiStruct
            tempData=tek.Field.Data(:,:,3);            
            this.input(dataGroup).data(:,ic)=tempData(:);
            this.input(dataGroup).data(this.input(dataGroup).coord(:,1)==999.999|this.input(dataGroup).coord(:,1)==-999)=nan;
            
        end
        close(hW)
        
        %Store rest of data in this optiStruct
        if size(W0,1)~=1
            W0=W0';
        end
        this.weights = W0;
        
        
    case 1
        % for now: each time step in the trim-file represents a condition
        % manual input of weight coefficients
        if isstr(weights)
            tek=tekal('read',weights);
            W0=tek.Field.Data(:,2);
        elseif isnumeric(weights)
            W0=weights;
        end
        if size(W0,2)~=1
            W0=W0';
        end

        N=vs_use(root,'quiet');
        
        if isempty(this.input(dataGroup).trimTimeStep)
            this.input(dataGroup).trimTimeStep=[2:length(N.GrpDat(1).SizeDim); 1:(length(N.GrpDat(1).SizeDim)-1)];
        elseif size(this.input(dataGroup).trimTimeStep,1)==1
            this.input(dataGroup).trimTimeStep(2,:)=[1 this.input(dataGroup).trimTimeStep(1,2:end)];
        end

        nc=size(this.input(dataGroup).trimTimeStep,2); %length(vs_get(N,'map-info-series','ITMAPC')-1;
        xCoord=vs_get('map-const','XZ','quiet');
        yCoord=vs_get('map-const','YZ','quiet');
        this.input(dataGroup).dataGridInfo=size(xCoord);
        this.input(dataGroup).coord=[xCoord(:) yCoord(:)];
        DPS=vs_get(N,'map-sed-series','DPS','quiet');
        hW = waitbar(0,'Reading computed bottom changes for each condition'); %waitbar
        for ic=1:nc
            tempData=DPS{this.input(dataGroup).trimTimeStep(1,ic)}-DPS{this.input(dataGroup).trimTimeStep(2,ic)};
            this.input(dataGroup).data(:,ic)=tempData(:);
            waitbar(ic/nc,hW);
        end
        close(hW)
        
        %Store rest of data in this optiStruct
        if size(W0,1)~=1
            W0=W0';
        end
        this.weights = W0;
        
    case 2
        % seperate trim-files for each condition
        % manual input of weight coefficients
        if isstr(weights)
            tek=tekal('read',weights);
            W0=tek.Field.Data(:,2);
        elseif isnumeric(weights)
            W0=weights;
        else
            error('Weight factors not understood');
            return
        end
        if prod(size(this.input(dataGroup).trimTimeStep))>1
            this.input(dataGroup).trimTimeStep=this.input(dataGroup).trimTimeStep(1);
            warning('trimTimeStep should be a [1x1] array, only 1 value will be used now!');
        end
        cd(root);
        pat=dir([this.input(dataGroup).dataDirPrefix '*']);
        pat={pat([pat.isdir]==1).name}';
        if isempty(pat)
            error(['No directories found in ' root ' with prefix ' this.input(dataGroup).dataDirPrefix]);
            return
        end
        
        nam=dir([pat{1} filesep 'trim*.dat']);
        if isempty(this.input(dataGroup).dataFilePrefix)
            if length(nam) > 1
                error('Multiple trim files in directory found. Please specify in optiStruct.dataFilePrefix the runID of the trims to use!');
                return
            end
        else
            nam.name=['trim-' this.input(dataGroup).dataFilePrefix '.dat'];
        end
        
        for ii=1:length(pat)
            trimNames{ii}=[pat{ii} filesep nam.name];
        end
        hW = waitbar(0,'Reading computed bottom changes for each condition'); %waitbar
        for ic=1:size(trimNames,2)
            N=vs_use(trimNames{ic},'quiet');
            if ic==1
                xCoord=vs_get('map-const','XZ','quiet');
                yCoord=vs_get('map-const','YZ','quiet');
                this.input(dataGroup).dataGridInfo=size(xCoord);
                this.input(dataGroup).coord=[xCoord(:) yCoord(:)];
            end
            tempData=vs_get(N,'map-sed-series',{this.input(dataGroup).trimTimeStep},'DPS','quiet')-vs_get(N,'map-sed-series',{1},'DPS','quiet');
            this.input(dataGroup).data(:,ic)=tempData(:);
            waitbar(ic/size(trimNames,2),hW);
        end
        close(hW)   
        
        %Store rest of data in this optiStruct
        if size(W0,1)~=1
            W0=W0';
        end
        this.weights = W0;
        
    case 3
        % seperate trim-files for each condition INCL mormerge
        if ~isdir([root filesep this.input(dataGroup).dataDirPrefix])
            error(['No mormerge directory found in ' root ' with name ' this.input(dataGroup).dataDirPrefix '. Please define in optiStruct.dataDirPrefix!']);
            return
        end
        
        if prod(size(this.input(dataGroup).trimTimeStep))>1
            this.input(dataGroup).trimTimeStep=this.input(dataGroup).trimTimeStep(1);
            warning('trimTimeStep should be a [1x1] array, only 1 value will be used now!');
        end
        
        cd([root filesep this.input(dataGroup).dataDirPrefix]);
        mergeFile = dir('*.mm');
        
        if length(mergeFile) > 1
            error('Please verify that only 1 mm-file is present...');
            return
        end
        
        merge=textread(mergeFile.name,'%s','delimiter','\n','headerlines',9);
        
        weightFac = 0;
        
        for ii= 1 : length(merge)
            [dum, temp]             = strtok(char(merge(ii)),'=');
            [tCondMap, tWeightFac]  = strtok(temp(2:end),':');
            condMap{ii}             = cellstr(tCondMap(~isspace(tCondMap)));
            weightFac(ii)           = str2num(tWeightFac(2:end));
        end
        
        W0 = weightFac / sum (weightFac);
        
        hW = waitbar(0,'Reading computed bottom changes for each condition'); %waitbar
        for ic=1:length(condMap)
            cd(['..\' char(condMap{ic})]);
            nam=dir('trim*.dat');
            if isempty(this.input(dataGroup).dataFilePrefix)
                if length(nam) > 1
                    error('Multiple trim files in directory found. Please specify in optiStruct.dataFilePrefix the runID of the trims to use!');
                    return
                end
            else
                nam.name=['trim-' this.input(dataGroup).dataFilePrefix '.dat'];
            end
            if ~exist(nam.name,'file')
                error(['Requested trimfile trim-' this.input(dataGroup).dataFilePefix ' not found. Please specify in optiStruct.dataFilePrefix the correct runID of the trims to use!']);
                return
            end
            
            N=vs_use(nam.name,'quiet');
            if ic==1
                xCoord=vs_get('map-const','XZ','quiet');
                yCoord=vs_get('map-const','YZ','quiet');
                this.input(dataGroup).dataGridInfo=size(xCoord);
                this.input(dataGroup).coord=[xCoord(:) yCoord(:)];
            end
            tempData=vs_get(N,'map-sed-series',{this.input(dataGroup).trimTimeStep},'DPS','quiet')-vs_get(N,'map-sed-series',{1},'DPS','quiet');
            this.input(dataGroup).data(:,ic)=tempData(:);
            waitbar(ic/length(condMap),hW);
        end
        cd ..
        close(hW)
        
        %Store rest of data in this optiStruct
        if size(W0,1)~=1
            W0=W0';
        end
        this.weights = W0;
        
end

%Account for polygons
if ~isempty(this.input(dataGroup).dataPolygon)
    this=optiUsePolygon(this,dataGroup);
end

%And rest of info
this.input(dataGroup).dataType='sedero';
this.input(dataGroup).dataFileRoot = root;
this.input(dataGroup).inputType=iType;
cd(curDir);