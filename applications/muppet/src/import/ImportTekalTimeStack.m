function DataProperties=ImportTekalTimeStack(DataProperties,i)
 
fi=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');

labels=fi.Field.ColLabels;

dates=fi.Field(DataProperties(i).Block).Data(:,1);
times=fi.Field(DataProperties(i).Block).Data(:,2);

years=floor(dates/10000);
months=floor( (dates-years*10000)/100 );
days=dates-years*10000-months*100;

hours=floor(times/10000);
minutes=floor( (times-hours*10000)/100 );
seconds=times-hours*10000-minutes*100;

if isnan(str2double(labels{3}))

    x=datenum( years,months,days,hours,minutes,seconds);
    y=fi.Field(DataProperties(i).Block).Data(:,3);
    z=fi.Field(DataProperties(i).Block).Data(:,4);

    DataProperties(i).x=x;
    DataProperties(i).y=y;
    DataProperties(i).z=z;
    DataProperties(i).z(DataProperties(i).z==999.999)=NaN;
    
    DataProperties(i).Type='Samples';
    DataProperties(i).TC='c';

else

    nlevels=length(labels);

    for ii=1:nlevels-2
        levels(ii)=str2double(labels{ii+2});
    end

    [x,y]=meshgrid(datenum( years,months,days,hours,minutes,seconds),levels);

    DataProperties(i).x=x;

    DataProperties(i).y=y;

    DataProperties(i).z=fi.Field(DataProperties(i).Block).Data(:,3:end);

    DataProperties(i).z=DataProperties(i).z';

    DataProperties(i).z(DataProperties(i).z==999.999)=NaN;
    DataProperties(i).z(DataProperties(i).z==-999)=NaN;
    DataProperties(i).zz=DataProperties(i).z;

    DataProperties(i).Type='TimeStack';

    DataProperties(i).TC='c';

end
