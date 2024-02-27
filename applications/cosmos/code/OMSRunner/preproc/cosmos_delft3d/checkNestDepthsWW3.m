function [x,y]=checkNestDepthsWW3(depname,xori,yori,nx,ny,dx,dy,x0,y0)

x=[];
y=[];
k=0;

depth=wldep('read',depname,[nx ny]);

for i=1:length(x0)

    xp=x0(i);
    yp=y0(i);
    xp=xp+360;
    xp=mod(xp,360);

    ix=floor((xp-xori)/dx)+1;
    iy=floor((yp-yori)/dy)+1;

    ixp=ix+1;
    iyp=iy+1;
    if ixp>nx
        ixp=1;
    end
    if iyp>ny
        iyp=1;
    end
    
    dpmin=min([depth(ix,iy) depth(ixp,iy) depth(ix,iyp) depth(ixp,iyp)]);

    if dpmin>0
        k=k+1;
        x(k,1)=xp;
        y(k,1)=yp;
    end

end
