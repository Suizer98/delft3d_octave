function ITHK_add_groyne(ss,phase,NGRO,sens)

global S

%% get info from struct
lat = S.userinput.groyne(ss).lat;
lon = S.userinput.groyne(ss).lon;
mag = S.userinput.groyne(ss).magnitude;

cstupdate = str2double(S.settings.groyne.coastlineupdate);
updatewidth = str2double(S.settings.groyne.updatewidth);
angleA = str2double(S.settings.groyne.angleshiftclimateA);
angleB = str2double(S.settings.groyne.angleshiftclimateB);

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
[MDAdata_ORIG]=ITHK_readMDA('BASIS_ORIG.MDA');
if phase==1 || NGRO>1
    [GROdata]=ITHK_readGRO([S.settings.outputdir S.userinput.groyne(ss).filename]);
else
    [GROdata]=ITHK_readGRO([S.settings.outputdir S.userinput.phase(phase-1).GROfile]);
end
%[GROdata]=ITHK_readGRO('BRIJN90A.GRO');

%% Find groyne location on initial coastline
% groyne points
XYgroyne = [x' y'];
Length = sqrt((x(1)-x(end))^2+(y(1)-y(end))^2);
S.UB.input(sens).groyne(ss).length = Length;

% initial coast line
x0              = MDAdata_ORIG.Xcoast; 
y0              = MDAdata_ORIG.Ycoast; 
s0              = distXY(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast);

% Groyne location 
for ii=1:length(XYgroyne)    
    dist{ii} = sqrt((XYgroyne(ii,1)-x0).^2+(XYgroyne(ii,2)-y0).^2);
    min_dist(ii) = min(dist{ii});
    id_coast(ii) = find(dist{ii}==min(dist{ii}),1,'first');
end
id_gro_cst = id_coast(find(min_dist==min(min_dist),1,'first'));
Xw = x0(id_gro_cst);
Yw = y0(id_gro_cst);
s1 = s0(id_gro_cst);

%% Update initial coastline around groyne (in MDA)
% Beach extension south of groyne (3 groyne length)
if cstupdate == 1
    dist_sth        = abs(s1-updatewidth*Length-s0);
    idsouth       = find(dist_sth==min(dist_sth));
    Xws             = x0(idsouth);
    Yws             = y0(idsouth);
    ss              = s0(idsouth);
    if length(idsouth:id_gro_cst)>1
        Y1south = interp1([Xws Xw],[0 0.5*Length],x0(idsouth:id_gro_cst));
    end
    Y1_new = MDAdata.Y1i;
    Y1_new(idsouth:id_gro_cst) = MDAdata.Y1i(idsouth:id_gro_cst)+Y1south;

    % Beach extension nord of groyne (3 groyne length)
    dist_nrd        = abs(s1+updatewidth*Length-s0);
    idnorth         = find(dist_nrd==min(dist_nrd));
    Xwn             = x0(idnorth);
    Ywn             = y0(idnorth);
    sn              = s0(idnorth);
    if length(id_gro_cst+1:idnorth)>1
        Y1north = interp1([Xw Xwn],[0.5*Length 0],x0(id_gro_cst+1:idnorth));
    end
    Y1_new(id_gro_cst+1:idnorth) = MDAdata.Y1i(id_gro_cst+1:idnorth)+Y1north;

    % Refine grid cells around groyne
    MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
    MDAdata.nrgridcells(id_gro_cst:id_gro_cst+1)=8;
    ITHK_writeMDA2('BASIS.MDA',[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);

    % For post-processing (same number of points)
    MDAdata_ORIG.nrgridcells=MDAdata_ORIG.Xi.*0+1;MDAdata_ORIG.nrgridcells(1)=0;
    MDAdata_ORIG.nrgridcells(id_gro_cst:id_gro_cst+1)=8;
    ITHK_writeMDA2('BASIS_ORIG.MDA',[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata_ORIG.nrgridcells);
end

%% Add local climates & adjust GROfile
% Updated coastline
[MDAdatanew]=ITHK_readMDA('BASIS.MDA');
xnew = MDAdatanew.Xcoast; 
ynew = MDAdatanew.Ycoast; 
snew = distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast);

% Find closest ray in GKL
[xGKL,yGKL,rayfiles]=ITHK_readGKL('locations5magrof2.GKL');
for ii=1:length(XYgroyne)    
    distray{ii} = sqrt((XYgroyne(ii,1)-xGKL).^2+(XYgroyne(ii,2)-yGKL).^2);
    min_distray(ii) = min(distray{ii});
    id_ray(ii) = find(distray{ii}==min(distray{ii}),1,'first');
end
idNEAREST = id_ray(find(min_distray==min(min_distray),1,'first'));

% Info local climates
RAYfilename = rayfiles(idNEAREST);
RAY = ITHK_readRAY([RAYfilename{1}(2:end-1) '.ray']);
equiA = mod(RAY.equi-angleA,360);
XA = xnew(id_gro_cst+8);
YA = ynew(id_gro_cst+8);
distC = abs(s1+2*Length-snew);
idC = find(distC==min(distC));
XC = xnew(idC);
YC = ynew(idC);
equiB = mod(RAY.equi-angleB,360);
distB = abs(s1+Length-snew);
idB = find(distB==min(distB));
XB = xnew(idB);
YB = ynew(idB);
XY = [XA YA; XB YB; XC YC];
nameA = [RAYfilename{1}(2:end-1) 'A.RAY'];
nameB = [RAYfilename{1}(2:end-1) 'B.RAY'];
nameC = [RAYfilename{1}(2:end-1) 'C.RAY'];
names = {nameA(1:end-4),nameB(1:end-4),nameC(1:end-4)};

% Write RAY files
RAY.path = {S.settings.outputdir};
RAY.name = {nameC};
ITHK_writeRAY(RAY);
RAY.name = {nameA};
RAY.equi = equiA;
ITHK_writeRAY(RAY);
RAY.name = {nameB};
RAY.equi = equiB;
ITHK_writeRAY(RAY);

% GROdata
Ngroynes = length(GROdata);
GROdata(Ngroynes+1).Xw = Xw;
GROdata(Ngroynes+1).Yw = Yw;
GROdata(Ngroynes+1).Length = Length;%0.2*Length; %Because length is not accurately represented in UNIBEST
GROdata(Ngroynes+1).BlockPerc = 100;
GROdata(Ngroynes+1).Yreference = 0;
GROdata(Ngroynes+1).option = 'right';
GROdata(Ngroynes+1).xyl = [];
GROdata(Ngroynes+1).ray_file1 = [];
GROdata(Ngroynes+1).xyr = XY;
GROdata(Ngroynes+1).ray_file2 = names;
ITHK_writeGRO([S.settings.outputdir S.userinput.groyne(ss).filename],GROdata);
S.UB.input(sens).groyne(ss).GROdata = GROdata;
%ITHK_writeGRO(['BRIJN90A' num2str(ss) '.GRO'],GROdata);
%S.groyne(ss).filename = ['BRIJN90A' num2str(ss) '.GRO'];
S.UB.input(sens).groyne(ss).rayfiles = {nameA,nameB,nameC};