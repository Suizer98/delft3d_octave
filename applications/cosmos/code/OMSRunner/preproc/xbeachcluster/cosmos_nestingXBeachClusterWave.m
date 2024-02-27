function ok=cosmos_nestingXBeachClusterWave(hm,m)

tmpdir=hm.tempDir;

mm=hm.models(m).waveNestModelNr;

outputdir=[hm.models(mm).dir 'archive' filesep 'output' filesep hm.cycStr filesep];

np=hm.models(m).nrProfiles;

switch lower(hm.models(mm).type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');

            runid=hm.models(m).runid;
            outfile='sp2list.txt';
            trefxbeach=hm.models(m).tFlowStart;

            [ok,times,files]=ExtractSWANNestSpec(outputdir,tmpdir,runid,trefxbeach,trefxbeach+hm.models(m).runTime/1440,hm,mm,m);
            
            cosmos_makeSpecList(tmpdir,outfile,times,files);
            
            disp('Compressing sp2 files ...');
            for j=1:np
                if ok(j)
                    [status,message,messageid]=copyfile([tmpdir outfile],[tmpdir hm.models(m).profile(j).name],'f');
                end
                system([hm.exeDir 'zip.exe -q -j ' tmpdir hm.models(m).profile(j).name filesep 'sp2.zip ' tmpdir hm.models(m).profile(j).name filesep '*.sp2']);
                delete([tmpdir hm.models(m).profile(j).name filesep '*.sp2']);
            end
            
            delete([tmpdir outfile]);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of XBeach in SWAN - ' hm.models(m).name]);
        end
     
end
