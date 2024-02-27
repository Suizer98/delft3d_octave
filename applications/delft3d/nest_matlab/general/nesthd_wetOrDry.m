function [wet] = nesthd_wetOrDry(fileInp,series,stationNames)

%  nesthd_wetOrDry, determine wherher a station in the serie array is wet or dry
%                   if all values in the series are identical a station is assumed to be dry
%
%% Initialise
notims        = size(series,1);
nostat        = size(series,2);
kmax          = 1;
if ndims(series) > 2 kmax = size(series,3); end

wet(1:nostat) = true;

%% Cycle over stations
for i_stat = 1: nostat
    
    %% Determine first active layer (sigma = 1, fixed layers, not known). Use vertical coordinates to cetermine this
    if kmax > 1
        k_act         = NaN;
        modelType     = EHY_getModelType(fileInp);
        data_zcen_cen = EHY_getmodeldata(fileInp,stationNames{i_stat},modelType,'varName','Zcen_cen','t',1);
        if isfield(data_zcen_cen,'val')
            zcen_cen      = squeeze(data_zcen_cen.val);
            for k = 1: kmax
                if ~isnan(zcen_cen(k))
                    k_act = k;
                    break;
                end
            end
        end
        k = k_act;
    else
        k = 1;
    end
    
    %% Check if station is wet
    index = [];
    if ~isnan(k) index = find(series(:,i_stat,k) == series(1,i_stat,k)); end
    if  isnan(k) || length(index) == notims
        wet(i_stat) = false;
    end
end
