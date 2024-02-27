function data = dflowfm_readDataPartitioned(mapFiles,varName,IDdims,grd,checkGhostCells)

% dflowfm_readDataPartitioned reads data from both sequential as
% partitioned Delft3D-FM model output files. When the output is partitioned,
% this function also makes sure that the ghostcells are excluded from the
% output of this function.
%
% The following input variables need to be specified:
%    mapFiles: result of a dir command (only in Matlab 2016 and newer), for
%            example mapFiles = dir([c:\Run01\FM_output\*_map.nc])
%    varName: variable name in .nc file (check available variable names with
%            the function nc_disp)
%    IDdims: A cell specifying for each dimension of the variable the
%            required elements {times, faces, layers (if model is in 3D)}.
%            If all elements are required, one can use 0. The definition of
%            the dimensions can be checked using the function nc_getvarinfo.
%    grd (optional): structure containing the network information, which is
%            the result of grd = dflowfm_readNetPartitioned(mapFiles). When
%            grd is not specified, the ghostcells cannot be removed from
%            the output
%
% example: reading the salinity data (all faces) for the first output time and the
% first layer:
%    mapFiles = dir([c:\Run01\FM_output\*_map.nc]);
%    grd = grd = dflowfm_readNetPartitioned(mapFiles);
%    data = dflowfm_readDataPartitioned(mapFiles,'mesh2d_sa1',{1,0,1},grd);

if nargin < 4
    checkGhostCells = 0;
elseif ~exist('checkGhostCells','var')
    checkGhostCells = 1;
end

IDdimsReal = IDdims;

for mm = 1:length(mapFiles)
    if nc_isvar([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName)
        disp(['Reading: ',mapFiles(mm).name,': ',varName])
        
        varInfo = nc_getvarinfo([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName);
        
        % set requested indices for each dimension
        startID = [];
        lengthID = [];
        for dd = 1:size(varInfo.Size,2)
            if length(IDdims) >= dd
                if IDdims{dd} == 0
                    IDdimsReal{dd} = 1:varInfo.Size(dd);
                end
            else
                IDdimsReal{dd} = 1:varInfo.Size(dd);
            end
            startID = [startID IDdimsReal{dd}(1)-1];
            lengthID = [lengthID length(IDdimsReal{dd})];
        end
        
        dimensionsSequence = [1:length(varInfo.Dimension)];
        if find(~cellfun('isempty',regexp(varInfo.Dimension,'time')))
            IDtime = find(~cellfun('isempty',regexp(varInfo.Dimension,'time')));
            if lengthID(IDtime) > 1
                dimensionsSequence(1:2) = [2 1];
            end
        end
        
        dataPartition = nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID);
        if min(diff(dimensionsSequence)) < 0
            dataPartition = permute(dataPartition,dimensionsSequence);
        end
        
        if mm == 1
            data = dataPartition;
        else
            try
                data = [data;dataPartition];
            catch
                error('data cannot be concatenated. Probably caused by different nc_varget function. This function is based on the nc_varget from OEtools.')
            end
        end
    else
        disp(['Reading: ',mapFiles(mm).name,': ',varName,' was not found'])
    end
end

if checkGhostCells && length(mapFiles)>1
    %     if ~isempty(find(~cellfun('isempty',regexp(varInfo.Dimension,'nFlowElem'))))
    Xcheck = grd.face.FlowElem_x';
    Ycheck = grd.face.FlowElem_y';
    %     end
    
    % finds cells which occur twice
    [~,IDFirst] = unique([Xcheck Ycheck],'rows','first');
    [~,IDLast] = unique([Xcheck Ycheck],'rows','last');
    IDghostCells = find(IDLast~=IDFirst);
    
    %     IDzero = find(data==0);
    %     data(IDzero) = NaN;
    if ~isempty(IDghostCells)
        if length(size(data)) == 3
            dataFirstLast = [data(IDFirst(IDghostCells),end,1)';data(IDLast(IDghostCells),end,1)'];
        else
            dataFirstLast = [data(IDFirst(IDghostCells),end)';data(IDLast(IDghostCells),end)'];
        end
        
        % check for the ghostcells which cell has the largest absolute value (this seems to be the correct value)
        [~,id] = max(abs(dataFirstLast),[],1);
        takeFirst = find(id==1);
        takeLast = find(id==2);
        
        if length(size(data)) == 3
            for tt = 1:size(data,2)
                for kk = 1:size(data,3)
                    dataReal(takeFirst) = data(IDFirst(IDghostCells(takeFirst)),tt,kk);
                    dataReal(takeLast) = data(IDLast(IDghostCells(takeLast)),tt,kk);
                    data(IDFirst(IDghostCells),tt,kk) = dataReal';
                end
            end
        else
            for tt = 1:size(data,2)
                dataReal(takeFirst) = data(IDFirst(IDghostCells(takeFirst)),tt);
                dataReal(takeLast) = data(IDLast(IDghostCells(takeLast)),tt);
                data(IDFirst(IDghostCells),tt) = dataReal';
            end
            
        end
    end
end