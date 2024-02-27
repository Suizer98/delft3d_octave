function cosmos_nestingDelft3DFLOW(hm,m)

tmpdir=hm.tempDir;

model=hm.models(m);

switch lower(model.flowNestType)
    case{'oceanmodel'}

        % Nesting in ocean model
        datafolder=[hm.oceanmodelsfolder model.oceanModel filesep];
        dataname=model.oceanModel;
        wlbndfile=[model.name '.wl.bnd'];
        wlbcafile=[model.name '.wl.bca'];
        curbndfile=[model.name '.current.bnd'];
        curbcafile=[model.name '.current.bca'];
        wlconst=model.zLevel+model.wlboundarycorrection;
        cs.name=model.coordinateSystem;
        cs.type=model.coordinateSystemType;
        wloption=model.oceanmodelnesttypewl;
        curoption=model.oceanmodelnesttypecur;
        writeNestXML([tmpdir 'nest.xml'],tmpdir,model.runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst,cs,wloption,curoption);
        makeBctBccIni('bct','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',model.runid,'workdir',tmpdir,'cs',cs);
        makeBctBccIni('bcc','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',model.runid,'workdir',tmpdir,'cs',cs);
        delete([tmpdir 'nest.xml']);
        
    otherwise
        % Regular nesting

        mm=model.flowNestModelNr;
        dr=hm.models(mm).dir;       
        outputdir=[dr 'archive' filesep 'output' filesep hm.cycStr filesep];
        usematlabnesthd2=1;

        if usematlabnesthd2

            runid1=model.runid;
            runid2=hm.models(mm).runid;
            nstadm=[model.datafolder 'nesting' filesep model.name '.nst'];
            zcor=hm.models(mm).zLevel-model.zLevel+model.zSeaLevelRise;
            
            hisfile=[outputdir 'trih-' runid2 '.dat'];
            
            opt='hydro';
            if model.includeSalinity || model.includeTemperature || ~isempty(model.tracer)
                opt='both';
            end
            
            cs=model.coordinateSystemType;
            nesthd2('hisfile',hisfile,'inputdir',tmpdir,'runid',runid1,'admfile',nstadm,'zcor',zcor,'save',1,'opt',opt,'coordinatesystem',cs);

        else

            [success,message,messageid]=copyfile([outputdir 'trih-*'],tmpdir,'f');

            cd(tmpdir);

            try

                nstadm=[model.dir 'nesting' filesep model.name '.nst'];

                %% Water level correction

                zcor=hm.models(mm).zLevel-model.zLevel+model.zSeaLevelRise;

                fid=fopen('nesthd2.inp','wt');

                fprintf(fid,'%s\n',[model.name '.bnd']);
                fprintf(fid,'%s\n',nstadm);
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
                delete('smoothbct.inp');

                delete('temp.bct');
                delete('nest.dia');
                delete('dummy.bcc');
                delete('trih*');

            catch
                WriteErrorLogFile(hm,['An error occured during nesting of ' model.name]);
            end

            cd(curdir);

        end

end
