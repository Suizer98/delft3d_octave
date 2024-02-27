function cosmos_moveDataXBeachCluster(hm,m)

model=hm.models(m);

rundir=[hm.jobDir model.name filesep];

delete([rundir '*.exe']);
if exist([rundir 'run.bat'],'file')
    delete([rundir 'run.bat']);
end

lst=dir(rundir);
for i=1:length(lst)
    if isdir([rundir lst(i).name])
        switch lst(i).name
            case{'.','..'}
            otherwise
                
                inpdir=[model.cycledirinput lst(i).name filesep];
                outdir=[model.cyclediroutput lst(i).name filesep];
                
                makedir(inpdir);
                makedir(outdir);

                [status,message,messageid]=movefile([rundir lst(i).name filesep model.runid '*.sp2'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.zip'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.txt'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.dep'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*.grd'],inpdir,'f');
                [status,message,messageid]=movefile([rundir lst(i).name filesep '*'],outdir,'f');

        end
    end
end
