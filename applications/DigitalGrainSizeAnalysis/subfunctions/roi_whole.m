
%roi_whole
% makes the entire current image the ROI
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

ButtonName = questdlg('Make the ROI the whole image','Are you sure?', ...
    'Yes','No', 'Yes');

if strcmp(ButtonName,'Yes')
    
    if length(sample)>1
        ButtonName = questdlg('Do this for all images?','ROI whole image', ...
            'Yes','No', 'Yes');
        
        if strcmp(ButtonName,'Yes')
            
            for ii=1:length(sample)
                
                % read data in if not already done so
                if isempty(sample(ii).data)
                    sample(ii).data=fileload(fullfile(image_path,char(image_name(ii))));
                end
                im=sample(ii).data;
                [n,m,p] = size(im);
                % cosine taper
                w = .25; % width of cosine in percent of width of X
                window = repmat(tukeywin(n,w),1,m).*rot90(repmat(tukeywin(m,w),1,n));
                
                for i = 1:p
                    im(:,:,i) = im(:,:,i).*window;
                end
                sample(ii).data=im;
                
                
                % first remove previous rois
                if sample(ii).num_roi>0 && sample(ii).whole_roi~=1
                    for k=1:sample(ii).num_roi
                        sample(ii).roi{k}=[];
                        sample(ii).roi_x{k}=[];
                        sample(ii).roi_y{k}=[];
                        sample(ii).roi_line{k}=[];
                    end
                end
                
                sample(ii).num_roi=1;
                sample(ii).roi{1}=sample(ii).data;
                sample(ii).roi_x{1}=[2 size(sample(ii).data,2)-1 size(sample(ii).data,2)-1 2 2];
                sample(ii).roi_y{1}=[2 2 size(sample(ii).data,1)-1 size(sample(ii).data,1)-1 2];
                
                
                % make a flag which says what has been done, in order to remove it for
                % subsequent roi draws
                sample(ii).whole_roi=1;
                
                sample(ii).roi_line{1} = line(sample(ii).roi_x{1},...
                    sample(ii).roi_y{1},'color','red','linewidth',2);
                
            end
            
            
        else
            
            sample(ix).whole_roi=1;
            % first remove previous rois
            if sample(ix).num_roi>0 && sample(ix).whole_roi~=1
                for k=1:sample(ix).num_roi
                    sample(ix).roi{k}=[];
                    sample(ix).roi_x{k}=[];
                    sample(ix).roi_y{k}=[];
                    sample(ix).roi_line{k}=[];
                end
            end
            
            chx = get(ax,'Children');
            if length(chx)>=2
                chx(end)=[];
                delete(chx)
            end
            axes(ax)
            
            sample(ix).num_roi=1;
            sample(ix).roi{1}=sample(ix).data;
            sample(ix).roi_x{1}=[1 size(sample(ix).data,2)-1 size(sample(ix).data,2)-1 1 1];
            sample(ix).roi_y{1}=[1 1 size(sample(ix).data,1)-1 size(sample(ix).data,1)-1 1];
            
            % make a flag which says what has been done, in order to remove it for
            % subsequent roi draws
            sample(ix).whole_roi=1;
            
            sample(ix).roi_line{1} = line(sample(ix).roi_x{1},...
                sample(ix).roi_y{1},'color','red','linewidth',2);
            
        end
        
    else
        
        sample(ix).whole_roi=1;
        sample(ix).num_roi=1;
        sample(ix).roi{1}=sample(ix).data;
        sample(ix).roi_x{1}=[1 size(sample(ix).data,2) size(sample(ix).data,2) 1 1];
        sample(ix).roi_y{1}=[1 1 size(sample(ix).data,1) size(sample(ix).data,1) 1];
        
    end
    
end

chx = get(ax,'Children');
if length(chx)>=2
    chx(end)=[];
    delete(chx)
end
axes(ax)

if sample(ix).num_roi>0
    for k=1:sample(ix).num_roi
        sample(ix).roi_line{k} = line(sample(ix).roi_x{k},sample(ix).roi_y{k},'color','red','linewidth',2);
    end
end

set(findobj('tag','current_image'),'userdata',sample);
