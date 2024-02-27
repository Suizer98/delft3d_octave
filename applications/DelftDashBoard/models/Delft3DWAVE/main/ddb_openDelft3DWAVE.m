function ddb_openDelft3DWAVE(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdw','Select MDW file');
        runid   = filename(1:end-4);
        if pathname~=0
            % Delete all domains
            ddb_plotDelft3DWAVE('delete','domain',0);
            handles.model.delft3dwave.domain = [];
            handles.activeWaveGrid                      = 1;
%            handles.toolbox(tb).Input.domains           = [];
            handles  = ddb_initializeDelft3DWAVEInput(handles,runid);
            filename =[runid '.mdw'];
            handles  = ddb_readMDW(handles,[pathname filename]);
            handles  = ddb_Delft3DWAVE_readAttributeFiles(handles);
            
            % Coupling with Delft3D-FLOW
            if handles.model.delft3dflow.domain(1).MMax>0

                % There is an active FLOW model
                ButtonName = questdlg('Couple with Delft3D-FLOW model?', ...
                    'Couple with flow', ...
                    'Cancel', 'No', 'Yes', 'Yes');
                switch ButtonName,
                    case 'Cancel',
                        return;
                    case 'No',
                        couplewithflow=0;
                    case 'Yes',
                        couplewithflow=1;
                end
                
                if couplewithflow
                    handles.model.delft3dwave.domain.referencedate=handles.model.delft3dflow.domain(1).itDate;
                    handles.model.delft3dwave.domain.mapwriteinterval=handles.model.delft3dflow.domain(1).mapInterval;
                    handles.model.delft3dwave.domain.comwriteinterval=handles.model.delft3dflow.domain(1).comInterval;
                    handles.model.delft3dwave.domain.writecom=1;
                    handles.model.delft3dwave.domain.coupling='ddbonline';
                    handles.model.delft3dwave.domain.mdffile=handles.model.delft3dflow.domain(1).mdfFile;
                    for id=1:handles.model.delft3dflow.nrDomains
                        handles.model.delft3dflow.domain(id).waves=1;
                        handles.model.delft3dflow.domain(id).onlineWave=1;
                    end
                    if handles.model.delft3dflow.domain(1).comInterval==0 || handles.model.delft3dflow.domain(1).comStartTime==handles.model.delft3dflow.domain(1).comStopTime
                        ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
                    end
                    if ~handles.model.delft3dflow.domain(1).wind
                        % Turn off wind
                        for id=1:handles.model.delft3dwave.domain.nrgrids
                            handles.model.delft3dwave.domain.domains(id).flowwind=0;                   
                        end
                    end
                end
                
            end
            
            setHandles(handles);
            ddb_plotDelft3DWAVE('plot','active',0,'visible',1,'wavedomain',awg);
            gui_updateActiveTab;
        end        
    otherwise
end
