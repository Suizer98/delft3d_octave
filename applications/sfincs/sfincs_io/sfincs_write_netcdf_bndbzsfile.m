function sfincs_write_netcdf_bndbzsfile(filename, x, y, EPSGcode, UTMname, refdate, time, bzs)
%
% v1.0  Leijnse     12-08-2019      Initial commit
%
% Input specification:
% - x and y expected as arrays with values per station in same projected coordinate system as in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - bzs input matrix dimensions assumed to be (t,stations)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
% 
% Remarks: 
% - data is now written away as singles
% 
% Example:
% filename = 'sfincs_netbndbzsfile.nc';
% 
% x = [0, 100, 200];
% y = [50, 150, 250];
% 
% EPSGcode = 32631;
% UTMname = 'UTM31N';
% 
% refdate  = '1970-01-01 00:00:00';
% time = [0, 60];
% 
% rng('default');
% bzs = -1 * randi([0 10],length(time),length(x));
%
% sfincs_write_netcdf_bndbzsfile(filename, x, y, EPSGcode, UTMname, refdate, time, bzs)
%
%% General info
ncid                = netcdf.create(filename,'NC_WRITE');
globalID            = netcdf.getConstant('NC_GLOBAL');

% Add attributes global to the dataset
netcdf.putAtt(ncid,globalID, 'title',           'SFINCS netcdf bnd/bzs water level time-series input');
netcdf.putAtt(ncid,globalID, 'institution',     'Deltares');
netcdf.putAtt(ncid,globalID, 'email',           'tim.leijnse@deltares.nl');
netcdf.putAtt(ncid,globalID, 'terms_for_use',   'Use as you like');
netcdf.putAtt(ncid,globalID, 'disclaimer',      'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE');

% Define the dimensions
mypointssize    = size(x,2); 
mytimesize      = length(time);

pointsdimid     = netcdf.defDim(ncid,'stations',mypointssize);
timedimid       = netcdf.defDim(ncid,'time',mytimesize);
crsdimid        = netcdf.defDim(ncid,'crs',1);

%% Standard names
% Standard names - 1 = x (bnd)
x_ID        = netcdf.defVar(ncid,'x','double',pointsdimid); 
netcdf.putAtt(ncid,x_ID,'standard_name','projection_x_coordinate');
netcdf.putAtt(ncid,x_ID,'long_name',['x coordinate according to ',UTMname]);
netcdf.putAtt(ncid,x_ID,'axis','X');
netcdf.putAtt(ncid,x_ID,'_FillValue',-999);
netcdf.putAtt(ncid,x_ID,'units','m');

% Standard names - 2 = y (bnd)
y_ID        = netcdf.defVar(ncid,'y','double',pointsdimid); 
netcdf.putAtt(ncid,y_ID,'standard_name','projection_y_coordinate');    
netcdf.putAtt(ncid,y_ID,'long_name',['y coordinate according to ',UTMname]);
netcdf.putAtt(ncid,y_ID,'axis','Y');
netcdf.putAtt(ncid,y_ID,'_FillValue',-999);
netcdf.putAtt(ncid,y_ID,'units','m');

% Standard names - 3 = crs
crs_ID      = netcdf.defVar(ncid,'crs','double',crsdimid);
netcdf.putAtt(ncid,crs_ID,'standard_name', 'coordinate_reference_system');
netcdf.putAtt(ncid,crs_ID,'long_name',['coordinate_reference_system_in_',UTMname]);
netcdf.putAtt(ncid,crs_ID,'epsg_code', ['EPSG:',num2str(EPSGcode)]);

% Standard names - 4 = time
time_ID     = netcdf.defVar(ncid,'time','double',timedimid);
netcdf.putAtt(ncid,time_ID,'standard_name', 'time');
netcdf.putAtt(ncid,time_ID,'long_name', 'time in minutes');
netcdf.putAtt(ncid,time_ID,'units', ['minutes since ',refdate]);

% Standard names - 5 = bzs
bzs_ID      = netcdf.defVar(ncid,'zs','double',[pointsdimid timedimid]); 
netcdf.putAtt(ncid,bzs_ID,'standard_name','water_level');
netcdf.putAtt(ncid,bzs_ID,'long_name','sea_surface_height_above_mean_sea_level');
netcdf.putAtt(ncid,bzs_ID,'units','m');
netcdf.putAtt(ncid,bzs_ID,'_FillValue',-999);
netcdf.putAtt(ncid,bzs_ID,'coordinates','x y time');
netcdf.putAtt(ncid,bzs_ID,'grid_mapping','crs');

%% Close defining the NetCdf and write data
netcdf.endDef(ncid);

% Store the dimension variables 
netcdf.putVar(ncid,x_ID,x);  
netcdf.putVar(ncid,y_ID,y);
netcdf.putVar(ncid,crs_ID,EPSGcode);
netcdf.putVar(ncid,time_ID,time);

% Store real data, correct dimensions data
bzsnew      = permute(squeeze(bzs), [2,1]); %set input to right dimensions
bzsnew      = single(bzsnew); %needed to specify as single?
netcdf.putVar(ncid,bzs_ID,bzsnew);

% We're done, close the netcdf input file
netcdf.close(ncid)
fclose('all'); 
end