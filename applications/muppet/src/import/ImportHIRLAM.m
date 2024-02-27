function DataProperties=ImportHIRLAM(DataProperties,i)

filename=[DataProperties(i).PathName DataProperties(i).FileName];

fid = fopen(filename,'r');
dummy = fgetl(fid);
dummy = fgetl(fid);
dummy=strread(dummy);
year=dummy(8);
month=dummy(9);
day=dummy(10);
hour=dummy(11);
time = datenum(year,month,day,hour,0,0);
dummy = fgetl(fid);
dummy = fgetl(fid);
dummy=strread(dummy);
nx=dummy(2);
ny=dummy(3);
y0=dummy(4)/1000;
x0=dummy(5)/1000;
y1=dummy(7)/1000;
x1=dummy(8)/1000;
dx=(x1-x0)/(nx-1);
dy=(y1-y0)/(ny-1);
exval = -999.00;
fclose(fid);

fid = fopen(filename,'r');

% 
% if ntime > 1
%     for ii = 1:ntime
%         dummy=fscanf(fid,'%g',33);
%         dummy=fscanf(fid,'%g',[ny nx]);
%     end
% end

dummy=fscanf(fid,'%g',33);
val1=fscanf(fid,'%g',[ny nx]);
val1 (val1 == exval) = NaN;

if strcmpi(DataProperties(i).Parameter,'Wind Velocity')
    for ii = 1:16
        dummy=fscanf(fid,'%g',33);
        dummy=fscanf(fid,'%g',[ny nx]);
    end
    dummy=fscanf(fid,'%g',33);
    val2=fscanf(fid,'%g',[ny nx]);
    val2 (val2 == exval) = NaN;
end

fclose(fid);



if strcmpi(DataProperties(i).Parameter,'Wind Velocity')
    DataProperties(i).z=[];
    DataProperties(i).u=val1;
    DataProperties(i).v=val2;
    DataProperties(i).z=sqrt(DataProperties(i).u.^2+DataProperties(i).v.^2);
    DataProperties(i).Type='2DVector';
else
    DataProperties(i).u=[];
    DataProperties(i).v=[];
    DataProperties(i).z=val1;
    DataProperties(i).zz=val1;
    DataProperties(i).Type='2DScalar';
end    

x = x0:dx:x0+(nx-1)*dx;
y = y0:dy:y0+(ny-1)*dy;

[x,y]=meshgrid(x,y);
DataProperties(i).x=x;
DataProperties(i).y=y;

DataProperties(i).TC='c';
