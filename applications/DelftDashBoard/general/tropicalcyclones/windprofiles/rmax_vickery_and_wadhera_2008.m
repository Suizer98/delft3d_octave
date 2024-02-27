function rmax=rmax_vickery_and_wadhera_2008(pn,pc,psi)
% Returns rmax (in km) according to Vickery and Wadhera (2008)
%pc=923;
%pn=1012;
%dp=pn-pc;
%psi=29;
% e.g.
dp=pn-pc;
rmax=exp(3.015-6.291e-5*dp.^2+0.0337*abs(psi));
%ln(rmax)=3.015-6.291e-5*dp^2+0.0337*psi
