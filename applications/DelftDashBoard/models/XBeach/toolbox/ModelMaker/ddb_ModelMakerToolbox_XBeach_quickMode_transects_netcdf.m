function [succes] = ddb_ModelMakerToolbox_XBeach_quickMode_transects_netcdf(x,y,distances, angles, time, Q)
% Function for creating the settings file of XBeach transects and LISFLOOD
succes = 0;
try
    
    % This is the name of the data file we will create. 
    FILE_NAME   ='settings.nc';

    % These are used to construct some example data. 
    sample_pressure = 900;
    sample_temp = 9.0;

    % Create some pretend data.
    NX  = length(x);
    NT  = length(time);

    % Create the file. 
    [ncid, status] = mexnc ( 'CREATE', FILE_NAME, nc_clobber_mode );


    % Define the dimensions. */
    [X_dimid, status] = mexnc ( 'DEF_DIM', ncid, 'transects', NX );
    [time_dimid, status] = mexnc ( 'DEF_DIM', ncid, 'time', NT );


    % Define coordinate netCDF variables. They will hold the
    [X_varid, status] = mexnc ( 'DEF_VAR', ncid,'Transect_x', nc_float, 1, X_dimid );
    [Y_varid, status] = mexnc ( 'DEF_VAR', ncid,'Transect_y', nc_float, 1, X_dimid );
    [angle_varid, status] = mexnc ( 'DEF_VAR', ncid,'Angle', nc_float, 1, X_dimid );
    [distance_varid, status] = mexnc ( 'DEF_VAR', ncid,'Distance', nc_float, 1, X_dimid );
    [time_varid, status] = mexnc ( 'DEF_VAR', ncid,'Time', nc_float, 1, time_dimid );
    [Q_varid, status] = mexnc ( 'DEF_VAR', ncid,'Discharge', nc_float, 2, [X_dimid time_dimid]);

    % Close the file. 
    status = mexnc ( 'CLOSE', ncid );   

    % Define units attributes for coordinate vars.
    nc_attput ( FILE_NAME, 'Transect_x', 'units', 'meter' );
    nc_attput ( FILE_NAME, 'Transect_y', 'units', 'meter' );
    nc_attput ( FILE_NAME, 'Angle', 'units', 'degrees' );
    nc_attput ( FILE_NAME, 'Distance', 'units', 'meter' );
    nc_attput ( FILE_NAME, 'Time', 'units', 'seconds' );
    nc_attput ( FILE_NAME, 'Discharge', 'units', 'm2/s' );

    % Write the coordinate variable data. This will put the latitudes
    % and longitudes of our data grid into the netCDF file.
    nc_varput ( FILE_NAME, 'Transect_x', x );
    nc_varput ( FILE_NAME, 'Transect_y', y );
    nc_varput ( FILE_NAME, 'Angle', angles );
    nc_varput ( FILE_NAME, 'Distance', distances);
    nc_varput ( FILE_NAME, 'Time', time );
    nc_varput ( FILE_NAME, 'Discharge', Q );
    succes = 1;
catch
    succes = 0;
end
        


