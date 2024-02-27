function ITHK_nourishment_to_kml(ss)

global S

%% Get info from structure
% General info
t0 = S.PP.settings.t0;
lat = S.userinput.nourishment(ss).lat;
lon = S.userinput.nourishment(ss).lon;
mag = S.userinput.nourishment(ss).magnitude;
% MDA info
x0 = S.PP.settings.x0;
y0 = S.PP.settings.y0;
s0 = S.PP.settings.s0;
% Grid info
sgridRough = S.PP.settings.sgridRough; 
dxFine = S.PP.settings.dxFine;
sVectorLength = S.PP.settings.sVectorLength;
% idplotrough = S.PP.settings.idplotrough;

%% preparation
% convert coordinates nourishment to RD new
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

% width nourishment
width               = (abs(x(1)-x(end))^2+abs(y(1)-y(end))^2)^0.5;

% project nourishment location on coast line
dist2           = ((x0-mean(x)).^2 + (y0-mean(y)).^2).^0.5;  % distance to coast line
idNEAREST       = find(dist2==min(dist2));
x1              = x0(idNEAREST);
y1              = y0(idNEAREST);
s1              = s0(idNEAREST);
clear dist2 idNEAREST

% soutern vertex
dist2           = abs(s1-width/2 - s0);
idNEAREST       = find(dist2==min(dist2));
x2              = x0(idNEAREST);
y2              = y0(idNEAREST);
s2              = s0(idNEAREST);
clear dist2 idNEAREST

% northern vertex
dist2           = abs(s1+width/2 - s0);
idNEAREST       = find(dist2==min(dist2));
x4              = x0(idNEAREST);
y4              = y0(idNEAREST);
s4              = s0(idNEAREST);
clear dist2 idNEAREST

% southern boundary fine grid
dist2           = abs(s2-dxFine - s0);
idNEAREST       = find(dist2==min(dist2));
sfine(1)        = s0(idNEAREST);
clear dist2 idNEAREST

% northern boundary fine grid
dist2           = abs(s4+dxFine - s0);
idNEAREST       = find(dist2==min(dist2));
sfine(2)        = s0(idNEAREST);
clear dist2 idNEAREST

% ids for barplots
for jj=1:length(sfine)
    dist{jj} = abs(sgridRough-sfine(jj));
    idrough(jj) = find(dist{jj} == min(dist{jj}),1,'first');
end
%idplotrough(idrough(1):idrough(2)) = 0;

% soutern vertex
dist2           = abs(s1-width/2 - sgridRough);
idNEAREST       = find(dist2==min(dist2));
idsth           = idNEAREST;
clear dist2 idNEAREST

% northern vertex
dist2           = abs(s1+width/2 - sgridRough);
idNEAREST       = find(dist2==min(dist2));
idnrth          = idNEAREST;
clear dist2 idNEAREST

S.PP.GEmapping.supp(S.userinput.nourishment(ss).start:S.userinput.nourishment(ss).stop,idsth:idnrth) = 1;

%% nourishment to KML
h = mag/width;
alpha = atan((y4-y2)/(x4-x2));
if alpha>0
    x3     = x1+0.5*sVectorLength*h*cos(alpha+pi()/2);
    y3     = y1+0.5*sVectorLength*h*sin(alpha+pi()/2);
elseif alpha<=0
    x3     = x1+0.5*sVectorLength*h*cos(alpha-pi()/2);
    y3     = y1+0.5*sVectorLength*h*sin(alpha-pi()/2);
end
xpoly=[x1 x2 x3 x4 x1];
ypoly=[y1 y2 y3 y4 y1];

% convert coordinates
[lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
lonpoly     = lonpoly';
latpoly     = latpoly';

% yellow triangle
S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
% polygon to KML
% output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(2006,1,1),'timeOut',datenum(2007,1,1)+364,'styleName','default')];
% output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(2026,1,1),'timeOut',datenum(2027,1,1)+364,'styleName','default')];
% output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(2046,1,1),'timeOut',datenum(2047,1,1)+364,'styleName','default')];
% output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(2066,1,1),'timeOut',datenum(2067,1,1)+364,'styleName','default')];
% output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(2086,1,1),'timeOut',datenum(2087,1,1)+364,'styleName','default')];

% implementation = [1 21 41 61 81];
% % implementation = [1 6 11 16 21 26 31 36 41 46 51 56 61 66 71 76 81 86 91];
% if  strcmp(S.nourishment(ss).category,'single')==1
%     output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation(ss),1,1),'timeOut',datenum(t0+implementation(ss)+1,1,1)+364,'styleName','default')];
% else
%     output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
% end
S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.nourishment(ss).start,1,1),'timeOut',datenum(t0+S.userinput.nourishment(ss).stop,1,1)+364,'styleName','default')];
clear lonpoly latpoly

% %% Save info fine and rough grids for plotting bars
% S.kml.idplotrough = idplotrough;
% S.output = output;




