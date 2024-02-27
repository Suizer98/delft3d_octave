clear all;close all;

outd='profiles\';

load('sb9xlines3mFinal.mat');

mdl.tstop=10000;
mdl.nt=120;
mdl.morfac=10;

mdl.dx=5;
mdl.dy=5;

zmax=10;

for i=1:length(prf)
    id=prf(i).id;
    mkdir(outd,num2str(id,'%0.5i'));
    dr=[outd num2str(id,'%0.5i') '\'];
    
    np=length(prf(i).x);
    
    nx=floor(prf(i).dist(end)/mdl.dx)+1;
    xx=0:mdl.dx:(nx-1)*mdl.dx;
    
    zz=interp1(prf(i).dist,prf(i).z,xx);

    imax=find(zz>zmax, 1 );
    
    mdl.nx=imax+1;
    
    d=zz(1:imax);
    d(end+1)=d(end);
    d(end+1)=d(end);
    
    mdl.xori=prf(i).xori;
    mdl.yori=prf(i).yori;
    mdl.alpha=180*prf(i).alpha/pi;
    
    mdl.depfile=[num2str(id,'%0.5i') '.dep'];
    
    writeParams(mdl,dr);

    % write dep file
    fid=fopen([dr num2str(id,'%0.5i') '.dep'],'wt');
    fmt=[repmat(' %13.5e',[1,mdl.nx+1]) '\n'];
    fprintf(fid,fmt,d);
    fprintf(fid,fmt,d);
    fprintf(fid,fmt,d);
    fclose(fid);

end
