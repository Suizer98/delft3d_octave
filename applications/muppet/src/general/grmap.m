function dat=grmap(dat0,iref,w);
 
npt=size(iref,2);
 
for i=1:npt
    dat(i)=0;
    if min(iref(:,i,1))>0
        for j=1:4
            dat(i)=dat(i)+w(j,i)*dat0(iref(j,i,1),iref(j,i,2));
        end
    else
        dat(i)=0;
    end
end
