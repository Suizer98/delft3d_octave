function write_netcdf_file(filename, x, y, EPSGcode, UTMname, ampr, outputname)
%
% v1.0  Leijnse     12-08-2019      Initial commit
% v1.1  Nederhoff   2020-03-25      Made it simple for grid output
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
% filename = 'sfincs_netamuamvfile.nc';
% 
% x = [0, 100, 200];
% y = [50, 150, 250, 350];
% 
% EPSGcode = 32631;
% UTMname = 'UTM31N';
% 
% 
% rng('default');
% ampr = 1 * randi([0 10],length(time),length(y),length(x));
%
% sfincs_write_netcdf_amuamvfile(filename, x, y, EPSGcode, UTMname, refdate, time, ampr)
%
%% General info
ncid                = netcdf.create(filename,'NETCDF4');
globalID            = netcdf.getConstant('NC_GLOBAL');

% Add attributes global to the dataset
netcdf.putAtt(ncid,globalID, 'title',           'SFINCS outputs');
netcdf.putAtt(ncid,globalID, 'institution',     'Deltares USA');
netcdf.putAtt(ncid,globalID, 'terms_for_use',   'Public domain');
netcdf.putAtt(ncid,globalID, 'disclaimer',      'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE');

% Define the dimensions
myxsize         = size(x,1); 
myysize         = size(y,1); 

xdimid          = netcdf.defDim(ncid,'x',myxsize);
ydimid          = netcdf.defDim(ncid,'y',myysize);
crsdimid        = netcdf.defDim(ncid,'crs',1);
%crsdimid        = EPSGcode;

% Get options
if strcmpi(outputname, 'waterdepth')
    shortname = 'waterdepth'; 
    longname  = 'water depth';
    unit      = 'm';
    type      = 'single';
    type_nc   = 'NC_FLOAT';    
    fill_val  = single(-9999);   
elseif strcmpi(outputname, 'waterlevel')
    shortname = 'waterlevel'; 
    longname  = 'water level';
    unit      = 'm+NAVD88';
    type      = 'single';
    type_nc   = 'NC_FLOAT';    
    fill_val  = single(-9999); 
elseif strcmpi(outputname, 'bedlevel')
    shortname = 'bedlevel'; 
    longname  = 'bed level';
    unit      = 'm+NAVD88';
    type      = 'single';
    type_nc   = 'NC_FLOAT';   
    fill_val  = single(-9999); 
elseif strcmpi(outputname, 'type')
    shortname = 'type'; 
    longname  = 'flooding type; 0 dry, 1 = continuous; 2 = discontinuous';
    unit      = '-';
    type      = 'uint8';
    type_nc   = 'NC_BYTE';    
    fill_val  = int8(9);    
elseif strcmpi(outputname, 'velocity')
    shortname = 'velocity'; 
    longname  = 'flow velocity';
    unit      = 'm/s';
    type      = 'single';
    type_nc   = 'NC_FLOAT';    
    fill_val  = single(-9999); 
elseif strcmpi(outputname, 'duration')
    shortname = 'duration'; 
    longname  = 'flood duration';
    unit      = 'hr';
    type      = 'single';
    type_nc   = 'NC_FLOAT';
    fill_val  = single(-9999);
elseif strcmpi(outputname, 'hs')
    shortname = 'Hs'; 
    longname  = 'Significant Wave Height';
    unit      = 'm';
    type      = 'single';
    type_nc   = 'NC_FLOAT';
    fill_val  = single(-9999);   
elseif strcmpi(outputname, 'tm')
    shortname = 'Tm'; 
    longname  = 'Mean Wave Period';
    unit      = 's';
    type      = 'single';
    type_nc   = 'NC_FLOAT';
    fill_val  = single(-9999);   
elseif strcmpi(outputname, 'wave_md')
    shortname = 'wave md'; 
    longname  = 'Mean Wave Direction';
    unit      = 'degrees';
    type      = 'single';
    type_nc   = 'NC_FLOAT';
    fill_val  = single(-9999);       
end


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

% Standard names - 4 = ampr
ampr_ID      = netcdf.defVar(ncid,shortname,type_nc,[xdimid ydimid]); 
netcdf.putAtt(ncid,ampr_ID,'standard_name',shortname);
netcdf.putAtt(ncid,ampr_ID,'long_name',longname);
netcdf.putAtt(ncid,ampr_ID,'units',unit);
netcdf.putAtt(ncid,ampr_ID,'_FillValue',fill_val);
netcdf.putAtt(ncid,ampr_ID,'coordinates','x y');
netcdf.putAtt(ncid,ampr_ID,'grid_mapping','crs');

% Make smaller
netcdf.defVarDeflate(ncid,x_ID,true,true,1);
netcdf.defVarDeflate(ncid,y_ID,true,true,1);
netcdf.defVarDeflate(ncid,ampr_ID,true,true,1);

%% Close defining the NetCdf and write data
netcdf.endDef(ncid);

% Store the dimension variables 
netcdf.putVar(ncid,x_ID,single(x));  
netcdf.putVar(ncid,y_ID,single(y));
netcdf.putVar(ncid,crs_ID,EPSGcode);

% Store real data, correct dimensions data
amprnew      = permute(squeeze(ampr), [2,1]);   % set input to right dimensions
if strcmpi(type, 'single')
    amprnew      = single(amprnew);                
elseif strcmpi(type, 'uint8')
    amprnew      = uint8(amprnew);     
end
netcdf.putVar(ncid,ampr_ID,amprnew);

% We're done, close the netcdf input file
netcdf.close(ncid)
fclose('all');

end