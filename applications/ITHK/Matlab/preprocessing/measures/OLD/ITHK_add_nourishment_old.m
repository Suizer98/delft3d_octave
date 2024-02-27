function ITHK_add_nourishment(ss,phase,sens)

global S

%% Get info from struct
lat = S.userinput.nourishment(ss).lat;
lon = S.userinput.nourishment(ss).lon;
mag = S.userinput.nourishment(ss).magnitude;

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
% if phase==1
%     [SOSdata0]=ITHK_readSOS([S.outputdir S.nourishment(ss).filename]);
% else
%     [SOSdata0]=ITHK_readSOS([S.outputdir S.phase(phase-1).SOSfile]);
% end
[SOSdata0]=ITHK_readSOS([S.settings.outputdir S.userinput.nourishment(ss).filename]);
%[SOSdata0]=ITHK_readSOS('1HOTSPOTS1IT.SOS');

%% calculate nourishment information
nSuppletion         = 1; % number of nourishments

nourishment          = struct;
nourishment.name     = 'hotspots1locIT';
nourishment.x        = mean(x);
nourishment.y        = mean(y);
volumes             = mag;

% width
width               = (abs(x(1)-x(end))^2+abs(y(1)-y(end))^2)^0.5;

% project line on coast
dist1=[];
for jj=1:nSuppletion
    dist3           = ((MDAdata.Xcoast-nourishment.x(jj)).^2 + (MDAdata.Ycoast-nourishment.y(jj)).^2).^0.5;  % distance to coast line
    idNEAREST       = find(dist3==min(dist3));
    x1(jj)          = MDAdata.Xcoast(idNEAREST);%MDAdata.QpointsX(idNEAREST);
    y1(jj)          = MDAdata.Ycoast(idNEAREST);%MDAdata.QpointsY(idNEAREST);
    dist            = distXY(MDAdata.Xcoast,MDAdata.Ycoast); % distance from boundary
    dist1(jj)       = dist(idNEAREST); % distance from boundary
end

%% write a SOS file (sources and sinks)
for ii=1:length(nourishment)
    for nn=1:length(volumes)
        if ii==1
            SOSfilename = [S.settings.outputdir S.userinput.nourishment(ss).filename];
            %SOSfilename = ['1HOTSPOTS',num2str(ss+1),'IT.sos'];
        end
        %SOSfilename = ['1HOTSPOTS',num2str(ss+1),'IT.sos'];
        ITHK_writeSOS(SOSfilename,SOSdata0);
        %S.nourishment(ss).filename = SOSfilename;
        nourishment(ii).volume = volumes(nn);
        nourishment(ii).width  = 0.5*width(nn);%must be radius
        ITHK_addTRIANGULARnourishment(MDAdata,nourishment(ii),SOSfilename)
    end
end
S.UB.input(sens).nourishment(ss).SOSdata = nourishment;