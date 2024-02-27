function dflowfm_checkLimitingCells(mduPath)
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

% read numlindt
for ff = 1:length(outputFiles)
    disp(['Reading numlimdt variable from ',outputFiles(ff).name])
    varInfo = nc_getvarinfo([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFiles(ff).name],'numlimdt');
    varIDTimes=find(~cellfun('isempty',regexp(varInfo.Dimension,'time')));
    varInfo.Size(varIDTimes) = length(times); % to make sure that the same amount of timesteps are read from each partition
    if ff == 1
        numlimdt = nc_varget([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFiles(ff).name],'numlimdt',[0 0],[varInfo.Size(1) varInfo.Size(2)]);
    else
        numlimdt = [numlimdt nc_varget([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFiles(ff).name],'numlimdt',[0 0],[varInfo.Size(1) varInfo.Size(2)])];
    end
end
[maxNumlimdt,maxNumlimdtFace] = sort(numlimdt(end,:),'descend');
IDplotFaces = 1:min(10,length(find(maxNumlimdt>1)));

%% reading history data

% finding history output files
outputFileHis = dir([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,'*_his.nc']);

% read times and computational timestep information
his.times = nc_cf_time([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFileHis(1).name]);
his.dT = ncread([mduDir,filesep,'DFM_OUTPUT_',mduName,filesep,outputFileHis(1).name],'timestep');

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


%% plotting overview
colorBarBins = linspace(0,maxNumlimdt(1),20);
colors = jet(20);

figure

hS(1) = subplot(2,1,1);
axis equal
hold on

plot(xFaceContour(:),yFaceContour(:),'Color',[0.8 0.8 0.8],'LineWidth',0.5);

% plot landboundary (if available)
if exist('ldb','var')
    plot(ldb(:,1),ldb(:,2),'Color',[0.5 0.5 0.5])
end

% plot cutcellpolygons (if available)
if exist('lstPol','var')
    plot(lstPol(:,1),lstPol(:,2),'Color',[0 0 0])
end

% plotting faces that are most limiting
if ~isempty(IDplotFaces)
    plotNr = 0;
    for pp = 1:length(IDplotFaces)
        
        % calculating area of cell
        xFaceContourInd = xFaceContour(:,maxNumlimdtFace(pp)); xFaceContourInd(isnan(xFaceContourInd)) = [];
        yFaceContourInd = yFaceContour(:,maxNumlimdtFace(pp)); yFaceContourInd(isnan(yFaceContourInd)) = [];
        if strcmpi(modelType,'spherical')
            [xFaceContourIndCart,yFaceContourIndCart] = convertCoordinates(xFaceContourInd,yFaceContourInd,'CS1.code',4326,'CS2.name',['WGS 84 / UTM zone ',utmZone.number,utmZone.NS]);
            faceArea(pp) = polyarea(xFaceContourIndCart,yFaceContourIndCart);
        else
            faceArea(pp) = polyarea(xFaceContourInd,yFaceContourInd);
        end
        
        colorPolygon =  colors(length(find(colorBarBins<maxNumlimdt(pp))),:);
        hP(pp) = plot(xFaceContourInd,yFaceContourInd,'Color',colorPolygon,'LineWidth',5,'DisplayName',['Cell ',num2str(pp),': ',num2str(maxNumlimdt(pp)),'x (area = ',num2str(round(faceArea(pp))),'m, depth = ',num2str(round(grd.face.FlowElem_z(maxNumlimdtFace(pp))*10)/10),'m)']);
        hT(pp) = text(nanmean(xFaceContourInd),nanmean(yFaceContourInd),num2str(pp),'FontSize',20,'Color',colorPolygon);
    end
    hL = legend(hP);
    
    title(['Number of times a cell was limiting in ',num2str(times(end)-times(1)),' days simulation time'])
else
    
    title(['No cell was limiting in ',num2str(times(end)-times(1)),' days simulation time'])
end

xlabel(x_label)
ylabel(y_label)

xlim([min(min(xFaceContour)) max(max(xFaceContour))])
ylim([min(min(yFaceContour)) max(max(yFaceContour))])

if strcmpi(modelType,'cartesian')
    kmAxis(gca,[kmTick kmTick]);
end

%% add timeseries plot
hS(2) = subplot(2,1,2);
set(hS(2),'defaultAxesColorOrder',[0 0 0; 0 1 0.4]);
hold on

% show variation of limiting cells over time
% yyaxis left
if ~isempty(IDplotFaces)
    for pp = 1:length(IDplotFaces)
        colorPolygon =  colors(length(find(colorBarBins<maxNumlimdt(pp))),:);
        hP2(pp) = plot(times,numlimdt(:,maxNumlimdtFace(pp)),'Color',colorPolygon);
    end
end
ylabel('Times cell was limiting')

% show variation of timestep over time
yyaxis right
hP3 = plot(his.times,his.dT,'r.-','Color',[0 1 0.4],'LineWidth',2,'MarkerSize',10)
ylabel('Timestep [s]')

datetickzoom
grid on
xlabel('Time')

set(hS(1),'Position',[0.08 0.29 0.9 0.68],'FontSize',6);
set(hS(2),'Position',[0.08 0.07 0.86 0.12],'FontSize',6);

% print figure
print(gcf,'-dpng','-r300',[mduDir,filesep,'Limiting_cells_overview.png'])
saveas(gcf,[mduDir,filesep,'Limiting_cells_overview.fig'],'fig')

%% plotting details of cell locations

if ~isempty(IDplotFaces)
    % prepare detailed figures
    nrFaces= min(200,length(grd.face.FlowElem_x));
    set(hP,'LineWidth',1)
    set(hL,'Visible','Off')
    delete(hT)
    for pp = 1:length(IDplotFaces)
        set(hP2,'Visible','Off')
        % find nearest 200 cells
        dists = sqrt((grd.face.FlowElem_x-grd.face.FlowElem_x(maxNumlimdtFace(pp))).^2+(grd.face.FlowElem_y-grd.face.FlowElem_y(maxNumlimdtFace(pp))).^2);
        [distFaces,closestFaces] = sort(dists);
        
        set(gcf,'currentaxes',hS(1))
        xlim([min(grd.face.FlowElem_x(closestFaces(1:nrFaces))) max(grd.face.FlowElem_x(closestFaces(1:nrFaces)))])
        ylim([min(grd.face.FlowElem_y(closestFaces(1:nrFaces))) max(grd.face.FlowElem_y(closestFaces(1:nrFaces)))])
        colorPolygon =  colors(length(find(colorBarBins<maxNumlimdt(pp))),:);
        hT2(pp) = text(nanmean(xFaceContour(:,maxNumlimdtFace(pp)))+distFaces(nrFaces)/20,nanmean(yFaceContour(:,maxNumlimdtFace(pp))),num2str(pp),'FontSize',20,'Color',colorPolygon);
        
        set(hP2(pp),'Visible','On')
        
        % print figure
        print(gcf,'-dpng','-r300',[mduDir,filesep,'Limiting_cells_details_cell_Nr_',num2str(pp,'%01i'),'.png'])
    end
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
colorbarBinsArea = linspace(0,mdu.geometry.Bamin,20);
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

title(['Overview of cells smaller than Bamin (',num2str(mdu.geometry.Bamin),'m^2)'])

xlabel(x_label)
ylabel(y_label)

xlim([min(min(xFaceContour)) max(max(xFaceContour))])
ylim([min(min(yFaceContour)) max(max(yFaceContour))])

% print figure
print(gcf,'-dpng','-r300',[mduDir,filesep,'small_cells_overview.png'])
saveas(gcf,[mduDir,filesep,'small_cells_overview.fig'],'fig')

close all
