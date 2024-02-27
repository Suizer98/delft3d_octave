function optiGUI_runOpti

[but,fig]=gcbo;

optiGUI_resetResults;

this=get(fig,'userdata');
this=optiRun(this);
set(fig,'userdata',this);
optiGUI_struct2gui(fig);