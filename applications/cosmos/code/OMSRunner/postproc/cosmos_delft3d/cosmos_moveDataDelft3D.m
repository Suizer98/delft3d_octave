function cosmos_moveDataDelft3D(hm,m)

model=hm.models(m);

rundir=[hm.jobDir model.name filesep];
inpdir=model.cycledirinput;
outdir=model.cyclediroutput;
restartdir=[model.dir 'restart' filesep];

delete([rundir '*.exe']);
delete([rundir 'finished.txt']);

%% Restart files

[status,message,messageid]=movefile([rundir 'tri-rst.rst'],inpdir,'f');

rstfiles=dir([rundir 'tri-rst.*']);

nrst=length(rstfiles);

if nrst>0
    for j=1:nrst
        % Only move tri-rst file of restartTime
        rstfil=rstfiles(j).name;
        dt=rstfil(end-14:end);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if abs(rsttime-model.restartTime)<0.01
            zip([restartdir 'tri-rst' filesep rstfil '.zip'],[rundir rstfil]);
            break
        end
    end
end
delete([rundir 'tri-rst*']);

% Throw away old restart files (3 days or older)
rstfiles=dir([restartdir 'tri-rst' filesep 'tri-rst.*.zip']);
nrst=length(rstfiles);
if nrst>0
    for j=1:nrst
        rstfil=rstfiles(j).name;
        dt=rstfil(end-18:end-4);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<model.restartTime-3 && model.deleterestartfiles
            delete([restartdir 'tri-rst' filesep rstfil]);
        end        
    end
end

hot0=[rundir 'hot_1_' datestr(model.tWaveStart,'yyyymmdd.HHMMSS')];

hot00=[rundir 'hot_1_00000000.000000'];
if exist(hot00,'file')
    movefile(hot00,hot0);
end

if exist(hot0,'file')
    [status,message,messageid]=movefile(hot0,inpdir,'f');
end

hotfiles=dir([rundir 'hot_1_*']);

nhot=length(hotfiles);

if nhot>0

    for j=1:nhot
        % Only move hot file of restartTime
        hotfil=hotfiles(j).name;
        dt=hotfil(7:end);
        hottime=datenum(dt,'yyyymmdd.HHMMSS');
        if abs(hottime-model.restartTime)<0.01
                    [status,message,messageid]=copyfile([rundir hotfil],[restartdir 'hot'],'f');
                    zip([restartdir 'hot' filesep hotfil '.zip'],[restartdir 'hot' filesep hotfil]);
                    delete([restartdir 'hot' filesep hotfil]);
            break;
        end
    end
end
delete([rundir 'hot*']);

% Throw away old hot files (3 days or older)
hotfiles=dir([restartdir 'hot' filesep 'hot*.zip']);
nhot=length(hotfiles);
if nhot>0
    for j=1:nhot
        hotfil=hotfiles(j).name;
        dt=hotfil(7:end-4);
        hottime=datenum(dt,'yyyymmdd.HHMMSS');
        if hottime<model.restartTime-3
            delete([restartdir 'hot' filesep hotfil]);
        end        
    end
end

%% Now move input and output files
[status,message,messageid]=movefile([rundir 'tri*'],outdir,'f');
[status,message,messageid]=movefile([rundir 'com-*.*'],outdir,'f');
[status,message,messageid]=movefile([rundir 'wavm-*.d*'],outdir,'f');
[status,message,messageid]=movefile([rundir 'fourier.*'],outdir,'f');

% %% PART
% [status,message,messageid]=movefile([rundir 'light_crude.csv'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'couplnef.out'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'his-' model.runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'map-' model.runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir 'plo-' model.runid '.d*'],outdir,'f');
% [status,message,messageid]=movefile([rundir model.runid '.out'],outdir,'f');

% delete([rundir model.runid '.his']);
% delete([rundir model.runid '.map']);
% delete([rundir model.runid '.plo']);

%% SWAN
delete([rundir '*.sp1']);

[status,message,messageid]=movefile([rundir model.name '.sp2'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.sp2'],outdir,'f');

delete([rundir 'swn-dia*']);

if exist([rundir 'WNDNOW'],'file')
    delete([rundir 'WNDNOW']);
end

[status,message,messageid]=movefile([rundir '*'],inpdir,'f');
