% vaklodingen2transects.m
%
% This program creates a KML file for the Vaklodingen. Bathymetric
% profiles are drawn at the Earth surface connecting the defined
% coordinates. 
% .kml file and .mat file are produced for all the years.
% The figure on matlab is relative to the specified period.
% Transects of the Western Scheldt have been defined manually on 
% GoogleEarth and then saved on "myplaces".
% The function KMLline is called to create the lines in Google Earth
% The function convertCoordinates is called to change coordinate 
% system.
%
% --------------------------------------------------------------------
% Copyright (C) 2010 Deltares
%       Giorgio Santinelli
%    
%       Giorgio.Santinelli@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
% See also: KMLline, convertCoordinates, googlePlot
% --------------------------------------------------------------------

allclear

% Question dialog box to add and save a path on GE
options.Interpreter = 'tex';
options.Default = 'Cancel';
qstring = sprintf(['Please, follow the instructions.\n\n',...
'- Open GoogleEarth \n',...
'- Add a path for the Western Scheldt \n',...
'- Give a name to the path \n',...
'- Move it on ''My Places''\n',...
'- Go to  File -> Save -> Save My Places']);
choice = questdlg(qstring,'Instructions',...
    'Continue','Cancel',options);
if ~strcmp(choice,'Continue')
    return
end

% Input dialog box to write the name of the path saved on GE
prompt = {'Write the name of the path saved', 'Enter starting date',...
    'Enter ending date'};
dlg_title = 'Name of path and Time interval';
num_lines = 1;
def = {'','01-Jan-1950',datestr(now, 'dd-mmm-yyyy')};
answer = inputdlg(prompt,dlg_title,num_lines,def); 
nametrans = answer{1};
startdate = answer{2};
enddate   = answer{3};

tic

% read the coordinates from "myplaces"
GE_lonlat = read_KMLtransects(nametrans);
fprintf('Reading of coordinates complete\n');

for j = 1:size(GE_lonlat,2)

% Define starting point (lon1, lat1) and ending point (lon2, lat2) in
% sexagesimal DMS, coordinate system: 'WGS 84'
lon1 = GE_lonlat(1,j); lat1 = GE_lonlat(2,j); % deg
lon2 = GE_lonlat(4,j); lat2 = GE_lonlat(5,j); %deg
% lat1 = 51.2407; lon1 = 3.3047; % sex
% lat2 = 51.2801; lon2 = 3.3159; % sex

% 1D Resolution of transect
stepsize = 5; % metres


% Read the path on pc-drive
% ncpath = 'F:\opendap\thredds\rijkswaterstaat\vaklodingen\'; % Rijkswaterstaat data
% ncpath = 'F:\opendap\thredds\rijkswaterstaat\DienstZeeland\'; % DienstZeeland data

% Read the path from the opendap
% ncpath = 'http://opendap.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/catalog.html'; % DienstZeeland data
ncpath = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html'; % Rijkswaterstaat data
%ncpath = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html';
ncfile = '*.nc';
fss = opendap_catalog(ncpath);
% fns = dir(fullfile(ncpath,ncfile));

% to avoid vaklodingen.nc
i = 1;
for ii = 1:length(fss)
if strcmp(fss{ii},'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingen.nc')
else
fns{i} = fss{ii};    
i = i+1;
end
end

% Conversion from sexagesimal DMS to decimale degrees. 
% Coordinate system: 'WGS 84' (code:4326)
% [lon1, lat1] = convertCoordinates(lon1, lat1, 'CS1.code', '4326', 'CS1.UoM.name', 'sexagesimal DMS', 'CS2.code', '4326'); % from sexagesimal DMS
% [lon2, lat2] = convertCoordinates(lon2, lat2, 'CS1.code', '4326', 'CS1.UoM.name', 'sexagesimal DMS', 'CS2.code', '4326'); % from sexagesimal DMS

% Convert coordinate system from 'WGS 84' (code:4326) to 
% 'Amersfoort / RD New' (code:28992)
[x1, y1] = convertCoordinates(lon1, lat1, 'CS1.code', '4326', 'CS2.code', '28992');
[x2, y2] = convertCoordinates(lon2, lat2, 'CS1.code', '4326', 'CS2.code', '28992');

% Define distances (dx, dy), length, number of steps (based on stepsize),
% transect points in 'WGS 84' (X_0, Y_0) and 'Amersfoort / RD New' (lon_0, lat_0)
dx = x2-x1; dy = y2-y1;
len = sqrt(dx^2+dy^2);
nstep = len/stepsize;
stepsize_x = dx/nstep; stepsize_y = dy/nstep;
X_0 = x1:stepsize_x:x1+((nstep)-1)*stepsize_x;
Y_0 = y1:stepsize_y:y1+((nstep)-1)*stepsize_y;
[lon_0, lat_0] = convertCoordinates(X_0, Y_0, 'CS1.code', '28992', 'CS2.code', '4326');

    
% Find related KB (urlcross) and date of measurement (date_KB)
i_KB = 1;
date_KB = [];
for i = 1:length(fns)
   % url = fullfile(ncpath, fns(i).name); % path on pc-drive
    url = fns{i}; % path from the opendap
    lon = nc_varget(url, 'lon');
    lat = nc_varget(url, 'lat');   

    if ismember(true, ((min(lon1,lon2)<lon)&(max(lon1,lon2)>lon))) &&...
            ismember(true, ((min(lat1,lat2)<lat)&(max(lat1,lat2)>lat)));
        urlcross{i_KB} = url;
        date{i_KB} = nc_cf_time(url, 'time');
        date_i = date{i_KB};
        date_KB = union(date_KB, date_i);
        i_KB = i_KB+1;
    end
end

disp('Related KaartBladen and dates of measurement found.')

% Create folder in the directory
mkdir('GE_Transects')

% Read bathymetry for the related KB, for every year
stepX_0 = 0:stepsize:((nstep)-1)*stepsize;
for k = 1:length(date_KB) % Cycle of dates of measurement
    z_0{k} = [];
    x_0{k} = [];
    
    for i = 1:(i_KB-1) % Cycle of the related KB
        [tf_date n_year] = ismember(date_KB, date{i});
        
        if tf_date(k) % Make it if, in date_KB, the related KB (urlcross) has data.
            Z{i} = squeeze(nc_varget(urlcross{i}, 'z', [n_year(k)-1,0,0], [1,-1,-1]));
            y{i} = nc_varget(urlcross{i}, 'y');
            x{i} = nc_varget(urlcross{i}, 'x');
            [X{i} Y{i}] = meshgrid(x{i}, y{i}); % Create the grid for interp2
            
            xline{i} = 0:stepsize:((nstep)-1)*stepsize;
            zline{i} = interp2(X{i}, Y{i}, Z{i}, X_0, Y_0);
        
            dumz = (zline{i})';
            z_0{k} = vertcat(z_0{k}, dumz);
            dumx = (xline{i})';
            x_0{k} = vertcat(x_0{k}, dumx); 
        end
    end
    
    z_nnan{k} = nan(size(z_0{k}));
    x_nnan{k} = nan(size(z_0{k}));
    
    if ~isempty(z_0{k}(~isnan(z_0{k})))
        z_nnan{k} = z_0{k}(~isnan(z_0{k}));
        x_nnan{k} = x_0{k}(~isnan(z_0{k}));
        z_kml{k} = interp1(x_nnan{k}, z_nnan{k}, stepX_0); % the cell variable of the bathymetry along the defined transect
        x_kml{k} = stepX_0;
    else
        z_kml{k} = nan(size(stepX_0));
        x_kml{k} = nan(size(stepX_0));
    end
    
end
clear dumx dumz

disp('z_kml has been created successfully. ')

% Define timeIn and timeOut for Google Earth
timeIn = date_KB;
timeOut = date_KB(2:end);
timeOut(end+1,1) = date_KB(end)+1;

% Create matrix z_KML for KMLline
for k = 1:length(date_KB)
    z_KML(k,:) = z_kml{k};
end

% save the .mat file
mkdir('GETrans_mat')
save(['GETrans_mat\trans_',nametrans],'z_KML','date_KB','lat_0','lon_0')

% Create matrixes lat_0 and lon_0 for KMLline
lat_0 = repmat(lat_0, size(z_KML,1), 1);
lon_0 = repmat(lon_0, size(z_KML,1), 1);

% Make KML file
fname = ['GE_Transects\',nametrans,'.kml'];
KMLline(lat_0', lon_0', z_KML', 'timeIn',timeIn,'timeOut',timeOut,...
    'fileName', fname, 'lineColor',jet(size(z_KML,1)),'lineWidth',2,...
    'fillColor',jet(size(z_KML,1)),'zScaleFun', @(z_KML)(z_KML+60)*10);

% KB within the specified period
date_KB_Tnan = date_KB(date_KB >= datenum(startdate) & date_KB <= datenum(enddate));
[dummy, date_KB_index] = ismember(date_KB_Tnan, date_KB);

% Bathymetries ~NaNs within the specified period
kk = 1;
for tt = 1:length(date_KB_index)
    if ~isequalwithequalnans(z_kml{date_KB_index(tt)},NaN(1,length(stepX_0)))
       date_KB_Time(kk) = date_KB_Tnan(tt);
       kk = kk+1;        
    end
end
[dummy, date_KB_index] = ismember(date_KB_Time, date_KB);

% Plot bathymetry within the specified period
figure(1)
col = jet(length(date_KB_Time));
for kk = 1:length(date_KB_index)
    plot(x_kml{date_KB_index(kk)},z_kml{date_KB_index(kk)},'Color',col(kk,:),'LineWidth', 1.5)
    grid on
    hold on
end
legend(datestr(date_KB_Time),-1);
set(gcf,'Position',[5 35 1040 760])
set(gca,'FontSize',12)
title(['Transect from (',num2str(lat1,'%5.2f'),', ',num2str(lon1,'%5.2f'),...
    ') to (',num2str(lat2,'%5.2f'),', ',num2str(lon2,'%5.2f'),')'],...
    'FontSize',12,'FontWeight','bold')
xlabel('Distance along transect,  x [m]','FontSize',12)
ylabel('Bed level,  z_b [m]','FontSize',12)

clear z_KML
end

fprintf(['The file ',nametrans,'.kml has been saved on the folder ''GE_Transects''\n']);
toc

