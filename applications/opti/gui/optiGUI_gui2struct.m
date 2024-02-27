function optiGUI_gui2struct(fig)

if nargin==0
    [but,fig]=gcbo;
end

this=get(fig,'userdata');

dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

this.input(dg).inputType=get(findobj(fig,'tag','inputType'),'value');
dataTypes=get(findobj(fig,'tag','dataType'),'string');
this.input(dg).dataType=dataTypes{get(findobj(fig,'tag','dataType'),'value')};
transType=get(findobj(fig,'tag','transportType'),'string');
this.input(dg).transParameter=transType{get(findobj(fig,'tag','transportType'),'value')};
this.input(dg).trimTimeStep=str2num(char(get(findobj(fig,'tag','trimTimeStep'),'string')));
this.input(dg).dataSedimentFraction=get(findobj(fig,'tag','dataSedimentFraction'),'value');
set(fig,'userdata',this);