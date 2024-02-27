function DataProperties=ImportLandboundary(DataProperties,i)
 
[x,y]=landboundary('read',[DataProperties(i).PathName DataProperties(i).FileName]);
 
DataProperties(i).x=x;
DataProperties(i).y=y;
DataProperties(i).z=0;
 
DataProperties(i).Type = 'Polyline';
DataProperties(i).TC='c';
