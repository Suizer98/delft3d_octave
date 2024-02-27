function DataProperties=ImportD3DMeteo(DataProperties,i)

fname=[DataProperties(i).PathName DataProperties(i).FileName];
itdate=DataProperties(i).RefDate;
t=DataProperties(i).DateTime;
par=DataProperties(i).Parameter;
iblock=DataProperties(i).Block;

switch(lower(par(1)))
    case{'w'}
        [x,y,u,times]=ReadAm([fname '.amu'],itdate,t,iblock,par);
        [x,y,v,times]=ReadAm([fname '.amv'],itdate,t,iblock,par);
        DataProperties(i).u=u;
        DataProperties(i).v=v;
        DataProperties(i).z=0;
        DataProperties(i).AvailableTimes=times;
        DataProperties(i).Type='2DVector';
    case{'p'}
        [x,y,p,times]=ReadAm([fname '.amp'],itdate,t,iblock,par);
        if strcmpi(DataProperties(i).PressureType,'mbar')
            p=p*0.01;
        end
        DataProperties(i).u=0;
        DataProperties(i).v=0;
        DataProperties(i).z=p;
        DataProperties(i).zz=p;
        DataProperties(i).AvailableTimes=times;
        DataProperties(i).Type='2DScalar';
end

DataProperties(i).AvailableMorphTimes=[];

DataProperties(i).x=x;
DataProperties(i).y=y;

DataProperties(i).TC='t';


function [x,y,val,times]=ReadAm(fname,itdate,t,iblock,par)

fid=fopen(fname,'r');

if strcmpi(par(1),'p');
    v0=strread(fgetl(fid),'%q');
end

v0=strread(fgetl(fid),'%q');
ncols=str2double(v0{2});
v0=strread(fgetl(fid),'%q');
nrows=str2double(v0{2});

v0=strread(fgetl(fid),'%q');
xllcentre=str2double(v0{2});
v0=strread(fgetl(fid),'%q');
yllcentre=str2double(v0{2});
v0=strread(fgetl(fid),'%q');
cellsize(1)=str2double(v0{2});
cellsize(2)=str2double(v0{3});
v0=strread(fgetl(fid),'%q');
nodata=str2double(v0{2});

xx=xllcentre:cellsize(1):xllcentre+(ncols-1)*cellsize(1);
yy=yllcentre:cellsize(2):yllcentre+(nrows-1)*cellsize(2);
[x,y]=meshgrid(xx,yy);

% if iblock>0
%     n=iblock;
% else
%     n=10000;
% end

n=10000;

for ii=1:n
    tx0=fgetl(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        th=str2double(v0{4});
        tf=itdate+th/24;
        times(ii)=tf;
        if iblock>0
            if ii==iblock
                val=fscanf(fid,'%g',[ncols nrows]);
                val(val==nodata)=NaN;
            else
                dummy=fscanf(fid,'%g',[ncols nrows]);
            end
        else
            if t==tf
                val=fscanf(fid,'%g',[ncols nrows]);
                val(val==nodata)=NaN;
                %            break;
            else
                dummy=fscanf(fid,'%g',[ncols nrows]);
            end
        end
        tx1=fgetl(fid);
    else
        u=[];
        v=[];
        break;
    end
end
val=val';
val=flipud(val);

fclose(fid);
