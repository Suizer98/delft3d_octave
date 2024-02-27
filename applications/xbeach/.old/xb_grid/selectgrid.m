function XB = selectgrid(xw, yw, Zbathy, varargin)
% XBEACH_SELECTGRID grid generator for XBeach



% default Input section
OPT = struct(...
    'dx', 2,...
    'dy', 2,...
    'dryval', 10,...
    'maxslp', .2,...
    'seaslp', .02,...
    'deepval', -10,...
    'dxmax', 20,...
    'dxmin', 2,...
    'dymax', 50,...
    'dymin', 10,...
    'finepart', 0.3);

figure(1);
scatter(xw,yw,5,Zbathy,'filled');
axis([min(xw)-.5*(max(xw)-min(xw)) ...
    max(xw)+.5*(max(xw)-min(xw)) ...
    min(yw)-.5*(max(yw)-min(yw)) ...
    max(yw)+.5*(max(yw)-min(yw)) ])
axis equal
colorbar
hold on
% Initially, the list of points is empty.
xi = [];yi=[];
n = 0;
% Loop, picking up the points.
disp('Click grid corner x=0,y=0')
disp('Then click point x=xn,y=0')
disp('Finally click to select extent of y')
but = 1;
while but == 1&n<3
    n = n+1;
    [xi(n),yi(n),but] = ginput(1);
    plot(xi,yi,'r-o')
end
xori=xi(1);yori=yi(1);
alfa=atan2(yi(2)-yi(1),xi(2)-xi(1));
Xbathy= cos(alfa)*(xw-xori)+sin(alfa)*(yw-yori);
Ybathy=-sin(alfa)*(xw-xori)+cos(alfa)*(yw-yori);
xn= cos(alfa)*(xi(2)-xori)+sin(alfa)*(yi(2)-yori);
yn=-sin(alfa)*(xi(3)-xori)+cos(alfa)*(yi(3)-yori);
figure(2);
scatter(Xbathy,Ybathy,5,Zbathy,'filled');axis equal;colorbar;hold on
plot([0 xn xn 0 0],[0 0 yn yn 0],'r-')
% Select polygon to include in bathy
xi = [];yi=[];
n = 0;
% Loop, picking up the points.
disp('Select polygon to include in bathy')
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;
while but == 1
    n = n+1;
    [xi(n),yi(n),but] = ginput(1);
    plot(xi,yi,'r-o');
end
xx=[0:OPT.dx:xn];
yy=[0:OPT.dy:yn];
for j=1:length(yy)
    X(:,j)=xx;
end
for i=1:length(xx)
    Y(i,:)=yy;
end
% Interpolate to grid
in=inpolygon(X,Y,xi,yi);
Z=zeros(size(X));
Z(in)=griddata(Xbathy,Ybathy,Zbathy,X(in),Y(in));
% Exclude points not in polygon
Z(~in)=nan;

figure(3);
surf(X,Y,Z);shading interp;colorbar

% Extrapolate to sides
m=size(X,1);n=size(X,2);
for i=1:m
    for j=floor(n/2):n
        if isnan(Z(i,j))
            Z(i,j)=Z(i,j-1);
        end
    end
    for j=floor(n/2)-1:-1:1
        if isnan(Z(i,j))
            Z(i,j)=Z(i,j+1);
        end
    end
end
for j=1:n
    % Extrapolate to land
    for i=floor(m/2):m
        if isnan(Z(i,j));
            Z(i,j)=min(Z(i-1,j)+maxslp*OPT.dx,OPT.dryval);
        end
    end
    % Extrapolate to sea
    for i=floor(m/2):-1:1
        if isnan(Z(i,j));
            Z(i,j)=max(Z(i+1,j)-seaslp*OPT.dx,deepval);
        end
    end
end
figure(4);
surf(X,Y,Z);shading interp;colorbar

xnew=zeros(m,1);
dnew=zeros(1,n);
yrefine=[0 0.5-finepart/2 0.5+finepart/2 1]*Y(1,end);
dyrefine=[dymax dymin dymin  dymax]
d0=-mean(Z(1,:));
i=1
xnew(1)=X(1,1);
while xnew(i)<X(end,1);
    for j=1:n
        dnew(j)=interp1(X(:,j),Z(:,j),xnew(i));
    end
    d=-min(dnew)
    dxnew=max(dxmax*sqrt(max(d,.1)/d0),dxmin);
    i=i+1;
    xnew(i)=xnew(i-1)+dxnew;
end
mnew=i-1
ynew=zeros(1,n)
i=1
while ynew(i)<Y(1,end);
    dynew=interp1(yrefine,dyrefine,ynew(i));
    i=i+1;
    ynew(i)=ynew(i-1)+dynew;
end
nnew=i-1
for j=1:nnew
    for i=1:mnew
        Xnew(i,j)=xnew(i);
        Ynew(i,j)=ynew(j);
    end
end
Znew=interp2(X',Y',Z',Xnew,Ynew);
figure(5)
pcolor(Xnew,Ynew,Znew);axis equal

fi=fopen('bathy.dep','wt');
for j=1:nnew
    fprintf(fi,'%7.3f ',Znew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);

fi=fopen('x.dep','wt');
for j=1:nnew
    fprintf(fi,'%7.3f ',Xnew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);

fi=fopen('y.dep','wt');
for j=1:nnew
    fprintf(fi,'%7.3f ',Ynew(:,j));
    fprintf(fi,'\n');
end
fclose(fi);

fi=fopen('griddata.txt','wt');
fprintf(fi,'nx      = %3i \n',mnew-1);
fprintf(fi,'ny      = %3i \n',nnew-1);
fprintf(fi,'dx      = %6.1f \n',OPT.dx);
fprintf(fi,'dy      = %6.1f \n',OPT.dy);
fprintf(fi,'xori    = %10.2f \n',xori);
fprintf(fi,'yori    = %10.2f \n',yori);
fprintf(fi,'alfa    = %10.2f \n',alfa*180/pi);
fprintf(fi,'depfile = bathy.dep \n')
fprintf(fi,'vardx   = 1 \n')
fprintf(fi,'xfile = x.dep \n')
fprintf(fi,'yfile = y.dep \n')
fprintf(fi,'posdwn  = -1 \n')
fclose(fi);

