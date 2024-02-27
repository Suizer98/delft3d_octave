function cosmos_moveDataWW3(hm,m)

model=hm.models(m);

rundir=[hm.jobDir model.name filesep];
inpdir=model.cycledirinput;
outdir=model.cyclediroutput;
restartdir=[model.dir 'restart' filesep];

% Rename nest files
n=0;
for ii=1:hm.nrModels
    if hm.models(ii).waveNested && strcmpi(hm.models(ii).type,'ww3') && strcmpi(hm.models(ii).waveNestModel,model.name)
        n=n+1;
        fname1=['nest' num2str(n) '.ww3'];
        fname2=['nest.' hm.models(ii).name '.ww3'];
        if exist([rundir fname1],'file')
            movefile([rundir fname1],[rundir fname2]);
        end
    end
end

% Move model inputs
[status,message,messageid]=movefile([rundir '*.inp'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bat'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.sh'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.obs'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.bot'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'wind.ww3'],inpdir,'f');
if exist([rundir 'nest.ww3'],'file')
    [status,message,messageid]=movefile([rundir 'nest.ww3'],inpdir,'f');
end

% Don't copy restart file
% [status,message,messageid]=movefile([rundir 'restart.ww3'],inpdir,'f');

% First check if the restart file exists in the run directory
flist=dir([rundir 'restart.*.zip']);
for ii=1:length(flist)
    fname=flist(ii).name;
    [status,message,messageid]=movefile([rundir fname],restartdir,'f');
end

% Throw away old restart files (10 days or older)
rstfiles=dir([restartdir 'restart.*.zip']);
nrst=length(rstfiles);
if nrst>0
    for j=1:nrst
        rstfil=rstfiles(j).name;
        dt=rstfil(13:end-4);
        rsttime=datenum(dt,'yyyymmdd.HHMMSS');
        if rsttime<model.restartTime-10
            delete([restartdir rstfil]);
        end        
    end
end

[status,message,messageid]=copyfile([rundir 'mod_def.ww3'],inpdir,'f');

delete([rundir 'restart*']);
delete([rundir 'out_grd.ww3']);

[status,message,messageid]=movefile([rundir '*.ww3'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.spc'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.ctl'],outdir,'f');
[status,message,messageid]=movefile([rundir '*.grads'],outdir,'f');
[status,message,messageid]=movefile([rundir 'screenfile'],outdir,'f');
