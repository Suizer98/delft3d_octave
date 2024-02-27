function cosmos_postFigures(hm,m)
% Post model output (kmz, png) to web server

model=hm.models(m);
cont=hm.models(m).continent;

locdir=[hm.webDir 'scenarios' filesep hm.scenario filesep model.continent filesep model.name filesep 'figures'];

% Uploading figures

dr='scenarios';

fid=fopen('scp.txt','wt');
fprintf(fid,'%s\n','option batch on');
fprintf(fid,'%s\n','option confirm off');
fprintf(fid,'%s\n','option echo on');
fprintf(fid,'%s\n',hm.scp.open);
fprintf(fid,'%s\n',['cd ' dr]);
fprintf(fid,'%s\n',['mkdir ' hm.scenario]);
fprintf(fid,'%s\n',['cd ' hm.scenario]);
fprintf(fid,'%s\n',['mkdir ' cont]);
fprintf(fid,'%s\n',['cd ' cont]);
fprintf(fid,'%s\n',['mkdir ' hm.models(m).name]);
fprintf(fid,'%s\n',['cd ' hm.models(m).name]);
fprintf(fid,'%s\n','mkdir figures');
fprintf(fid,'%s\n','cd figures');
fprintf(fid,'%s\n','rm *.png');
fprintf(fid,'%s\n','rm *.kmz');
fprintf(fid,'%s\n','rm *.html');
fprintf(fid,'%s\n','rm *.xml');
fprintf(fid,'%s\n',['put ' locdir filesep '*.*']);
fprintf(fid,'%s\n','close');
fprintf(fid,'%s\n','exit');
fclose(fid);
system([hm.exeDir 'winscp.exe /console /script=scp.txt']);
delete('scp.txt');
