function DataProperties=ImportTekalXY(DataProperties,i)
 
fi=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');
 
j=DataProperties(i).Block;

DataProperties(i).x=fi.Field(j).Data(:,DataProperties(i).ColumnX);
 
DataProperties(i).y=fi.Field(j).Data(:,DataProperties(i).Column);

x=DataProperties(i).MultiplyX*DataProperties(i).x;
y=DataProperties(i).MultiplyX*DataProperties(i).y;

DataProperties(i).x=DataProperties(i).MultiplyX*DataProperties(i).x+DataProperties(i).AddX;

DataProperties(i).x(x==-999.0)=NaN;
DataProperties(i).x(x==999.999)=NaN;
DataProperties(i).y(y==-999.0)=NaN;
DataProperties(i).y(y==999.999)=NaN;

DataProperties(i).Type='XYSeries';
DataProperties(i).TC='c';
