%EXAMPLE .
%
%See also: 

%% setup netcdf
addpath mexnc
addpath snctools
javaaddpath ( './toolsUI-2.2.22.jar' )
setpref ('SNCTOOLS', 'USE_JAVA', true); % this requires SNCTOOLS 2.4.8 or better
%% server at deltares
% test server
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/test/transect.nc';
% url = 'http://micore.wldelft.nl/opendap/rijkswaterstaat/jarkus/transect.nc';

%% Load transect data from the internet using old functions
% first call takes over 200 seconds on the test server.
% mainly bacause an array of 2000x2000x2 coordinates  are pre-loaded 
% this takes over 170 seconds (through vpn on adsl)
% next calls take 0.25seconds
d = readTransectDataNetcdf(url, 'Ameland', '0300', '2005');


%% Below shows the way to work with the data in the netcdf way
% look up metadata
info = nc_info(url); % this takes about 9seconds on my machine

%% lookup dimensions, variables and global attributes
{info.Dimension.Name}
{info.Dataset.Name}
{info.Attribute.Name}

% overview of the dataset
nc_dump(url)

% query variables
x = nc_varget(url, 'x');
y = nc_varget(url, 'y');

% big plot (4M points)
plot(x,y, '.');

% get 40 years of data for all 1925 seaward points for first 5 transects
data = nc_varget(url, 'height', [0,0,0], [40,10,1925]); 

% plot 
for i=1:40
    point3(x(1:10,:),y(1:10,:),squeeze(data(i,:,:)), '.');
    pause(1);
end

plot(data)


%% create an animation from the transects
yearArray = nc_varget(url, 'year');
seawardDistanceArray =  nc_varget(url, 'seaward_distance');
idArray =  nc_varget(url, 'id');

find(yearArray == 2004);
find(idArray == 7003800);

for i = 1:length(yearArray)
    year = yearArray(i);
    d = readTransectDataNetcdf(url, 3000380, year);
    plot(d.x,  d.height);
    pause(1);
end

% d = readTransectdata('JARKUS data', 'Noord-Holland', '03800', '2004')


%% examples of other  remote file
info = nc_info('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods');

x = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'X');
X = repmat(x,1,217)';
y = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'Y');
Y = repmat(y, 1,432);
bath = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'bath');
Z = bath;
% Set up axes
axesm ('globe','Grid', 'on');
view(60,60)
axis off
% Display a surface
% load geoid
% meshm(Z,[(427)/360 90 0], [427 227], Z);
% geoshow(y, x, Z, 'DisplayType', 'surface')
% surfm(y,x,geoid,bath/100000)
% plot3m(x,y,bath/10000)
surfacem(Y,X,Z,Z/100000);


