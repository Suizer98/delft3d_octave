function DataProperties=ImportTekalMap(DataProperties,i)
 
fil=tekal('open',[DataProperties(i).PathName DataProperties(i).FileName],'loaddata');

data=squeeze(fil.Field(DataProperties(i).Block).Data);

ColLabels=fil.Field(DataProperties(i).Block).ColLabels;
ixd = strmatch('xd',lower(ColLabels));
iyd = strmatch('yd',lower(ColLabels));
if ixd>0
    usexd=1;
    colx=ixd;
    coly=iyd;
else
    usexd=0;
end

colx=DataProperties(i).ColumnX;
coly=DataProperties(i).ColumnY;


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

if usexd
    x0=squeeze(data(N1:NStep:N2,M1:MStep:M2,colx));
    y0=squeeze(data(N1:NStep:N2,M1:MStep:M2,coly));
    x0(x0==999.999)=NaN;
    y0(y0==999.999)=NaN;
    x0(x0==-999)=NaN;
    y0(y0==-999)=NaN;
    x0(x0==0.0)=NaN;
    y0(y0==0.0)=NaN;
else
    x0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnX));
    y0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).ColumnY));
    x0(x0==999.999)=NaN;
    y0(y0==999.999)=NaN;
    x0(x0==-999)=NaN;
    y0(y0==-999)=NaN;
end
z0=squeeze(data(N1:NStep:N2,M1:MStep:M2,DataProperties(i).Column));
z0(z0==999.999)=NaN;
z0(z0==-999)=NaN;


if (DataProperties(i).M1==DataProperties(i).M2 && DataProperties(i).M1>0) || (DataProperties(i).N1==DataProperties(i).N2 && DataProperties(i).N1>0)

    DataProperties(i).x=DataProperties(i).MultiplyX*pathdistance(x0,y0)+DataProperties(i).AddX;
    DataProperties(i).y=z0;

    DataProperties(i).Type='XYSeries';
    
else
    if usexd
        z1=z0(1:end-1,1:end-1);
        z2=z0(2:end,1:end-1);
        z3=z0(2:end,2:end);
        z4=z0(1:end-1,2:end);
        z1fin=isfinite(z1);
        z2fin=isfinite(z2);
        z3fin=isfinite(z3);
        z4fin=isfinite(z4);
        z1(isnan(z1))=-999;
        z2(isnan(z2))=-999;
        z3(isnan(z3))=-999;
        z4(isnan(z4))=-999;
        zfin=z1fin+z2fin+z3fin+z4fin;
        z5=(z1.*z1fin+z2.*z2fin+z3.*z3fin+z4.*z4fin)./max(1e-6,zfin);
        z5(zfin==0)=NaN;
        z=zeros(size(z0));
        z(z==0)=NaN;
        z(1:end-1,1:end-1)=z5;
        DataProperties(i).z=z;
    else
        DataProperties(i).z=z0;
    end

    DataProperties(i).x=x0;
    DataProperties(i).y=y0;
    DataProperties(i).zz=z0;

    DataProperties(i).Type='2DScalar';
end

clear fil data xz yz zz x0 y0 z0

DataProperties(i).TC='t';
