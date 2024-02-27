%VAKLODINGEN2PNG   make kml files with vaklodingen as georeferenced pngs
%
%See also: jarkusgrids2png, vaklodingen2kml, vaklodingen_overview

url                     = vaklodingen_url;
EPSG                    = load('EPSG');

figure('Visible','Off')
h = surf(2*peaks-.1);

shading    interp;
material  ([.88 0.11 .08]);
lighting   phong
axis       off;
axis       tight;
view      (0,90);
lightangle(0,90)
clim      ([-50 25]);
colormap  (colormap_cpt('bathymetry_vaklodingen',500));

for ii = 1:length(url);
    [path, fname] = fileparts(url{ii});
    x    = nc_varget(url{ii},   'x');
    y    = nc_varget(url{ii},   'y');
    time = nc_varget(url{ii},'time');
    
    % expand x and y 15 m in each direction to create some overlap
    x = [x(1) + (x(1)-x(2))*.75; x; x(end) + (x(end)-x(end-1))*.75];
    y = [y(1) + (y(1)-y(2))*.75; y; y(end) + (y(end)-y(end-1))*.75];
    % coordinates:
    [X  ,Y  ] = meshgrid(x,y);
    [lon,lat] = convertCoordinates(X,Y,...
        EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    
    jj = size(time,1);
    
    
    % load z data
    z = nc_varget(url{ii},'z',[jj-1,0,0],[1,-1,-1]);
    z(z>500) = nan;
    if ~all(all(isnan(z)))
        disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%'])
        % expand z
        z = z([1 1:end end],:);
        z = z(:,[1 1:end end]);
        
        KMLfigure_tiler(h,lat,lon,z,...
             'highestLevel',6,...
              'lowestLevel',14,...
       'mergeExistingTiles',true,...
                  'bgcolor',[255 0 255],...
                  'fileName','vaklodingen.kml');
    else
        disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%, no file created'])
    end
end   