function [xmin,xmax,dx]=roundlimits(xmin,xmax)
dx=xmax-xmin;
order=floor(log10(dx));
xmin=10^(order-1)*floor(xmin/10^(order-1));
xmax=10^(order-1)*ceil(xmax/10^(order-1));

dx=(xmax-xmin)/10;

n=0;
for ii=-10:10
    n=n+1;
    v(n)=10^ii;    
    n=n+1;
    v(n)=2*10^ii;
    n=n+1;
    v(n)=5*10^ii;    
end
ii=find(v<dx,1,'last');
dx=v(ii);
