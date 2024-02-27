function optiGUI_trimTimeStep

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

this.input(dg).trimTimeStep=str2num(get(findobj(fig,'tag','trimTimeStep'),'string'));
set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);