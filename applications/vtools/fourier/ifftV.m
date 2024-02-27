%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: ifftV.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/ifftV.m $
%
%INPUT
%
%E.G.
%   [fx,fy,P2]=fftV(x,y,noise);
%   noise_rec=ifftV(x,v,P2);




function [varargout]=ifftV(varargin)

%% PARSE

ni=numel(varargin);
if mod(ni,2)==0 %there are 2 input plus pair-input argument
    x=varargin{1,1};
    P2=varargin{1,2};
    if ni>2
        varargin_pi=varargin{3:end};
    end
    is1d=1;
    y=42; %by giving it one value, dy qill be empty but ny=1
elseif mod(ni-3,2)==0 %there are 3 input plus pair-input argument
    x=varargin{1,1};
    y=varargin{1,2};
    P2=varargin{1,3};
    if ni>3
        varargin_pi=varargin{4:end};
    end
    is1d=0;
else
    error('Input number does not match expectations.');
end

%% CALC

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);

[x_in,y_in]=meshgrid(x,y);
nx=numel(x);
ny=numel(y);
nmx=numel(fx2); %same as nx if double-sided spectrum
nmy=numel(fy2); %same as ny if double-sided spectrum

noise_rec_m=NaN(1,nx,ny,1,nmx,nmy); %[eigenvalue, x, y, time, mode x, mode y]
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        cx_fou=P2(kmy,kmx);
        noise_loc=cx_fou*exp(1i*kx_fou*x_in).*exp(1i*ky_fou*y_in);
        noise_rec_m(1,:,:,1,kmx,kmy)=noise_loc';
    end
    fprintf('%4.2f %% \n',kmx/nmx*100);
end
noise_rec=sum(noise_rec_m,[5,6]);
noise_rec_2d=real(squeeze(noise_rec)');

%% OUT

varargout{1,1}=noise_rec_2d;
varargout{1,2}=noise_rec;

end %function