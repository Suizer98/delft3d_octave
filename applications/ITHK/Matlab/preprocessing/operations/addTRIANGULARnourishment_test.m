function addTRIANGULARnourishment(MDAdata,nourishment,SOSfilename)

SOSdata=struct;
SOSdata.headerline='';
SOSdata.nrsourcesandsinks=0;
SOSdata.XW=[];
SOSdata.YW=[];
SOSdata.CODE=0;
SOSdata.Qs=[];
SOSdata.COLUMN=1;
SOSdata2=SOSdata;
if exist(SOSfilename)
    SOSdata=ITHK_io_readSOS(SOSfilename); 
end

for ii=1:length(nourishment.x)
    %% find gridcells inside range of nourishment
    [idNEAREST,idRANGE]=findGRIDinrange(MDAdata.QpointsX,MDAdata.QpointsY,nourishment.x(ii),nourishment.y(ii),nourishment.width);

    %% determine distances and location of gridcells
    distance        = distXY(MDAdata.Xi(1:end),MDAdata.Yi(1:end));
    gridcellwidth   = diff(distance);
    gridcellwidth2  = gridcellwidth(idRANGE);
    spreadingwidth  = abs(distance(idRANGE(1)+1:idRANGE(end)+1)-distance(idNEAREST+1));

    SOSdata(ii+1).XW=MDAdata.QpointsX(idRANGE);
    SOSdata(ii+1).YW=MDAdata.QpointsY(idRANGE);

    %% determine magnitude for each grid cell (based on length of grid cells)
    distrfactor1 = 1-spreadingwidth/nourishment.width;
    distrfactor2 = distrfactor1/sum(distrfactor1);        % influence of differences in width of cells
    
    volumepernourishment = nourishment.volume/length(nourishment.x);
    volumepercell  = distrfactor2*volumepernourishment;
    SOSdata(ii+1).CODE   = zeros(length(idRANGE),1) ;
    SOSdata(ii+1).Qs     = volumepercell;
    SOSdata(ii+1).COLUMN = zeros(length(idRANGE),1);
end

%% combine different nourishment and initial data in file
ids=[];
for ii=1:length(SOSdata)
    for jj=1:length(SOSdata(ii).XW)
        [idNEAREST]=findGRIDinrange(MDAdata.QpointsX,MDAdata.QpointsY,SOSdata(ii).XW(jj),SOSdata(ii).YW(jj),0);
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
SOSdata2.CODE=abs(SOSdata2.Qs*0);
SOSdata2.COLUMN=abs(SOSdata2.Qs*0)+1;
SOSdata2.nrsourcesandsinks=length(SOSdata2.XW);
ITHK_io_writeSOS(SOSfilename,SOSdata2);
end

%% function to find nearest point on coastline
function [idNEAREST,idRANGE]=findGRIDinrange(QpointsX,QpointsY,x,y,radius)
    dist2 = ((QpointsX-x).^2 + (QpointsY-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((QpointsX-QpointsX(idNEAREST)).^2 + (QpointsY-QpointsY(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end