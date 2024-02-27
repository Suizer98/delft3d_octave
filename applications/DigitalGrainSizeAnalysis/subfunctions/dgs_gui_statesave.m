% dgs_gui_statesave
% save gui state to MAT file

function dgs_gui_statesave(obj, event)

[fname, fpath] = uiputfile({'*.dgs';'*.*'},'Save state file ...');

h=findobj('tag','current_image');
sample=get(h,'userdata');

save(fullfile(fpath, fname), 'sample');