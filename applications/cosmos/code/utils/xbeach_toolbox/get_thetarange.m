function [thetamin,thetamax]=get_thetarange(out2d,hthreshold)

% This program reads in the structure of 2d spectral data and alfa and
% calculates thetamin and thetamax for input into the params.txt file.

%   Inputs:
%     hthreshold = threshold wave height value to search for directional
%     range (this is converted to S and all cells with energy less than
%     this value are not considered).
%     out2d = timeseries of output 2D spectral data stored in the following
%             format.
%     out2d = array with 2D spectral data
%     out2d.t = matlab datenumber
%     out2d.f = frequencies 
%     out2d.d = directions 
%     out2d.s = variance densities,
%     size(out2d.s) = [length(out2d.f) length(out2d.dir) length(out2d.time)]     

%   Outputs:
%     thetamin = minimum angle in Cartesian coordinate system for input
%     into params.txt assuming thetanaut=1 (ex: ' 250)
%     thetamax = maximum angle in XBeach coordinate system for input into
%     params.txt assuming thetanaut=1 (ex: '290')

% Pick the minimum S value to use from the wave height threshold
dirres=abs(out2d.d(2)-out2d.d(1));
df=abs(out2d.f(2)-out2d.f(1));
if hthreshold>0
    Smin=((hthreshold/4)^2)/(dirres.*df);
else
    Smin = 0;
end

% Estimate the range of angles from the timeseries of 2d spectra
for jj=1:length(out2d.t)
    for kk=1:length(out2d.f)
        tmin1(kk)=min(out2d.d(out2d.s(kk,:,jj)>Smin));
        tmax1(kk)=max(out2d.d(out2d.s(kk,:,jj)>Smin));
    end
	tmin(jj)=min(tmin1);
    tmax(jj)=max(tmax1);
end

thetamin=min(tmin);
thetamax=max(tmax);



