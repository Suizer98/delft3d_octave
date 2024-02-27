function this = smarterOptiKeepWeights(this)

%SMARTOPTI - smartOpti optimizer for optiStruct data
%
% modified by GL 10 Dec 2006
% To be a bit smarter about making "random" weighting changes

% opti
% bepaalt de morfologisch meest bepalende conditie aan de hand van
% bodemveranderingen per conditie en bijbehorende weegfactoren
% (ofwel kansen van voorkomen). Berekent eerst op basis van de
% bodemveranderingen en weegfactoren van alle condities de gewogen
% gemiddelde bodemverandering en laat dan tijdens een iteratieproces telkens
% 1 conditie afvallen die het minste bijdraagt aan de daadwerkelijke
% bodemverandering. Geeft ook statistische output (rms, covariantie, etc)
% zodat zichtbaar wordt hoe goed de nieuwe bodemverandering is wanneer er
% weer een conditie is afgevallen.
%

groups=length(this.input);
if groups~=length(this.dataGroupWeights)
    error(['Specify ' num2str(groups) ' weights in this.dataGroupsWeights']);
    return
end

if ~isfield(this.optiSettings,'scaleTol')
    this.optiSettings.scaleTol = 1; % defines range of random factors with which the weights are multiplied with (1 means a range of [1-1 1+1] = [0 2])
end
if ~isfield(this.optiSettings,'smallIter')
    this.optiSettings.smallIter = 100; % maximum number of wave conditions to assign a random weighting to
end

% make sure that the sum of dataGroupWeitghs = 1
this.dataGroupWeights=this.dataGroupWeights./sum(this.dataGroupWeights);

% note: scaleTol is arbitrary, but 0.5 seems to work better than 0.3 or 1.0
% note: this scaling is only used if idmax <100. For large numbers of
% iterations it is better to let it go free..
scaleRange = [1-this.optiSettings.scaleTol 1+this.optiSettings.scaleTol];

%Set target, if not yet set, to weighted mean of optiStruct.data
%Compute std of optiStruct.data
for ij=1:groups
    if isempty(this.input(ij).target)
        this.input(ij).target=optiComputeMean(this,ij);
    end
    stdcc(ij,:)=optiComputeStd(this,ij);
end

numRemain=length(this.weights);

W0=this.weights'; %initialize with original weights

% start iteration
hW = waitbar(0,['Number of remaining conditions: ' num2str(numRemain)]); %waitbar
for iter=1:length(this.weights) 	% loop over the number of conditions. This is the 'elimination race' of conditions
    % (each time one condition is removed, or rather W0=0).
    InonZ = find(W0~=0);
    nonZ = length(InonZ);
    
    W=repmat(W0,1,this.optiSettings.maxIter);
    if iter>1
        rand('seed',0);% zodat uitkomsten reproduceerbaar zijn
        W(:,2:end)=(1-this.optiSettings.scaleTol + this.optiSettings.scaleTol.*2.*rand(size(W(:,2:end)))).*W(:,2:end);
        % for smarterOptiKeepWeights we want to make sure that the sum of
        % the weights stays equal to 1, thus:
        W=W./repmat(sum(W,1),size(W,1),1);
    end
    
    for ij=1:groups % loop over verschillende data groepen
        zsum=this.input(ij).data*W;
        
%         id2=find(~isnan(this.input(ij).target)&this.input(ij).target<999&abs(this.input(ij).target)>0&abs(this.input(ij).target)<900);
        id2=find(~isnan(this.input(ij).target)&abs(this.input(ij).target)>0);
        npnt=length(id2);
        
        %bias=sum(zsum(id2,:)-repmat(this.input(ij).target(id2),1,this.optiSettings.maxIter))./npnt;
        rms(ij,:)=sqrt(sum((zsum(id2,:)-repmat(this.input(ij).target(id2),1,this.optiSettings.maxIter)).^2,1)/npnt);    % rms error between these bottom changes and original bottom changes
        stdm=sqrt(sum(this.input(ij).target(id2).^2,1)/npnt);               % standard deviation of initial bottom changes
        stdc=sqrt(sum(zsum(id2,:).^2,1)/npnt);                      % standard deviation of these bottom changes
        rmsRel(:,ij)=[rms(ij,:)./stdm]';             % relative rms error
        cov(ij,:)=sum(repmat(this.input(ij).target(id2),1,this.optiSettings.maxIter).*zsum(id2,:),1)/npnt;              % covariance of these and initial bottom changes
        corr(ij,:)=cov(ij,:)./stdm./stdc;                         % correlation of these and initial bottom changes
    end	    
    rmsRelWeighted=rmsRel*this.dataGroupWeights';
    [rmsRelmin, idmin]=min(rmsRelWeighted);
    W0=W(:,idmin); % the new weight factors to choose are the ones where the smallest rms was calculated and thus the best bottom was obtained.
    icmin2=find(W0>0); % find the conditions which have not yet been removed
    numRemain=length(icmin2);
    
    %Store results to optiStruct
    this.iteration(iter).conditions=find(W0~=0)'; %remaining conditions from original list
    this.iteration(iter).weights=W0';    %associated weights
    this.iteration(iter).rmsRelWeighted=rmsRelmin;
    this.iteration(iter).rmsRel=rmsRel';        
    this.iteration(iter).rms=rms;    
    this.iteration(iter).corr=corr;    
    this.iteration(iter).cov=cov;    
    this.iteration(iter).iteration=idmin;    
    
    % now decide which condition will be removed in this loop (by scaling
    % for each data group the changes per condition to the total change and
    % summing these scaled changes for all datagroups per condition)
    cont=repmat(this.dataGroupWeights,numRemain,1).*repmat(W0(icmin2),1,groups).*stdcc(:,icmin2)'*[1./[stdcc(:,icmin2)*W0(icmin2)]']';
    [dum1 icmin]=min(cont); 
    icmin=icmin2(icmin);
    disp(['Drop condition # ' num2str(icmin)]);
    dropWeight=W0(icmin); %
    W0(icmin)=0; % Set the selected weight factor to 0, so will take no further part in the subsequent loops
    
    %%%%% adding dropped weight to remaining other weights
    W0(W0>0)=W0(W0>0)+dropWeight/length(W0(W0>0));
    %%%%%
    
    disp(['% Dropping condition ' num2str(icmin) ', Weight ' num2str(dropWeight)]);
    waitbar(iter/length(this.weights),hW,['Number of conditions left: ' num2str(numRemain)]);  % update waitbar    
end % end loop over conditions

close(hW); % close waitbar
