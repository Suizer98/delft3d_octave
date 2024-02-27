function [succes] = ddb_NestingToolbox_XBeach_D3DFM_nest2b( model,xq, yq, Qq,tq, distances)

%% Function to apply discharges from XBeach in Delft3D-FLOW
succes = 0;
try
    
% Apply in LISFLOOD
cd(model.path);

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
        xlines = interp1([0 steps], xline, [0:1:steps]);
        ylines = interp1([0 steps], yline, [0:1:steps]);
    elseif ii == ntransects
        xline = [xq(ii),(xq(ii)+xq(ii-1))*0.5];
        yline = [yq(ii),(yq(ii)+yq(ii-1))*0.5];
        xlines = interp1([0 steps], xline, [0:1:steps]);
        ylines = interp1([0 steps], yline, [0:1:steps]);
    else
        xline = [(xq(ii)+xq(ii-1))*0.5, xq(ii), (xq(ii)+xq(ii+1))*0.5];
        yline = [(yq(ii)+yq(ii-1))*0.5, yq(ii), (yq(ii)+yq(ii+1))*0.5];
        xlines = interp1([0 steps/2 steps], xline, [0:1:steps]);
        ylines = interp1([0 steps/2 steps], yline, [0:1:steps]);
    end

    % All points are taken into account
    discharges(count1).x = xlines; discharges(count1).y =  ylines;
    count1 = count1+1;
end

% Distribute water over discharges
count1 = 1;
for ii = id
    Qtotal = Qq(ii,:) * distances(ii);          % m3/s total from transect
    id = Qtotal < 0; Qtotal(id) = 0;            % only water IN LISFLOOD
    npoints = length(discharges(count1).x);     
    Qtotalpoint = Qtotal / npoints;             % distribute over # points
    discharges(count1).q = Qtotalpoint;       
    discharges(count1).t = tq;
    count1 = count1+1;
end
    
% Make files for FM
count = 1;
for ii = 1:length(discharges)
    for jj = 1:length(discharges(ii).x)
        fname = ['SourceSink', num2str(count)];

        
        %% Make .pli
        fname1 = [fname, '.pli'];
        fileID = fopen(fname1,'w');
        fprintf(fileID,fname);
        fprintf(fileID,'\n');
        fprintf(fileID,'  1   2');
        fprintf(fileID,'\n');
        fprintf(fileID,[num2str(discharges(ii).x(jj)), ' ', num2str(discharges(ii).y(jj))]);
        fprintf(fileID,'\n');
        fclose(fileID);   
        
        %% Make tim
        fname1 = [fname, '.tim'];
        fileID = fopen(fname1,'w');
        for xx = 1:length(discharges(ii).t)
            fprintf(fileID,num2str(discharges(ii).t(xx)/60));
            fprintf(fileID,' ');
            fprintf(fileID,num2str(discharges(ii).q(xx)));
            fprintf(fileID,' 0 0');
            fprintf(fileID,'\n');
        end
        fclose(fileID);        

        % next step
        count = count+1;
    end
end

%% Make ext
count = 1;
fileID = fopen('FlowFM2.ext','w');
for ii = 1:length(discharges)
    for jj = 1:length(discharges(ii).x)
            fname = ['SourceSink', num2str(count)];
            fprintf(fileID,'\n');
            fprintf(fileID,'QUANTITY=discharge_salinity_temperature_sorsin');
            fprintf(fileID,'\n');
            fprintf(fileID,'FILENAME=');
            fprintf(fileID,[fname, '.pli']);
            fprintf(fileID,'\n');
            fprintf(fileID,'FILETYPE=9');
            fprintf(fileID,'\n');
            fprintf(fileID,'METHOD=1');
            fprintf(fileID,'\n');
            fprintf(fileID,'OPERAND=O');
            fprintf(fileID,'\n');
            count = count+1;
    end
end
fclose(fileID);        
fclose('all');
succes = 1;

catch
    succes = 0;
end
