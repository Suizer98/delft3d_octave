
%check_savedfile
% function to create new filename if requested file already exists
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

function savedfile=check_savedfile(savedfile,filetype)

% see if the requested file already exists, and if so find an
% alternative to avoid overwriting
counter=1;
while exist(savedfile,'file')==2
    disp([savedfile,' already exists!'])
    savedfile=[savedfile(1:regexp(savedfile,filetype)-2),'_',...
        num2str(counter),['.',filetype]];
    counter=counter+1;
end