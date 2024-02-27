function sfincs_write_netcdf_amprfile(filename, x, y, EPSGcode, UTMname, refdate, time, ampr)
%
% v1.0  Leijnse     12-08-2019      Initial commit
%
% Input specification:
% - x and y expected as arrays with values along axis, no matrix. Grid is assumed rectilinear and projected in SFINCS.
% - refdate is expected as string like '1970-01-01 00:00:00' 
% - time is expected as minutes since refdate
% - ampr input matrix dimensions assumed to be (t,y,x)
% - EPSGcode as a value like: 32631
% - UTMname as a string like: 'UTM31N'
% 
% Remarks: 
% - data is now written away as singles
% 
% Example:
% filename = 'sfincs_netamprfile.nc';
% 
% x = [0, 100, 200];
% y = [50, 150, 250, 350];
% 
% EPSGcode = 32631;
% UTMname = 'UTM31N';
% 
% refdate  = '1970-01-01 00:00:00';
% time = [0, 60];
% 
% rng('default');
% ampr = 1 * randi([0 10],length(time),length(y),length(x));
%
% sfincs_write_netcdf_amprfile(filename, x, y, EPSGcode, UTMname, refdate, time, ampr)
%
%% General info
ncid                = netcdf.create(filename,'NC_WRITE');
globalID            = netcdf.getConstant('NC_GLOBAL');

% Add attributes global to the dataset
netcdf.putAtt(ncid,globalID, 'title',           'SFINCS netcdf ampr precipitation input');
netcdf.putAtt(ncid,globalID, 'institution',     'Deltares');
netcdf.putAtt(ncid,globalID, 'email',           'tim.leijnse@deltares.nl');
netcdf.putAtt(ncid,globalID, 'terms_for_use',   'Use as you like');
netcdf.putAtt(ncid,globalID, 'disclaimer',      'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE');

% Define the dimensions
myxsize         = size(x,2); 
myysize         = size(y,2); 
mytimesize      = length(time);

xdimid          = netcdf.defDim(ncid,'x',myxsize);
ydimid          = netcdf.defDim(ncid,'y',myysize);
timedimid       = netcdf.defDim(ncid,'time',mytimesize);
crsdimid        = netcdf.defDim(ncid,'crs',1);

%% Standard names
% Standard names - 1 = x
x_ID        = netcdf.defVar(ncid,'x','double',xdimid); 
netcdf.putAtt(ncid,x_ID,'standard_name','projection_x_coordinate');
netcdf.putAtt(ncid,x_ID,'long_name',['x coordinate according to ',UTMname]);
netcdf.putAtt(ncid,x_ID,'axis','X');
netcdf.putAtt(ncid,x_ID,'_FillValue',-999);
netcdf.putAtt(ncid,x_ID,'units','m');

% Standard names - 2 = y
y_ID        = netcdf.defVar(ncid,'y','double',ydimid); 
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

% Standard names - 5 = ampr
ampr_ID      = netcdf.defVar(ncid,'Precipitation','double',[xdimid ydimid timedimid]); 
netcdf.putAtt(ncid,ampr_ID,'standard_name','precipitation');
netcdf.putAtt(ncid,ampr_ID,'long_name','precipitation_rate');
netcdf.putAtt(ncid,ampr_ID,'units','mm/hr');
netcdf.putAtt(ncid,ampr_ID,'_FillValue',-999);
netcdf.putAtt(ncid,ampr_ID,'coordinates','x y');
netcdf.putAtt(ncid,ampr_ID,'grid_mapping','crs');

%% Close defining the NetCdf and write data
netcdf.endDef(ncid);

% Store the dimension variables 
netcdf.putVar(ncid,x_ID,x);  
netcdf.putVar(ncid,y_ID,y);
netcdf.putVar(ncid,crs_ID,EPSGcode);
netcdf.putVar(ncid,time_ID,time);

% Store real data, correct dimensions data
amprnew      = permute(squeeze(ampr), [3,2,1]); %set input to right dimensions
amprnew      = single(amprnew); %needed to specify as single?
netcdf.putVar(ncid,ampr_ID,amprnew);

% We're done, close the netcdf input file
netcdf.close(ncid)
fclose('all');
end