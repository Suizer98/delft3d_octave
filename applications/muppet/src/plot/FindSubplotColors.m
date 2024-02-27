function handles=FindSubplotColors(handles,i,j)

% Colors
handles.Figure(i).Axis(j).XLabelFontColor      = FindColor(handles.Figure(i).Axis(j),'XLabelFontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).YLabelFontColor      = FindColor(handles.Figure(i).Axis(j),'YLabelFontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).YLabelFontColorRight = FindColor(handles.Figure(i).Axis(j),'YLabelFontColorRight',handles.DefaultColors);
handles.Figure(i).Axis(j).TitleFontColor       = FindColor(handles.Figure(i).Axis(j),'TitleFontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).AxesFontColor        = FindColor(handles.Figure(i).Axis(j),'AxesFontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).FontColor            = FindColor(handles.Figure(i).Axis(j),'FontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).LegendColor          = FindColor(handles.Figure(i).Axis(j),'LegendColor',handles.DefaultColors);
handles.Figure(i).Axis(j).LegendFontColor      = FindColor(handles.Figure(i).Axis(j),'LegendFontColor',handles.DefaultColors);
handles.Figure(i).Axis(j).BackgroundColor      = FindColor(handles.Figure(i),'BackgroundColor',handles.DefaultColors);
for k=1:handles.Figure(i).Axis(j).Nr
    % Colors
    handles.Figure(i).Axis(j).Plot(k).Color           = FindColor(handles.Figure(i).Axis(j).Plot(k),'Color',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).FillColor       = FindColor(handles.Figure(i).Axis(j).Plot(k),'FillColor',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).VectorColor     = FindColor(handles.Figure(i).Axis(j).Plot(k),'VectorColor',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).MarkerEdgeColor = FindColor(handles.Figure(i).Axis(j).Plot(k),'MarkerEdgeColor',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).MarkerFaceColor = FindColor(handles.Figure(i).Axis(j).Plot(k),'MarkerFaceColor',handles.DefaultColors);
%     handles.Figure(i).Axis(j).Plot(k).LineColor       = FindColor(handles.Figure(i).Axis(j).Plot(k),'LineColor',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).FontColor       = FindColor(handles.Figure(i).Axis(j).Plot(k),'FontColor',handles.DefaultColors);
    handles.Figure(i).Axis(j).Plot(k).EdgeColor       = FindColor(handles.Figure(i).Axis(j).Plot(k),'EdgeColor',handles.DefaultColors);
end    

