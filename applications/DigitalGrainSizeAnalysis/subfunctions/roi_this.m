
% roi_this
% creates ROIs for the current image
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

if ~isfield(sample(ix),'whole_roi') && sample(ix).whole_roi~=1
    
    % if ~exist('whole_roi','var') || whole_roi
    whole_roi=0;
    sample(ix).num_roi=0;
    for k=1:sample(ix).num_roi
        sample(ix).roi{k}=[];
        sample(ix).roi_x{k}=[];
        sample(ix).roi_y{k}=[];
        sample(ix).roi_line{k}=[];
    end
    chx = get(ax,'Children');
    if length(chx)>=2
        chx(end)=[];
        delete(chx)
    end
    axes(ax)
end


[Nv,Nu,blank] = size(sample(1).data);
set(ax,'xlim',[-2 Nu+2],'ylim',[-2 Nv+2])

%[blank,rectpos]=crop_image(ax);
rectpos=round(getrect(ax));

sample_indices = ix;
if length(sample)>1
    ButtonName = questdlg('Do this for all images?','ROI image', ...
        'Yes','No', 'Yes');

    if strcmp(ButtonName,'Yes')
        sample_indices = 1:length(sample);
    end
end

for ix = sample_indices

    if isempty(sample(ix).data)
        sample(ix).data=fileload(fullfile(image_path,image_name{ix})); %#ok<*SAGROW>
    end
    
    sample(ix).whole_roi=0;
    sample(ix).num_roi=sample(ix).num_roi+1;

    % define the points for the line to be drawn
    sample(ix).roi_x{sample(ix).num_roi} =round([rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), ...
        rectpos(1), rectpos(1)]);
    sample(ix).roi_y{sample(ix).num_roi} = round([rectpos(2), rectpos(2), rectpos(2)+rectpos(4), ...
        rectpos(2)+rectpos(4), rectpos(2)]);
    sample(ix).roi_line{sample(ix).num_roi} = line(sample(ix).roi_x{sample(ix).num_roi},...
        sample(ix).roi_y{sample(ix).num_roi},'color','red','linewidth',2);

    sample(ix).roi{sample(ix).num_roi}=sample(ix).data(min(sample(ix).roi_y{sample(ix).num_roi}):...
        max(sample(ix).roi_y{sample(ix).num_roi}),...
        min(sample(ix).roi_x{sample(ix).num_roi}):...
        max(sample(ix).roi_x{sample(ix).num_roi}));
    
end

clear rectpos

set(findobj('tag','current_image'),'userdata',sample);


if ~isempty(sample(ix).dist)
    uiwait(msgbox('... remember to calculate size distribution again!','New ROIs defined ...','modal'));
end
