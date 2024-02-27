function writeDIOConfig(dr)

fid=fopen([dr filesep 'dioconfig.ini'],'wt');

fprintf(fid,'%s\n','[Settings]');
fprintf(fid,'%s\n','#Delay=100');
fprintf(fid,'%s\n','#SleepTime=20');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','[Defaults]');
fprintf(fid,'%s\n','#StreamType=ASCII');
fprintf(fid,'%s\n','StreamType=SharedMem');
fprintf(fid,'%s\n','OnLine=True');
fprintf(fid,'%s\n','Active=True');
fprintf(fid,'%s\n','# timeOut in communication DD;UU;MM;SS.S/100');
fprintf(fid,'%s\n','TimeOut=00;01:00:00.00');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','NumberOfDatasets=2');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','[Dataset1]');
fprintf(fid,'%s\n','Name=FLOW2WAVE_DATA');
fprintf(fid,'%s\n','StreamType=ASCII');
fprintf(fid,'%s\n','OnLine=True');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','[Dataset2]');
fprintf(fid,'%s\n','Name=WAVE2FLOW_DATA');
fprintf(fid,'%s\n','StreamType=ASCII');
fprintf(fid,'%s\n','OnLine=True');

fclose(fid);
