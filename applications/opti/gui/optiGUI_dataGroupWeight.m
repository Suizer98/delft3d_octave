function optiGUI_dataGroupWeight

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
this.dataGroupWeights(dg)=str2num(get(findobj(fig,'tag','dataGroupWeight'),'string'));
set(fig,'userdata',this);