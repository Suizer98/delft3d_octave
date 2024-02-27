%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18312 $
%$Date: 2022-08-19 14:16:54 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fftV.m 18312 2022-08-19 06:16:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fftV.m $
%
%Wrap aroun Fast Fourier Transform
%
%INPUT:
%   For 1D:
%       -x = independent variable; double, [1,nx];
%       -z = dependent variable; double, [1,ny];
%
%   For 2D:
%       -x = independent variable; double, [1,nx];
%       -y = independent variable; double, [1,ny];
%       -z = dependent variable; double, [ny,nx];
%
%OUTPUT:
%   If 1D:
%       -f2 = double-sided frequency [1/unit(X)]
%       -f1 = single-sided frequency [1/unit(X)]
%TO DO:
%	-Check that everything works in 1D
%
%E.G. 2D
%   [fx2,fy2,P2,fx1,fy1,P1]=fftV(x,y,z)
%
%E.G. 1D
%   [f2,P2,f1,P1]=fftV(x,z)

function [varargout]=fftV(varargin)

%% PARSE

ni=numel(varargin);
if mod(ni,2)==0 %there are 2 input plus pair-input argument
    x=varargin{1,1};
    z=varargin{1,2};
    if ni>2
        varargin_pi=varargin{3:end};
    end
    is1d=1;
    y=42; %by giving it one value, dy qill be empty but ny=1
elseif mod(ni-3,2)==0 %there are 3 input plus pair-input argument
    x=varargin{1,1};
    y=varargin{1,2};
    z=varargin{1,3};
    if ni>3
        varargin_pi=varargin{4:end};
    end
    is1d=0;
else
    error('Input number does not match expectations.');
end

%% CALC

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);

nx=numel(x);
ny=numel(y);

if any(size(z)~=[ny,nx])
    error('dimensions of z incorrect.')
end

if is1d
    error('try calling only fft2')
    zf=fft(z); 
else
    zf=fft2(z); 
end

zf_shift=fftshift(zf);

%single-sided
% P2a=zf/nx; %without shift
% P1=P2a(1:nx/2+1);
% P1(2:end-1)=2*P1(2:end-1);

%double-sided
P2=zf_shift/nx/ny;

if is1d
    varargout{1,1}=fx2;
    varargout{1,2}=P2;
else
    varargout{1,1}=fx2;
    varargout{1,2}=fy2;
    varargout{1,3}=P2;
end

end %function