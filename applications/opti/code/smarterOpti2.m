function this = smartOpti(this)

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

idum=0;
rand('seed',0);
numRemain=length(this.weights);

W0=this.weights'; %initialize with original weights

% start iteration
hW = cwaitbar([0 0],{['Number of remaining conditions: ' num2str(numRemain)],['Iterating...']});
for iter=1:length(this.weights) 	% loop over the number of conditions. This is the 'elimination race' of conditions
    % (each time one condition is removed, or rather W0=0).
    
    rmsmin=Inf;
    corrmx=-Inf;
    covmx=-Inf;
    
    InonZ = find(W0~=0);
    nonZ = length(InonZ);
    
    for id=1:this.optiSettings.maxIter % this is the loop over the number of iterations
        %%%%% weight function
        if idum==0
            % If idum=0 (1st iteration of each condition) then W is set equal to W0
            % at the end of each condition-loop (iter) W0 becomes fixed and then counts again as an initial
            % weightfactor for the rest of the iterations for that particular condition.
            
            rand('seed',0);
            idum=1;	% idum is set to 1, so that during the next iteration this misses but goes to
            % the 'else' block .
            %             sumw0=0;
            W(:,id)=W0; % weight factors are set to W0
            %             sumw0=sum(W0(closeCond));
        else
            r=rand(length(W0),1).*(scaleRange(2)-scaleRange(1)) + scaleRange(1);
            W(:,id)=W0.*r; % initial weight factors are adjusted by the random factor;
        end 
        for ij=1:groups % loop over verschillende data groepen
            zsum=this.input(ij).data*W(:,id);
            id2=(~isnan(this.input(ij).target)&this.input(ij).target<999&abs(this.input(ij).target)>0&abs(this.input(ij).target)<900);
            npnt=length(id2);
            bias=sum(zsum(id2)-this.input(ij).target(id2))/npnt;              % bias (mean offset) from original bottom changes
            stdm=sqrt(sum(this.input(ij).target(id2).^2)/npnt);               % standard deviation of initial bottom changes
            stdc=sqrt(sum(zsum(id2).^2)/npnt);                                % standard deviation of these bottom changes
            rms(ij,id)=sqrt(sum((zsum(id2)-this.input(ij).target(id2)).^2)/npnt);    % rms error between these bottom changes and original bottom changes
            rmsRel(id,ij)=rms(ij,id)/mean(abs(this.input(ij).target(id2)));             % relative rms error
            cov(ij,id)=sum(this.input(ij).target(id2).*zsum(id2))/npnt;              % covariance of these and initial bottom changes
            corr(ij,id)=cov(ij,id)/stdm/stdc;                                   % correlation of these and initial bottom changes
        end
        rmsRelWeighted(id)=rmsRel(id,:)*this.dataGroupWeights';
        cwaitbar([2 id/this.optiSettings.maxIter]);
    end % end of loop over the number of iterations
    [rmsRelmin idmin]=min(rmsRelWeighted);
    
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
 
    idum=0;
    % now decide which condition will be removed in this loop
    [dum1 icmin]=min(W0(icmin2).*stdcc(icmin2)'); % now determine which condition contributes least to the bottom change
    icmin=icmin2(icmin);
    disp(['Drop condition # ' num2str(icmin)]);
    dropWeight=W0(icmin); %
    W0(icmin)=0; % Set the selected weight factor to 0, so will take no further part in the subsequent loops
    disp(['% Dropping condition ' num2str(icmin) ', Weight ' num2str(dropWeight)]);
    cwaitbar([1 iter/length(this.weights)]);  % update waitbar
    hWtitle=get(get(hW,'children'),'title');
    set(hWtitle{1},'string',['Number of conditions left: ' num2str(numRemain)]);
end % end loop over conditions

close(hW); % close waitbar


