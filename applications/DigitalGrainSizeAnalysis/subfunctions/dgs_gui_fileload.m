
% dgs_gui_fileload
% loads images into the program
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

[image_name, image_path] = uigetfile({'*.*';'*.JPG';'*.BMP';'*.PNG';...
    '*.TIFF';'*.jpg';'*.bmp';'*.png';'*.tiff';'*.tif'},...
    'Load images ...', 'MultiSelect', 'on');	% get image names

if isequal(image_name,0) || isequal(image_path,0)
    disp('You pressed cancel') % msg if cancel button pressed
    sample = struct('data',[],'name','');
else % cancel button not pressed
    
    addpath(image_path) % add these to path so matlab can find them
    
    if ~iscell(image_name) % only 1 image selected
        
        F{1}=[image_path,image_name];
        
        sample(1).data=fileload(fullfile(image_path,image_name));
        im=sample(1).data;
        [n,m,p] = size(im);
        % cosine taper
        w = .25;
        window = repmat(tukeywin(n,w),1,m).*rot90(repmat(tukeywin(m,w),1,n));
        
        for i = 1:p
            im(:,:,i) = im(:,:,i).*window;
        end
        sample(1).data=im;
        
        sample(1).name=image_name;
        sample(1).path=image_path;
        sample(1).num_roi=0;
        sample(1).whole_roi=0;
        sample(1).roi={};
        sample(1).roi_x={};
        sample(1).roi_y={};
        sample(1).resolution=1;
        sample(1).flattened=0;
        sample(1).filtered=0;
        sample(1).filt1=2;
        sample(1).filt2=0.25;
        sample(1).filt3=2;
        sample(1).percentiles={};
        sample(1).arith_moments={};
        sample(1).geom_moments={};
        sample(1).dist={};
        
        
    else % more than 1 image
        
        % more efficient to preallocate
        sample = struct('data',cell(1,length(image_name)),...
            'name',cell(1,length(image_name)),...
            'path',cell(1,length(image_name)),...
            'resolution',cell(1,length(image_name)),....
            'num_roi',cell(1,length(image_name)),....
            'whole_roi',cell(1,length(image_name)),....
            'roi',cell(1,length(image_name)),...
            'roi_y',cell(1,length(image_name)),...
            'roi_x',cell(1,length(image_name)),...
            'flattened',cell(1,length(image_name)),....
            'filtered',cell(1,length(image_name)),...
            'filt1',cell(1,length(image_name)),...
            'filt2',cell(1,length(image_name)),...
            'filt3',cell(1,length(image_name)),...
            'percentiles',cell(1,length(image_name)),...
            'arith_moments',cell(1,length(image_name)),...
            'geom_moments',cell(1,length(image_name)),...
            'dist',cell(1,length(image_name)));
        
        F=cell(1,size(image_name,2));
        for i=1:size(image_name,2)
            ff=fullfile(image_path, char(image_name(i)));
            disp(['User selected ', ff]);
            fprintf(fid,'%s\n',['%User selected ', ff]);
            F{i}=ff;
        end
       
        % load first two images only
        sample(1).data=fileload(fullfile(image_path,char(image_name(1))));
        
        im=sample(1).data;
        [n,m,p] = size(im);
        % cosine taper
        w = .25; % width of cosine in percent of width of X
        window = repmat(tukeywin(n,w),1,m).*rot90(repmat(tukeywin(m,w),1,n));
        
        for i = 1:p
            im(:,:,i) = im(:,:,i).*window;
        end
        sample(1).data=im;
           
        
        for i=1:length(image_name)
            %         sample(i).data=imread([image_path char(image_name(i))]);
            sample(i).name=char(image_name(i));
            sample(i).path=char(image_path);
            sample(i).num_roi=0;
%             sample(i).roi={};
%             sample(i).roi_x={};
%             sample(i).roi_y={};
            sample(i).resolution=1;
            sample(i).flattened=0;
            sample(i).filtered=0;
            sample(i).filt1=2;
            sample(i).filt2=0.25;
            sample(i).filt3=2;
        end
        
    end
    
end

ix=1;

dgs_gui_show(sample(ix));

h=findobj('tag','PickImage');
set(h,'string',{sample.name});

h=findobj('tag','current_image');
set(h,'userdata',sample);

clear h ans ff Nu Nv mag im auto nlags l centx centy

