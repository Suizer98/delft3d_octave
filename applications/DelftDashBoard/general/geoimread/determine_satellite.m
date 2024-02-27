function [xx,yy,z,col] = determine_satellite(xl0, yl0, workdir, zmlev)

% Extract area
dx = xl0(2) - xl0(1);
xl0(1) = xl0(1)-dx/4;  xl0(2) = xl0(2)+dx/4;
yl0(1) = yl0(1)-dx/4;  yl0(2) = yl0(2)+dx/4;
npix=1024;
if isempty(zmlev)
    zmlev=round(log2(npix*3/(dx)));
    zmlev=max(zmlev,4);
    zmlev=min(zmlev,23);
end
[xx,yy,c2]=ddb_getMSVEimage(xl0(1),xl0(2),yl0(1),yl0(2),'zoomlevel',zmlev,'npix',npix,'whatKind','aerial','cache',workdir);
ii1=find(xx>=xl0(1),1,'first');
ii2=find(xx<xl0(2),1,'last');
jj1=find(yy>=yl0(1),1,'first');
jj2=find(yy<yl0(2),1,'last');
xx=xx(ii1:ii2);
yy=yy(jj1:jj2);
c2=c2(jj1:jj2,ii1:ii2,:);
c2=double(c2);
c2=uint8(c2);
[XX,YY] = meshgrid(xx,yy);
col=double(c2)/255;
z=zeros(size(XX));
end

