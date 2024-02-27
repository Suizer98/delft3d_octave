function DataProperties=ImportD3DGrid(DataProperties,i)
 
[DataProperties(i).x,DataProperties(i).y,dummy]=wlgrid('read',[DataProperties(i).PathName DataProperties(i).FileName]);
DataProperties(i).TC='c';
DataProperties(i).Type='Grid';
