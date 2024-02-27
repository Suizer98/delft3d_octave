function this=optiReadTransportData(this,dataGroup,iType,root,weights)

% OPTIREADTRANSPORTDATA - reads transport data in optiStruct
%
% Reads transport data in optiStruct from specified source type
% specified with iType and specified root dir/file.
% 
% Usage:
%     optiStruct=optiReadTransportData(optiStruct,dataGroup,iType,root,weights(for certain iTypes))
%
% in which iType is numeric and can have the following values:
%   1 - one trim-file with all conditions
%   2 - series of trim-files (one trim per condition); No mormerge
%   3 - series of trim-files (one trim per condition); With mormerge
%
% and root is respectively the root directory of opti input (1), a fullpath
% trim-filename for option (2), the root directory with simulation
% directories (one per condition) containing the trim-files or similar to
% (3), but for a simulation with mormerge, including a 'merge' directory
% and *.mm file. 
% For option 2-3 a tekal weight factor file must be supplied as full filename string 
% in weights, or an array sized [Nx1] or [1xN] (N = number of conditions) containing 
% weight factors (0 - 1) in the order of the initial conditions

%Ms MJ oplossing
if ~isfield(this.input(dataGroup), 'trimTimeStep')
    this.trimTimeStep=0;
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

if ~isempty(this.input(dataGroup).dataTransect)&~isempty(this.input(dataGroup).dataPolygon)
    error('Use of both transects and polygons is not allowed.');
    return
end    
curDir=pwd;

switch iType
    case 1
        % for now: each time step in the trim-file represents a condition
        % manual input of weight coefficients
        if isstr(weights)
            tek=tekal('read',weights);
            optiDataIn.W0=tek.Field.Data(:,2);
        elseif isnumeric(weights)
            optiDataIn.W0=weights;
        end
        if size(optiDataIn.W0,2)~=1
            optiDataIn.W0=optiDataIn.W0';
        end
        
        %Account for multiple fractions
        if isempty(this.input(dataGroup).dataSedimentFraction)
            this.input(dataGroup).dataSedimentFraction=1;
        end
        
        N=vs_use(root,'quiet');
        if isempty(this.input(dataGroup).trimTimeStep)
            this.input(dataGroup).trimTimeStep=[2:length(N.GrpDat(1).SizeDim)];
        end
        xCoord=vs_get('map-const','XZ','quiet');
        yCoord=vs_get('map-const','YZ','quiet');
        this.input(dataGroup).dataGridInfo=size(xCoord);
        this.input(dataGroup).coord=[xCoord(:) yCoord(:)];
        MT=qpread(N,this.input(dataGroup).transParameter,'data',this.input(dataGroup).dataSedimentFraction,this.input(dataGroup).trimTimeStep');
        nc=size(this.input(dataGroup).trimTimeStep,2);
        tempDataX=MT.XComp;
        tempDataY=MT.YComp;
        %id=find(tempDataX>999|abs(tempDataX)<eps|tempDataY>999|abs(tempDataY)<realmin);
        %tempDataX(id)=nan;
        %tempDataY(id)=nan;            
        this.input(dataGroup).data=[reshape(tempDataX(:),nc,prod(this.input(dataGroup).dataGridInfo))'; reshape(tempDataY(:),nc,prod(this.input(dataGroup).dataGridInfo))'];
        if ~isempty(this.input(dataGroup).dataPolygon) %check if polygon will be used
            this.input(dataGroup).origCoord=this.input(dataGroup).coord;
            [ldbCell, dum,dum,dum]=disassembleLdb(this.input(dataGroup).dataPolygon);
	    inpoly=[];
	    for ii=1:length(ldbCell)
	       inpoly=[inpoly; find(inpolygon(this.input(dataGroup).coord(:,1),this.input(dataGroup).coord(:,2),ldbCell{ii}(:,1),ldbCell{ii}(:,2)))];
            end
            this.input(dataGroup).coord=this.input(dataGroup).coord(inpoly,:);
            this.input(dataGroup).data=this.input(dataGroup).data(inpoly,:);
        end
        %Store rest of data in this optiStruct
        if size(optiDataIn.W0,1)~=1
            optiDataIn.W0=optiDataIn.W0';
        end
        this.weights = optiDataIn.W0;
        
    case 2
        % seperate trim-files for each condition
        % manual input of weight coefficients
        if isstr(weights)
            tek=tekal('read',weights);
            optiDataIn.W0=tek.Field.Data(:,2);
        elseif isnumeric(weights)
            optiDataIn.W0=weights;
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
        
        if isempty(this.input(dataGroup).dataFilePrefix)
            nam=dir([pat{1} filesep 'trim*.dat']);
            if length(nam) > 1
                error('Multiple trim files in directory found. Please specify in optiStruct.dataFilePrefix the runID of the trims to use!');
                return
            end
        else
            nam.name=['trim-' this.input(dataGroup).dataFilePrefix '.dat'];
        end
        
        %Account for multiple fractions
        if isempty(this.input(dataGroup).dataSedimentFraction)
            this.input(dataGroup).dataSedimentFraction=1;
        end
        
        for ii=1:length(pat)
            trimNames{ii}=[pat{ii} filesep nam.name];
        end
        hW = waitbar(0,'Reading transports for each condition'); %waitbar
        for ic=1:size(trimNames,2)
            N=vs_use(trimNames{ic},'quiet');
            if isempty(N)
                errordlg(['Trim-file ' trimNames{ic} ' does not exist, check the opti input again!']);
                return
            end
            if ic==1
                MT=qpread(N,this.input(dataGroup).transParameter,'griddata',this.input(dataGroup).dataSedimentFraction,this.input(dataGroup).trimTimeStep);
                this.input(dataGroup).coord=[MT.X(:) MT.Y(:)];
                this.input(dataGroup).dataGridInfo=size(MT.X);
                if ~isempty(this.input(dataGroup).dataPolygon) % check if polygon will be used
                    [ldbCell, dum,dum,dum]=disassembleLdb(this.input(dataGroup).dataPolygon);
                    inpoly=[];
                    for ii=1:length(ldbCell)
                        inpoly=[inpoly; find(inpolygon(this.input(dataGroup).coord(:,1),this.input(dataGroup).coord(:,2),ldbCell{ii}(:,1),ldbCell{ii}(:,2)))];
                    end
                    this.input(dataGroup).origCoord=this.input(dataGroup).coord;
                    this.input(dataGroup).coord=this.input(dataGroup).coord(inpoly,:);
                end
            else
                MT=qpread(N,this.input(dataGroup).transParameter,'data',this.input(dataGroup).dataSedimentFraction,this.input(dataGroup).trimTimeStep);
            end
            tempData=[MT.XComp(:);MT.YComp(:)];
            if ~isempty(this.input(dataGroup).dataPolygon) % check if polygon will be used
                this.input(dataGroup).data(:,ic)=tempData([inpoly ; inpoly+size(this.input(dataGroup).origCoord(:,1),1)]);
            else
                this.input(dataGroup).data(:,ic)=tempData;
            end
            waitbar(ic/size(trimNames,2),hW);
        end
        close(hW)   
        
        %Store rest of data in this optiStruct
        if size(optiDataIn.W0,1)~=1
            optiDataIn.W0=optiDataIn.W0';
        end
        this.weights = optiDataIn.W0;
        
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
        
        oldPat=pwd;
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
        
        optiDataIn.W0 = weightFac / sum (weightFac);
        
        hW = waitbar(0,'Reading transports for each condition'); %waitbar
        for ic=1:length(condMap)
            cd(['..\' char(condMap{ic})]);
            if isempty(this.input(dataGroup).dataFilePrefix)
                nam=dir('trim*.dat');
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
            
            %Account for multiple fractions
            if isempty(this.input(dataGroup).dataSedimentFraction)
                this.input(dataGroup).dataSedimentFraction=1;
            end
            
            N=vs_use(nam.name,'quiet');            
            if ic==1
	                    MT=qpread(N,this.input(dataGroup).transParameter,'griddata',this.input(dataGroup).dataSedimentFraction,this.input(dataGroup).trimTimeStep);
	                    this.input(dataGroup).coord=[MT.X(:) MT.Y(:)];
	                    this.input(dataGroup).dataGridInfo=size(MT.X);
	                    if ~isempty(this.input(dataGroup).dataPolygon) % check if polygon will be used
	                        [ldbCell, dum,dum,dum]=disassembleLdb(this.input(dataGroup).dataPolygon);
	                        inpoly=[];
	                        for ii=1:length(ldbCell)
	                            inpoly=[inpoly; find(inpolygon(this.input(dataGroup).coord(:,1),this.input(dataGroup).coord(:,2),ldbCell{ii}(:,1),ldbCell{ii}(:,2)))];
	                        end
	                        this.input(dataGroup).origCoord=this.input(dataGroup).coord;
	                        this.input(dataGroup).coord=this.input(dataGroup).coord(inpoly,:);
	                    end
	                else
	                    MT=qpread(N,this.input(dataGroup).transParameter,'data',this.input(dataGroup).dataSedimentFraction,this.input(dataGroup).trimTimeStep);
	                end
	                tempData=[MT.XComp(:);MT.YComp(:)];
	                if ~isempty(this.input(dataGroup).dataPolygon) % check if polygon will be used
	                    this.input(dataGroup).data(:,ic)=tempData([inpoly ; inpoly+size(this.input(dataGroup).origCoord(:,1),1)]);
	                else
	                    this.input(dataGroup).data(:,ic)=tempData;
            end
            
            waitbar(ic/length(condMap),hW);
        end
        cd(oldPat);
        close(hW);
        
        %Store rest of data in this optiStruct
        if size(optiDataIn.W0,1)~=1
            optiDataIn.W0=optiDataIn.W0';
        end
        this.weights = optiDataIn.W0;
        
end

%Account for polygons
%if ~isempty(this.input(dataGroup).dataPolygon)
%    this=optiUsePolygon(this,dataGroup);
%end

%Account for transects
if ~isempty(this.input(dataGroup).dataTransect)
    this=optiInterpTransect(this,dataGroup);
    this=optiComputeTransportThroughTransect(this,dataGroup);
end

%And rest of info
this.input(dataGroup).dataType='transport';
this.input(dataGroup).dataFileRoot = root;
this.input(dataGroup).inputType=iType;
cd(curDir);