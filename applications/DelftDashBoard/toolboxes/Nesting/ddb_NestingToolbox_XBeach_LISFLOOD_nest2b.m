function [succes] = ddb_NestingToolbox_XBeach_LISFLOOD_nest2b( model,xq, yq, Qq,tq, distances)

%% Function to apply discharges from XBeach in LISFLOOD
succes = 0;
try
    
% Apply in LISFLOOD
cd(model.path);

% Load model DEM
[A] = textread(model.name,'%s');
id = find(strcmpi(A, 'DEMfile')); namedep = A{id+1};
[Xlis Ylis Zlis] = arcgridread(namedep);

% Grid size
dem_dxdy = abs((Ylis(1,1) - Ylis(2,1)));
    
%% Distribute locations: 
Qqsum = sum(Qq');
id = find( Qqsum ~=0);
ntransects = length(distances);
count1 = 1;
Qtotal2 = [];
for ii = 1:length(distances)
    Qtotal2(ii,:) = Qq(ii,:) * distances(ii);          % m3/s total from transect
end
Qtotal2 = sum(Qtotal2');

% Distances
resolutionwanted = 10;
meandistances = mean(distances);
steps = round(meandistances/resolutionwanted);

% Check amount of steps
id = find(Qtotal2 > 0.00001);
lengthtotal = length(id)*2;
if lengthtotal > 950
    possible = 950/2;
    Qtotal2sorted = sort(Qtotal2);
    ny = length(Qtotal2sorted);
    Qthreshold = Qtotal2sorted((ny-possible));
    id = find(Qtotal2 > Qthreshold);
end

for ii = id

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
for ii = id
    Qtotal = Qq(ii,:) * distances(ii);      % m3/s total from transect
    idtmp = Qtotal < 0; Qtotal(idtmp) = 0;        % only water IN LISFLOOD
    npoints = length(discharges(ii).x);     
    Qtotalpoint = Qtotal / npoints;         % distribute over # points
    qtotalpoints = Qtotalpoint / dem_dxdy;  % divide by DEM grid size (m2/s is required)
    discharges(ii).q = qtotalpoints;       
    discharges(ii).t = tq;
end
    
% Loop
ymin = num2str(min(min(Ylis))-100); ymax = num2str(max(max(Ylis))+100);
xmin = num2str(min(min(Xlis))-100); xmax = num2str(max(max(Xlis))+100);

dischfile   = 'discharges.txt';
bndfile     = 'boundaries.txt';
f_ID        = fopen (bndfile,'wt');       % bcifile boundaries.txt
f_ID2       = fopen (dischfile,'wt');     % bcyfile discharges.txt
fprintf (f_ID,'%s','N', ymin, ' ', ymax, ' FREE'); 	fprintf (f_ID,'\n');
fprintf (f_ID,'%s','S', ymin, ' ', ymax, ' FREE'); fprintf (f_ID,'\n');
fprintf (f_ID,'%s','W', xmin, ' ', xmax, ' FREE');  fprintf (f_ID,'\n');
fprintf (f_ID,'%s','E', xmin, ' ', xmax, ' FREE');   fprintf (f_ID,'\n');
    
xcount = 0;
for j = id
    nlocations = length(discharges(j).x);
    for i = 1:nlocations

    % additional point locations
    xcount = xcount + 1;
    row_to_write = {'P' num2str(discharges(j).x(i)) num2str(discharges(j).y(i)) 'QVAR' strcat('DISCH_',num2str(xcount))};
        for k = 1:length(row_to_write)
            if k == length(row_to_write)
                strtype='%s';
            else
                strtype='%s ';
            end
            fprintf(f_ID,strtype,row_to_write{1,k});
        end
        fprintf(f_ID,'\n');

    % discharges
    discharge   = discharges(j).q;
    timestep    = discharges(j).t;
    heading     = strcat('DISCH_',num2str(xcount));
    subheading  = {num2str(length(discharge)) 'seconds'};
    fprintf (f_ID2,'\n');
    fprintf (f_ID2,'%s\r\n',heading);
    for k = 1:length(subheading);
        if k == length(subheading)
            strtype='%s';
        else
            strtype='%s ';
        end
        fprintf (f_ID2,strtype,subheading{1,k});
    end
    fprintf (f_ID2,'\n');
    for k = 1:length(discharge);
        discharge_step = [discharge(k) timestep(k)];
        fprintf (f_ID2,'%g %g',discharge_step);
        fprintf (f_ID2,'\n');
    end
end
end
fclose('all');
succes = 1;
catch
    succes = 0;
end
