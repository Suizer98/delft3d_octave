function dflowfm_xy_locations_small_cells(mduPath,minSize)
%DFLOWFM_XY_LOCATIONS_SMALL_CELLS Function to find the x,y locations of the
%cells smaller than variable minSize. The mduPath needs to refer to a model
%which has *_map.nc output. 

% The output of the function is a figure showing the small cells and a text
% file with three columns, x-coordinate, y-coordinate and area, of the
% small cells. This file can be used in combination with the cutcellpolygon
% technique to make sure that these small cells (after the cutcellpolygon
% action) retain their original area. To be able to use this functionality,
% the text_file needs to have the name "prev_numlimdt.xyz". In the .mdu
% file the keywords numlimdt_baorg = XX needs to be added in the [numerics]
% block. All locations in which the third column value is larger than XX
% will retain their original area. 
%
% Wilbert Verbruggen, 2018

warning off

% getting directory name and mdu name
[mduDir,mduName,mduExt] = fileparts(mduPath);

% reading mdf file
mdu = dflowfm_io_mdu('read',mduPath);

% reading landboundary file if specified
if ~strcmpi(mdu.geometry.LandBoundaryFile,'')
    ldb = landboundary('read',[mduDir,filesep,mdu.geometry.LandBoundaryFile]);
end

% reading cutcellpolygons if specified
if exist([mduDir,filesep,'cutcellpolygons.lst'],'file')
    lstPol = [];
    lst = importdata([mduDir,filesep,'cutcellpolygons.lst']);
    for kk = 1:size(lst,1)
        lstPol = [lstPol; landboundary('read',[mduDir,filesep,deblank(lst{kk})]); NaN NaN];
    end
end

%% reading map data
% finding map output files
outputFiles = dir([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,'*_map.nc']);

% read times
times = nc_cf_time([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFiles(1).name]);

% read network
grd = dflowfm_readNetPartitioned(outputFiles);


%% prepare x and y coordinates for plotting face contours (after cutcellpolygon.lst operation if applicable)
xFaceContour = grd.face.FlowElemCont_x;
yFaceContour = grd.face.FlowElemCont_y;

xDummy = repmat(xFaceContour(1,:),size(xFaceContour,1),1);
yDummy = repmat(yFaceContour(1,:),size(yFaceContour,1),1);
IDNaN = find(isnan(xFaceContour));
xFaceContour(IDNaN) = xDummy(IDNaN);
yFaceContour(IDNaN) = yDummy(IDNaN);
xFaceContour(size(xFaceContour,1)+1,:) = NaN;
yFaceContour(size(yFaceContour,1)+1,:) = NaN;

%% check if it is a spherical or cartesian model
if max(abs(grd.node.x))<=180 & max(abs(grd.node.y))<= 180
    modelType = 'spherical';
else
    modelType = 'cartesian';
end

kmTicks = [0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000];
switch modelType
    case 'cartesian'
        % find best km tick
        kmTick = kmTicks(nearestpoint(diff(x_lim)/5,kmTicks*1000));
        x_label = 'Easting [km]';
        y_label = 'Northing [km]';
    case 'spherical'
        x_label = 'Longitude [^o]';
        y_label = 'Latitude [^o]';
        [~,~,utmZone] =  deg2utm(xFaceContour(1,1),yFaceContour(1,1));
end


%% plotting area of cells
if strcmpi(modelType,'spherical')
    [xFaceContourCart,yFaceContourCart] = convertCoordinates(xFaceContour,yFaceContour,'CS1.code',4326,'CS2.name',['WGS 84 / UTM zone ',utmZone.number,utmZone.NS]);
else
    xFaceContourCart = xFaceContour;
    yFaceContourCart = yFaceContour;
end

for gg = 1:length(xFaceContourCart)
    area(gg) = polyarea(xFaceContourCart(~isnan(xFaceContourCart(:,gg)),gg),yFaceContourCart(~isnan(yFaceContourCart(:,gg)),gg));
end

% defining colorbar steps
colorbarBinsArea = linspace(0,minSize,20);
colors = flipud(jet(19));

figure
axis equal
hold on

plot(xFaceContour(:),yFaceContour(:),'Color',[0.9 0.9 0.9],'LineWidth',0.5);

for cc = 1:length(colorbarBinsArea)-1
    IDcell = find(area>= colorbarBinsArea(cc) & area< colorbarBinsArea(cc+1));
    xDummy = xFaceContour(:,IDcell);
    yDummy = yFaceContour(:,IDcell);
    plot(xDummy(:),yDummy(:),'Color',colors(cc,:),'LineWidth',5);
end

% plot landboundary (if available)
if exist('ldb','var')
    plot(ldb(:,1),ldb(:,2),'Color',[0.5 0.5 0.5])
end

% plot cutcellpolygons (if available)
if exist('lstPol','var')
    plot(lstPol(:,1),lstPol(:,2),'Color',[0 0 0])
end

hC = colorbar
set(hC,'colormap',colors)
set(get(hC,'YLabel'),'String','Cell area [m^2]')
caxis([colorbarBinsArea(1) colorbarBinsArea(end)])

title(['Overview of cells smaller than (',num2str(minSize),'m^2)'])

xlabel(x_label)
ylabel(y_label)

xlim([min(min(xFaceContour)) max(max(xFaceContour))])
ylim([min(min(yFaceContour)) max(max(yFaceContour))])

% print figure
print(gcf,'-dpng','-r300',[mduDir,filesep,'small_cells_overview.png'])
saveas(gcf,[mduDir,filesep,'small_cells_overview.fig'],'fig')
close all

% print text file with x, y, area of the small cells
IDcells = find(area<=minSize);
[~,IDsort] = sort(area(IDcells),'ascend');
IDcells= IDcells(IDsort);
smallCellData = [grd.face.FlowElem_x(IDcells)' grd.face.FlowElem_y(IDcells)' area(IDcells)'];
fid = fopen([mduDir,filesep,'small_cells_xyz.xyz'],'w');
fprintf(fid,'%16.7e %16.7e %10.2f \n',smallCellData');
fclose(fid);

