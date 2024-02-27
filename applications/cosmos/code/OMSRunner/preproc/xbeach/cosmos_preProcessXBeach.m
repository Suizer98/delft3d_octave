function cosmos_preProcessXBeach(hm,m)

tmpdir=hm.tempDir;

%AdjustInputXBeach(hm,m);
%MakeXBeachParamsFile(hm,m);
cosmos_writeXBeachParams(hm,m);

if hm.models(m).flowNested
    cosmos_nestingXBeachFlow(hm,m);
end

if hm.models(m).waveNested
    cosmos_nestingXBeachWave(hm,m);
end

model=hm.models(m);

switch model.runEnv
    
    case{'win32'}
        
        % Make run batch file
        fid=fopen([tmpdir 'run.bat'],'wt');
        fprintf(fid,'%s\n','@ echo off');
        fprintf(fid,'%s\n','DATE /T > running.txt');
        fprintf(fid,'%s\n',[hm.xbeach_home filesep 'xbeach.exe']);
        fprintf(fid,'%s\n','del *.exe');
        fprintf(fid,'%s\n','del E_*.sp2');
        fprintf(fid,'%s\n','del q_*.sp2');
        fprintf(fid,'%s\n','move running.txt finished.txt');                
        fprintf(fid,'%s\n','exit');
        fclose(fid);
        
    case{'h4'}
        
        [success,message,messageid]=copyfile([hm.exeDir 'xbeach'],tmpdir,'f');
        
        %         fid=fopen([tmpdir 'run.sh'],'wt');
        %         fprintf(fid,'%s\n','### ********************************************************************');
        %         fprintf(fid,'%s\n','### ********************************************************************');
        %         fprintf(fid,'%s\n','### **                                                                **');
        %         fprintf(fid,'%s\n','### **  Example shell script to run XBeach executable in parallel     **');
        %         fprintf(fid,'%s\n','### **  with MPICH2 via SGE on linux cluster.                         **');
        %         fprintf(fid,'%s\n','### **  c 2009 Deltares                                               **');
        %         fprintf(fid,'%s\n','### **  author: Menno Genseberger                                     **');
        %         fprintf(fid,'%s\n','### **                                                                **');
        %         fprintf(fid,'%s\n','### ********************************************************************');
        %         fprintf(fid,'%s\n','### ********************************************************************');
        %         fprintf(fid,'%s\n','### The next line species the shell "/bin/sh" to be used for the execute');
        %         fprintf(fid,'%s\n','### of this script.');
        %         fprintf(fid,'%s\n','#!/bin/bash');
        %         fprintf(fid,'%s\n','### The "-cwd" requests execution of this script from the current');
        %         fprintf(fid,'%s\n','### working directory; without this, the job would be started from the');
        %         fprintf(fid,'%s\n','### user''s home directory.');
        %         fprintf(fid,'%s\n','#$ -cwd');
        %         fprintf(fid,'%s\n','### The name of this SGE job is explicitly set to another name;');
        %         fprintf(fid,'%s\n','### otherwise the name of the SGE script itself would be used. The name');
        %         fprintf(fid,'%s\n','### of the job also determines how the jobs output files will be called. ');
        %         fprintf(fid,'%s\n',['#$ -N ' hm.models(m).name]);
        %         fprintf(fid,'%s\n','### The next phrase asks for a "parallel environment" called "distrib",');
        %         fprintf(fid,'%s\n','### to be run with 4 slots (for instance 4 cores).');
        %         fprintf(fid,'%s\n','### "distrib" is a specific name for H3/H4 linux clusters (this name is');
        %         fprintf(fid,'%s\n','### for instance "mpi" on DAS-2/DAS-3 linux clusters).');
        % %        fprintf(fid,'%s\n',['#$ -pe distrib ' hm.models(m).numCores]);
        %         fprintf(fid,'%s\n',['#$ -pe distrib 2']);
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### Start SGE.');
        %         fprintf(fid,'%s\n','. /opt/sge/InitSGE');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### Code compiled with Intel 11.0 compiler.');
        %         fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/opt/intel/Compiler/11.0/081/lib/ia32');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### Specific setting for H3/H4 linuxclusters, needed for MPICH2');
        %         fprintf(fid,'%s\n','### commands (mpdboot, mpirun, mpiexed, mpdallexit etc.).');
        %         fprintf(fid,'%s\n','export PATH="/opt/mpich2/bin:${PATH}"');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### Set two_cores_per_node to "yes" if you want to use two cores per x-node.');
        %         fprintf(fid,'%s\n','two_cores_per_node=yes');
        %         fprintf(fid,'%s\n','if [ "$two_cores_per_node" == "yes" ]; then');
        %         fprintf(fid,'%s\n','    export NSLOTS=`expr $NSLOTS \* 2`');
        %         fprintf(fid,'%s\n','fi');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### Some general information available via SGE. Note that NHOSTS can be');
        %         fprintf(fid,'%s\n','echo ----------------------------------------------------------------------');
        %         fprintf(fid,'%s\n','echo Parallel run of XBeach with MPICH2 on H4 linuxcluster.');
        %         fprintf(fid,'%s\n','echo SGE_O_WORKDIR: $SGE_O_WORKDIR');
        %         fprintf(fid,'%s\n','echo HOSTNAME     : $HOSTNAME');
        %         fprintf(fid,'%s\n','echo NHOSTS       : $NHOSTS');
        %         fprintf(fid,'%s\n','echo NQUEUES      : $NQUEUES');
        %         fprintf(fid,'%s\n','echo NSLOTS       : $NSLOTS');
        %         fprintf(fid,'%s\n','echo PE_HOSTFILE  : $PE_HOSTFILE');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### General for MPICH2, create needed machinefile for mpdboot and');
        %         fprintf(fid,'%s\n','### mpdexec from $PE_HOSTFILE. The first column contains the node');
        %         fprintf(fid,'%s\n','### identifier, the second column the number of processes to be started');
        %         fprintf(fid,'%s\n','### on this node.');
        %         fprintf(fid,'%s\n','if [ "$two_cores_per_node" == "yes" ]; then');
        %         fprintf(fid,'%s\n','    awk ''{print $1":"1}'' $PE_HOSTFILE > $(pwd)/machinefile');
        %         fprintf(fid,'%s\n','awk ''{print $1":"1}'' $PE_HOSTFILE >> $(pwd)/machinefile');
        %         fprintf(fid,'%s\n','else');
        %         fprintf(fid,'%s\n','    awk ''{print $1":"$2}'' $PE_HOSTFILE > $(pwd)/machinefile');
        %         fprintf(fid,'%s\n','fi');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','echo Contents of machinefile:');
        %         fprintf(fid,'%s\n','cat $(pwd)/machinefile');
        %         fprintf(fid,'%s\n','echo ----------------------------------------------------------------------');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### General for MPICH2, startup your MPICH2 communication network (you');
        %         fprintf(fid,'%s\n','### can check if it is already there with mpdtrace).');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','mpdboot -n $NHOSTS --rsh=/usr/bin/rsh -f $(pwd)/machinefile');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### General, start XBeach in parallel by means of mpirun.');
        %         fprintf(fid,'%s\n','mpirun -np $NSLOTS $(pwd)/xbeach >> output_xbeach_mpi 2>&1');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','### General for MPICH2, finish your MPICH2 communication network.');
        %         fprintf(fid,'%s\n','mpdallexit');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
        %         fprintf(fid,'%s\n','');
        %         fprintf(fid,'%s\n','rm *.sp2');
        %         fprintf(fid,'%s\n','mv running.txt finished.txt');
        %         fclose(fid);
        
        fid=fopen([tmpdir 'run.sh'],'wt');
        
        fprintf(fid,'%s\n','#!/bin/sh');
        fprintf(fid,'%s\n','### ********************************************************************');
        fprintf(fid,'%s\n','### ********************************************************************');
        fprintf(fid,'%s\n','### **                                                                **');
        fprintf(fid,'%s\n','### **  Example shell script to run XBeach executable in parallel     **');
        fprintf(fid,'%s\n','### **  with MPICH2 via SGE on linux cluster.                         **');
        fprintf(fid,'%s\n','### **  c 2009 Deltares                                               **');
        fprintf(fid,'%s\n','### **  author: Menno Genseberger                                     **');
        fprintf(fid,'%s\n','### **                                                                **');
        fprintf(fid,'%s\n','### ********************************************************************');
        fprintf(fid,'%s\n','### ********************************************************************');
        fprintf(fid,'%s\n','### The next line species the shell "/bin/sh" to be used for the execute');
        fprintf(fid,'%s\n','### of this script.');
        fprintf(fid,'%s\n','### The "-cwd" requests execution of this script from the current');
        fprintf(fid,'%s\n','### working directory; without this, the job would be started from the');
        fprintf(fid,'%s\n','### users home directory.');
        fprintf(fid,'%s\n','#$ -cwd');
        fprintf(fid,'%s\n','### The name of this SGE job is explicitly set to another name;');
        fprintf(fid,'%s\n','### otherwise the name of the SGE script itself would be used. The name');
        fprintf(fid,'%s\n','### of the job also determines how the jobs output files will be called. ');
        fprintf(fid,'%s\n',['#$ -N ' model.name]);
        fprintf(fid,'%s\n','### The next phrase asks for a "parallel environment" called "distrib",');
        fprintf(fid,'%s\n','### to be run with 4 slots (for instance 4 cores).');
        fprintf(fid,'%s\n','### "distrib" is a specific name for H3/H4 linux clusters (this name is');
        fprintf(fid,'%s\n','### for instance "mpi" on DAS-2/DAS-3 linux clusters).');
        fprintf(fid,'%s\n','#$ -pe distrib 2');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### Start SGE.');
        fprintf(fid,'%s\n','. /opt/sge/InitSGE');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### Code compiled with Intel 11.0 compiler.');
        fprintf(fid,'%s\n','export LD_LIBRARY_PATH=/opt/intel/Compiler/11.0/081/lib/ia32');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### Specific setting for H3/H4 linuxclusters, needed for MPICH2');
        fprintf(fid,'%s\n','### commands (mpdboot, mpirun, mpiexed, mpdallexit etc.).');
        fprintf(fid,'%s\n','export PATH="/opt/mpich2/bin:${PATH}"');
        fprintf(fid,'%s\n','');
        %fprintf(fid,'%s\n','xbeach_bin_dir=/u/ormondt/checkouts/XBeach');
        fprintf(fid,'%s\n','xbeach_bin_dir=/u/ormondt/checkouts/xb_dano2');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### Set two_cores_per_node to "yes" if you want to use two cores per x-node.');
        fprintf(fid,'%s\n','two_cores_per_node=no');
        fprintf(fid,'%s\n','if [ "$two_cores_per_node" == "yes" ]; then');
        fprintf(fid,'%s\n','   export NSLOTS=`expr $NSLOTS \* 2`');
        fprintf(fid,'%s\n','fi');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### Some general information available via SGE. Note that NHOSTS can be');
        fprintf(fid,'%s\n','echo ----------------------------------------------------------------------');
        fprintf(fid,'%s\n','echo Parallel run of XBeach with MPICH2 on H4 linuxcluster.');
        fprintf(fid,'%s\n','echo SGE_O_WORKDIR: $SGE_O_WORKDIR');
        fprintf(fid,'%s\n','echo HOSTNAME     : $HOSTNAME');
        fprintf(fid,'%s\n','echo NHOSTS       : $NHOSTS');
        fprintf(fid,'%s\n','echo NQUEUES      : $NQUEUES');
        fprintf(fid,'%s\n','echo NSLOTS       : $NSLOTS');
        fprintf(fid,'%s\n','echo PE_HOSTFILE  : $PE_HOSTFILE');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### General for MPICH2, create needed machinefile for mpdboot and');
        fprintf(fid,'%s\n','### mpdexec from $PE_HOSTFILE. The first column contains the node');
        fprintf(fid,'%s\n','### identifier, the second column the number of processes to be started');
        fprintf(fid,'%s\n','### on this node.');
        fprintf(fid,'%s\n','if [ "$two_cores_per_node" == "yes" ]; then');
        fprintf(fid,'%s\n','   awk ''{print $1":"1}'' $PE_HOSTFILE > $(pwd)/machinefile');
        fprintf(fid,'%s\n','   awk ''{print $1":"1}'' $PE_HOSTFILE >> $(pwd)/machinefile');
        fprintf(fid,'%s\n','else');
        fprintf(fid,'%s\n','   awk ''{print $1":"$2}'' $PE_HOSTFILE > $(pwd)/machinefile');
        fprintf(fid,'%s\n','fi');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','echo Contents of machinefile:');
        fprintf(fid,'%s\n','cat $(pwd)/machinefile');
        fprintf(fid,'%s\n','echo ----------------------------------------------------------------------');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### General for MPICH2, startup your MPICH2 communication network (you');
        fprintf(fid,'%s\n','### can check if it is already there with mpdtrace).');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### mpdboot -n $NHOSTS -f $(pwd)/machinefile');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### General, start XBeach in parallel by means of mpirun.');
        fprintf(fid,'%s\n','');
%        fprintf(fid,'%s\n','StageIn');
%        fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
        fprintf(fid,'%s\n',['date -u ''+%Y%m%d %H%M%S'' >> running.txt']);
        %                fprintf(fid,'%s\n','unzip sp2.zip');
        fprintf(fid,'%s\n','$xbeach_bin_dir/xbeach >> output_xbeach 2>&1');
        fprintf(fid,'%s\n','rm q_*.sp2');
        fprintf(fid,'%s\n','rm E_*.sp2');
        fprintf(fid,'%s\n','rm *.sp2');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
%        fprintf(fid,'%s\n','StageOut');
        fprintf(fid,'%s\n','');
%        fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n',['mv running.txt finished.txt']);
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','### General for MPICH2, finish your MPICH2 communication network.');
        fprintf(fid,'%s\n','### mpdallexit');
        
        fclose(fid);
        
end

