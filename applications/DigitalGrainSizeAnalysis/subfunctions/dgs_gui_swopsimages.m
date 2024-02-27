
% dgs_gui_swopsimages
% callback for main program, swops images
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

% get current image
ix=get(findobj('tag','PickImage'),'value');
% and current image data
sample=get(findobj('tag','current_image'),'userdata');

% % get next image
if isempty(sample(ix).data)
    sample(ix).data=fileload(sample(ix));
    
    im=sample(ix).data;
    [n,m,p] = size(im);
    % cosine taper
    w = .25; % width of cosine in percent of width of X
    window = repmat(tukeywin(n,w),1,m).*rot90(repmat(tukeywin(m,w),1,n));
    
    for i = 1:p
        im(:,:,i) = im(:,:,i).*window;
    end
    sample(ix).data=im;
    
end

dgs_gui_show(sample(ix));

set(findobj('tag','current_image'),'userdata',sample);

clear chx k n Nu Nv mag im auto nlags l centx centy tmpimage h




