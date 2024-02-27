function ITHK_groyne_to_kml(ss,NGRO)

global S

%% Get info from structure
% General info
t0 = S.PP.settings.t0;
% MDA info
x0 = S.PP.settings.x0;
y0 = S.PP.settings.y0;
s0 = S.PP.settings.s0;
% Grid info
sgridRough = S.PP.settings.sgridRough; 
dxFine = S.PP.settings.dxFine;
% idplotrough = S.PP.settings.idplotrough;
% GRO data
GROdata = ITHK_readGRO([S.settings.outputdir S.userinput.groyne(ss).filename]);
% GROdata = ITHK_readGRO('BRIJN90A.GRO');
Xw = GROdata(4+NGRO).Xw;  %because of existing groynes in GRO file
Yw = GROdata(4+NGRO).Yw;  %because of existing groynes in GRO file
Length = GROdata(4+NGRO).Length;

%% preparation
% convert coordinates nourishment to RD new
EPSG                = load('EPSG.mat');

% Find groyne location
%dist1 = ((MDAdata_NEW.Xcoast-x0).^2 + (MDAdata_NEW.Ycoast-y0).^2).^0.5;
dist2 = ((x0-Xw).^2 + (y0-Yw).^2).^0.5;
idNEAREST = find(dist2==min(dist2),1,'first');
s1 = s0(idNEAREST);
% clear idNEAREST
xgroyne1 = x0(idNEAREST);
ygroyne1 = y0(idNEAREST);

% Soutern vertex
%dist3           = abs(s1-100-s0);%100 refers to distance south of groyne
% idNEAREST       = find(dist3==min(dist3));
% xs1             = x0(idNEAREST);
% ys1             = y0(idNEAREST);
% ss1             = s0(idNEAREST);
% clear dist3 idNEAREST
xs1             = x0(idNEAREST-1);
ys1             = y0(idNEAREST-1);
ss1             = s0(idNEAREST-1);

% Northern vertex
%dist3           = abs(s1+100-s0);%100 refers to distance north of groyne
% idNEAREST       = find(dist3==min(dist3));
% xn1             = x0(idNEAREST);
% yn1             = y0(idNEAREST);
% sn1             = s0(idNEAREST);
% clear dist3 idNEAREST
xn1             = x0(idNEAREST+1);
yn1             = y0(idNEAREST+1);
sn1             = s0(idNEAREST+1);


% Polygon (5*length, since length in groyne file represents only 0.2 of actual length)
alpha    = atan((yn1-ys1)/(xn1-xs1));
if alpha>0
%     xs2     = xs1+5*Length*cos(alpha+pi()/2);
%     ys2     = ys1+5*Length*sin(alpha+pi()/2);
%     xn2     = xn1+5*Length*cos(alpha+pi()/2);
%     yn2     = yn1+5*Length*sin(alpha+pi()/2);
    xgroyne2 = xgroyne1+5*Length*cos(alpha+pi()/2);
    ygroyne2 = ygroyne1+5*Length*sin(alpha+pi()/2);
elseif alpha<=0
%     xs2     = xs1+5*Length*cos(alpha-pi()/2);
%     ys2     = ys1+5*Length*sin(alpha-pi()/2);
%     xn2     = xn1+5*Length*cos(alpha-pi()/2);
%     yn2     = yn1+5*Length*sin(alpha-pi()/2);
    xgroyne2 = xgroyne1+5*Length*cos(alpha-pi()/2);
    ygroyne2 = ygroyne1+5*Length*sin(alpha-pi()/2);
end
% xpoly=[xs1 xs2 xn2 xn1 xs1];
% ypoly=[ys1 ys2 yn2 yn1 ys1];

xpoly = [xgroyne1 xgroyne2];
ypoly = [ygroyne1 ygroyne2];

% convert coordinates
[lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
lonpoly     = lonpoly';
latpoly     = latpoly';

% black rectangle

% output = [output KML_stylePoly('name','default','fillColor',[0 0 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[0 0 0],'lineColor',[0 0 0],'lineWidth',4,'fillAlpha',0.7)];

% polygon to KML

% % output = [output KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
% % clear lonpoly latpoly
% output = [output KML_line(latpoly ,lonpoly ,'timeIn',datenum(t0+implementation,1,1),'timeOut',datenum(t0+duration,1,1)+364,'styleName','default')];
% clear lonpoly latpoly
S.PP.output.kml = [S.PP.output.kml KML_line(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.groyne(ss).start,1,1),'timeOut',datenum(t0+S.userinput.groyne(ss).stop,1,1)+364,'styleName','default')];
clear lonpoly latpoly


% ids for barplot
sfine(1)        = s1(1)-dxFine;
sfine(2)        = s1(1)+dxFine;

for ii=1:length(sfine)
    dist{ii} = abs(sgridRough-sfine(ii));
    idrough(ii) = find(dist{ii} == min(dist{ii}),1,'first');
end
%idplotrough(idrough(1):idrough(end)) = 0;

dist2           = abs(s1 - sgridRough);
idNEAREST       = find(dist2==min(dist2));
idgro           = idNEAREST;
clear dist2 idNEAREST

S.PP.GEmapping.gro(S.userinput.groyne(ss).start:S.userinput.groyne(ss).stop,idgro) = 1;


% %% Save info fine and rough grids for plotting bars
% S.kml.idplotrough = idplotrough;
% S.output = output;