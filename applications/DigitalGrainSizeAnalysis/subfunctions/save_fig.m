%save_fig.m
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
mkdir([pwd,filesep,'outputs',filesep,'prints'])

for ii=1:length(sample)
    
    if ~isempty(sample(ii).dist)
        
        outfile=[pwd,filesep,'outputs',filesep,'prints',...
            filesep,sample(ii).name(1:regexp(sample(ii).name,'\.')-1),'_psd.png'];
        if exist(outfile,'file')==2
            delete(outfile)
        end
        
        set(findobj('tag','PickImage'),'value',ii)
        dgs_gui_swopsimages
        
        orient landscape
        print('-dpng','-r200',outfile) ;
        disp(['Results printed to ... ',outfile])
        
    end
    
end

set(findobj('tag','PickImage'),'value',ix)
dgs_gui_swopsimages

uiwait(msgbox('Screengrabs saved ','','modal'));



