function writeWW3batchH4(fname,names,datstr,trst1,trst2)

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','#! /bin/sh');
fprintf(fid,'%s\n','. /opt/sge/InitSGE');
fprintf(fid,'%s\n','. /opt/intel/Compiler/11.0/081/bin/ifortvars.sh ia32');
fprintf(fid,'%s\n','. /opt/intel/Compiler/11.0/081/bin/ia32/idbvars.sh');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/opt/intel/fc/10/lib');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','export exedir=/u/ormondt/wavewatch3/exe/mpi');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','echo $exedir     >> screenfile');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','echo JobID is:        $DELTAQ_JobID    >> screenfile');
fprintf(fid,'%s\n','echo Running on:      $DELTAQ_NodeList >> screenfile');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','# ============ remove output files');
fprintf(fid,'%s\n','# ./run_delft3d_init.sh $runid');
fprintf(fid,'%s\n','# rm -f $argfile');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
fprintf(fid,'%s\n','');
%% Unzip restart file (if necessary)
if ~isempty(trst1)
    fprintf(fid,'%s\n',['unzip restart.ww3.' datestr(trst1,'yyyymmdd.HHMMSS') '.zip']);
    fprintf(fid,'%s\n',['mv restart.ww3.' datestr(trst1,'yyyymmdd.HHMMSS') ' restart.ww3']);    
end
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','$exedir/ww3_grid >> screenfile');
fprintf(fid,'%s\n','$exedir/ww3_prep >> screenfile');
fprintf(fid,'%s\n','$exedir/ww3_shel >> screenfile');
fprintf(fid,'%s\n','$exedir/gx_outf  >> screenfile');
%% 2D spectra
for i=1:length(names)
    fprintf(fid,'%s\n',['cp ww3_outp_' names{i} '.inp ww3_outp.inp']);    
    fprintf(fid,'%s\n','$exedir/ww3_outp >> screenfile');
    fprintf(fid,'%s\n',['mv ww3.' datstr '.spc ww3.' names{i} '.spc']);    
    if i==1
        fprintf(fid,'%s\n',['cp ww3_outp_' names{i} '_sp2.inp ww3_outp.inp']);    
        fprintf(fid,'%s\n','$exedir/ww3_outp >> screenfile');
        fprintf(fid,'%s\n',['mv ww3.' datstr '.spc ww3.' names{i} '.spc']);
    end
end
%% Zip restart file
if ~isempty(trst2)
    fprintf(fid,'%s\n',['mv restart1.ww3 restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS')]);    
    fprintf(fid,'%s\n',['zip restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS') '.zip restart.ww3.' datestr(trst2,'yyyymmdd.HHMMSS')]);    
end
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
fprintf(fid,'%s\n','');
fprintf(fid,'%s\n','mv running.txt finished.txt');
fclose(fid);
