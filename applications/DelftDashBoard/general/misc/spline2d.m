function [xs2,ys2]=spline2d(xp,yp,varargin)
% Generates spline in xy spaces with equidistant points

dx=[];
cstype='projected';

if nargin>2
    dx=varargin{1};
end

if nargin>3
    cstype=varargin{2};
end

if length(xp)<2
    xs2=xp;
    ys2=yp;
    return
end

if size(xp,1)==1
    % Column vector
    xy=[xp;yp];
else
    xy=[xp';yp'];
end

np=20;
n=length(xp);

t=1:n;
ts=1:(1/np):n;
xys=spline(t,xy,ts);

xs=xys(1,:);
ys=xys(2,:);

pd0=pathdistance(xs,ys,cstype);
if isempty(dx)
    dx=(pd0(end)/(np*n));
end
pd=0:dx:pd0(end);

xs2=interp1(pd0,xs,pd);
ys2=interp1(pd0,ys,pd);
