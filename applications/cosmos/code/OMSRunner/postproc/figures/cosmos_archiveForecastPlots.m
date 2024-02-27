function cosmos_archiveForecastPlots(hm,m)

model=hm.models(m);
dr=model.dir;
% outdir=[dr 'lastrun' filesep 'output' filesep model.forecastplot.name filesep];
% archdir = model.archiveDir;
% 
% dout=[archdir hm.cycStr filesep 'forecasts' filesep];

dir1=[dr 'lastrun' filesep 'figures' filesep 'forecast' filesep '*.*'];
dir2=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep hm.cycStr filesep 'forecasts'];
     
[status,message,messageid]=copyfile(dir1,dir2,'f');


