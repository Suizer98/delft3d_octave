function AdjustInputXBeach(hm,m)

tmpdir=hm.tempDir;

parfile=[tmpdir 'params.txt'];

findreplace(parfile,'TSTOPKEY',num2str(hm.models(m).runTime*60));
findreplace(parfile,'MORFACKEY',num2str(hm.models(m).morFac));
findreplace(parfile,'DEPKEY',[hm.models(m).name '.dep']);

findreplace(parfile,'REFDATEKEY',datestr(hm.cycle,'yyyymmdd'));
findreplace(parfile,'REFTIMEKEY',datestr(hm.cycle,'HHMMSS'));
