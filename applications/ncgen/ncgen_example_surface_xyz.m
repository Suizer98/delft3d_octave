% Example script for creating a netcdf from xyz source data
% 
%% The basics:
% Netcdf generation with the ncgen toolbox is done by the function
% ncgen_mainFcn. This function does the basics and can be used for many
% different file types / data sets. To do so, the function uses a schema
% function, a read function and a write function:
%
% * schema funtion
%   creates the lay out schema of the netcdf files to write the data to. This
%   schema is usually dependant on the type of data. For surface data, use
%   ncgen_schemaFcn_surface; for timeseries, ncgen_schemaFcn_timeseries.
%
% * read function 
%   Reads the raw data filetype. For xyz surface data, use
%   ncgen_readFcn_surface_xyz.
%
% * writeFcn, 
%   Writes the data to the netcdf file. for surface data use 
%   ncgen_writeFcn_surface.

%% ceate some dummy data
% We need some dummy data to write to netcdf. Two xyz files are created
% with different timestamps and coverage;
dummy_file_location = fullfile(tempdir,'ncgen_example_surface_xyz','raw');
mkpath(dummy_file_location)
[x,y] = meshgrid(67501:2:69499,446001:2:446999);
z = [peaks(500)*2 peaks(500)*10];

xyz = [x(:) y(:) z(:)]';
fid = fopen(fullfile(dummy_file_location,'2012-01-01.xyz'),'w');
fprintf(fid,'%0.0f,%0.0f,%0.1f\n',xyz);
fclose(fid);

n = (1:1e5)';
xyz = [x(n) y(n) z(n)+2]';
fid = fopen(fullfile(dummy_file_location,'2012-02-01.xyz'),'w');
fprintf(fid,'%0.0f,%0.0f,%0.1f\n',xyz);
fclose(fid);

%% get default OPT
OPT = ncgen_surface_xyz;

%% OPT.main
% adjust the general settings which apply to every netcdf generation
% define source location
OPT.main.path_source      = dummy_file_location;
OPT.main.dateFcn          = @(filename) datenum(filename(1:10),'yyyy-mm-dd');% specify method to extract a datenum from the filename
OPT.main.path_netcdf      = fullfile(tempdir,'ncgen_example_surface_xyz','nc');% determine where to write to

%% OPT.schema
% there are settings specific to the schemaFcn.
% To correctly process the test files, define the following:
OPT.schema.EPSGcode       = 28992; % epsg code for Rijksdriehoek
OPT.schema.grid_cellsize   = 2;     % x and y coordinates are spaced 2m apart, only on uneven numbers
OPT.schema.grid_offset    = 1;     
OPT.schema.grid_tilesize  = 250; % put 250 by 250 z points in one nc file

% To save space, we can can specify a different datatype for z than the
% default 64-bits double precision floating point
% a 16 bits integer scaled by 0.1 can hold all data in z and is 4 x smaller
OPT.schema.z_datatype     = 'int16';
OPT.schema.z_scale_factor = 0.1;

% add information about the generating script in the met data.
OPT.schema.meta           = struct(...
    'Conventions'   ,'CF-1.4',...
    'CF_featureType','grid',...
    'title'         ,'Dummy surface data',...
    'institution'   ,'n/a',...
    'source'        ,'n/a',...
    'history'       ,'Created with: $Id: ncgen_example_surface_xyz.m 6372 2012-06-12 12:48:08Z tda.x $ $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgen_example_surface_xyz.m $',...
    'references'    ,'No reference material available',...
    'comment'       ,'dummy data',...
    'email'         ,'e@mail.com',...
    'version'       ,'1.0',...
    'terms_of_use'  ,'These data is for internal use only!',...
    'disclaimer'    ,'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% OPT.read
% read settings for the file, we define the following:
OPT.read.delimiter        = ',';
OPT.read.format           = '%f%f%f';
OPT.read.headerlines      = 0;

%% OPT.write
% the defaults are ok

ncgen_surface_xyz(OPT)


%% check results

ncfile = fullfile(OPT.main.path_netcdf,'x0068001y0446501.nc');
ncdisp(ncfile);
surf(ncread(ncfile,'z'))