function ddb_menuViewXBeach(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'ddb_menuViewModelGrid'}
        ddb_menuViewGrid_Callback(hObject,eventdata,handles);
    case{'ddb_menuViewModelModelBathymetry'}
        ddb_menuViewModelBathymetry_Callback(hObject,eventdata,handles);
    % case{'ddb_menuViewModelObservationPoints'}
        % ddb_menuViewObservationPoints_Callback(hObject,eventdata,handles);
    % case{'ddb_menuViewModelCrossSections'}
        % ddb_menuViewCrossSections_Callback(hObject,eventdata,handles);
end    

%%
function ddb_menuViewGrid_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','XBeachGrid');
    if ~isempty(h)
        set(h,'Visible','off');
    end        
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','XBeachGrid');
    if ~isempty(h)
        set(h,'Visible','on');
    end        
end    

%%
function ddb_menuViewModelBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','XBeachBathymetry');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','XBeachBathymetry');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end
%%
