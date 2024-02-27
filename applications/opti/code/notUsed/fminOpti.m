function this = fminOpti(this)

%FMINOPTI - fminOpti optimizer for optiStruct data
%

options=optimset;
options.MaxIter=this.optiSettings.maxIter;

w=this.weights;

%Set target, if not yet set, to weighted mean of optiStruct.data
if isempty(this.target)
    this.target=optiComputeMean(this);
end


for iter=1:length(this.weights) 	% loop over the number of conditions. This is the 'elimination race' of conditions
    % (each time one condition is removed, or rather W0=0).
    
    if iter==1
        this.iteration(1).data=this.data;
    else
        this.iteration(iter).data=this.iteration(iter-1).data;
    end
    
    disp(['Working on iteration ' num2str(iter) ' of ' num2str(length(this.weights)) ]);
    [w,rms]=fminsearch(@fcost,w,options,this);
    
    RMS(iter)=rms;
    [wd,idw]=min(abs(w));
    disp(['Weight ' num2str(wd) ' dropped']); 
    this.iteration(iter).data(:,idw)=[];
    w(idw)=[];
    
    
    
    %Store results to optiStruct
    this.iteration(iter).conditions=[]; %remaining conditions from original list
    this.iteration(iter).weights=w';    %associated weights
    this.iteration(iter).RMS=RMS(iter);
    
end % end loop over conditions



function rms=fcost(w,this)

idnan=find(isnan(this.iteration(end).data(:,1)));
z=sum(this.iteration(end).data(~idnan,:).*repmat(w,size(this.iteration(end).data(~idnan,:),1),1),2);
rms=sum((z(~idnan)-this.target(~idnan)).^2);