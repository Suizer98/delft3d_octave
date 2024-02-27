function optiGUI_closePostProc

[but,fig]=gcbo;

this=get(fig,'userdata');
close(fig);

fig2=openfig('optiGUI.fig','reuse');
name = get(fig2,'name');

set(fig2,'userdata',this,'visible','on');
optiGUI_struct2gui(fig2);
optiGUI_gui2struct(fig2);