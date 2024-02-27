function [succes] = ddb_NestingToolbox_XBeach_D3DFLOW_nest2b( model,xq, yq, Qq,tq, distances)

%% Function to apply discharges from XBeach in Delft3D-FLOW
succes = 0;
try
    
% Apply in LISFLOOD

cd(model.path);

% Load delft3D-FLOW grid
delft3dgrid = delft3d_io_grd('read', [model.name, '.grd']);
Xlis = delft3dgrid.cen.x;  Ylis = delft3dgrid.cen.y;
dem_dxdy = ((Xlis(2,1) - Xlis(1,1)).^2 + (Ylis(2,1) - Ylis(1,1)).^2).^0.5;

%% Distribute locations: ik ben hier
ntransects = length(distances);
for ii = 1:ntransects

    % Determine line
    if ii == 1;
        xline = [xq(ii), (xq(ii)+xq(ii+1))*0.5];
        yline = [yq(ii), (yq(ii)+yq(ii+1))*0.5];
        xlines = interp1([0 100], xline, [0:1:100]);
        ylines = interp1([0 100], yline, [0:1:100]);
    elseif ii == ntransects
        xline = [xq(ii),(xq(ii)+xq(ii-1))*0.5];
        yline = [yq(ii),(yq(ii)+yq(ii-1))*0.5];
        xlines = interp1([0 100], xline, [0:1:100]);
        ylines = interp1([0 100], yline, [0:1:100]);
    else
        xline = [(xq(ii)+xq(ii-1))*0.5, xq(ii), (xq(ii)+xq(ii+1))*0.5];
        yline = [(yq(ii)+yq(ii-1))*0.5, yq(ii), (yq(ii)+yq(ii+1))*0.5];
        xlines = interp1([0 50 100], xline, [0:1:100]);
        ylines = interp1([0 50 100], yline, [0:1:100]);
    end

    % Unique LISFLOOD grid points
    idxx = []; idyy = []; distancesaved = [];
    for jj = 1:100
        distance = ((Xlis - xlines(jj)).^2 + (Ylis - ylines(jj)).^2).^0.5;
        [idx idy] = find(min(min(distance)) == distance); idx = idx(1); idy = idy(1);
        a1 = []; b1 = []; a2 = []; b2 = [];
        [a1 b1]=find(idxx==idx); [a2 b2]=find(idyy==idy); 
        if isempty(a1) | isempty(a2) 
            if distance(idx, idy) < dem_dxdy*4;
            idxx = [idxx idx]; idyy = [idyy idy]; distancesaved = [distance(idx, idy) distancesaved];
            end
        end
    end

    % Locations
    XTMP = []; YTMP = [];
    for xx = 1:length(idxx);
    XTMP(xx) = (Xlis(idxx(xx), idyy(xx))); YTMP(xx) = Ylis(idxx(xx), idyy(xx)); 
    end
    discharges(ii).x = XTMP(~isnan(XTMP)); discharges(ii).y =  YTMP(~isnan(YTMP)); discharges(ii).dis = distancesaved;
end

% Distribute water over discharges
for ii = 1:ntransects
    Qtotal = Qq(ii,:) * distances(ii);      % m3/s total from transect
    id = Qtotal < 0; Qtotal(id) = 0;        % only water IN Delft3d
    npoints = length(discharges(ii).x);     
    Qtotalpoint = Qtotal / npoints;         % distribute over # points
    qtotalpoints = Qtotalpoint;             % dont divide
    discharges(ii).q = qtotalpoints;       
    discharges(ii).t = tq;
end
    
figure; hold on;
for ii = 1:ntransects
    for jj = 1:length(discharges(ii).x)
        scatter(discharges(ii).x(jj), discharges(ii).y(jj), [], nanmax(discharges(ii).q), 'filled')
        qmax(ii) = nanmax(discharges(ii).q);
    end
end
colormap(jet)

% Trow away discharge points without discharge
id = qmax < 0.000001; 
discharges(id) = [];

% Loop find n and m
src = delft3d_io_src('read', [model.name, '2.src']); src2 = src;
dis = bct_io('read', [model.name, '2.dis']); dis2 = dis;
count = 1;

for ii = 1:length(discharges)
    for jj = 1:length(discharges(ii).x)
        
        % Source
        [nn mm] = find(discharges(ii).x(jj) == Xlis & discharges(ii).y(jj) == Ylis);
        src2.m(count) = mm; src2.n(count) = nn;
        src2.DATA(count).name = ['dis_', num2str(count)];
        src2.DATA(count).interpolation = 'Y';
        src2.DATA(count).m = mm;
        src2.DATA(count).n = nn;
        src2.DATA(count).k = 0;
        src2.DATA(count).type = 'M';
        
        % Discharge
        dis2.Table(count).Name      = ['dis_', num2str(count)];
        dis2.Table(count).Location  = ['dis_', num2str(count)];
        TMP                         = [discharges(ii).t/60; discharges(ii).q; ones(size(discharges(ii).q))*1.5; ones(size(discharges(ii).q))*150];
        dis2.Table(count).Data      = TMP';
        % Next one
        count = count+1;
    end
end
src3 = delft3d_io_src('write', [model.name, '2.src'], src2);      
dis3 = bct_io('write', [model.name, '2.dis'], dis2);         

fclose('all');
succes = 1;
catch
    succes = 0;
end
