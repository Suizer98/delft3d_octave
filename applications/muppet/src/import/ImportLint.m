function DataProperties=ImportLint(DataProperties,i)

fi=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');

[x,y]=landboundary('read',DataProperties(i).PolygonFile);
 
DataProperties(i).x(1)=min(min(x));
DataProperties(i).x(2)=max(max(x));
DataProperties(i).y(1)=min(min(y));
DataProperties(i).y(2)=max(max(y));

DataProperties(i).z=fi.Field.Data(:,2);
 
DataProperties(i).Type='Lint';
 
DataProperties(i).TC='c';
