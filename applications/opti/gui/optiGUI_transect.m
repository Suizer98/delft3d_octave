function optiGUI_transect

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

if get(findobj(fig,'tag','dataTransect'),'value')==1
    this=optiReadTransect(this,dg);
else
    this.input(dg).dataTransect=[];
end

set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);
