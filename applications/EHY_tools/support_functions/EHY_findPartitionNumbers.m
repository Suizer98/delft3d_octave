function partitionNrs = EHY_findPartitionNumbers(inputFile,varargin)
%% partitionNrs = EHY_findPartitionNumbers(inputFile,varargin)
% Function to find partition numbers that are (partially) within bounding box
% or cross the polyline
%
% Example1: partitionNrs = EHY_findPartitionNumbers('d:\model_0002_map.nc','xrange',[4 5],'yrange',[52 54])
% Example2: partitionNrs = EHY_findPartitionNumbers('d:\model_0002_map.nc','thalweg.pli')

%% OPT
OPT.pliFile = ''; % e.g. thalweg.pli
OPT.pli     = []; % e.g. [1 1; 1 5; 4 2]
OPT.xrange  = []; % e.g. [4 5]
OPT.yrange  = []; % e.g. [52 54]
OPT.disp    = 1;
OPT         = setproperty(OPT,varargin);

%%
partitionNrs = [];

%% check
if ~EHY_isPartitioned(inputFile)
    return
end

if ~isempty(OPT.pliFile)
    pli = io_polygon('read',OPT.pliFile);
elseif ~isempty(OPT.pli)
    pli = OPT.pli;
elseif ~isempty(OPT.xrange) && ~isempty(OPT.yrange)
    box = [OPT.xrange(1) OPT.yrange(1); OPT.xrange(2) OPT.yrange(1); ...
        OPT.xrange(2) OPT.yrange(2); OPT.xrange(1) OPT.yrange(2)];
else
    error('You need to specify either "pliFile", "pli" or "xrange" and "yrange"')
end

%% process
ncFiles = EHY_getListOfPartitionedNcFiles(inputFile);

if exist('pli','var')
    % pli
    for iF = 1:length(ncFiles)
        gridInfo = EHY_getGridInfo(ncFiles{iF},{'XYcor','face_nodes'},'mergePartitions',0);
        warning off
        arb = arbcross(gridInfo.face_nodes',gridInfo.Xcor,gridInfo.Ycor,pli(:,1),pli(:,2));
        warning on
        
        if any(~arb.outside)
            [~,name] = fileparts(ncFiles{iF}); % domain number
            if OPT.disp
                disp(['Trajectory from pli/pliFile crosses partition number: ' name(end-7:end-4)]);
            end
            partitionNrs(end+1,1) = str2num(name(end-7:end-4));
        end
    end
    
elseif exist('box','var')
    % box
    for iF = 1:length(ncFiles)
        gridInfo = EHY_getGridInfo(ncFiles{iF},{'XYcor'},'mergePartitions',0);
        in = inpolygon(gridInfo.Xcor,gridInfo.Ycor,box(:,1),box(:,2));
        if any(in)
            [~,name] = fileparts(ncFiles{iF}); % domain number
             if OPT.disp
                disp(['Partition number ' name(end-7:end-4) ' is in bounding box [X = ' num2str(OPT.xrange)  ', Y = ' num2str(OPT.yrange) ']']);
            end
            partitionNrs(end+1,1) = str2num(name(end-7:end-4));
        end
    end
end
