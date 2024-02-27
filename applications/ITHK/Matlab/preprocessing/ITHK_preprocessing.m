% function S = preprocessingUnibestIT(lat,lon,mag,time,name,measure,inputDir,outputDir)
function ITHK_preprocessing(sens)

global S

status='ITHK preprocessing';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing\n');

%% Preprocessing Unibest Interactive Tool

%% Copy input files to output directory
status='ITHK preprocessing : Copy default UNIBEST model files';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing : Copy default UNIBEST model files\n');
%copyfile(S.settings.inputdir,S.settings.outputdir);
%{
copyfile([S.settings.inputdir 'BASIS.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BASIS_ORIG.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BASIS_ORIG_OLD.MDA'],S.settings.outputdir);
copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir 'BASIS.SOS']);
copyfile([S.settings.inputdir 'BRIJN90A.GRO'],[S.settings.outputdir 'BASIS.GRO']);
copyfile([S.settings.inputdir 'HOLLANDCOAST.REV'],[S.settings.outputdir 'BASIS.REV']);
copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],S.settings.outputdir);
copyfile([S.settings.inputdir 'BRIJN90A.GRO'],S.settings.outputdir);
copyfile([S.settings.inputdir 'HOLLANDCOAST.REV'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.BCI'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.BCO'],S.settings.outputdir);
copyfile([S.settings.inputdir 'NULL.OBW'],S.settings.outputdir);
copyfile([S.settings.inputdir 'locations5magrof2.GKL'],S.settings.outputdir);
%}
%% Prepare input Unibest CL for different measures
status='ITHK preprocessing : Preparing UNIBEST structures and nourishments';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK preprocessing : Preparing UNIBEST structures and nourishments\n');
% IMPORTANT: first add groynes, since MDA might be updated --> increase in number of coastline points
for jj = 1:length(S.userinput.phases)
    
    % If GRO-file in phase differs from 'basis', add groyne
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')      
    if ~strcmp(strtok(S.userinput.phase(jj).GROfile,'.'),S.settings.CLRdata.GRO{1})
        if ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile])
            status='Adding groyne(s)';
            try
                sendWebStatus(status,S.xml);
            catch
            end        
            disp('Adding groyne(s)')
            
            % Check for initial files 
            if ~isempty(S.userinput.phase(jj).ini)
                phaseid = find(ismember(S.userinput.initphases,S.userinput.phases(jj)));
                % If user added info before combine this with ini file
                if isfield(S.userinput.userdefined,'GRO')
                    [GROdata]=ITHK_io_readGRO([S.settings.rundir S.settings.CLRdata.GRO{phaseid} '.GRO']);
                    len = length(GROdata);
                    for ii = 1:length(S.userinput.userdefined.GRO);
                        GROdata(len+ii) = S.userinput.userdefined.GRO(ii);
                    end
                    ITHK_io_writeGRO([S.settings.outputdir S.userinput.phase(jj).GROfile],GROdata);
                end
            % If groynes have been added in previous phase, use this file as 
            % the basis for adding groynes in current phase    
            else
                if jj>1
                    %if ~strcmp(lower(strtok(S.userinput.phase(jj-1).GROfile,'.')),'basis')
                     if ~strcmp(strtok(S.userinput.phase(jj-1).GROfile,'.'),S.settings.CLRdata.GRO{1})
                        copyfile([S.settings.outputdir S.userinput.phase(jj-1).GROfile],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
                     else
                        copyfile([S.settings.rundir S.settings.CLRdata.GRO{1} '.GRO'],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
                    end
                else
                    copyfile([S.settings.rundir S.settings.CLRdata.GRO{1} '.GRO'],[S.settings.outputdir S.userinput.phase(jj).GROfile]);
                end
            end
            NGRO = 0;
            for ii = 1:length(S.userinput.phase(jj).groids)    
                NGRO = NGRO+1;
                ITHK_add_groyne(S.userinput.phase(jj).groids(ii),jj,NGRO,sens);
            end
        end
    end
    
    % If SOS-file in phase differs from 'basis', add nourishment
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
    if ~strcmp(strtok(S.userinput.phase(jj).SOSfile,'.'),S.settings.CLRdata.SOS{1})
        status='Adding nourishment(s)';
        try
            sendWebStatus(status,S.xml);
        catch
        end        
        disp('Adding nourishment(s)')
        
        % Check for initial files 
        if ~isempty(S.userinput.phase(jj).ini)
            phaseid = find(ismember(S.userinput.initphases,S.userinput.phases(jj)));
            % If user added info before combine this with ini file
            if isfield(S.userinput.userdefined,'SOS')
                [SOSdata]=ITHK_io_readSOS([S.settings.rundir S.settings.CLRdata.SOS{phaseid} '.SOS']);
                len = length(SOSdata);
                for ii = 1:length(S.userinput.userdefined.SOS);
                    SOSdata(len+ii) = S.userinput.userdefined.SOS(ii);
                end
                ITHK_io_writeSOS([S.settings.outputdir S.userinput.phase(jj).SOSfile],SOSdata);
                copyfile([S.settings.outputdir S.userinput.phase(jj).SOSfile],[S.settings.outputdir 'nourishment_cont.sos']);
            end
        else
            % If continuous nourishment exist, use continuous nourishments as base. 
            % Else use template file to add nourishment
            if exist([S.settings.outputdir 'nourishment_cont.sos'],'file') &&  ~strcmp([S.settings.outputdir S.userinput.phase(jj).SOSfile],[S.settings.outputdir 'nourishment_cont.sos'])
               copyfile([S.settings.outputdir 'nourishment_cont.sos'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]); 
            elseif ~exist([S.settings.outputdir 'nourishment_cont.sos'],'file')
                copyfile([S.settings.rundir  S.settings.CLRdata.SOS{1} '.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
            end
    %         elseif exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
    %         else
    %            copyfile([S.settings.inputdir '1HOTSPOTS1IT.SOS'],[S.settings.outputdir S.userinput.phase(jj).SOSfile]);
    %         end
        end
        for ii = 1:length(S.userinput.phase(jj).supids)
            ITHK_add_nourishment(ii,jj,sens);
        end
    end
    % If REV-file in phase differs from 'basis', add revetment
    %if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
    if ~strcmp(strtok(S.userinput.phase(jj).REVfile,'.'),S.settings.CLRdata.REV{1})
        if ~strcmp([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile])
            status='Adding revetment(s)';
            try
                sendWebStatus(status,S.xml);
            catch
            end        
            disp('Adding revetment(s)')
            % Check for initial files 
            if ~isempty(S.userinput.phase(jj).ini)
                phaseid = find(ismember(S.userinput.initphases,S.userinput.phases(jj)));
                % If user added info before combine this with ini file
                if isfield(S.userinput.userdefined,'REV')
                    [REVdata]=ITHK_io_readREV([S.settings.rundir S.settings.CLRdata.REV{phaseid} '.REV']);
                    len = length(REVdata);
                    for ii = 1:length(S.userinput.userdefined.REV);
                        REVdata(len+ii) = S.userinput.userdefined.REV(ii);
                    end
                    ITHK_io_writeREV([S.settings.outputdir S.userinput.phase(jj).REVfile],REVdata);
                end
            else
                % If revetments have been added in previous phase, use this file as 
                % the basis for adding revetments in current phase        
                if jj>1
                    %if ~strcmp(lower(strtok(S.userinput.phase(jj-1).REVfile,'.')),'basis')
                    if ~strcmp(strtok(S.userinput.phase(jj).REVfile,'.'),S.settings.CLRdata.REV{1})
                        copyfile([S.settings.outputdir S.userinput.phase(jj-1).REVfile],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
                    else
                        copyfile([S.settings.rundir S.settings.CLRdata.REV{1} '.REV'],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
                    end
                else
                    %copyfile([S.settings.rundir 'BASIS.REV'],[S.settings.outputdir S.userinput.phase(jj).REVfile]);

                    copyfile([S.settings.rundir S.settings.CLRdata.REV{1} '.REV'],[S.settings.outputdir S.userinput.phase(jj).REVfile]);
                end
            end
            
            NREV = 0;
            for ii = 1:length(S.userinput.phase(jj).revids)
                NREV = NREV+1;
                ITHK_add_revetment(S.userinput.phase(jj).revids(ii),jj,NREV,sens);
            end
        end
    end
end

ITHK_prepareCLrun;
