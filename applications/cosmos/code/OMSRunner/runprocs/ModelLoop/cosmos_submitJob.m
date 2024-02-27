function cosmos_submitJob(hm,m)

model=hm.models(m);

switch model.runEnv

    case{'win32'}

        % No more daemon
        
%         f=dir([hm.jobDir filesep 'action.*']);
% 
%         nrmax=0;
%         if ~isempty(f)
%             n=length(f);
%             for i=1:n
%                 nr=str2double(f(i).name(8:end));
%                 nrmax=max(nr,nrmax);
%             end
%         end
% 
%         nrmax=nrmax+1;
% 
%         fname =[hm.jobDir 'action.' num2str(nrmax,'%0.4i')];
% 
%         %inpdir=[hm.jobDir model.name filesep];
%         inpdir=[hm.jobDir model.name];
% 
%         fid=fopen(fname,'wt');
% 
%         cycstr=datestr(hm.cycle,'yyyymmddHHMMSS');
%         % TODO: What does this do?
%         % Copy the inpdir (job+model) directory to the current directory
%         fprintf(fid,'%s\n',['xcopy /E /I ' inpdir ' ' model.name]);
%         % remove the job/model directory
%         fprintf(fid,'%s\n',['rmdir /Q /S ' inpdir]);
%         % add the date to a file
%         fprintf(fid,'%s\n',['realdate /f="CCYYMMDD hhmmss" >> ' hm.jobDir 'running.' cycstr '.' model.name]);
%         % go into the model directory
%         fprintf(fid,'%s\n',['cd ' model.name]);
%         % start the run
%         fprintf(fid,'%s\n','call run.bat');
%         % ping yourself? Maybe some alternative for sleeping?
%         fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
%         fprintf(fid,'%s\n','cd ..');
%         % and ping again but 3 times?
%         fprintf(fid,'%s\n','ping localhost -n 3 -w 1000 > nul');
%         % copy the model directory back to its original place
%         fprintf(fid,'%s\n',['xcopy /E /I ' model.name ' ' inpdir]);
%         fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
%         % throw away the directory where the model was run
%         fprintf(fid,'%s\n',['rmdir /Q /S ' model.name]);
%         fprintf(fid,'%s\n','ping localhost -n 1 -w 1000 > nul');
%         % echo a "."?
%         fprintf(fid,'%s\n',['echo. >>  ' hm.jobDir 'running.' cycstr '.' model.name]);
%         % add the date again? Finish time?
%         fprintf(fid,'%s\n',['realdate /f="CCYYMMDD hhmmss" >> ' hm.jobDir 'running.' cycstr '.' model.name]);
%         % echo a dot again?
%         fprintf(fid,'%s\n',['echo. >>  ' hm.jobDir 'running.' cycstr '.' model.name]);
%         % move the file which was called running to finished. This is what the
%         % runner will check for
%         fprintf(fid,'%s\n',['move ' hm.jobDir 'running.' cycstr '.' model.name ' ' hm.jobDir 'finished.' cycstr '.' model.name]);
% 
%         fclose(fid);

        fid=fopen('tmp.bat','wt');
        fprintf(fid,'%s\n',['cd ' hm.jobDir model.name]);        
        fprintf(fid,'%s\n','call run.bat');        
        fclose(fid);
        pause(0.1);
        system('start tmp.bat');
        pause(1);
        delete('tmp.bat');

    case{'h4','h4i7'}
        
        % H4 cluster
        
        if ~isempty(hm.clusterNode)
            clusterstr=[' -q ' hm.clusterNode];
        else
            clusterstr=' -q normal-i7';
        end
        
        fid=fopen('run_h4.sh','wt');
        
        fprintf(fid,'%s\n','#!/bin/sh');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n',['cd ' hm.h4.path model.name]);
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','. /opt/sge/InitSGE');
        fprintf(fid,'%s\n','. /opt/intel/fc/10/bin/ifortvars.sh');
        fprintf(fid,'%s\n','');
        switch lower(model.type)
            case{'xbeachcluster'}
                nprfperjob=hm.nrProfilesPerJob;
                njobs=ceil(model.nrProfiles/nprfperjob);
                for j=1:njobs
                    fprintf(fid,'%s\n',['dos2unix run' num2str(j) '.sh']);
                    fprintf(fid,'%s\n',['qsub -V -N ' model.runid '_' num2str(j) clusterstr ' run' num2str(j) '.sh']);
                end
            otherwise
                fprintf(fid,'%s\n','dos2unix run.sh');
                fprintf(fid,'%s\n',['qsub -V -N ' model.name clusterstr ' run.sh']);
        end
        fprintf(fid,'%s\n','qstat -u $USER ');
        fprintf(fid,'%s\n','');
        fprintf(fid,'%s\n','exit');

        fclose(fid);    
        
        system([hm.exeDir 'dos2unix run_h4.sh']);
        
        [success,message,messageid]=movefile('run_h4.sh','u:\','f');
        system([hm.exeDir 'plink ' hm.h4.userName '@h4 -pw ' hm.h4.password ' ~/run_h4.sh']);

end
