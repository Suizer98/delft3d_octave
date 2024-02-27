function values = ncread_blocks(inputFile,varName,start,count,dims)

%% Identical to ncread however te speed up data is read in blocks (loop over variable 'time')
% Note that the handling of wanted indices is also done within this script,
% it if therefore not the same as ncread without looping over blocks.

no_dims     = length(dims);
timeInd     = strmatch('time',{dims(:).name});

% allocate variable 'values' > also to get NaN's in e.g. non-existing stations
if no_dims == 1
    values = NaN(1,dims.sizeOut);
else
    values = NaN(dims.sizeOut);
end

% check if output is char or double
infonc = ncinfo(inputFile,varName);
if strcmp(infonc.Datatype,'char')
    values = char(values);
end

if all(ismember({'start','count'},who)) && ~isempty(timeInd) % start and count specified, variable has time dimension
    
    if timeInd ~= 1
        error(['timeInd is not last variable, ncread_blocks does not work correctly in that case' char(10) ...
            'Please contact Julien.Groenenboom@deltares.nl'])
    end
    
    % stride / time-interval used ?
    stride       = ones(size(start));
    uniqTimeDiff = unique(diff(dims(timeInd).index));
    if numel(uniqTimeDiff) == 1
        stride(1) = uniqTimeDiff;
    end
    
    nr_times      = dims(timeInd).size;
    nr_times_clip = count(timeInd);
    
    % devide in blocks
    filesize     = dir(inputFile);
    filesize     = filesize.bytes /(1024^3); %converted to Gb
    maxblocksize = 0.5*stride(1); %Gb
    no_blocks    = ceil((nr_times_clip / nr_times) * (filesize / maxblocksize));
    bl_length    = ceil(nr_times_clip / no_blocks);
    while (no_blocks-1) * bl_length > nr_times_clip % two times ceil() leads to too much indices
        no_blocks = no_blocks - 1;
    end
    
    % cycle over blocks
    offset       = start(1) - 1;
    for i_block = 1:no_blocks
        bl_start = 1 + (i_block-1) * bl_length;
        bl_stop  = min(i_block * bl_length, nr_times_clip);
        
        % less indices requested small when stride(1) > 1
        bl_ind = bl_start:bl_stop;
        [lia,locb] = ismember(bl_ind,dims(timeInd).index);
        bl_ind = bl_ind(lia);
        locb(locb==0) = [];
        timeIndexOut = locb;
        
        start(1) = bl_ind(1) + offset;
        count(1) = numel(bl_ind);
        
        % Make sure values_tmp has the correct dimensions as
        % MATLAB automatically squeezes if size(values_tmp,1) would have been 1
        for iC = 1:numel(count)
            tmp(iC).indexOut = 1:count(iC);
        end
        values_tmp = [];
        values_tmp(tmp(:).indexOut) = nc_varget(inputFile,varName,start-1,count,stride);
        
        if no_dims == 1
            % probably [time]        = [time]
            values(timeIndexOut) = values_tmp;
        elseif no_dims == 2
            values(timeIndexOut,dims(2).indexOut) = values_tmp(:,dims(2).index);
        elseif no_dims == 3
            values(timeIndexOut,dims(2).indexOut,dims(3).indexOut) = values_tmp(:,dims(2).index,dims(3).index);
        end
    end
       
else
    % Make sure values_tmp has to correct dimensions (MATLAB
    % automatically squeezes if size(values_tmp,1) would have been 1
    for iC = 1:numel(count); tmp(iC).indexOut = 1:count(iC); end
    
    if all(ismember({'start','count'},who)) && isempty(timeInd)
        % start and count specified, variable has not a time dimension
        values_tmp(tmp(:).indexOut) = nc_varget(inputFile,varName,start-1,count);
        values(dims.indexOut) = values_tmp(dims.index);
    else
        % no start and count specified, regular ncread
        values_tmp(tmp(:).indexOut) = nc_varget(inputFile,varName);
        values(dims.indexOut) = values_tmp(dims.index);
    end
end
