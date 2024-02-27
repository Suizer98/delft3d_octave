function optiGUI_setTimeFormat(fig);

if nargin==0
    [but,fig]=gcbo;
end

dg=str2num(get(findobj(fig,'tag','curDg'),'string'));
this=get(fig,'userdata');

dataType=this.input(dg).dataType;
inputType=this.input(dg).inputType;

if inputType==1
    switch dataType
        case 'transport'
            set(findobj(fig,'tag','trimTimeStep'),'TooltipString',' format: specify timesteps (= conditions) to use (seperated by spaces)');
        case 'sedero'
            set(findobj(fig,'tag','trimTimeStep'),'TooltipString',' format: specify for each condition a pair of timesteps (t1start t2start ... tnstart ;t1end t2end ... tnend) from which bed level changes between the two timesteps are calculated');
    end
elseif inputType==2|inputType==3
    set(findobj(fig,'tag','trimTimeStep'),'TooltipString',' format: specify timestep to use (1 value)');
end