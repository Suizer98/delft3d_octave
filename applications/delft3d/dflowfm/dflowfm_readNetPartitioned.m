function [grd,grdPart] = dflowfm_readNetPartitioned(mapFiles,FlagShiftNodesCutCellPolygonLST)

%% Reads network from partitioned Delft3D-FM files (_map.nc, _net.nc, etc.)
%
% required input:
% mapFiles = structure containing the fields folder and name (resulting
% from e.g. mapFiles = dir([d:/temp/NCfiles/])
%
% optional input:
% FlagShiftNodesCutCellPolygonLST = 1: changes the X and Y coordinates of
% the nodes, which have been shifted due to the cutcellpolygon.lst routine
% in Delft3D-FM (if applied). This only work when the Statistics Toolbox
% can be accessed. If no license is available, this part of the routine
% will be skipped (a warning will be given).

if nargin < 2
    FlagShiftNodesCutCellPolygonLST = 0;
end

for mm = 1:length(mapFiles)
    disp(['Reading: ',mapFiles(mm).name])
    readDomain = 1;
    if nc_isvar([mapFiles(mm).folder,filesep,mapFiles(mm).name], 'mesh2d_node_x')
        grdPart(mm) = dflowfm.readNet([mapFiles(mm).folder,filesep,mapFiles(mm).name]); % Ugrid format
        grd.format = 4;
    elseif nc_isvar([mapFiles(mm).folder,filesep,mapFiles(mm).name],'NetNode_x')
        grdPart(mm) = dflowfm.readNetOld([mapFiles(mm).folder,filesep,mapFiles(mm).name]); % Old Netcdf format
        grd.format = 1;
    else
        disp(['Reading: ',mapFiles(mm).name,': doesn''t contain 2D/3D networks'])
        readDomain = 0;
    end
    
    if readDomain
        % add domain number of each face (to be able to find ghost cells)
        domainNr = str2num(mapFiles(mm).name(end-10:end-7));
        
        if isempty(domainNr)
            try
                domainNr = median(grdPart(mm).face.FlowElemDomain);
            catch
                domainNr = 0;
            end
        end
        
        grdPart(mm).face.Domain = zeros(size(grdPart(mm).face.FlowElem_x))+domainNr;
        
        % replace 0 by NaN in grdPart(mm).face.NetElemNode
        try
            grdPart(mm).face.NetElemNode(grdPart(mm).face.NetElemNode==0) = NaN;
        end
        
        if mm == 1
            grd = grdPart(mm);
        else
            %% Determine amount of nodes, elements and netlinks from previous partitions
            
            if isfield(grd,'node')
                addNode = length(grd.node.x);
            end
            if isfield(grd,'face')
                addFlowElem = length(grd.face.FlowElem_x);
            end
            if isfield(grd,'edge')
                addNetLink = length(grd.edge.NetLinkType);
            end
            
            %% Append variables
            if isfield(grd,'node')
                % merge fields
                nodeFields = fieldnames(grd.node);
                nodeDim = find(size(grd.node.x)>1);
                for ff = 1:length(nodeFields)
                    if ~strcmpi(nodeFields{ff},'n')
                        grd.node.(nodeFields{ff}) = appendMatrices(grd.node.(nodeFields{ff}),grdPart(mm).node.(nodeFields{ff}),nodeDim);
                    end
                end
                grd.node.n = length(grd.node.x);
            end
            
            if isfield(grd,'edge')
                % merge fields
                edgeFields = fieldnames(grd.edge);
                if ~isempty(find(~cellfun('isempty',regexp(edgeFields,'NetLink'))))
                    edgeDim = find(size(grd.edge.NetLinkType)>1);
                elseif ~isempty(find(~cellfun('isempty',regexp(edgeFields,'FlowLink'))))
                    edgeDim = find(size(grd.edge.FlowLinkType)>1);
                end
                for ff = 1:length(edgeFields)
                    if strcmpi(edgeFields{ff},'NetLink')
                        grd.edge.NetLink = appendMatrices(grd.edge.NetLink,grdPart(mm).edge.NetLink+addNode,edgeDim);
                    elseif strcmpi(edgeFields{ff},'FlowLink')
                        grd.edge.FlowLink = appendMatrices(grd.edge.FlowLink,grdPart(mm).edge.FlowLink+addFlowElem,edgeDim);
                    elseif ~strcmpi(edgeFields{ff},'NetLinkSize') & ~strcmpi(edgeFields{ff},'FlowLinkSize') & ~strcmpi(edgeFields{ff},'NetLinkTypeFlag') & ~strcmpi(edgeFields{ff},'FlowLinkTypeFlag')
                        grd.edge.(edgeFields{ff}) = appendMatrices(grd.edge.(edgeFields{ff}),grdPart(mm).edge.(edgeFields{ff}),edgeDim);
                    end
                end
                
                if isfield(grd.edge,'NetLinkType')
                    grd.edge.NetLinkSize = length(grd.edge.NetLinkType);
                end
                
                if isfield(grd.edge,'FlowLinkType')
                    grd.edge.FlowLinkSize = length(grd.edge.FlowLinkType);
                end
            end
            
            if isfield(grd,'face')
                % merge fields
                faceFields = fieldnames(grd.face);
                faceDim = find(size(grd.face.FlowElem_x)>1);
                for ff = 1:length(faceFields)
                    if strcmpi(faceFields{ff},'NetElemNode')  %% check if this is always the case
                        grd.face.NetElemNode = appendMatrices(grd.face.NetElemNode,grdPart(mm).face.NetElemNode+addNode,1);
                    elseif strcmpi(faceFields{ff},'BndLink')
                        grd.face.BndLink = appendMatrices(grd.face.BndLink,grdPart(mm).face.BndLink+addNetLink,faceDim);
                    elseif ~strcmpi(faceFields{ff},'FlowElemSize')
                        grd.face.(faceFields{ff}) = appendMatrices(grd.face.(faceFields{ff}),grdPart(mm).face.(faceFields{ff}),faceDim);
                    end
                end
                grd.face.FlowElemSize = length(grd.face.FlowElem_x);
            end
            
            if isfield(grd,'map3')
                grd.map3= [grd.map3;grdPart(mm).map3+addFlowElem];
            end
            
            if isfield(grd,'tri')
                grd.tri= [grd.tri;grdPart(mm).tri+addNode];
            end
        end
    end
end

% find activeCells
try
    grd.face.FlowElemActive = find(grd.face.FlowElemDomain==grd.face.Domain);
catch
    grd.face.FlowElemActive = zeros(size(grd.face.FlowElem_x))+1;
end

%% shift nodes which have been cut by the cutcellpolygon.lst
if FlagShiftNodesCutCellPolygonLST
    try
        grd = dflowfm_shiftNodesCutCellPolygon(grd)
    catch
        disp('Warning: Could not take into account the shifting of nodes due to the cutcellpolygon.lst, because you don''t have a license for the Statistics toolbox')
    end
end

end

function newVal = appendMatrices(val1,val2,AppendDimension)
switch AppendDimension
    case 1
        newVal = zeros(size(val1,1)+size(val2,1),max(size(val1,2),size(val2,2)))+NaN;
        newVal(1:size(val1,1),1:size(val1,2)) = val1;
        newVal(size(val1,1)+1:end,1:size(val2,2)) = val2;
    case 2
        newVal = zeros(max(size(val1,1),size(val2,1)),size(val1,2)+size(val2,2))+NaN;
        newVal(1:size(val1,1),1:size(val1,2)) = val1;
        newVal(1:size(val2,1),size(val1,2)+1:end) = val2;
end

end