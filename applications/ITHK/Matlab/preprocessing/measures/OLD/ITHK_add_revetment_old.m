function ITHK_add_revetment(ii,phase,NREV,sens)

global S

%% get relevant info from struct
lat = S.userinput.revetment(ii).lat;
lon = S.userinput.revetment(ii).lon;
mag = S.userinput.revetment(ii).magnitude;

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
if phase==1 || NREV>1
    [REVdata]=ITHK_readREV([S.settings.outputdir S.userinput.revetment(ii).filename]);
else
    [REVdata]=ITHK_readREV([S.settings.outputdir S.userinput.phase(phase-1).REVfile]);
end
%[REVdata]=ITHK_readREV('HOLLANDCOAST.REV');

%% process
sREV = distXY(x,y);
S.UB.input(sens).revetment(ii).length = sum(sREV);    

Nrev = length(REVdata);
REVdata(Nrev+1).filename = [S.settings.outputdir S.userinput.revetment(ii).filename];
%REVdata(Nrev+1).filename = ['HOLLANDCOAST' num2str(ii) '.REV'];
REVdata(Nrev+1).Xw = x;
REVdata(Nrev+1).Yw = y;
REVdata(Nrev+1).Top = [];
if  mag==0
    REVdata(Nrev+1).Option = mag;
else
    REVdata(Nrev+1).Option = 2;
end
ITHK_writeREV_new(REVdata,MDAdata,0.1)
S.UB.input(sens).revetment(ii).REVdata = REVdata;
%S.revetment(ii).filename = ['HOLLANDCOAST' num2str(ii) '.REV'];
