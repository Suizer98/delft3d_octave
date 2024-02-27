function optiGUI_inputType

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

this.input(dg).inputType=get(findobj(fig,'tag','inputType'),'value');
set(fig,'userdata',this);
optiGUI_resetData;
optiGUI_struct2gui(fig);