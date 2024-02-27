%function roi_load()

[fname, fpath] = uigetfile({'*.roi';'*.*'},'Load ROI file ...'); % uigetfile
filename = fullfile(fpath,fname);
load(filename,'roi_x','roi_y','-mat');

objImage = findobj('tag','current_image');
sample = get(objImage,'userdata');

[sample(:).roi_x]= deal({roi_x});
[sample(:).roi_y]= deal({roi_y});

[sample.num_roi]=deal(1);

for i=1:length(sample)
    if isempty(sample(i).data)
        sample(i).data = fileload(fullfile(sample(i).path,sample(i).name));
    end
    
    sample(i).roi={sample(i).data(min(roi_x):max(roi_x),min(roi_y):max(roi_y))};
end 

set(objImage,'userdata',sample);

dgs_gui_show;