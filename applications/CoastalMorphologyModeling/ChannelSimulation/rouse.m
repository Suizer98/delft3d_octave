function [z,c,cmean]=rouse(a,ca,h,ws,ustar,alpha)
kappa=0.4;n=100;
dz=(h-a)/n;
z=-h+a:dz:0;
c=ca*((z+h)/a.*(a-h)./z).^(-alpha*ws/kappa/ustar);
cmean=sum( (z(2:end)-z(1:end-1)).*(c(1:end-1)+c(2:end)) )/2/(h-a);
