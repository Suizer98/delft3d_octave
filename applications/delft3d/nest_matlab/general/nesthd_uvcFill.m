function series = nesthd_uvcFill(series,varargin)

%  nesthd_uvcFill, fills series above water level or below bed  with first resp. last value
%
%% Initialise
kmax        = size(series,3);
OPT.noValue = NaN;
OPT         = setproperty(OPT,varargin);

%% Fill missing values
for kk=kmax-1:-1:1
    if series(:,:,kk)==OPT.noValue
        series(:,:,kk)=series(:,:,kk+1);
    end
end
for kk=2:kmax
    if series(:,:,kk)==OPT.noValue
        series(:,:,kk)=series(:,:,kk-1);
    end
end
