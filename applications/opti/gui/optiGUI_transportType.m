function optiGUI_transportType

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

transType=get(findobj(fig,'tag','transportType'),'string');
this.input(dg).transParameter=transType{get(findobj(fig,'tag','transportType'),'value')};
set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);