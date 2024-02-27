% Bilinear interpolation (neigbouring NaNs avoided)
% in point xt,yt
% x(n),y(m) - coordinates for h(n,m)
% xt(N),yt(N) - coordinates for interpolated values
% Global case is not considered
%
% Last update: January 3, 2006
%
%========================================================================

function [hi]=BLinterp(x,y,h,xt,yt);
dx=x(2)-x(1);dy=y(2)-y(1);
inan=find(isnan(h)>0);
h(inan)=0;
mz=(h~=0);
n=length(x);m=length(y);
[n1,m1]=size(h);
if n~=n1 | m~=m1,
 fprintf('Check dimensions\n');
 hi=NaN;
 return
end
[X,Y]=meshgrid(x,y);
q=1/(4+2*sqrt(2));q1=q/sqrt(2);
h1=q1*h(1:end-2,1:end-2)+q*h(1:end-2,2:end-1)+q1*h(1:end-2,3:end)+...
   q1*h(3:end,1:end-2)+q*h(3:end,2:end-1)+q1*h(3:end,3:end)+...
   q*h(2:end-1,1:end-2)+q*h(2:end-1,3:end);
mz1=q1*mz(1:end-2,1:end-2)+q*mz(1:end-2,2:end-1)+q1*mz(1:end-2,3:end)+...
   q1*mz(3:end,1:end-2)+q*mz(3:end,2:end-1)+q1*mz(3:end,3:end)+...
   q*mz(2:end-1,1:end-2)+q*mz(2:end-1,3:end);
mz1(find(mz1==0))=1;
h2=h;
h2(2:end-1,2:end-1)=h1./mz1;
ik=find(mz==1);
h2(ik)=h(ik);
h2(find(h2==0))=NaN;
hi=interp2(X,Y,h2',xt,yt);hi=conj(hi);
return
