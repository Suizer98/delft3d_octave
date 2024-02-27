function cosmos_nestingXBeachClusterFlow(hm,m)

model=hm.models(m);
mm=model.flowNestModelNr;

dr=hm.models(mm).dir;

outputdir=[dr 'archive' filesep 'output' filesep hm.cycStr filesep];

[status,message,messageid]=copyfile([outputdir 'trih-*'],pwd,'f');

np=model.nrProfiles;

zcor=hm.models(mm).zLevel-model.zLevel;

for i=1:np
    
    if model.profile(i).run
        
        id=model.profile(i).name;
        
        tmpdir=hm.tempDir;
        
        try
                    
            fid=fopen('xb.bnd','wt');
            fprintf(fid,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
            fclose(fid);
            
            [status,message,messageid]=copyfile([model.datafolder 'nesting' filesep id filesep model.name '.nst'],[pwd filesep 'xb.nst'],'f');
            
            fid=fopen('nesthd2.inp','wt');
            
            fprintf(fid,'%s\n','xb.bnd');
            fprintf(fid,'%s\n','xb.nst');
            fprintf(fid,'%s\n',hm.models(mm).runid);
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n','dummy.bcc');
            fprintf(fid,'%s\n','nest.dia');
            fprintf(fid,'%s\n',num2str(zcor));
            fclose(fid);
            
            system([hm.exeDir 'nesthd2.exe < nesthd2.inp']);
            fid=fopen('smoothbct.inp','wt');
            fprintf(fid,'%s\n','temp.bct');
            fprintf(fid,'%s\n',[model.name '.bct']);
            fprintf(fid,'%s\n','3');
            
            fclose(fid);
            
            system([hm.exeDir 'smoothbct.exe < smoothbct.inp']);
            
            delete('nesthd2.inp');
            delete('nest.dia');
            delete('smoothbct.inp');
            
            delete('temp.bct');
            delete('dummy.bcc');
            
            delete('xb.bnd');
            delete('xb.nst');
            
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of XBeach in Delft3D-FLOW - ' model.name ' profile ' model.profile(i).name]);
        end
        
        %     cd(curdir);
        
        ConvertBct2XBeach([model.name '.bct'],[tmpdir id filesep 'tide.txt'],model.tFlowStart);
        delete([model.name '.bct']);
    end
end

delete('trih-*');
