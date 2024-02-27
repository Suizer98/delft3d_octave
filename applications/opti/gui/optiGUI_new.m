function optiGUI_new

[but,fig]=gcbo;

this=optiStruct;
set(fig,'userdata',this);
optiGUI_struct2gui(fig);
optiGUI_gui2struct(fig);