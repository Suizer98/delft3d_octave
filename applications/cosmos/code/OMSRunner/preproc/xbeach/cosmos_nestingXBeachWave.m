function cosmos_nestingXBeachWave(hm,m)

tmpdir=hm.tempDir;

mm=hm.models(m).waveNestModelNr;

outputdir=[hm.models(mm).dir 'archive' filesep 'output' filesep hm.cycStr filesep];

switch lower(hm.models(mm).type)

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            runid=hm.models(m).runid;
            outfile='waves.txt';
            trefxbeach=hm.models(m).tFlowStart;

            [ok,times,files]=ExtractSWANNestSpec(outputdir,tmpdir,runid,trefxbeach,trefxbeach+hm.models(m).runTime/1440,hm,mm,m);
            cosmos_makeSpecList(tmpdir,outfile,times,files);
            
            parfile=[tmpdir 'params.txt'];
            findreplace(parfile,'INSTATNR','5');
            findreplace(parfile,'WAVEFILE',outfile);

        catch
            WriteErrorLogFile(hm,'An error occured during nesting of XBeach in SWAN');
        end
     
end
