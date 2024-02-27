function nan=ARC_INFO_BINARY2KML
%ARC_INFO_BINARY2KML   example script to save ESRI grid (ascii or adf) file as kml
%
%See also: ARC_INFO_BINARY, ARCGISREAD, KMLFIG2PNG

  clc
 clear all
fclose all;

%% Test data 
% All data files in
%    F:\checkouts\OpenEarthRawData\
% are a Subversion checkout from:
%    http:repos.deltares.nl/repos/OpenEarthRawData/trunk/

maps = {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007',... % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007'};   % 3

ascii= {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007\rastert_dz10_ju.txt',...  % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007\rastert_dz50_ju1.txt',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007\rastert_dz90_ju1.txt',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007\rastert_grind_f1.txt',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007\rastert_slib_ju1.txt'};   % 3

epsg = [32631 % 'WGS 84 / UTM zone 31N'
        32631
        32631
        32631
        32631];

clims= [100 400
        100 400
        100 400
          0 100
          0 100];

lgnd = {'Grain size small d10 [micrometer]',...
        'Grain size median d50 [micrometer]',...
        'Grain sizes large d90 [micrometer]',...
        'Pebbles [%]',...
        'Mud [%]'};

for im= 1:5 %:length(maps)

   close all
   
   if ~isempty(dir([fname{im},'\*.adf']))
      
     [X,Y,D,M] = arc_info_binary([fname{im},'\'],...
        'debug',0,...
         'plot',0,...
       'export',1,...
        'clim',clims(im,:),...
        'epsg',epsg(im),...
          'vc','http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'); % coastline for debugging
   else
     [X,Y,D] = ArcGisRead(ascii{im})       
     M = [];
   end
   disp(['succes: ',num2str(im),' ',maps{im}]);
   succes(im) = 1;
       
   [X  ,Y  ] = meshgrid(X,Y);
   [LON,LAT] = convertCoordinates(X,Y,'CS1.code',epsg(im),'CS2.code',4326); % to WGS84 for Google
   
   clear X Y
 
   h = pcolorcorcen(LON,LAT,D);
   
   caxis(clims(im,:));
   
   % see help KMLfigure_tiler for LAARGE file chunking
   
   KMLfigure_tiler(h,...
        'levels',[-2 4],...
      'fileName',[last_subdir(maps{im}),'.kml'],...
   'description',[lgnd{im}]);

end
