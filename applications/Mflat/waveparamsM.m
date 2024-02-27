function [k,omega,c,cg,n,Dw,Qb,Dr,dir,fw,tau_w,Df,Sw]=waveparamsM(h,t,E,gamma,beta,Er,dir0,c0,kb,u10)

%WAVEPARAMSM calculates wave parameters incl frictionparameter, dissipation by breaking and friction and wind
%growth
%
%   See also runMflat.m Mflat.m Mflat_output.m balanceM.m 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 IHE 
%       mvw
%
%       m.vanderwegn@un-ihe.org
%
%       IHE Delft Institute for Water Education,
%       PO Box 3015, 2601 DA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Jul 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: $
% $Date: $
% $Author: Dano Roelvink and Mick van der Wegen $
% $Revision: $
% $HeadURL: $
% $Keywords: mudflat morphodynamics$


g=9.81;
rho=1025;
fac=8/rho/g;
alpha=1;
fw_lim=0.8; % no fw>fw_lim
opt=1;%1 =Baldock and 3=Battjes-Jansen

H=sqrt(fac*E);
a1 = 5.060219360721177D-01; a2 = 2.663457535068147D-01;
a3 = 1.108728659243231D-01; a4 = 4.197392043833136D-02;
a5 = 8.670877524768146D-03; a6 = 4.890806291366061D-03;
b1 = 1.727544632667079D-01; b2 = 1.191224998569728D-01;
b3 = 4.165097693766726D-02; b4 = 8.674993032204639D-03;

c1f=0.24;% fully developed Hs
c2f=7.69;% fully developed Tp
a1f=2.88*10^-3; % wind: van der lugt, tabel 2.2
b1f=0.45;% wind: van der lugt, tabel 2.2


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
kh=k.*h;
tkh=tanh(kh);
cg=g/2./omega.*(tkh+kh.*(1.-tkh.*tkh));
n=cg./c;
%
dir=asin(sin(dir0).*c/c0);
%
% Compute dissipation according to Baldock
Hmax=0.88./k.*tanh(gamma.*k.*h/0.88);
Qb=exp(-(Hmax./H).^2);% should be implicit pp14?
if opt==1
    Dw=0.25*alpha*rho*g./t.*Qb.*(Hmax.^2+H.^2);
else
    Dw=0.25*alpha*rho*g./t.*Qb.*(Hmax.^3+H.^3)./gamma./h;
end
if opt==3
    Dw=0.25*alpha*rho*g./t.*Qb.*(Hmax.^2);%Battjes Jansen pp14
end

%% calculate fw
u_orb=0.25*sqrt(pi)*H.*2*pi./t./sinh(kh); % d3d user manual eq. 9.204 assume omega =constant along profile
u_orb(isnan(u_orb)==1)=0;
%fw=1.39*(u_orb/(omegaw*ks/33)).^(-0.52); % see 3.35 in Roelvink&Reiniersdoe not work : too much ssc
AA= u_orb.*t/2/pi();% Nielsen(1992) in Lacy(2014)
% kb=0.011;% see Lacy(2014) for San Pablo Bay in winter: 0.0035
fw =exp(5.213*((kb./AA).^0.194)-5.977);
% fw=fw.*wwet;% no fw at dry cells
fw(fw>=fw_lim)=fw_lim;% no fw > fw_lim
tau_w=fw.*(u_orb.^2).*0.5*rho;

% u_rms=0.5*omega*H./(sinh(kh)); %from xbeach manual
u_rms=H.*pi./t./sinh(kh)./sqrt(2); % dano
Df=rho*fw*(abs(u_rms))^3;
% Compute roller dissipation
Dr=2.*beta*g.*Er./c;% not really needed

% Fully developed state
% u10=sqrt(g*H/c1f);
tfull=c2f*u10/g;
Sw=cg*rho*u10^2/((16/(2*a1f^2*b1f))*(16*g*E/(rho*u10^4*a1f^2))^(1/(2*b1f)-1));


