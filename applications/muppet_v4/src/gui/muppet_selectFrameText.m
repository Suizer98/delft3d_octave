function [fig,ok]=muppet_selectFrameText(fig,frame)

width=400;
height=length(frame.text)*30+80;

nelm=0;
for ielm=1:length(frame.text)
    nelm=nelm+1;
    element(nelm).element.style='edit';
    element(nelm).element.position=[60 height-nelm*30-10 300 20];
    element(nelm).element.variable=['frametext(' num2str(ielm) ').frametext.text'];
    element(nelm).element.text=['Text ' num2str(ielm)];
end

% Cancel
nelm=nelm+1;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-170 20 70 25];

% OK
nelm=nelm+1;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-90 20 70 25];

xml.element=element;

xml=gui_fillXMLvalues(xml);

handles=getHandles;

[fig,ok]=gui_newWindow(fig,'element',xml.element,'tag','uifigure','width',width,'height',height, ...
    'title','Frame Text','modal',0,'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
