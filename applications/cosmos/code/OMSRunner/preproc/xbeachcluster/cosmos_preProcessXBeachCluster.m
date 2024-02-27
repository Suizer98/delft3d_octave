function cosmos_preProcessXBeachCluster(hm,m)

model=hm.models(m);

np=model.nrProfiles;

tmpdir=hm.tempDir;

% for i=1:np
%     if model.profile(i).run
%         [status,message,messageid]=copyfile([model.dir 'input' filesep model.profile(i).name],[tmpdir model.profile(i).name],'f');
%     end
% end

if model.waveNested
    ok=cosmos_nestingXBeachClusterWave(hm,m);
end

for i=1:model.nrProfiles
    if model.profile(i).run
        disp(['Generating params.txt cluster ' model.longName ' - profile ' model.profile(i).name]);
        cosmos_writeXBeachProfileParams(hm,m,i);
    end
end

if model.flowNested
    cosmos_nestingXBeachClusterFlow(hm,m);
end

%[status,message,messageid]=copyfile([hm.exeDir 'xbeach_noMPI.exe'],tmpdir,'f');

nprfperjob=hm.nrProfilesPerJob;

switch model.runEnv
    
    case{'win32'}

        [status,message,messageid]=copyfile([hm.exeDir 'xbeach_dano.exe'],tmpdir,'f');

        % Make run batch file
        fid=fopen([tmpdir 'run.bat'],'wt');
        
        for i=1:np
            if ok(i)
                id=model.profile(i).name;
                %        fprintf(fid,'%s\n',['copy xbeach_noMPI.exe ' id]);
                fprintf(fid,'%s\n',['copy xbeach_dano.exe ' id]);
                fprintf(fid,'%s\n',['cd ' id]);
                %        fprintf(fid,'%s\n','xbeach_noMPI.exe');
                fprintf(fid,'%s\n','xbeach_dano.exe');
                fprintf(fid,'%s\n','del *.exe');
                fprintf(fid,'%s\n','del E_*.sp2');
                fprintf(fid,'%s\n','del q_*.sp2');
                fprintf(fid,'%s\n','cd ..');
            end
        end
        
        fclose(fid);
        
    case{'h4','h4i7'}

        % Determine number of jobs that need to be submitted
        njobs=ceil(np/nprfperjob);


        for j=1:njobs

            fid=fopen([tmpdir 'run' num2str(j) '.sh'],'wt');

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
            fprintf(fid,'%s\n','#$ -pe distrib 1');
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
%            fprintf(fid,'%s\n','StageIn');
%            fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
            fprintf(fid,'%s\n',['date -u ''+%Y%m%d %H%M%S'' >> running' num2str(j) '.txt']);
            for i=(j-1)*nprfperjob+1:min(j*nprfperjob,np)
                if ok(i)
                    id=model.profile(i).name;
                    fprintf(fid,'%s\n',['cd ' id]);
                    fprintf(fid,'%s\n','unzip sp2.zip');
                    fprintf(fid,'%s\n','$xbeach_bin_dir/xbeach >> output_xbeach 2>&1');
                    fprintf(fid,'%s\n','rm q_*.sp2');
                    fprintf(fid,'%s\n','rm E_*.sp2');
                    fprintf(fid,'%s\n','rm *.sp2');
                    fprintf(fid,'%s\n','cd ..');
                end
            end
            fprintf(fid,'%s\n','');
            fprintf(fid,'%s\n',['date -u ''+%Y%m%d %H%M%S'' >> running' num2str(j) '.txt']);
%            fprintf(fid,'%s\n','StageOut');
            fprintf(fid,'%s\n','');
%            fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
            fprintf(fid,'%s\n','');
            fprintf(fid,'%s\n',['mv running' num2str(j) '.txt finished' num2str(j) '.txt']);
            fprintf(fid,'%s\n','');
            fprintf(fid,'%s\n','### General for MPICH2, finish your MPICH2 communication network.');
            fprintf(fid,'%s\n','### mpdallexit');

            fclose(fid);

        end
end
