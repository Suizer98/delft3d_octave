function [hm,WaitingList]=cosmos_updateWaitingList(hm)
% Function determines which model are ready to be pre-processed

j=0;

WaitingList=[];
if strcmpi(hm.runEnv,'win32')
    % Wait for models to finish
    for ii=1:hm.nrModels
        if strcmpi(hm.models(ii).status,'running')
            % Wait for this model to finish
            return;
        end
    end
end
    
% Check which models need to run next

for i=1:hm.nrModels
    if strcmpi(hm.models(i).status,'waiting') && hm.models(i).priority>0 && hm.models(i).run
        if ~hm.models(i).flowNested && ~hm.models(i).waveNested
            % Not nested in any other model: model is ready to run
            j=j+1;
            tmplist(j)=i;
            priority(j)=hm.models(i).priority;
        else
            % Check status of flow model in which it is nested
            if hm.models(i).flowNested
                mmf=hm.models(i).flowNestModelNr;
                statf=hm.models(mmf).status;
            else
                statf='finished';
            end
            % Check status of wave model in which it is nested
            if hm.models(i).waveNested
                mmw=hm.models(i).waveNestModelNr;
                statw=hm.models(mmw).status;
            else
                statw='finished';
            end
            if strcmpi(statf,'finished') && strcmpi(statw,'finished')
                j=j+1;
                tmplist(j)=i;
                priority(j)=hm.models(i).priority;
            end
            
            if strcmpi(statf,'failed') || strcmpi(statw,'failed')
                % Flow or wave model failed: nested model is skipped
                if ~strcmpi(hm.models(i).status,'failed')
                    disp(['Skipping model ' hm.models(i).name ' due to failure in overall model!']);
                end
                hm.models(i).status='failed';
            end
        end
    end
end

% Sort waiting list according to prioritization
if j>0
    [y,ii]=sort(priority,'descend');
    WaitingList=tmplist(ii);
    if strcmpi(hm.runEnv,'win32')
        WaitingList=WaitingList(1);
    end
else
    WaitingList=[];
end

