function [Data,time_index,select,varargout] = EHY_getmodeldata_time_index(Data,OPT)

varargout{1} = {};
select       = [];
if ~isempty(OPT.t) && ~all(OPT.t==0)
    if ischar(OPT.t) && strcmpi(OPT.t,'end'); OPT.t = length(Data.times); end
    select        = false(length(Data.times),1);
    if max(OPT.t) > length(Data.times)
        warning(['Following timesteps not available (yet) - these will be skipped: ' newline num2str(OPT.t(OPT.t > length(Data.times)))])
        OPT.t(OPT.t > length(Data.times)) = [];
    end
    select(OPT.t) = true;
    time_index    = OPT.t;
    Data.times    = Data.times(time_index);
    varargout{1}  = 1:length(time_index);
elseif (~isempty(OPT.t0) && ~isempty(OPT.tend)) || ~isempty(OPT.tint)
    if isempty(OPT.t0) && isempty(OPT.tend)
        t0_ind = 1;
        tend_ind = length(Data.times);
    else
        t0_ind = find(Data.times + 10^-8 >= OPT.t0,1,'first');
        tend_ind = find(Data.times - 10^-8 <= OPT.tend,1,'last');
    end
    
    if isfield(OPT,'tint') && ~isempty(OPT.tint)
        modelTimes_int = Data.times(3) - Data.times(2); % in days
        stride = OPT.tint/modelTimes_int;
        if mod(stride,1) < 10^-5 % mod(stride,1) is just above 0
            stride = round(stride);
        elseif 1-mod(stride,1) < 10^-5 % mod(stride,1) is just below 1
            stride = round(stride);
        else
            error('OPT.tint (in days) needs to be a multiple of the model output timestep')
        end
    else
        stride = 1;
    end
    time_index = t0_ind:stride:tend_ind;
    select(time_index,1) = true;

    if ~isempty(time_index)
        Data.times = Data.times(time_index);
    else
        error(['These time steps are not available in the outputfile' newline,...
            'requested data period: ' datestr(OPT.t0) ' - ' datestr(OPT.tend) newline,...
            'available model data:  ' datestr(Data.times(1)) ' - ' datestr(Data.times(end))])
    end
    varargout{1} = 1:length(time_index);

else
    select       = true(length(Data.times),1);
    time_index   = find(select);
    varargout{1} = time_index;
end

end
