function gui_updateActiveTab
h=getappdata(gcf,'activetabpanel');
iac=getappdata(gcf,'activetab');
% Get element structure of tab panel
element=getappdata(h,'element');
% Get element structure of elements in active tab
elements=element.tab(iac).tab.element;
gui_setElements(elements);
