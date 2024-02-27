function cosmos_moveDataXBeach(hm,m)

model=hm.models(m);

rundir=[hm.jobDir model.name filesep];
inpdir=model.cycledirinput;
outdir=model.cyclediroutput;

delete([rundir '*.exe']);
delete([rundir 'run.bat']);

[status,message,messageid]=movefile([rundir model.runid '*.sp2'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'params.txt'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'x.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'y.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'xbeach.tim'],inpdir,'f');
[status,message,messageid]=movefile([rundir 't.t'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.dep'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'RF_table.txt'],inpdir,'f');

delete([rundir '*.sp2']);

[status,message,messageid]=movefile([rundir '*'],outdir,'f');
