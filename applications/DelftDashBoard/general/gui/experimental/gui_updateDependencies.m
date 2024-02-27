function gui_updateDependencies(element,getFcn)

for i=1:length(element)
    switch lower(element(i).element.style)
        case{'tabpanel'}
            for j=1:length(element(i).element.tabs)
                gui_updateDependency(element(i).element.tabs(j).tab,0,getFcn);
            end
        otherwise
            gui_updateDependency(element(i).element,0,getFcn);
    end
end
