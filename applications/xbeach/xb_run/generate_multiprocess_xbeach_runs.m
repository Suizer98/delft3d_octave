function generate_multiprocess_xbeach_runs(xbeachExecutable,modeldirs,nProc,batchfilename)

imageName ='xbeach.exe';
startOptions = '/MIN';
pingTime = 5;

nrsims = length(modeldirs);
formatlength = ceil(log10(nrsims))+1;
formatstring = ['%0' num2str(formatlength) '.0f'];

fid = fopen(batchfilename,'wt');
fprintf(fid,'%s\n','ECHO OFF');
fprintf(fid,'%s\n','ECHO Do not close this window. This will stop all further simulations');
fprintf(fid,'%s\n',['set "coa = 0"']);
count = 0;
for i=1:nrsims
    count = count +1;
    randomID = char(round(rand(1,6)*26)+96);
    tempfile1 = [randomID '.tl1']; %tempname(modeldirs{i});
    tempfile2 = [randomID '.tl2']; %tempname(modeldirs{i});
    fprintf(fid,'%s\n',[':START' num2str(count,formatstring)]);
    fprintf(fid,'%s\n',['ping -n ' num2str(pingTime) ' localhost > NUL']);
    fprintf(fid,'%s\n',['tasklist /FI "IMAGENAME eq ' imageName '" > ' tempfile1]);
    fprintf(fid,'%s\n',['find /C /I "' imageName '" ' tempfile1 ' > ' tempfile2]);
    fprintf(fid,'%s\n',['for /F "tokens=2 delims=:" %%i in (' tempfile2 ') do set coa=%%i']);
    fprintf(fid,'%s\n',['IF %coa% GEQ ' num2str(nProc) ' GOTO START' num2str(count,formatstring)]);
    fprintf(fid,'%s\n',['del ' tempfile1]);
    fprintf(fid,'%s\n',['del ' tempfile2]);
    fprintf(fid,'%s\n',['cd ' modeldirs{i}]);
    fprintf(fid,'%s\n',['ECHO Running: ' modeldirs{i}]);
    fprintf(fid,'%s\n',['START ' startOptions ' ' xbeachExecutable]);
end
fprintf(fid,'%s\n',':FINISHED');
fprintf(fid,'%s\n','ping -n 10 localhost > NUL');
fprintf(fid,'%s\n','tasklist /FI "IMAGENAME eq xbeach.exe" > rtgrqd.tl1');
fprintf(fid,'%s\n','find /C /I "xbeach.exe" rtgrqd.tl1 > rtgrqd.tl2');
fprintf(fid,'%s\n','for /F "tokens=2 delims=:" %%i in (rtgrqd.tl2) do set coa=%%i');
fprintf(fid,'%s\n','IF %coa% GEQ 1 GOTO FINISHED');
fprintf(fid,'%s\n',['cd ' modeldirs{i}]);
fprintf(fid,'%s\n','cd ..');
fprintf(fid,'%s\n',':@echo The XBeach simulations have finished!> finished.txt');
fclose(fid);