function S=ITHK_add_distrsupp(S,ii)

%% Get info from struct
lat = S.distrsupp(ii).lat;
lon = S.distrsupp(ii).lon;
mag = S.distrsupp(ii).magnitude;

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
[SOSdata0]=ITHK_readSOS('1HOTSPOTS1IT.SOS');

%% calculate nourishment information
volumes             = mag;

    SOSdata=struct;
    SOSdata.headerline='';
    SOSdata.nrsourcesandsinks=0;
    SOSdata.XW=[];
    SOSdata.YW=[];
    SOSdata.CODE=0;
    SOSdata.Qs=[];
    SOSdata.COLUMN=1;
    SOSdata2=SOSdata;
    
    SOSdata(1)= SOSdata0;
    SOSfilename = '1HOTSPOTS1IT.sos';
    
    %% find gridcells inside range of nourishment
    distance        = distXY(MDAdata.Xi(1:307),MDAdata.Yi(1:307));
    gridcellwidth   = diff(distance);
    gridcellwidth   = [gridcellwidth(1:3:end-2)+gridcellwidth(2:3:end-1)+gridcellwidth(3:3:end)];
    idRANGE         = [2:3:length(MDAdata.QpointsX(1:307))-1];
    SOSdata(2).XW   = MDAdata.QpointsX(idRANGE);
    SOSdata(2).YW   = MDAdata.QpointsY(idRANGE);
    
    
    %% determine magnitude for each grid cell (based on length of grid cells)
    distrfactor        = gridcellwidth/sum(gridcellwidth);
    volumepercell      = distrfactor*volumes; %/length(idRANGE);
    SOSdata(2).CODE    = zeros(length(idRANGE),1);
    SOSdata(2).Qs      = volumepercell;
    SOSdata(2).COLUMN  = zeros(length(idRANGE),1);
    
    %% combine different nourishment and initial data in file
    ids=[];
    for ii=1:length(SOSdata)
        for jj=1:length(SOSdata(ii).XW)
%             dist3           = ((MDAdata.Xcoast-nourishment.x(jj)).^2 + (MDAdata.Ycoast-nourishment.y(jj)).^2).^0.5;  % distance to coast line
%             idNEAREST       = find(dist3==min(dist3));
            
            dist2 = ((MDAdata.QpointsX-SOSdata(ii).XW(jj)).^2 + (MDAdata.QpointsY-SOSdata(ii).YW(jj)).^2).^0.5;
            idNEAREST  = find(dist2==min(dist2));
            
            idVOL = find(ids==idNEAREST(1), 1);
            if isempty(idVOL)
                ids=[ids;idNEAREST(1)];
                SOSdata2.Qs = [SOSdata2.Qs ; SOSdata(ii).Qs(jj)];
                SOSdata2.XW = [SOSdata2.XW ; MDAdata.QpointsX(idNEAREST(1))];
                SOSdata2.YW = [SOSdata2.YW ; MDAdata.QpointsY(idNEAREST(1))];
            else
                SOSdata2.Qs(idVOL)=SOSdata2.Qs(idVOL)+SOSdata(ii).Qs(jj);
            end
        end
    end
    SOSdata2B=SOSdata2;
    SOSdata2=SOSdata2B;
    SOSdata2.CODE=SOSdata2.Qs*0;
    SOSdata2.COLUMN=SOSdata2.Qs*0+1;
    SOSdata2.nrsourcesandsinks=length(SOSdata2.XW);
    ITHK_writeSOS(SOSfilename,SOSdata2);
