function DataProperties=ImportCurvedVectors(DataProperties,i)
 
fil=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName]);
 
DataProperties(i).x=fil.Field(DataProperties(i).Block).Data(:,1);
DataProperties(i).y=fil.Field(DataProperties(i).Block).Data(:,2);

DataProperties(i).x(DataProperties(i).x==999.999)=NaN;
DataProperties(i).y(DataProperties(i).y==999.999)=NaN;

DataProperties(i).Type = 'CurvedVectors';
DataProperties(i).TC='c';
