function EHY_tba(fileOut,runid,stations,Tide_cmp,Tide_obs)

% Write triana tba file however as xls
if exist(fileOut,'file') delete(fileOut); end

%% General parameters
deg2rad  = pi()/180;
no_stat  = length(Tide_cmp);
no_freq  = length(Tide_cmp(1).name);
colwidth = [30  repmat(10,1,8)];
format   = {'0.000' '0.000' '0.0' '0.0' '0.000' '0.0' '0.000' '0.000'};

%% General comments
Comments{1} = ['Simulation      : ' runid];
Comments{4} = ['Analysis Period from ' datestr(Tide_cmp(1).period(1)) ' until ' datestr(Tide_cmp(1).period(2))];
Comments{6} = 'Hc = Computed Amplitude (m)  Ho = Observed Amplitude (m)';
Comments{7} = 'Gc = Computed phase      (deg)  Gc = Observed phase      (deg)';
Comments{8} = 'VD = Vector difference      (m)';

%% Column names
cell_arr{1, 1} = 'Station';
cell_arr{1, 2} = 'Hc';
cell_arr{1, 3} = 'Ho';
cell_arr{1, 4} = 'Gc';
cell_arr{1, 5} = 'Go';
cell_arr{1, 6} = 'Hc - Ho';
cell_arr{1, 7} = 'Gc - Go';
cell_arr{1, 8} = 'Hc/Ho';
cell_arr{1, 9} = 'VD';

for i_freq = 1: no_freq
    Comments{2} = ['Constituent     : ' Tide_cmp(1).name(i_freq,:)];
    for i_stat = 1: no_stat
        Hc = Tide_cmp(i_stat).tidecon(i_freq,1);
        Ho = Tide_obs(i_stat).tidecon(i_freq,1);
        Gc = Tide_cmp(i_stat).tidecon(i_freq,3);
        Go = Tide_obs(i_stat).tidecon(i_freq,3);
        if (Gc - Go) >  180  Gc = Gc - 360.; end
        if (Gc - Go) < -180  Gc = Gc + 360.; end
        VD =  sqrt( (Hc*cos(deg2rad * Gc) - Ho*cos(deg2rad * Go) )^2 + ...
                    (Hc*sin(deg2rad * Gc) - Ho*sin(deg2rad * Go) )^2 );
        cell_arr{i_stat + 1,1} = stations{i_stat};
        cell_arr{i_stat + 1,2} = Hc;
        cell_arr{i_stat + 1,3} = Ho;
        cell_arr{i_stat + 1,4} = Gc;
        cell_arr{i_stat + 1,5} = Go;
        cell_arr{i_stat + 1,6} = Hc - Ho;
        cell_arr{i_stat + 1,7} = Gc - Go;
        cell_arr{i_stat + 1,8} = Hc/Ho;
        cell_arr{i_stat + 1,9} = VD;
    end
    cell_arr{no_stat + 2,1} = 'Summarizing Statistics:';
    cell_arr{no_stat + 3,1} = 'Mean Error';
    cell_arr{no_stat + 4,1} = 'Mean Absolute Error';
    cell_arr{no_stat + 5,1} = 'RMS Error';
    for i_col = 6: 9
        values = cell2mat(cell_arr(2:no_stat + 1,i_col));
        index  = ~isnan(values);
        cell_arr{no_stat + 3,i_col} = mean(values(index));
    end
    
    for i_col = 6: 7
        values = cell2mat(cell_arr(2:no_stat + 1,i_col));
        index  = ~isnan(values);
        cell_arr{no_stat + 4,i_col} = mean(abs(values(index)));
    end
    
    for i_col = 6: 9
        values  = cell2mat(cell_arr(2:no_stat + 1,i_col));
        index   = ~isnan(values);
        no_values = length(values(index));
        cell_arr{no_stat + 5,i_col} = norm(values(index))/sqrt(no_values);
    end
    
    fileOut=strrep(fileOut,[filesep filesep],[filesep]);
    xlswrite_report(fileOut,cell_arr,Tide_cmp(1).name(i_freq,:),'Comments',Comments,...
                                                                  'colwidth',colwidth,...
                                                                  'format'  ,format  );
end
  
    




