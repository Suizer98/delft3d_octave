function optiGUI_grossMode

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

if get(findobj(fig,'tag','grossMode'),'value')==1
    this.input(dg).transportMode='gross';
else
    this.input(dg).transportMode='nett';
end

set(fig,'userdata',this);

optiGUI_resetData;
optiGUI_struct2gui(fig);
