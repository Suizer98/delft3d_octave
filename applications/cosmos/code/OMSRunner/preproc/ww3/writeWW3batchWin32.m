function writeWW3batchWin32(fname,names,datstr,trst1,trst2,exedir,mpidir,zipdr)

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','DATE /T > running.txt');

%% Unzip restart file (if necessary)
if ~isempty(trst1)
    fprintf(fid,'%s\n',['"' zipdr 'unzip" restart.ww3.' datestr(trst1,'yyyymmdd.HHMMSS') '.zip']);
    fprintf(fid,'%s\n',['move restart.ww3.' datestr(trst1,'yyyymmdd.HHMMSS') ' restart.ww3']);    
end

fprintf(fid,'%s\n',['"' exedir '\ww3_grid.exe"']);
fprintf(fid,'%s\n',['"' exedir '\ww3_prep.exe"']);

if isempty(mpidir)
    fprintf(fid,'%s\n',['"' exedir '\ww3_shel.exe"']);
else
    fprintf(fid,'%s\n',['"' mpidir '\mpiexec" -n %NUMBER_OF_PROCESSORS%  -localonly "' exedir '\ww3_shel.exe"']);
end
fprintf(fid,'%s\n',['"' exedir '\gx_outf.exe"']);

%% 2D spectra
for i=1:length(names)
    fprintf(fid,'%s\n',['copy ww3_outp_' names{i} '.inp ww3_outp.inp']);    
    fprintf(fid,'%s\n',['"' exedir '\ww3_outp.exe"']);
    fprintf(fid,'%s\n',['move ww3.' datstr '.spc ww3.' names{i} '.spc']);    
    if i==1
        fprintf(fid,'%s\n',['copy ww3_outp_' names{i} '_sp2.inp ww3_outp.inp']);    
        fprintf(fid,'%s\n',['"' exedir '\ww3_outp >> screenfile']);
        fprintf(fid,'%s\n',['move ww3.' datstr '.spc ww3.' names{i} '.spc']);
    end
end

%% Zip restart file
if ~isempty(trst2)
    fprintf(fid,'%s\n',['move restart1.ww3 restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS')]);    
    fprintf(fid,'%s\n',['"' zipdr 'zip" restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS') '.zip restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS')]);    
end

fprintf(fid,'%s\n','move running.txt finished.txt');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','exit');

fclose(fid);
