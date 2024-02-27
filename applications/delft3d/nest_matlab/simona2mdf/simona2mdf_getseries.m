function [times,values] = simona2mdf_getseries(series,varargin)

% simona2mdf_getseries : extract time series uit of a siminp file
%% Special case, wind speed and direction (must be more generic way of reading)
OPT.speedDir = false;
OPT          = setproperty(OPT,varargin);

%% Regular series
if strcmpi(series.SERIES,'regular')
    times  = series.FRAME(1):series.FRAME(2):series.FRAME(3);
    values = series.VALUES(1:length(times));
else
    %% Irregular 
    for itim = 1: size(series.TIME_AND_VAL,1)
        times(itim)  = series.TIME_AND_VAL(itim,1)*1440 + ...
                       series.TIME_AND_VAL(itim,2)*60   + ...
                       series.TIME_AND_VAL(itim,3)      ;
        %  Not wind (1 value)
        if ~OPT.speedDir
            values(itim) = series.TIME_AND_VAL(itim,4);
        else
            %  Wind (2 values)
            values(itim,:) = series.TIME_AND_VAL(itim,4:5);
        end
    end
end

if times(1) > 0 && simona2mdf_fieldandvalue(series,'TID')
    times (2:end+1)  = times (1:end);
    values(2:end+1)  = values(1:end);
    times (1      )  = 0.;
    values(1      )  = series.TID;
end

