function DataProperties=ImportSamples(DataProperties,i)
 
a=load([DataProperties(i).PathName DataProperties(i).FileName]);
 
DataProperties(i).x=a(:,1);
DataProperties(i).y=a(:,2);
kol = DataProperties(i).Column;
DataProperties(i).z=a(:,kol);

DataProperties(i).Type = 'Samples';
DataProperties(i).TC='c';
