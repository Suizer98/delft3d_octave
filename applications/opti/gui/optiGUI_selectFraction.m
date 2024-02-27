function optiGUI_selectFraction

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

this.input(dg).dataSedimentFraction=get(findobj(fig,'tag','dataSedimentFraction'),'value');
set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);