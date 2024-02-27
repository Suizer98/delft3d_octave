function varargout=muppet_importTekal(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
        end
    end
end

%%
function dataset=read(dataset,parameter)

fid=tekal('open',dataset.filename);
 
dates=fid.Field(DataProperties(i).Block).Data(:,1);
times=fid.Field(DataProperties(i).Block).Data(:,2);
 
years=floor(dates/10000);
months=floor( (dates-years*10000)/100 );
days=dates-years*10000-months*100;
 
hours=floor(times/10000);
minutes=floor( (times-hours*10000)/100 );
seconds=times-hours*10000-minutes*100;
 
DataProperties(i).x=datenum( years,months,days,hours,minutes,seconds);
 
DataProperties(i).y=fi.Field(DataProperties(i).Block).Data(:,DataProperties(i).Column);

DataProperties(i).y(DataProperties(i).y==999.999)=NaN;
DataProperties(i).y(DataProperties(i).y==-999)=NaN;

DataProperties(i).Type='TimeSeries';

DataProperties(i).TC='c';
