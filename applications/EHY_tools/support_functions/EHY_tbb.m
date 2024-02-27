function EHY_tbb(fileOut,runid,stations,Tide_cmp,Tide_obs)

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
cell_arr{1, 1} = 'Constituent';
cell_arr{1, 2} = 'Hc';
cell_arr{1, 3} = 'Ho';
cell_arr{1, 4} = 'Gc';
cell_arr{1, 5} = 'Go';
cell_arr{1, 6} = 'Hc - Ho';
cell_arr{1, 7} = 'Gc - Go';
cell_arr{1, 8} = 'Hc/Ho';
cell_arr{1, 9} = 'VD';

for i_stat = 1: no_stat
    Comments{2} = ['Station     : ' stations{i_stat}];
    for i_freq = 1: no_freq
        Hc = Tide_cmp(i_stat).tidecon(i_freq,1);
        Ho = Tide_obs(i_stat).tidecon(i_freq,1);
        Gc = Tide_cmp(i_stat).tidecon(i_freq,3);
        Go = Tide_obs(i_stat).tidecon(i_freq,3);
        if (Gc - Go) >  180  Gc = Gc - 360.; end
        if (Gc - Go) < -180  Gc = Gc + 360.; end
        VD =  sqrt( (Hc*cos(deg2rad * Gc) - Ho*cos(deg2rad * Go) )^2 + ...
                    (Hc*sin(deg2rad * Gc) - Ho*sin(deg2rad * Go) )^2 );
        cell_arr{i_freq + 1,1} = Tide_cmp(i_stat).name(i_freq,:);
        cell_arr{i_freq + 1,2} = Hc;
        cell_arr{i_freq + 1,3} = Ho;
        cell_arr{i_freq + 1,4} = Gc;
        cell_arr{i_freq + 1,5} = Go;
        cell_arr{i_freq + 1,6} = Hc - Ho;
        cell_arr{i_freq + 1,7} = Gc - Go;
        cell_arr{i_freq + 1,8} = Hc/Ho;
        cell_arr{i_freq + 1,9} = VD;
    end
    cell_arr{no_freq + 2,1} = 'Summarizing Statistics:';
    cell_arr{no_freq + 3,1} = 'Summed VD';
    
    cell_arr{no_freq + 3,9} = sum(cell2mat(cell_arr(2:no_freq + 1,9)));
        
    xlswrite_report(fileOut,cell_arr,stations{i_stat},'Comments',Comments, ...
                                                        'colwidth',colwidth, ...
                                                        'format'  ,format  );
end
  
    




