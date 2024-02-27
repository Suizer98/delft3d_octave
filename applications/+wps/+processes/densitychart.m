function [ image ] = densitychart( timeseries )
%DENSITYCHART Summary of this function goes here
%   Detailed explanation goes here

% input:
% timeseries = application/netcdf

% output:
% image = image/png

% TODO:
% call: timeseries

fig = gcf();
% filename
ext = '.png';
dirname = tempname();
mkdir(dirname);
image = fullfile(dirname,  ['image',  ext]);

plot(rand(100, 1), rand(100,1), 'k.');
print(fig, '-dpng', image);
close();
end

