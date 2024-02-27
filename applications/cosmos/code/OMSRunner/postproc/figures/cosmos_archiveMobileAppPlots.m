function cosmos_archiveMobileAppPlots(hm,m)

model=hm.models(m);
dr=model.dir;

dir1=[dr 'lastrun' filesep 'figures' filesep 'mobileapp' filesep '*.*'];
dir2=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep hm.cycStr filesep 'mobileapp'];
     
[status,message,messageid]=copyfile(dir1,dir2,'f');


