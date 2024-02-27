function optiGUI_groupSlide(direction)

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
nodg=length(this.input);

switch direction
    case 'forward'
        if dg<nodg
            set(findobj(fig,'tag','curDg'),'string',num2str(dg+1));
        end
    case 'backward'
        if dg>1
            set(findobj(fig,'tag','curDg'),'string',num2str(dg-1));
        end
end
optiGUI_struct2gui(fig);