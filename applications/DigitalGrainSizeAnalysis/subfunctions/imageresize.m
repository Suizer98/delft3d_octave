

function img_out=imageresize(img_in, rowScale, colScale);
%IMAGERESIZE Resize image 
%   IMAGERESIZE resize an image to any scale. 
%   This is a simple implementation of IMRESIZE.
%   Example:
%            imin   = imread('cameraman.tif');
%            imoutL = imageresize(imin, 2, 2); % enlarge image
%            imoutS = imageresize(imin, 0.2, 0.2) % shrink image
% 
% Written by Daniel Buscombe, various times in 2012 and 2013
% while at
% School of Marine Science and Engineering, University of Plymouth, UK
% then
% Grand Canyon Monitoring and Research Center, U.G. Geological Survey, Flagstaff, AZ 
% please contact:
% dbuscombe@usgs.gov
% for lastest code version please visit:
% https://github.com/dbuscombe-usgs
% see also (project blog):
% http://dbuscombe-usgs.github.com/
%====================================
%   This function is part of 'dgs-gui' software
%   This software is in the public domain because it contains materials that originally came 
%   from the United States Geological Survey, an agency of the United States Department of Interior. 
%   For more information, see the official USGS copyright policy at 
%   http://www.usgs.gov/visual-id/credit_usgs.html#copyright
%====================================
[row col]=size(img_in);

img_out=zeros(floor(row*rowScale),floor(col*colScale));
for i=1:floor(row*rowScale)
    for j=1:floor(col*colScale)
        img_out(i,j)=img_in(ceil(1/rowScale * i), ceil(1/colScale * j));
    end
end
