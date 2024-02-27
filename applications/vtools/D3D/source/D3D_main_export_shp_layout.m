

%% FILES
simdef.D3D.dire_sim='C:\Users\chavarri\temporal\210310_parallel_sequential\02_simulations\sims\r017\';
simdef=D3D_simpath(simdef);

ncFile = simdef.file.map;
shpFile = fullfile(simdef.D3D.dire_sim,'test.shp'); 

%% GRID

polygons=D3D_grid_polygons(ncFile);

%% DATA

Data=EHY_getMapModelData(ncFile,'varName','mesh2d_flowelem_bl');

%% WRITE

shapewrite(shpFile,'polygon',polygons,Data.val)

%a prj-file is missing when exporting. The following string is valid for Google Earth
str_prj='LOCAL_CS ["WGS 84",LOCAL_DATUM["World Geodetic System 1984",SPHEROID ["WGS84",6378137.0,298.257223563,AUTHORITY["EPSG","7030"]], AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]], UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST], AXIS["Ellipsoidal height",UP],AUTHORITY["EPSG","262148"]]';
fname_prj=strrep(shpFile,'.shp','.prj');
fid=fopen(fname_prj,'w');
fprintf(fid,str_prj);
fclose(fid);

