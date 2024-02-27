%function roi_save()

objSelectBox = findobj('tag','PickImage');
objImage     = findobj('tag','current_image');

ix = get(objSelectBox,'value');
sample = get(objImage,'userdata');

roi_x = sample(ix).roi_x{1};
roi_y = sample(ix).roi_y{1};

[fname, fpath] = uiputfile({'*.roi';'*.*'},'Save ROI file ...');

filename = fullfile(fpath,fname);
save(filename,'roi_x','roi_y','-mat');