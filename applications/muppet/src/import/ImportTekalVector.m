function DataProperties=ImportTekalVector(DataProperties,i)
 
fil=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');

data=fil.Field(DataProperties(i).Block).Data;

if DataProperties(i).M1==0
    M1=1;
    M2=size(data(:,:,1),2);
    MStep=1;
else
    M1=DataProperties(i).M1;
    M2=DataProperties(i).M2;
    MStep=DataProperties(i).MStep;
end

if DataProperties(i).N1==0
    N1=1;
    N2=size(data(:,:,1),1);
    NStep=1;
else
    N1=DataProperties(i).N1;
    N2=DataProperties(i).N2;
    NStep=DataProperties(i).NStep;
end

x0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnX));
y0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnY));
u0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnU));
v0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnV));

x0(x0==999.999)=NaN;
y0(y0==999.999)=NaN;
u0(u0==999.999)=NaN;
v0(v0==999.999)=NaN;

DataProperties(i).x=x0;
DataProperties(i).y=y0;
DataProperties(i).u=u0;
DataProperties(i).v=v0;
DataProperties(i).z=sqrt(DataProperties(i).u.^2+DataProperties(i).v.^2);

DataProperties(i).Type='2DVector';

clear fil data xz yz zz x0 y0 z0

DataProperties(i).TC='t';

