function optiGUI_resetResults

[but,fig]=gcbo;

this=get(fig,'userdata');
dg=str2num(get(findobj(fig,'tag','curDg'),'string'));

% opti  results resetten
this=rmfield(this,'iteration');
this.iteration.conditions=[]; %remaining conditions from original list
this.iteration.weights=[];    %associated weights
set(fig,'userdata',this);