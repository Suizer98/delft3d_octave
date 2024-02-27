function cosmos_nestingDelft3DWave(hm,m)

model=hm.models(m);

tmpdir=hm.tempDir;

curdir=pwd;

mm=model.waveNestModelNr;

% dr=model.dir;

outputdir=[hm.models(mm).dir 'archive' filesep 'output' filesep hm.cycStr filesep];

switch lower(hm.models(mm).type)

    case{'ww3'}

         try

            disp('Nesting in WWIII ...');

            % Nesting Delft3D in WWIII
                        
            fname=[outputdir 'ww3.' model.name '.spc'];

            ConvertWW3spc(fname,[tmpdir model.name '.sp2'],model.coordinateSystem,model.coordinateSystemType);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in WWIII - ' model.name]);
        end

    case{'delft3dwave','delft3dflowwave'}

        try

            % Nesting Delft3D in SWAN

            disp('Nesting in SWAN ...');
            
            [success,message,messageid]=copyfile([outputdir model.runid '*.sp2'],tmpdir,'f');

            ConvertSWANNestSpec(tmpdir,[tmpdir model.name '.sp2'],hm,mm,m);
            
            delete([tmpdir model.runid '.*t*.sp2']);
            
        catch
            WriteErrorLogFile(hm,['An error occured during nesting of Delft3D in SWAN - ' model.name]);
        end
     
end

cd(curdir);
