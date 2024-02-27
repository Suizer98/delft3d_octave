function LT_mouse_click(curAx,action)

while ~strcmp(get(curAx,'type'),'axes')
    curAx = get(curAx,'parent');
end
fig = curAx;
while ~strcmp(get(fig,'type'),'figure')
    fig = get(fig,'parent');
end

if ~strcmp(get(fig,'pointer'),'arrow')
    guidata(curAx,action);
else
    guidata(curAx,[]);
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: First click a function!');
    pause(1);
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
end

end