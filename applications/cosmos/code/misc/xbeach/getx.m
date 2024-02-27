clear all;close all;
a=load('sb9xlines3mFinal.prn');

id=a(:,1);
x0=a(:,3);
y0=a(:,4);
z0=a(:,5);


id0=0;
nprof=0;
for i=1:length(id)
    if id(i)~=id0
        npoints=0;
        nprof=nprof+1;
        id0=id(i);
    end
    npoints=npoints+1;
    prf(nprof).id=id(i);
    prf(nprof).x(npoints)=x0(i);
    prf(nprof).y(npoints)=y0(i);
    prf(nprof).z(npoints)=z0(i);
end

for i=1:nprof
    prf(i).xori=prf(i).x(1);
    prf(i).yori=prf(i).y(1);
    prf(i).alpha=atan2(prf(i).y(end)-prf(i).y(1),prf(i).x(end)-prf(i).x(1));
    prf(i).dist=pathdistance(prf(i).x,prf(i).y);
end

save('sb9xlines3mFinal.mat','prf');
