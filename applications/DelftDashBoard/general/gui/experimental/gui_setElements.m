function gui_setElements(element)

if ischar(element)
    h=findobj(gcf,'Tag',element);
    if isempty(h)
        return
    end
    element=getappdata(h,'elements');
end

for i=1:length(element)
    
    if isfield(element(i).element,'handle')
        if ~isempty(element(i).element.handle)
            try
                gui_setElement(element(i).element.handle);
            catch
%                disp(['Something went wrong when setting UI element ' element(i).element.tag]);
            end
        else
            disp(['Warning : no handle for ' element(i).element.tag ' !']);
        end
    else
        disp(['Warning : no handle for ' element(i).element.tag ' !']);
    end
    
end
