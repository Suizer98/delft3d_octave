function gui_updateWindow

hobj=findobj('tag','uifigure');
hobj=gcf;
element=getappdata(hobj,'elements');
gui_setElements(element);
