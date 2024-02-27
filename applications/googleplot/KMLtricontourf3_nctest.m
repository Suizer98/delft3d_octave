clc
clear
EPSG = load('EPSG');
% urls = vaklodingen_url;
% 
% url = 'http://opendap.deltares.nl/opendap/hyrax/rijkswaterstaat/vaklodingen/vaklodingenKB130_1312.nc';
% 
% x = nc_varget(url,'x');
% y = nc_varget(url,'y');
% [X,Y] = meshgrid(x,y);
% times = [nc_varget(url,'time') + datenum('1-1-1970'); now];
% 
% Z = nc_varget(url,'z',[0 0 0],[-1 -1 -1]);
% Z(Z>100) = nan;
% save testdata X Y Z times url 
load testdata
% nn = [1:4:624 625];
% mm = [1:4:499 500];

nn = [100:1:300];
mm = [100:1:300];
[lon,lat] = convertCoordinates(X(nn,mm),Y(nn,mm),EPSG,'CS1.code',28992,'CS2.code',4326);
profile on


for time = 1%:1:length(times)-1;
    z = squeeze(Z(time,nn,mm));
    
    if numel(z(~isnan(z)))>30
       
        levels=[-52:4:-12 -11:2:-3 -2.5 -2:0.25:2 2.5 3:2:11 12:4:30]+0.001;
        
        [dummy,nc_name] = fileparts(url);
        
        plot(levels,'.')
        plot(1)
        colormap(colormap_cpt('bathymetry_vaklodingen',250))
        clim([-12.5 25])
        
        
        
        z(50:70,50:70) = nan;
        
        
%         KMLtricontourf3(tri,lat,lon,z,'levels',levels,'fileName',KML_testdir(['3D_' nc_name '_' datestr(times(time),'yyyy') '.kml']),...
%             'zScaleFun',@(z) (z+15)*4,'staggered',0,'debug',0,'colorbar',false,...
%             'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),'colorSteps',250,'cLim',[-50 25],'timeIn',times(time))
%         KMLcontourf(lat,lon,z,'levels',levels,'zScaleFun',@(z) (z+15)*4,...
%             'fileName',KML_testdir(['2D_' nc_name '_' datestr(times(time),'yyyy') '.kml']),...
%             'staggered',0,'debug',0,'colorbar',false,'colorSteps',250,...
%             'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),...
%             'cLim',[-50 25],'timeIn',times(time),'timeOut',times(time+1))
        KMLcontourf3(lat,lon,z,'levels',levels,'zScaleFun',@(z) (z+15)*4,...
            'fileName',KML_testdir(['3D_' nc_name '_' datestr(times(time),'yyyy') '.kml']),...
            'staggered',1,'debug',0,'colorbar',false,'colorSteps',250,...
            'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),...
            'cLim',[-50 25],'timeIn',times(time),'timeOut',times(time+1))
    end
end
profile viewer
