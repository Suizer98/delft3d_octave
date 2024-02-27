function [time,val]=readtekaltimeseries(filename,varargin)

parameter=[];
block=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'block'}
                block=varargin{ii+1};
        end
    end
end

fid=tekal('open',filename,'loaddata');

columnlabels=fid.Field(1).ColLabels;
if ~isempty(parameter)
    icol=strmatch(lower(parameter),lower(columnlabels),'exact');
else
    icol=3;
end

sz=fid.Field(1).Size;
nblocks=length(fid.Field);

nrows=sz(1);
ncols=sz(2);

for iblock=1:nblocks
    blocks{iblock}=fid.Field(iblock).Name;
end
if ~isempty(block)
    iblock=strmatch(lower(block),lower(blocks),'exact');
else
    iblock=1;
end

% Times
dates=fid.Field(1).Data(:,1);
times=fid.Field(1).Data(:,2);
years=floor(dates/10000);
months=floor((dates-years*10000)/100);
days=dates-years*10000-months*100;
hours=floor(times/10000);
minutes=floor((times-hours*10000)/100);
seconds=times-hours*10000-minutes*100;
time=datenum(years,months,days,hours,minutes,seconds);


% Values
val=fid.Field(iblock).Data(:,icol);
val(val==999.999)=NaN;
val(val==-999)=NaN;
