function [k] = dispersion(h,T)
% Really stupid and inefficient routine to solve dispersion relation
g=9.81;
omega=2*pi/T;
k0=g/omega;
k=k0;kold=1000;
niter=0;
while abs(k-kold)>0.00001;
   niter=niter+1;
   kold=k;
   k=omega^2/g/tanh(kold.*h);
end
