% dgs_gui_stateload
% load gui state from MAT file

function dgs_gui_stateload(obj, event)

[fname, fpath] = uigetfile({'*.dgs';'*.*'},...
    'Load state file ...', 'MultiSelect', 'off');

matfile = fullfile(fpath, fname);

vars = whos('-file',matfile);
if ismember('sample', {vars.name})
    load(matfile,'-mat','sample');
    
    h=findobj('tag','PickImage');
    set(h,'string',{sample.name});
    
    h=findobj('tag','current_image');
    set(h,'userdata',sample);
    
    dgs_gui_show(sample(1));
    
else
    errordlg('Invalid state file');
end