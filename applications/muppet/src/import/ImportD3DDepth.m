function DataProperties=ImportD3DDepth(DataProperties,i)

grd=wlgrid('read',[DataProperties(i).GrdFile]);
z=wldep('read',[DataProperties(i).PathName DataProperties(i).FileName],grd);

DataProperties(i).x=grd.X;
DataProperties(i).y=grd.Y;
DataProperties(i).z=z(1:end-1,1:end-1);
DataProperties(i).z(DataProperties(i).z==-999.0)=NaN;
DataProperties(i).z(DataProperties(i).z==999.999)=NaN;
DataProperties(i).zz=z(1:end-1,1:end-1);
DataProperties(i).zz(DataProperties(i).zz==-999.0)=NaN;
DataProperties(i).zz(DataProperties(i).zz==999.999)=NaN;


DataProperties(i).Type='2DScalar';
DataProperties(i).TC='c';
