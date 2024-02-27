function optiGUI_selectTarget

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
if get(but,'value')==0
    set(but,'value',1);
    return
end
    
switch get(but,'tag')
    case 'allCond'
        set(findobj(fig,'tag','userDefined'),'value',0);
        this.input(dg).target=[];
    case 'userDefined'
        set(findobj(fig,'tag','allCond'),'value',0);
        [namT,patT]=uigetfile('*.tek','Select tekal-file with target');
        if namT==0
            set(findobj(fig,'tag','allCond'),'value',1);
            set(findobj(fig,'tag','userDefined'),'value',0);
            return
        end
        tek=tekal('read',[patT filesep namT]);
        this.input(dg).target=tek.Field.Data(:,2);        
end
set(fig,'userdata',this);
