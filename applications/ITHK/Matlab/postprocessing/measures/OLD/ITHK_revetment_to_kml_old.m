function ITHK_revetment_to_kml(ss)

global S

%% Get info from structure
% General info
t0 = S.PP.settings.t0;
lat = S.userinput.revetment(ss).lat;
lon = S.userinput.revetment(ss).lon;
% MDA info
MDAdata_NEW = S.PP.settings.MDAdata_NEW;
x0 = S.PP.settings.x0;
y0 = S.PP.settings.y0;
s0 = S.PP.settings.s0;
% Grid info
sgridRough = S.PP.settings.sgridRough; 
dxFine = S.PP.settings.dxFine;
% idplotrough = S.PP.settings.idplotrough;

%% preparation
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

for jj=1:length(x)
    dist1 = ((MDAdata_NEW.Xcoast-x(jj)).^2 + (MDAdata_NEW.Ycoast-y(jj)).^2).^0.5;
    x1(jj) = x0(dist1==min(dist1));x2(jj) = MDAdata_NEW.Xcoast(dist1==min(dist1));
    y1(jj) = y0(dist1==min(dist1));y2(jj) = MDAdata_NEW.Ycoast(dist1==min(dist1));
    s1(jj) = s0(dist1==min(dist1));
    clear dist1
end

% % Polygon for potential coastline extension related to landfill
% xpoly1=[x1(1:end) x2(end:-1:1) x1(1)];
% ypoly1=[y1(1:end) y2(end:-1:1) y1(1)];
%Polygon for location of revetment
xpoly2=[x(1:end)];%xpoly2=[x1(1:end)];
ypoly2=[y(1:end)];%ypoly2=[y1(1:end)];

% convert coordinates
% [lonpoly1,latpoly1] = convertCoordinates(xpoly1,ypoly1,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
% lonpoly1     = lonpoly1';
% latpoly1     = latpoly1';
[lonpoly2,latpoly2] = convertCoordinates(xpoly2,ypoly2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
lonpoly2     = lonpoly2';
latpoly2     = latpoly2';

% % yellow triangle
% output = [output KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
% % polygon to KML
% output = [output KML_poly(latpoly1 ,lonpoly1 ,'timeIn',datenum(t0,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
% clear lonpoly1 latpoly1

% orange line
S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','lineColor',[238/255 118/255 0],'lineWidth',7)];
% polygon to KML
% output = [output KML_line(latpoly2 ,lonpoly2 ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
% clear lonpoly2 latpoly2
S.PP.output.kml = [S.PP.output.kml KML_line(latpoly2 ,lonpoly2 ,'timeIn',datenum(t0+S.userinput.revetment(ss).start,1,1),'timeOut',datenum(t0+S.userinput.revetment(ss).stop,1,1)+364,'styleName','default')];
clear lonpoly2 latpoly2

% Ids for barplots
if s1(1)<s1(end) 
    sfine(1)        = s1(1)-dxFine;
    sfine(2)        = s1(end)+dxFine;
else
    sfine(1)        = s1(end)-dxFine;
    sfine(2)        = s1(1)+dxFine;
end
for ii=1:length(sfine)
    dist{ii} = abs(sgridRough-sfine(ii));
    idrough(ii) = find(dist{ii} == min(dist{ii}),1,'first');
end
%idplotrough(idrough(1):idrough(end)) = 0;

% soutern vertex
dist2           = abs(s1(1) - sgridRough);
idNEAREST       = find(dist2==min(dist2));
idsth           = idNEAREST;
clear dist2 idNEAREST

% northern vertex
dist2           = abs(s1(end) - sgridRough);
idNEAREST       = find(dist2==min(dist2));
idnrth          = idNEAREST;
clear dist2 idNEAREST

S.PP.GEmapping.rev(S.userinput.revetment(ss).start:S.userinput.revetment(ss).stop,idsth:idnrth) = 1;

% %% Save info fine and rough grids for plotting bars
% S.kml.idplotrough = idplotrough;
% S.output = output;
