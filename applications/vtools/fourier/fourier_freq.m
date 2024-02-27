%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18334 $
%$Date: 2022-08-25 17:30:40 +0800 (Thu, 25 Aug 2022) $
%$Author: chavarri $
%$Id: fourier_freq.m 18334 2022-08-25 09:30:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_freq.m $
%
%Compute frequencies of FFT
%
%INPUT:
%	-x   = independent variable; double, [1,nx];
%   -y   = independent variable; double, [1,ny];
%
%OUTPUT:
%	-dx  = step in x direction; double, [1,1];
%	-fx2 = double-sided frequency in x direction; double, [1,nx];
%	-fx1 = single-sided frequency in x direction; double, [1,nx/2+1];
%	-dy  = step in y direction double, [1,1];
%	-fy2 = double-sided frequency in y direction; double, [1,ny];
%	-fy1 = single-sided frequency in y direction; double, [1,ny/2+1];

function [dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y)

dx=get_dy(x);
dy=get_dy(y);

if isinf(dx) && isinf(dy)
    error('at least one dimension larger than 1')
end

fsx=1/dx; %sampling frequency
fsy=1/dy; %sampling frequency

nx=numel(x);
ny=numel(y);

fx1=fsx*(0:(nx/2))/nx; 
fy1=fsy*(0:(ny/2))/ny; 

fx2=(-nx/2:nx/2-1)*(fsx/nx);
fy2=(-ny/2:ny/2-1)*(fsy/ny);

end %function

%%
%% FUNCTIONS
%%

function dy=get_dy(y)

y_diff=diff(y);
if isempty(y_diff) %1D in y
    dy=Inf;
else
    dy=y_diff(1);
    if any(y_diff-dy)
        error('space step must be constant.')
    end
end

end
