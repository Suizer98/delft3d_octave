function optiGUI_open

[but,fig]=gcbo;

[namO,patO]=uigetfile('*.mat','Open opti structure');
if namO==0
    return
end
load([patO namO]);

if exist('this')
    set(fig,'userdata',this);
    optiGUI_struct2gui(fig);
else
    errordlg('no opti structure found in mat-file!')
    return
end