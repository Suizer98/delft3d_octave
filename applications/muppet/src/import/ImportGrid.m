function DataProperties=ImportGrid(DataProperties,i)
 
[DataProperties(i).x,DataProperties(i).y,dummy]=wlgrid('read',DataProperties(i).File);
DataProperties(i).TC='c';
DataProperties(i).Type='Grid';
