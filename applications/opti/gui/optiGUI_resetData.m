function optiGUI_resetData

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

% data resetten
this.input(dg).data=[];
this.input(dg).target=[];
set(findobj(fig,'tag','dataLoad'),'string','Data not loaded yet');
set(fig,'userdata',this);
optiGUI_resetResults;