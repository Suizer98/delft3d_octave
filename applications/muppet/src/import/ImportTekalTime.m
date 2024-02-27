function DataProperties=ImportTekalTime(DataProperties,i)
 
fi=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');
 
dates=fi.Field(DataProperties(i).Block).Data(:,1);
times=fi.Field(DataProperties(i).Block).Data(:,2);
 
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
