%======================================
function [pd,gm,am]=gsdparams(d,sizes)
% function to compute grain size distribution parameters
%
% INPUTS
% d = grain size distribution;
% sizes = grain size vector
%
% OUTPUTS
% pd - 7 element vector of percentiles (5,16,25,50,75,84,95)
% gm - 4 element vector of geometric mean, sorting, skewness, and kurtosis,
% as given by Folk and Ward (1957)
% am - 4 element vector of arithmetic moments: mean, sorting, skewness, and
% kurtosis
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

d=d(:); sizes=sizes(:);

if sum(d)~=1
    d=d./sum(d); d=d(:);
end
[sizes,d]=make_distinct(sizes,d);
cd=cumsum(d(:));


if length(d)~=length(sizes)
    error('input vectors must be the same length')
elseif length(cd)~=length(sizes)
    error('input vectors must be the same length')
elseif length(d)~=length(cd)
    error('input vectors must be the same length')
end

cd=[0;cd]; d=[0;d]; sizes=[0;sizes];

% percentiles (5,16,25,50,75,84,95)
pd(1)=interp1(cd,sizes,.05);
pd(2)=interp1(cd,sizes,.10);
pd(3)=interp1(cd,sizes,.16);
pd(4)=interp1(cd,sizes,.25);
pd(5)=interp1(cd,sizes,.50);
pd(6)=interp1(cd,sizes,.75);
pd(7)=interp1(cd,sizes,.84);
pd(8)=interp1(cd,sizes,.90);
pd(9)=interp1(cd,sizes,.95);

cd(1)=[]; d(1)=[]; sizes(1)=[];

% Folk and Ward geometric graphical measures
gm(1)=exp((log(pd(3))+log(pd(5))+log(pd(7)))/3); %mean

gm(2)=abs(exp(((log(pd(7))-log(pd(3)))/4)+...
    (log((pd(9))-log(pd(1)))/6.6))); % sorting

gm(3)=((log(pd(3))+log(pd(7))-2*(log(pd(5))))/(2*(log(pd(7))-log(pd(3))))) ...
    + ((log(pd(1))+log(pd(9))-2*(log(pd(5))))/(2*(log(pd(9))-log(pd(1))))); %skewness

gm(4)= abs((log(pd(1))-log(pd(9)))/(2.44*(log(pd(6))-log(pd(4))))); %kurtosis

%=============

f=find(d<.000001); d(f)=[]; sizes(f)=[];

% arithmetic moments
am(1)=sum(d.*sizes); % mean
am(2)=sqrt(sum(d.*((sizes-am(1)).^2))); % sorting
am(3)=(sum(d.*((sizes-am(1)).^3)))/(100*am(2).^3); % skewness
am(4)=(sum(d.*((sizes-am(1)).^4)))/(100*am(2).^4); % kurtosis



