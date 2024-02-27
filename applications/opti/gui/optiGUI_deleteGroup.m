function optiGUI_deleteGroup

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
nodg=length(this.input);

if nodg==1
    errordlg('Cannot delete last group!');
    return
end

this.input(dg)=[];
this.dataGroupWeights(dg)=[];
set(findobj(fig,'tag','curDg'),'string',num2str(1));
set(findobj(fig,'tag','maxDg'),'string',['/ ' num2str(nodg-1)]);
set(fig,'userdata',this);
optiGUI_struct2gui(fig);