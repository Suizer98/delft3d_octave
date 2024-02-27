%secondary_flow computes the extra terms due to secondary flow
%
%INPUT:
%   -
%
%OUTPUT:
%   -[Txx,Txy,Tyy] shear stress per unit mass and volume along the fow depth in the direction x-y [m3/s2]
%
%NOTES:
%
%HISTORY:
%161024
%   -V. Created for the first time.
%
%161024->161215
%   -V. Added alpha as output.

function [Txx,Txy,Tyy,alpha,LI,Ssxx,Ssyx,Ssxy,Ssyy,beta_st]=secondary_flow(flg,cnt,q,cf,I,beta_c,h)
%comment out fot improved performance if the version is clear from github
% version='2';
% if kt==1; fprintf(fid_log,'function_name version: %s\n',version); end 

q_m=norm(q);

alpha=sqrt(cf)/cnt.k;
alpha(alpha>0.5)=0.5;

beta_st=beta_c*(5*alpha-15.6*alpha^2+37.5*alpha^3);

Txx=-2*beta_st*I*q(1)*q(2)/q_m;
Txy=beta_st*I*(q(1)^2-q(2)^2)/q_m;
Tyy=-Txx;

LI=(1-2*alpha)/(2*cnt.k^2*alpha);
% Las=1.3/sqrt(cf);

calib=1; %this is simply to desactivate secondary flow with the same parameter, no physical sense whatsoever
Ss_fac=calib*1/q_m/h^2/LI;

Ssxx=Ss_fac*(-q(1)*q(2));
Ssyx=Ss_fac*( q(1)^2);
Ssxy=Ss_fac*(-q(2)^2);
Ssyy=Ss_fac*( q(1)*q(2));
end %function
