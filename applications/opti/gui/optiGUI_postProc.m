function optiGUI_postProc

[but,fig]=gcbo;

this=get(fig,'userdata');
close(fig);
fig2=openfig('optiPostProc.fig','reuse');
name = get(fig2,'name');

set(fig2,'userdata',this);
set(findobj(fig2,'tag','conditionSlider'),'value',1);
set(findobj(fig2,'tag','conditionSlider'),'max',length(this.iteration),'min',1,'sliderstep',[1/(length(this.iteration)-1) 5/(length(this.iteration)-1)]);

optiGUI_showResults(fig2);
optiGUI_conditionSlider(findobj(fig2,'tag','conditionSlider'),fig2);