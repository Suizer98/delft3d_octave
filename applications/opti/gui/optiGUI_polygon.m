function optiGUI_polygon

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

if get(findobj(fig,'tag','dataPolygon'),'value')==1
    this=optiReadPolygon(this,dg);
else
    this.input(dg).dataPolygon=[];
end

set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);
