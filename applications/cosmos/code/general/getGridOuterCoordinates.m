function [xb,yb]=getGridOuterCoordinates(xg,yg,nstep)

% Bottom boundary
x=xg(1:end-1,1);
y=yg(1:end-1,1);
[xbb,ybb]=getCoords(x,y,nstep);

% Right boundary
x=xg(end,1:end-1);
y=yg(end,1:end-1);
x=x';
y=y';
[xbr,ybr]=getCoords(x,y,nstep);

% Top boundary
x=xg(2:end,end);
y=yg(2:end,end);
x=flipud(x);
y=flipud(y);
[xbt,ybt]=getCoords(x,y,nstep);

% Left boundary
x=xg(1,2:end);
y=yg(1,2:end);
x=x';
y=y';
x=flipud(x);
y=flipud(y);
[xbl,ybl]=getCoords(x,y,nstep);

xb=[xbb;xbr;xbt;xbl];
yb=[ybb;ybr;ybt;ybl];

function [xx,yy]=getCoords(x,y,nstep)

iac=[];

nx=length(x);

nn=0;
np=0;
ibeg=1;

for i=1:nx
    if ~isnan(x(i))
        if isnan(x(min(i+1,nx))) || nn==nstep-1 || ibeg==1 || i==nx
            nn=0;
            np=np+1;
            iac(np)=i;
        else
            nn=nn+1;
        end
        ibeg=0;
    else
        ibeg=1;
    end
end

xx=x(iac);
yy=y(iac);
