function run_runs(dirs_run,nproc,filename,name)
% Simple function to run executables 
for ii = 1:length(dirs_run)
    
    % Show progress
    disp([num2str(ii) ' of ' num2str(length(dirs_run))]);
    p1      = System.Diagnostics.Process.GetProcessesByName(name);
    runs    = double(max(p1.Length, 0));
    
    % If more than defined, than wait
    while runs >= nproc
        disp('  waiting for other runs to finish');
        pause(10);
        p1      = System.Diagnostics.Process.GetProcessesByName(name);
        runs    = double(max(p1.Length, 0));
    end
    
    % Launch and continue
    TMP     = dirs_run{ii}; cd(TMP);
    runTMP  = ['\', filename, ' & ' ];
    [x,y]   = system([TMP runTMP]);
end

% No more runs to launch, but we are still not done!
p1      = System.Diagnostics.Process.GetProcessesByName(name);
runs    = double(max(p1.Length, 0));
while runs > 0
    disp('  waiting for last runs to finish');
    pause(10);
    p1      = System.Diagnostics.Process.GetProcessesByName(name);
    runs    = double(max(p1.Length, 0));
end



