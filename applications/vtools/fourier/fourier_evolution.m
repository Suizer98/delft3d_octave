%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18312 $
%$Date: 2022-08-19 14:16:54 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fourier_evolution.m 18312 2022-08-19 06:16:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_evolution.m $
%
%Compute evolution of fourier coefficients
%
%INPUT:
%	-x      = independent variable; double, [1,nx];
%   -y      = independent variable; double, [1,ny];
%   -t      = independent variable; double, [1,nt];
%   -P2     = double-sided Fourier coefficients weighted by number of modes; double, [ny,nx];
%	-R      = right eigenvectors matrix; double, [ne,ne,nx,ny]
%	-omega  = eigenvalues vector [ne,nx,ny]
%	-dim_in = dimension (i.e., equation number) in which the initial perturbation is applied; double, [1,1]
%
%OUTPUT:
%	-Q      = solution for all modes; double, [ne,nx,ny,nt,nx,ny];
%	-Q_rec  = solution adding modes; double, [ne,nx,ny,nt];

function [Q,Q_rec]=fourier_evolution(x,y,t,P2,R,omega,dim_ini,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'full',1);

parse(parin,varargin{:});

do_full=parin.Results.full;

%% CALC

%% domain

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);
[x_in,y_in]=meshgrid(x,y);

ne=size(R,1);
nx=numel(x);
ny=numel(y);
nt=numel(t);
nmx=numel(fx2);
nmy=numel(fy2);

%% evolution

%preallocate
if do_full
    Q=NaN(ne,nx,ny,nt,nmx,nmy); %getting information for each mode, much more memory required
else
    Q=NaN;
    Q_rec=zeros(ne,nx,ny,nt); %already summing up the modes
end

%loop
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        cx_fou=P2(kmy,kmx);
        
        d=zeros(ne,1);
        d(dim_ini)=cx_fou;
        
        a=R(:,:,kmx,kmy)\d;

        for kt=1:nt
            b=NaN(ne,1);
            for ke=1:ne
                b(ke)=a(ke)*exp(-1i*omega(ke,kmx,kmy)*t(kt));
            end %ke
            c=R(:,:,kmx,kmy)*b;
            for ky=1:ny
                e=real(c*exp(1i*kx_fou*x_in(ky,:)).*exp(1i*ky_fou*y_in(ky,:)));
                if do_full
                    Q(:,:,ky,kt,kmx,kmy)=e;
                else
                    Q_rec(:,:,ky,kt)=Q_rec(:,:,ky,kt)+e;
                end
            end %ky
        end %kt
    end %kmy
    fprintf('mode %4.2f %% \n',kmx/nmx*100);
end %kmx

if do_full
    Q_rec=sum(Q,[5,6]);
end

end %function