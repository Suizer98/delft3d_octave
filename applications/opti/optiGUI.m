function optiGUI

if ~strcmp(version('-release'),'13')
    warndlg('Only tested with Matlab 6.5 (R13)')
end


if ~exist('vs_use.m','file')
    wlsettings;
end

basePath=strrep(which('optiGUI.m'),'optiGUI.m','');

addpath(basePath);
addpath([basePath  'code']);
addpath([basePath  'gui']);

fig=openfig('optiGUI.fig','reuse');
name = get(fig,'name');

this=optiStruct;
set(fig,'userdata',this,'visible','on');
optiGUI_struct2gui(fig);
optiGUI_gui2struct(fig);
warning off MATLAB:divideByZero;