function ObservationPoints=ReadObsFile(fname)

m=[];
n=[];
name=[];

[name,m,n] = textread(fname,'%21c%f%f');


% Check for duplicates
Names{1}='';

nobs=length(m);

% for k=1:length(m)
%     Names{k}=deblank(name(k,:));
% end
nobs=0;
for i=1:length(m)
    if m(i)>0
        if isempty(strmatch(deblank(name(i,:)),Names,'exact'))
            nobs=nobs+1;
            ObservationPoints(nobs).name=deblank(name(i,:));
            ObservationPoints(nobs).m=m(i);
            ObservationPoints(nobs).n=n(i);
        end
    end
end
