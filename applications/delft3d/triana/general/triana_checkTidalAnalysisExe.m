function analysisExe  = triana_checkTidalAnalysisExe

analysisExe = '';

% find available tide_analysis.exe on this machine
D3DBaseDir = 'c:\Program Files (x86)\Deltares';
D3Ddirs = dir([D3DBaseDir,filesep,'Delft3D*']);
makeCheckDir = 1; exeID = 0;
if ~isempty(D3Ddirs)
    for dd = 1:length(D3Ddirs)
        if exist([D3DBaseDir,filesep,D3Ddirs(dd).name,'\win32\tide\bin\tide_analysis.exe'],'file')
            exeID=exeID+1;
            dirNR(exeID) = dd;
            localCheckDir{exeID} = [getenv('TEMP'),filesep,'TideAnalysisCheck_',num2str(dd,'%02i'),'_',datestr(now,'yyyymmddHHMMSS'),filesep];
            makedir(localCheckDir{exeID});
            makeCheckDir = 0;
            dirFiles = [fileparts(which('triana')),filesep,'checkAnalysis'];
            copyfiles([fileparts(which('triana')),filesep,'checkAnalysis'],localCheckDir{exeID});
            copyfile([D3DBaseDir,filesep,D3Ddirs(dd).name,'\win32\tide\bin\tide_analysis.exe'],localCheckDir{exeID})
            cd(localCheckDir{exeID})
            system(['tide_analysis.exe &']);
        end
    end
    if exeID>0
        it = 0;
        while it<3
            it = it+1;
            % check if .cmp is generated, which is an indicator for a correct
            % tide_analysis.exe file
            for qq = 1:length(localCheckDir)
                if ~isempty(dir([localCheckDir{qq},'*.cmp']))
                    analysisExe = [D3DBaseDir,filesep,D3Ddirs(dirNR(qq)).name,'\win32\tide\bin\tide_analysis.exe'];
                    it = 3;
                end
            end
        end
        
        % kill hanging processes after 3 seconds
        dos('taskkill /im tide_analysis.exe /f');
        for qq = 1:length(localCheckDir)
            delete([localCheckDir{qq},'*']);
        end
    end
else
    error('No Delft3D installations found on this machine')
end