%% Reading a netCDF file
% Someone should finish this tutorial. It still looks like nothing....

%% Basics of netCDF files

% Visit a link, any suggestions?

%% Locating a data file on the internet
% To locate a netCDF data file, browse to an OPeNDAP website, as e.g. the
% OpenEarth website:
%%
% <http://OPeNDAP.deltares.nl:8080> 

%% 
% Find the Jarkus netCDF file by clicking on the following links:
% HYRAX ==> Rijkswaterstaat ==> JarKus ==> transects.
% Click on the link to the file and extract the direct link to the JarKus
% netCDF data file. 

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';

%%
% For some frequently used filetypes a dedicated funtion exists. This has 
% the advantage that it returns the link to the netCDF file on the Deltares
% network if it is available. This is faster than accessing data over the
% internet. 

url = jarkus_url;

%% get a collection of small files

urls = opendap_catalog('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/sea_surface_height/catalog.xml');
name = cell(5,1);
for i=1:5
    name{i,1}=nc_varget(urls{i},'station_name');
end
disp(name);

%% Interacting with a netCDF file
% To let matlab talk with a netCDF file, the snc toolbox has been
% developed. See what is in there:

help snctools

%%
% Important functions are nc_varget and nc_dump

help nc_dump   
%% 

help nc_varget

%% View metadata
% We can get data from this file using the function nc_varget. But first, let's see what
% is in the file using nc_dump. nc_dump shows all the metadata in the file.
% In the case of the JarKus file this is a lot.

nc_dump(url)

%% 
% From the metadata we can see that there is a field 'id'. To get this
% data, use nc_varget.

id = nc_varget(url,'id');

%%
% Now id contains the id's:

id(1:10)

%% Zero based indexing
%

id = nc_varget(url,'id',[5-1],1); % get 5th number: nc_varget starts at 0

%% Stride
%
% TODO

%% netCDF viewers
%
% TODO
