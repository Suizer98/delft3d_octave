function DataProperties=ImportUCITxyz(DataProperties,i)
 
data=load([DataProperties(i).PathName DataProperties(i).FileName]);

if DataProperties(i).M1==0
    M1=1;
    M2=size(data.d.X,1);
    MStep=1;
else
    M1=DataProperties(i).M1;
    M2=DataProperties(i).M2;
    MStep=DataProperties(i).MStep;
end

if DataProperties(i).N1==0
    N1=1;
    N2=size(data.d.X,2);
    NStep=1;
else
    N1=DataProperties(i).N1;
    N2=DataProperties(i).N2;
    NStep=DataProperties(i).NStep;
end

x0=squeeze(data.d.X(M1:MStep:M2,N1:NStep:N2));
y0=squeeze(data.d.Y(M1:MStep:M2,N1:NStep:N2));
z0=squeeze(data.d.Z(M1:MStep:M2,N1:NStep:N2));

x0(x0==999.999)=NaN;
y0(y0==999.999)=NaN;
z0(z0==999.999)=NaN;






if (DataProperties(i).M1==DataProperties(i).M2 & DataProperties(i).M1>0) | (DataProperties(i).N1==DataProperties(i).N2 & DataProperties(i).N1>0)

    DataProperties(i).x=DataProperties(i).MultiplyX*pathdistance(x0,y0)+DataProperties(i).AddX;
    DataProperties(i).y=z0;

    DataProperties(i).Type='XYSeries';
    
else

    xz=squeeze(x0);
    yz=squeeze(y0);
    zz=squeeze(z0);

    xz(xz==999.999)=NaN;
    yz(yz==999.999)=NaN;
    xz(xz==0.0)=NaN;
    yz(yz==0.0)=NaN;
    zz(isnan(xz))=NaN;

    xz=xz';
    yz=yz';
    zz=zz';

    DataProperties(i).x=xz;
    DataProperties(i).y=yz;
    DataProperties(i).z=zz;
    DataProperties(i).zz=zz;

    DataProperties(i).Type='2DScalar';
end


clear fil data xz yz zz x0 y0 z0

DataProperties(i).TC='t';

