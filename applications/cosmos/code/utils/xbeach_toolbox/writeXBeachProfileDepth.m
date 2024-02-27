function [nx,hardLayer]=writeXBeachProfileDepth(outdir,fname,x,z,dx,zmax,maxslope)

hardLayer=0;

dist=pathdistance(x);

nx=floor(dist(end)/dx)+1;
    
xx=0:dx:(nx-1)*dx;
    
zz=interp1(dist,z,xx);

imax=find(zz>zmax, 1,'first');

slope=(zz(2:end)-zz(1:end-1))/(xx(2:end)-zz(1:end-1));
slope=[0 slope];

ihard=find(slope>maxslope,1,'first');

nx=imax+1;

d=zz(1:imax);
d(end+1)=d(end);
d(end+1)=d(end);

% write dep file
fid=fopen([outdir fname '.dep'],'wt');
fmt=[repmat(' %13.5e',[1,nx+1]) '\n'];
fprintf(fid,fmt,d);
fprintf(fid,fmt,d);
fprintf(fid,fmt,d);
fclose(fid);
