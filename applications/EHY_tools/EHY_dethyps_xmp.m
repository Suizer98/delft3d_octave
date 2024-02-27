% EHY_dethyps_xmp Example script showing how to generate hypsometric curve from simulation output file
fileOut = 'p:\1220688-lake-kivu\3_modelling\1_FLOW\7_heatfluxinhis\030\trim-thiery_002_coarse';
filePol = '';

%% Get data out of mat file
data      = EHY_getGridInfo(fileOut,{'XYcen' 'Z' 'spherical'});
mmax      = size(data.Xcen,2);
nmax      = size(data.Xcen,1);
x         = reshape(data.Xcen,mmax*nmax,1);
y         = reshape(data.Ycen,mmax*nmax,1);
z         = reshape(data.Zcen,mmax*nmax,1);
spherical = data.spherical;

exist = ~isnan(x);
x     = x (exist); y = y(exist); z = z(exist);

%% Determine hysometric curve
interface                 = -500:10:0;
[area, volume, interface] = EHY_dethyps(x,y,z,'spherical',spherical,'filePol',filepol,'interface',interface);

%% Write to ouput file
fid = fopen('dethyps_xmp.tek','w+');
fprintf(fid,'* Column 1: Depth (positive downward) [m]  \n');
fprintf(fid,'* Column 2: Area                      [m2] \n');
fprintf(fid,'* Column 3: Volume                    [m3] \n');
fprintf(fid,'Hypso   \n');
fprintf(fid,'%5i %5i \n',length(interface),3);
for i_int = 1: length(interface)
    fprintf(fid,'%8.3f %12.4e %12.4e \n',interface(i_int),area(i_int),volume(i_int));
end
fclose(fid);
