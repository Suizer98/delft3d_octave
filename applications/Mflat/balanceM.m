function [E,Hrms,Er,Qb,Dw,Dr,k,C,Cg,dir,Fx,Fy,fw,tau_w]= ...
    balanceM(Hrms0,dir0,eta0,Tp,x,zb,gamma,gammax,beta,hmin,ht,kb,u10)

%BALANCEM Solve 1D wave energy, roller energy and cross-shore momentum
% balance , yielding cross-shore distribution of wave height and energym,
% roller energy, water level and longshore component of radiation stress
% gradient and wave induced shearstress.
%
%   See also runMflat.m Mflat.m Mflat_output.m waveparamsM.m

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

rho=1025;g=9.81;eps=1e-6;
%% Initialise arrays
% eta=zeros(size(x));
E=zeros(size(x));
Hrms=zeros(size(x));
Er=zeros(size(x));
Qb=zeros(size(x));
Dw=zeros(size(x));
Df=zeros(size(x));
Sw=zeros(size(x));
Dr=zeros(size(x));
eta=zeros(size(x));
h=zeros(size(x));
k=zeros(size(x));
C=zeros(size(x));
Cg=zeros(size(x));
dir=zeros(size(x));
Fx=zeros(size(x));
Fy=zeros(size(x));
fw=zeros(size(x));
tau_w=zeros(size(x));
%% Set boundary conditions
E(1)=1/8*rho*g*Hrms0^2;
c1f=0.24;
Hrmsmax=c1f*u10^2/g;
Emax=1/8*rho*g*Hrmsmax^2;% waves do no grow more by wind
Hrms(1)=Hrms0;
Er(1)=0;
% eta(1)=eta0;
% h(1)=eta(1)-zb(1);
ix=1;
C0=0;
[k(ix),omega,C(ix),Cg(ix),n(ix),Dw(ix),Qb(ix),Dr(ix),dir(ix),fw(ix),tau_w(ix),Df(ix),Sw(ix)]= ...
    waveparamsM(ht(ix),Tp,E(ix),gamma,beta,Er(ix),dir0,C0,kb,u10);
C0=C(1);
nx=length(x);
%% Start loop in x-direction
for ix=2:nx
    % First estimate of eta(i+1),E(i+1),Er(i+1)
%     eta(ix)=eta(ix-1);
    E(ix)=E(ix-1);
    Er(ix)=Er(ix-1);
    dx=x(ix)-x(ix-1);
    %% Two-step integration scheme
    for step=1:2;
%         h(ix)=eta(ix)-zb(ix);
        %% Check if h>hmin; otherwise leave parameters zero
        if ht(ix)>hmin
            %% Local functions
            [k(ix),omega,C(ix),Cg(ix),n(ix),Dw(ix),Qb(ix),Dr(ix),dir(ix),fw(ix),tau_w(ix),Df(ix),Sw(ix)]= ...
                waveparamsM(ht(ix),Tp,E(ix),gamma,beta,Er(ix),dir0,C0,kb,u10);
            %% Wave energy
            E(ix)=E(ix-1)*Cg(ix-1)*cos(dir(ix-1))/dx/(Cg(ix)*cos(dir(ix))/dx+(Dw(ix-1)+Df(ix-1)-Sw(ix-1))/E(ix-1));% implicit by Dano
            if E(ix)>= Emax %no wind growth
                E(ix)=E(ix-1)*Cg(ix-1)*cos(dir(ix-1))/dx/(Cg(ix)*cos(dir(ix))/dx+(Dw(ix-1)+Df(ix-1))/E(ix-1));
            end
            %E(i)=min(E(i),1/8*rho*g*h(i)^2);
            E(ix)=max(E(ix),eps);
            E(ix)=min(E(ix),.125*rho*g*(gammax*ht(ix))^2);
            %% Roller energy
            Er(ix)=(Er(ix-1)*C(ix-1)*cos(dir(ix-1))...
                +.5*(Dw(ix-1)+Dw(ix)-Dr(ix-1)-Dr(ix))*dx)...
                /(C(ix)*cos(dir(ix))); 
            Er(ix)=max(Er(ix),eps);
            %% Wave force in x-direction
            Fx(ix)=-(   (n(ix)*(cos(dir(ix)))^2+n(ix)-.5)*E(ix)...
                - (n(ix-1)*(cos(dir(ix-1)))^2+n(ix-1)-.5)*E(ix-1)...
                + (cos(dir(ix)))^2*Er(ix)...
                - (cos(dir(ix-1)))^2*Er(ix-1))/dx;
%             eta(ix)=eta(ix-1)+2*Fx(ix)/rho/g/(ht(ix-1)+ht(ix))*dx;
            %% Wave force in y-direction
            Fy(ix)=Dr(ix)*sin(dir(ix))/C(ix);
            Hrms(ix)=sqrt(8*E(ix)/rho/g);
        end
    end
end
dd=3;
