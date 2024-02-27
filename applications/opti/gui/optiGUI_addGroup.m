function optiGUI_addGroup

[but,fig]=gcbo;
this=get(fig,'userdata');

optiGUI_gui2struct;

nodg=length(this.input);
this.input(nodg+1).inputType=1;
this.input(nodg+1).dataType='transport';
this.input(nodg+1).dataSedimentFraction=1;

% scherm resetten
set(findobj(fig,'tag','curDg'),'string',num2str(nodg+1));
set(findobj(fig,'tag','maxDg'),'string',num2str(nodg+1));
set(findobj(fig,'tag','trimfile'),'string',' ');
set(findobj(fig,'tag','timesteps'),'string','.. timesteps found in trim-file');
set(findobj(fig,'tag','fractions'),'string','.. sediment fractions found in trim-file');
this.dataGroupWeights(nodg+1)=0;
set(fig,'userdata',this);
optiGUI_struct2gui(fig);
optiGUI_setTimeFormat;