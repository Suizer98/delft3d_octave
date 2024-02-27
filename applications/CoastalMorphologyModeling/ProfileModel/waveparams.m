function [k,omega,c,cg,n,Dw,Qb,Dr,dir]=waveparams(h,t,E,gamma,beta,Er,dir0,c0)
g=9.81;
rho=1025;
fac=8/rho/g;
alpha=1;
opt=3;

H=sqrt(fac*E);
a1 = 5.060219360721177D-01; a2 = 2.663457535068147D-01;
a3 = 1.108728659243231D-01; a4 = 4.197392043833136D-02;
a5 = 8.670877524768146D-03; a6 = 4.890806291366061D-03;
b1 = 1.727544632667079D-01; b2 = 1.191224998569728D-01;
b3 = 4.165097693766726D-02; b4 = 8.674993032204639D-03;

pi    = 4.0 .* atan ( 1.0);
ome2  = (2.0 .* pi ./ t).^2 .*  (h) ./  (g);

num  = 1.0 + ome2.*(a1+ome2.*(a2+ome2.*(a3+ome2.*(a4+ome2.*(a5+ome2.*a6)))));
den  = 1.0 + ome2.*(b1+ome2.*(b2+ome2.*(b3+ome2.*(b4          +ome2.*a6 ))));
k   = sqrt ( ome2 .* num ./ den) ./  h;

omega=2*pi./t;
c=omega./k;
if c0==0
    c0=c(1);
end
%c0=g/omega;
kh=k.*h;
tkh=tanh(kh);
cg=g/2./omega.*(tkh+kh.*(1.-tkh.*tkh));
n=cg./c;
%
dir=asin(sin(dir0).*c/c0);
%
% Compute dissipation according to Baldock
Hmax=0.88./k.*tanh(gamma.*k.*h/0.88);
Qb=exp(-(Hmax./H).^2);
if opt==1
    Dw=0.25*alpha*rho*g./t.*Qb.*(Hmax.^2+H.^2);
else
    Dw=0.25*alpha*rho*g./t.*Qb.*(Hmax.^3+H.^3)./gamma./h;
end
% Compute roller dissipation
Dr=2.*beta*g.*Er./c;
