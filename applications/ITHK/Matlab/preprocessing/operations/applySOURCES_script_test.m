
ldb1      = ITHK_io_readldb('3hotspots_locs.pol',999.999);
ldb2      = ITHK_io_readldb('6hotspots_locs.pol',999.999);

%% read MDA file  &  get transport points (instead of coastline points)
ldb       = ITHK_io_readldb('HollandCoast_RD.ldb',999.999);
[MDAdata] = ITHK_io_readMDA('BASIS.mda');
[GROdata] = ITHK_io_readGRO('BRIJN90A.GRO');

%% Suppletion information
nourishment=struct;
nourishment(1).name    = 'hotspots_3locs';
nourishment(2).name    = 'hotspots_6locs';
nourishment(1).x       = ldb1.x;
nourishment(2).x       = ldb2.x;
nourishment(1).y       = ldb1.y;
nourishment(2).y       = ldb2.y;
volumes = [3e6, 6e6, 9e6, 12e6];
width   = [2000, 2000, 2000, 2000];

dist1=[];dist2=[];
for jj=1:length(ldb1.x)
    dist3 = ((MDAdata.Xi-ldb1.x(jj)).^2 + (MDAdata.Yi-ldb1.y(jj)).^2).^0.5;
    idNEAREST = find(dist3==min(dist3));
    x1(jj) = MDAdata.QpointsX(idNEAREST);
    y1(jj) = MDAdata.QpointsY(idNEAREST);
    dist=distXY(MDAdata.Xi,MDAdata.Yi);
    dist1(jj)=dist(idNEAREST);
end
fprintf('%f %f %f\n',[x1',y1',dist1']')
for jj=1:length(ldb2.x)
    dist3 = ((MDAdata.Xi-ldb2.x(jj)).^2 + (MDAdata.Yi-ldb2.y(jj)).^2).^0.5;
    idNEAREST = find(dist3==min(dist3));
    x2(jj) = MDAdata.QpointsX(idNEAREST);
    y2(jj) = MDAdata.QpointsY(idNEAREST);
    dist=distXY(MDAdata.Xi,MDAdata.Yi);
    dist2(jj)=dist(idNEAREST);
end
fprintf('%f %f %f\n',[x2',y2',dist2']')

%% Plot the coastline and nourishments
for nn=1:length(nourishment)
    figure;
    title(nourishment(nn).name);
    plot(MDAdata.X,MDAdata.Y);
    hold on;plot(MDAdata.X,MDAdata.Y,'b-'); %'MDA reference line'
    hold on;plot(MDAdata.Xcoast,MDAdata.Ycoast,'r.-'); %'MDA coastline'
    plot(MDAdata.QpointsX,MDAdata.QpointsY,'c+');     %'MDA transport points'
    plot(nourishment(nn).x,nourishment(nn).y,'g*');           %zandmotor locations
    legend({'MDA reference line','MDA coastline','MDA transport points','zandmotor locations'},'Location','NorthWest')
    axis equal
end

%% 3 mega nourishments
for ii=1:length(nourishment)
for nn=1:length(volumes)
    %SOSfilename = [nourishment(ii).name,'_',num2str(volumes(nn)/1e6,'%02.0f'),'Mm3.sos'];
    if ii==1
    SOSfilename = ['3HOTSPOTS',num2str(nn),'_test.sos'];
    elseif ii==2
    SOSfilename = ['6HOTSPOTS',num2str(nn),'_test.sos'];
    end
    SOSdata0=ITHK_io_readSOS('SANDBYPASS.SOS');
    ITHK_io_writeSOS(SOSfilename,SOSdata0);
    nourishment(ii).volume = volumes(nn);
    nourishment(ii).width  = width(nn);
    addTRIANGULARnourishment(MDAdata,nourishment(ii),SOSfilename);
end
end


%% UNIFORM distribution along the shore
for nn=1:length(volumes)
    SOSdata=struct;
    SOSdata.headerline='';
    SOSdata.nrsourcesandsinks=0;
    SOSdata.XW=[];
    SOSdata.YW=[];
    SOSdata.CODE=0;
    SOSdata.Qs=[];
    SOSdata.COLUMN=1;
    SOSdata2=SOSdata;
    
    SOSdata(1)=ITHK_io_readSOS('SANDBYPASS.SOS');
    %SOSfilename = ['UNIFORM_',num2str(volumes(nn)/1e6,'%02.0f'),'Mm3.sos'];
    SOSfilename = ['DISTRIBUTED',num2str(nn),'.sos'];
    
    %% find gridcells inside range of nourishment
    distance        = distXY(MDAdata.Xi(1:end),MDAdata.Yi(1:end));
    fid=fopen('xy.txt','wt');fprintf(fid,'%f %f\n',[MDAdata.Xi,MDAdata.Yi]');
    gridcellwidth   = diff(distance);
    gridcellwidth   = [gridcellwidth(1:3:end-2)+gridcellwidth(2:3:end-1)+gridcellwidth(3:3:end)];
    idRANGE         = [2:3:length(MDAdata.QpointsX)-1];
    SOSdata(2).XW   = MDAdata.QpointsX(idRANGE);
    SOSdata(2).YW   = MDAdata.QpointsY(idRANGE);
    
    %% determine magnitude for each grid cell (based on length of grid cells)
    distrfactor        = gridcellwidth/sum(gridcellwidth);
    volumepercell      = distrfactor*volumes(nn); %/length(idRANGE);
    SOSdata(2).CODE    = zeros(length(idRANGE),1);
    SOSdata(2).Qs      = volumepercell;
    SOSdata(2).COLUMN  = zeros(length(idRANGE),1);
    
    %% combine different nourishment and initial data in file
    ids=[];
    for ii=1:length(SOSdata)
        for jj=1:length(SOSdata(ii).XW)
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
%     for jj=1:length(GROdata.Xw)
%         dist3 = ((MDAdata.QpointsX-GROdata.Xw(jj)).^2 + (MDAdata.QpointsY-GROdata.Yw(jj)).^2).^0.5;
%         idNEAREST = find(dist3==min(dist3));
%         idGROSOS  = find(SOSdata2.XW==MDAdata.QpointsX(idNEAREST) & SOSdata2.YW==MDAdata.QpointsY(idNEAREST));
%         if ~isempty(idGROSOS)
%               VOL2 = SOSdata2.Qs(idGROSOS);
%               SOSdata2.XW = [SOSdata2.XW(1:idGROSOS-1);SOSdata2.XW(idGROSOS+1:end)];
%               SOSdata2.YW = [SOSdata2.YW(1:idGROSOS-1);SOSdata2.YW(idGROSOS+1:end)];
%               SOSdata2.Qs = [SOSdata2.Qs(1:idGROSOS-1);SOSdata2.Qs(idGROSOS+1:end)];
%               SOSdata2.XW = [SOSdata2.XW;MDAdata.QpointsX(idNEAREST-1);MDAdata.QpointsX(idNEAREST+1)];
%               SOSdata2.YW = [SOSdata2.YW;MDAdata.QpointsY(idNEAREST-1);MDAdata.QpointsY(idNEAREST+1)];
%               SOSdata2.Qs = [SOSdata2.Qs;VOL2/2;VOL2/2];
%         end
%     end
    
    SOSdata2.CODE=SOSdata2.Qs*0;
    SOSdata2.COLUMN=SOSdata2.Qs*0+1;
    SOSdata2.nrsourcesandsinks=length(SOSdata2.XW);
    ITHK_io_writeSOS(SOSfilename,SOSdata2);
end
