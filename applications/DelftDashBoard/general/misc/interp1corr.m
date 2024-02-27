function y1=interp1corr(x0,y0,x1)

% First get rid of double points in x0
dx=x0(2:end)-x0(1:end-1);
isame=zeros(size(x0))+1;
ii=find(dx<1e-3)+1;
isame(ii)=0;
x0=x0(isame==1);
y0=y0(isame==1);

y1=interp1(x0,y0,x1);
