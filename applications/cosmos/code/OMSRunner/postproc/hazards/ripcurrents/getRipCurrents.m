function [vcrsmax,yy,rips,warningLevel]=getRipCurrents(x,y,t,u,v,h,d,ref,warningLevels,dmin,dmax)

rot=(ref.orientation-90)*pi/180;

reslon=10;
rescrs=10;

%% Make grid
xx=-ref.width1:rescrs:ref.width2;
yy=(-round(ref.length1/reslon))*reslon:reslon:(round(ref.length2/reslon))*reslon;
[xg0,yg0]=meshgrid(xx,yy);
xg =  xg0 .*  cos(rot) + yg0 .* -sin(rot) + ref.x0;
yg =  xg0 .*  sin(rot) + yg0 .* cos(rot) + ref.y0;
nx=length(xx);
ny=length(yy);

[dpx,dpy,dpz]=vec(x,y,d);
p = [dpx dpy];
tri=delaunay(dpx,dpy);
botz=tinterp(p,tri,dpz,xg,yg,'quadratic');

nt=length(t);

vcrs=zeros(ny,nx,nt);

%% Determine offshore currents

for it=1:nt

%    disp(['Processing time step ' num2str(it) ' of ' num2str(nt) ' ...']);
    
    [ux,uy,uz]=vec(x,y,squeeze(u(it,:,:)));
    [vx,vy,vz]=vec(x,y,squeeze(v(it,:,:)));
    [hx,hy,hz]=vec(x,y,squeeze(h(it,:,:)));

    p = [dpx dpy];
    tri=delaunay(dpx,dpy);

    uu=tinterp(p,tri,uz,xg,yg,'quadratic');
    vv=tinterp(p,tri,vz,xg,yg,'quadratic');

    p = [hx hy];
    tri=delaunay(hx,hy);
    hh=tinterp(p,tri,hz,xg,yg,'quadratic');

    dep=hh-botz;
    
    uu(dep>dmax)=0;
    vv(dep>dmax)=0;
    uu(dep<dmin)=0;
    vv(dep<dmin)=0;

    vcrs0 =  uu .* cos(rot) + vv .* sin(rot); % Positive in x direction
    
    vcrs(:,:,it)=-vcrs0;

end

%% Maximum offshore currents
vcrsmax=zeros(ny,nt);
for it=1:nt
    vcrsmax0 = max(squeeze(vcrs(:,:,it)),[],2);
    vcrsmax(:,it) = vcrsmax0;
end

%% Coordinates of maximum offshore currents
for i=1:ny
    v=max(squeeze(vcrs(i,:,:)),[],2);
    vmax=max(max(squeeze(vcrs(i,:,:))));
    j=find(v==vmax);
    if ~isempty(j)
        xcor(i)=xg(i,j(1));
        ycor(i)=yg(i,j(1));
    else
        xcor(i)=NaN;
        ycor(i)=NaN;
    end
end

%% Warning Levels
warningLevel=zeros(1,nt);
for it=1:nt
    vmax=max(vcrsmax(:,it));
    warningLevel(it)=0;
    for i=1:length(warningLevels)
        if vmax>warningLevels(i)
            warningLevel(it)=i;            
        end
    end
end

%% Find individual rip currents
vmin=warningLevels(1);
iin=0;
n=0;
for i=1:ny
    vmax=max(vcrsmax(i,:));
    if vmax>vmin && iin==0
        % New rip channel found
        n=n+1;
        rind1(n)=i;
        rind2(n)=i;
        iin=1;
    elseif vmax>vmin && iin==1
        % Existing rip channel
        rind2(n)=i;
    else
        iin=0;
    end
end
nrRips=n;

%% Coordinates of individual rip currents
for i=1:nrRips
    rips(i).x=0.5*(xcor(rind1(i))+xcor(rind2(i)));
    rips(i).y=0.5*(ycor(rind1(i))+ycor(rind2(i)));
end

%% Time series in individual rip currents
for it=1:nt
    for i=1:nrRips
        rips(i).t(it)=t(it);
        rips(i).vmax(it)=max(max(vcrs(rind1(i):rind2(i),:,it)));
    end
end

%% Warning levels per rip
for i=1:nrRips
    if max(rips(i).vmax)<warningLevels(2)
        rips(i).warningLevel=1;
    elseif max(rips(i).vmax)<warningLevels(3)
        rips(i).warningLevel=2;
    else
        rips(i).warningLevel=3;
    end
end
    
function [xv,yv,zv]=vec(x,y,z)

dpx=reshape(x,[size(x,1)*size(x,2) 1]);
dpy=reshape(y,[size(y,1)*size(y,2) 1]);
dpz=reshape(z,[size(z,1)*size(z,2) 1]);

inan=~isnan(dpx);
inan=min(inan,~isnan(dpy));
inan=min(inan,~isnan(dpz));

dpx=dpx(inan);
dpy=dpy(inan);
dpz=dpz(inan);

xv=dpx(~isnan(dpx));
yv=dpy(~isnan(dpy));
zv=dpz(~isnan(dpz));
