function cosmos_runModelLoop(hObject, eventdata)

% This is the model loop timer function. It is executed every 5 seconds,
% until all simulations are finished.
%
% It first checks whether any new simulations can be started. If this is
% the case, then for each model,the pre-processing will be done, and the
% job will be submitted.
%
% Next, the model loop checks whether simulations are finished and waiting
% somewhere on the network. If so, the model output of each simulation
% will be moved to the local directory.
%
% Next, the model loop does the post-processing (extracting data, making
% figures, uploading to website). It does this for only one
% model. This is better than post-processing all models in one execution of the model
% loop, as this can take a bit of time. In the mean time, simulations
% could be ready to run, but would have to (unnecessarily) wait for
% post-processing of other models.
%
% Finally, the model loop checks if all simulations are finished. If so,
% the main loop timer (which executes every 6 or 12 hours) and the model loop
% timer are deleted. A new main loop timer is started if the the cycle mode
% has been set to continuous.

try
    
    hm=guidata(findobj('Tag','OMSMain'));
    
    %%   Moving all finished model output to local directory
    
    % First check which simulations have been finished and are waiting to
    % be moved to local main directory
    [hm,FinishedList]=cosmos_checkForFinishedSimulations(hm);
    
    % If there are simulations ready ...
    if ~isempty(FinishedList)
        
        n=length(FinishedList);
        
        % Move all waiting simulations
        for i=1:n
            
            % Moving data
            m=FinishedList(i);

            if ~strcmpi(hm.models(m).status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
                mdl=hm.models(m).name;
                set(hm.textModelLoopStatus,'String',['Status : moving ' mdl ' ...']);drawnow;
                                
                % Build in check for WAVEWATCHIII
                ok=1;
                if strcmpi(hm.models(m).type,'ww3')
                    rundir=[hm.jobDir hm.models(m).name filesep];
                    if ~exist([rundir 'out_grd.ww3'],'file')
                        % Something went wrong (probably related to MPI stuff)
                        % Delete rundir and set status back to waiting
                        [status,message,messageid]=rmdir(rundir, 's');
                        hm.models(m).status='waiting';
                        disp('Trying WAVEWATCH III again !!!');
                        ok=0;
                    end
                end
                
                if ok
                    try
                        WriteLogFile(['Moving data ' hm.models(m).name]);
                        tic
                        % Move the model results to local main directory
                        cosmos_moveModelData(hm,m);
                    catch
                        WriteErrorLogFile(hm,['Something went wrong moving data of ' hm.models(m).name]);
                        hm.models(m).status='failed';
                    end
                    hm.models(m).moveDuration=toc;
                    
                    % Set model status to simulationfinished (if everything went okay)
                    % The model is now ready for further post-processing (extracting data, making figures, uploading to website)
                    if ~strcmpi(hm.models(m).status,'failed')
                        hm.models(m).status='simulationfinished';
                    end
                    
                end
            end
        end
    end
        
    
    %%   Pre-Processing

    [hm,WaitingList]=cosmos_updateWaitingList(hm);    
    
    % If there are model ready to run ...
    if ~isempty(WaitingList)
        
        % Pre process all waiting simulations
        for i=1:length(WaitingList)
            
            % Close all files that may have been left open due to an error
            % in previous model
            fclose all;
            
            m=WaitingList(i);
            
            if ~strcmpi(hm.models(m).status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
                
                % Check if simulation actually needs to run (not sure how
                % this could happen... TODO Should check it out.
                if hm.models(m).runSimulation
                    mdl=hm.models(m).name;
                    set(hm.textModelLoopStatus,'String',['Status : pre-processing ' mdl ' ...']);drawnow;
                    try
                        WriteLogFile(['Pre-processing ' hm.models(m).name]);
                        % Pre-processing
                        cosmos_preProcess(hm,m);
                    catch
                        WriteErrorLogFile(hm,['Something went wrong pre-processing ' hm.models(m).name]);
                        hm.models(m).status='failed';
                    end
                    try
                        % If pre-processing went okay, now submit the job
                        if ~strcmpi(hm.models(m).status,'failed') && ~isempty(timerfind('Tag', 'ModelLoop'))
                            WriteLogFile(['Submitting job ' hm.models(m).name]);
                            % Submitting
                            %                            if ~strcmpi(hm.models(m).type,'xbeachcluster')
                            cosmos_submitJob(hm,m);
                            %                            end
                        end
                    catch
                        WriteErrorLogFile(hm,['Something went wrong submitting job for ' hm.models(m).name]);
                        hm.models(m).status='failed';
                    end
                end
                
                % If everything went okay, set model status to running
                if ~strcmpi(hm.models(m).status,'failed')
                    hm.models(m).status='running';
                end
                
            end
        end
    end
    
    %%   Post-Processing
    
    % Find simulations that are finished and been moved to local pc
    m=[];
    for i=1:hm.nrModels
        if strcmpi(hm.models(i).status,'simulationfinished')
            m=i;
            % Only post-process one model at a time
            break;
        end
    end
    
    % If there is a simulation ready for processing ...
    if ~isempty(m)
        
        mdl=hm.models(m).name;
        set(hm.textModelLoopStatus,'String',['Status : post-processing ' mdl ' ...']);drawnow;
        
        WriteLogFile(['Processing data ' hm.models(m).name]);
        
        % Process model results
        hm=cosmos_processData(hm,m);
        
        disp(['Post-processing ' hm.models(m).name ' finished']);
        
        % Check if anything went wrong
        if ~strcmpi(hm.models(m).status,'failed')
            % Model finished, no failures
            cosmos_writeJoblistFile(hm,m,'finished');
            hm.models(m).status='finished';
        else
            % Model finished, with failures
            cosmos_writeJoblistFile(hm,m,'failed');
            hm.models(m).status='failed';
        end
        
    end
    set(hm.textModelLoopStatus,'String','Status : active');drawnow;
    
    
    %%  Check if all simulations are finished
    
    alfin=1;
    failed=0;
    for i=1:hm.nrModels
        if ~strcmpi(hm.models(i).status,'finished') && ~strcmpi(hm.models(i).status,'failed') && hm.models(i).priority>0
            alfin=0;
        end
        % Check if one of the models failed.
        if strcmpi(hm.models(i).status,'failed')
            failed=1;
        end
    end
    
    if alfin
        disp('All models finished!');
    end
    
    % If all finished, delete timer functions ModelLoop and MainLoop
    t1 = timerfind('Tag', 'ModelLoop');
    t2 = timerfind('Tag', 'MainLoop');
    if alfin && ~isempty(t2)
        delete(t1);
        delete(t2);
        set(hm.textModelLoopStatus,'String','Status : inactive');drawnow;
        % If cycle mode is continuous, start new MainLoop
        if strcmpi(hm.cycleMode,'continuous')
            disp(['Finished cycle ' datestr(hm.cycle,'yyyymmdd.HHMMSS')]);
            hm.cycle=hm.nextCycle;
            disp(['Starting cycle ' datestr(hm.cycle,'yyyymmdd.HHMMSS')]);
            set(hm.editCycle,'String',datestr(hm.cycle,'yyyymmdd HHMMSS'));
            set(hm.textModelLoopStatus,'String','Status : waiting');drawnow;
            guidata(findobj('Tag','OMSMain'),hm);
            cosmos_startMainLoop(hm);
        end
    end
    
    guidata(findobj('Tag','OMSMain'),hm);
    
catch
    
    WriteErrorLogFile(hm,'Something went wrong running in the model loop');
    
end
