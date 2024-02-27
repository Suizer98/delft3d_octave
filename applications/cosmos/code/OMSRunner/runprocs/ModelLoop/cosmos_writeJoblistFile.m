function writeJoblistFile(hm,m,opt)

hm.models(m).processDuration=hm.models(m).extractDuration+hm.models(m).plotDuration+hm.models(m).uploadDuration;
fid=fopen([hm.scenarioDir  'joblist' filesep opt '.' datestr(hm.cycle,'yyyymmdd.HHMMSS') '.' hm.models(m).name],'wt');
fprintf(fid,'%s\n',datestr(hm.models(m).simStart,'yyyymmdd HHMMSS'));
fprintf(fid,'%s\n',datestr(hm.models(m).simStop,'yyyymmdd HHMMSS'));
fprintf(fid,'%s\n',['Run duration     : ' num2str(hm.models(m).runDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Move duration    : ' num2str(hm.models(m).moveDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Extract duration : ' num2str(hm.models(m).extractDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Plot duration    : ' num2str(hm.models(m).plotDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Upload duration  : ' num2str(hm.models(m).uploadDuration,'%8.2f') ' s']);
fprintf(fid,'%s\n',['Process duration : ' num2str(hm.models(m).processDuration,'%8.2f') ' s']);
fclose(fid);
