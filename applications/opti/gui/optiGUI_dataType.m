function optiGUI_dataType

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

dataType=get(findobj(fig,'tag','dataType'),'string');
this.input(dg).dataType=dataType{get(findobj(fig,'tag','dataType'),'value')};
set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);