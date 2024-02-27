function gui_addMenu(h,menuitem)

for ii=1:length(menuitem)
    h2=uimenu(h,'Label',menuitem(ii).menuitem.label);
    if isfield(menuitem(ii).menuitem,'separator')
        set(h2,'separator',menuitem(ii).menuitem.separator);
    end
    if isfield(menuitem(ii).menuitem,'callback')
        f=str2func(menuitem(ii).menuitem.callback);
        set(h2,'callback',{@selectItem,f,menuitem(ii).menuitem.option});
    end
    if isfield(menuitem(ii).menuitem,'menuitem')
        gui_addMenu(h2,menuitem(ii).menuitem.menuitem);
    end
end

%%
function selectItem(hObject, eventdata,callback,option)
feval(callback,option);
