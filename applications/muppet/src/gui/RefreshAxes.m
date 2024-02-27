function handles=RefreshAxes(handles)

set(handles.EditTitle, 'String','');
set(handles.EditXLabel,'String','');
set(handles.EditYLabel,'String','');
set(handles.EditCMin,  'String','');
set(handles.EditCStep, 'String','');
set(handles.EditCMax,  'String','');
set(handles.EditXMin,      'String','');
set(handles.EditXMax,      'String','');
set(handles.EditXTick,     'String','');
set(handles.EditYMin,      'String','');
set(handles.EditYMax,      'String','');
set(handles.EditYTick,     'String','');
set(handles.EditScale,     'String','');
set(handles.EditTMinYear,    'String','');
set(handles.EditTMinMonth,   'String','');
set(handles.EditTMinDay,     'String','');
set(handles.EditTMinHour,    'String','');
set(handles.EditTMinMinute,  'String','');
set(handles.EditTMinSecond,  'String','');
set(handles.EditTMaxYear,    'String','');
set(handles.EditTMaxMonth,   'String','');
set(handles.EditTMaxDay,     'String','');
set(handles.EditTMaxHour,    'String','');
set(handles.EditTMaxMinute,  'String','');
set(handles.EditTMaxSecond,  'String','');
set(handles.EditTTickYear,   'String','');
set(handles.EditTTickMonth,  'String','');
set(handles.EditTTickDay,    'String','');
set(handles.EditTTickHour,   'String','');
set(handles.EditTTickMinute, 'String','');
set(handles.EditTTickSecond, 'String','');
set(handles.ToggleAxesEqual,'Value',0);
set(handles.ToggleAdjustAxes,'Value',0);
set(handles.ToggleXGrid,     'Value',0);
set(handles.ToggleYGrid,     'Value',0);
set(handles.ToggleTGrid,     'Value',0);
set(handles.toggleGeographic,'Value',0);
set(handles.ToggleAxesEqual,'Enable','off');
set(handles.ToggleAdjustAxes,'Enable','off');

if handles.Mode==2
    set(handles.EditSubplotPositionX,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditSubplotPositionY,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditSubplotSizeX,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditSubplotSizeY,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.TextPosition,        'Enable','off');
    set(handles.TextSubplotSize,     'Enable','off');
    set(handles.TextPosX,            'Enable','off');
    set(handles.TextPosY,            'Enable','off');
    set(handles.TextSizeX,           'Enable','off');
    set(handles.TextSizeY,           'Enable','off');
    set(handles.EditTitle, 'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditXLabel,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditYLabel,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    DisableTAxis(handles);
    DisableXAxis(handles);
    DisableYAxis(handles);
    DisableScale(handles);
    DisableScaleBar(handles);
    DisableLegend(handles);
    DisableColorScale(handles);
    DisableTitle(handles);
    Disable3DOptions(handles);
    DisableRightAxis(handles);
    DisableAdjustAxes(handles);
    DisableDrawBox(handles);
    DisableAxesEqual(handles);
    DisableArrows(handles);
    DisableBackgroundColor(handles);
    set(handles.ToggleMap2D,     'Value',0);
    set(handles.ToggleMap3D,     'Value',0);
    set(handles.ToggleXY,        'Value',0);
    set(handles.ToggleTimeSeries,'Value',0);
    set(handles.ToggleJpg,       'Value',0);
    set(handles.ToggleTextBox,   'Value',0);
    set(handles.ToggleMap2D,     'Enable','off');
    set(handles.ToggleMap3D,     'Enable','off');
    set(handles.PushApplyToAll,  'Enable','off');
else
    if handles.Figure(handles.ActiveFigure).NrSubplots>0

        set(handles.EditSubplotPositionX,'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditSubplotPositionY,'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditSubplotSizeX,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditSubplotSizeY,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextPosition,        'Enable','on');
        set(handles.TextSubplotSize,     'Enable','on');
        set(handles.TextPosX,            'Enable','on');
        set(handles.TextPosY,            'Enable','on');
        set(handles.TextSizeX,           'Enable','on');
        set(handles.TextSizeY,           'Enable','on');

        set(handles.EditTitle,'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Title);
        set(handles.EditXLabel,'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabel);
        set(handles.EditYLabel,'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabel);

        set(handles.ToggleMap2D,     'Enable','off');
        set(handles.ToggleMap3D,     'Enable','off');
        set(handles.ToggleXY,        'Enable','off');
        set(handles.ToggleTimeSeries,'Enable','off');
        set(handles.ToggleJpg,       'Enable','off');
%         set(handles.ToggleTextBox,   'Enable','off');
        set(handles.PushApplyToAll,  'Enable','on');

        set(handles.EditSubplotPositionX,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)));
        set(handles.EditSubplotPositionY,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)));
        set(handles.EditSubplotSizeX,    'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3)));
        set(handles.EditSubplotSizeY,    'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4)));

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotLegend;
        set(handles.ToggleLegend,        'Value' ,i);
        if i==1
            set(handles.EditLegend,'Enable','on');
        else
            set(handles.EditLegend,'Enable','off');
        end

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotColorBar;
        set(handles.ToggleColorBar,        'Value' ,i);
        if i==1
            set(handles.EditColorBar,'Enable','on');
        else
            set(handles.EditColorBar,'Enable','off');
        end

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotVectorLegend;
        set(handles.ToggleVectorLegend,        'Value' ,i);
        if i==1
            set(handles.EditVectorLegend,'Enable','on');
        else
            set(handles.EditVectorLegend,'Enable','off');
        end

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotNorthArrow;
        set(handles.ToggleNorthArrow,        'Value' ,i);
        if i==1
            set(handles.EditNorthArrow,'Enable','on');
        else
            set(handles.EditNorthArrow,'Enable','off');
        end

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotScaleBar;
        set(handles.ToggleScaleBar,        'Value' ,i);
        if i==1
            set(handles.EditScaleBar,'Enable','on');
        else
            set(handles.EditScaleBar,'Enable','off');
        end

        ic=1;
        for k=1:size(handles.ColorMaps,2)
            switch lower(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColMap),
                case lower(handles.ColorMaps(k).Name)
                    ic=k;
            end
        end
        set(handles.SelectColorMap, 'Value', ic);

        str={'linear','logarithmic','normprob'};
        i=findcell(str,handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XScale);
        set(handles.SelectXAxisScale,'Value',i);
        i=findcell(str,handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YScale);
        set(handles.SelectYAxisScale,'Value',i);

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).RightAxis;
        set(handles.ToggleRightAxis,        'Value' ,i);

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual;
        set(handles.ToggleAxesEqual,        'Value' ,i);

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AddDate;
        set(handles.ToggleAddDate,        'Value' ,i);

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AdjustAxes;
        set(handles.ToggleAdjustAxes,        'Value' ,i);

        i=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DrawBox;
        set(handles.ToggleDrawBox,        'Value' ,i);

        if strcmpi(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ContourType,'custom')
            set(handles.ToggleCustomContours,'Value',1);
        else
            set(handles.ToggleCustomContours,'Value',0);
        end

        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX==-1
            iDecimX=1;
        elseif handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX==-999
            iDecimX=9;
        else
            iDecimX=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX+2;
        end

        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY==-1
            iDecimY=1;
        elseif handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY==-999
            iDecimY=9;
        else
            iDecimY=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY+2;
        end

        nrcol=length(handles.DefaultColors);
        for i=1:nrcol
            handles.Colors{i}=handles.DefaultColors(i).Name;
        end
        set(handles.SelectSubplotColor,'String',handles.Colors);
        i=strmatch(lower(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).BackgroundColor),lower(handles.Colors),'exact');
        set(handles.SelectSubplotColor,'Value',i);

        switch lower(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType),

            case {'2d'}

                set(handles.ToggleMap2D,     'Value',1);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','on');
                set(handles.ToggleMap3D,     'Enable','on');

                set(handles.EditXMin,      'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin,7));
                set(handles.EditXMax,      'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax,7));
                set(handles.EditXTick,     'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XTick));
                set(handles.SelectDecimX,  'Value', iDecimX);
                set(handles.ToggleXGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid);

                set(handles.EditYMin,      'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin,7));
                set(handles.EditYMax,      'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax,7));
                set(handles.EditYTick,     'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick));
                set(handles.SelectDecimY,  'Value', iDecimY);
                set(handles.ToggleYGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid);

                set(handles.EditScale,     'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale,7));

                if strcmpi(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.type,'geographic')
                    set(handles.toggleGeographic,  'Value',1);
                else
                    set(handles.toggleGeographic,  'Value',0);
                end

                DisableTAxis(handles);
                EnableXAxis(handles);
                EnableYAxis(handles);
                EnableScale(handles);
                EnableTitle(handles);
                EnableScaleBar(handles);
                EnableLegend(handles);
                EnableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                EnableAdjustAxes(handles);
                EnableDrawBox(handles);
                EnableAxesEqual(handles);
                EnableArrows(handles);
                EnableBackgroundColor(handles);
                EnableCoordSys(handles);

            case {'3d'}

                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',1);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','on');
                set(handles.ToggleMap3D,     'Enable','on');

                set(handles.EditXMin,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin);
                set(handles.EditXMax,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax );
                set(handles.EditXTick,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XTick);
                set(handles.SelectDecimX,  'Value', iDecimX);
                set(handles.ToggleXGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid);

                set(handles.EditYMin,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin );
                set(handles.EditYMax,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax );
                set(handles.EditYTick,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick);
                set(handles.SelectDecimY,  'Value', iDecimY);
                set(handles.ToggleYGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid);

                DisableTAxis(handles);
                EnableXAxis(handles);
                EnableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                EnableColorScale(handles);
                Enable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                EnableAdjustAxes(handles);
                EnableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                EnableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'xy'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',1);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');

                set(handles.EditXMin,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin);
                set(handles.EditXMax,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax );
                set(handles.EditXTick,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XTick);
                set(handles.SelectDecimX,  'Value', iDecimX);
                set(handles.ToggleXGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid);

                set(handles.EditYMin,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin );
                set(handles.EditYMax,      'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax );
                set(handles.EditYTick,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick);
                set(handles.SelectDecimY,  'Value', iDecimY);
                set(handles.ToggleYGrid,   'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid);

                DisableTAxis(handles);
                EnableXAxis(handles);
                EnableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                EnableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                EnableXScale(handles);
                EnableYScale(handles);
                EnableRightAxis(handles);
                EnableAdjustAxes(handles);
                DisableDrawBox(handles);
                EnableAxesEqual(handles);
                EnableArrows(handles);
                EnableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'timeseries'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',1);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');

                set(handles.EditTMinYear,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMin);
                set(handles.EditTMinMonth,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMin);
                set(handles.EditTMinDay,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMin);
                set(handles.EditTMinHour,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMin);
                set(handles.EditTMinMinute,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMin);
                set(handles.EditTMinSecond,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMin);

                set(handles.EditTMaxYear,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMax);
                set(handles.EditTMaxMonth,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMax);
                set(handles.EditTMaxDay,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMax);
                set(handles.EditTMaxHour,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMax);
                set(handles.EditTMaxMinute,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMax);
                set(handles.EditTMaxSecond,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMax);

                set(handles.EditTTickYear,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearTick);
                set(handles.EditTTickMonth,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthTick);
                set(handles.EditTTickDay,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayTick);
                set(handles.EditTTickHour,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourTick);
                set(handles.EditTTickMinute, 'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteTick);
                set(handles.EditTTickSecond, 'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondTick);

                set(handles.ToggleTGrid,     'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid);

                set(handles.EditYMin,        'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin);
                set(handles.EditYMax,        'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax );
                set(handles.EditYTick,       'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick);
                set(handles.SelectDecimY,    'Value', iDecimY);
                set(handles.ToggleYGrid,     'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid);

                set(handles.SelectTTickFormat, 'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DateFormatNr);

                EnableTAxis(handles);
                DisableXAxis(handles);
                EnableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                EnableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                EnableYScale(handles);
                EnableRightAxis(handles);
                EnableAdjustAxes(handles);
                DisableDrawBox(handles);
                DisableAxesEqual(handles);
                EnableArrows(handles);
                EnableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'timestack'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',1);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');

                set(handles.EditTMinYear,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMin);
                set(handles.EditTMinMonth,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMin);
                set(handles.EditTMinDay,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMin);
                set(handles.EditTMinHour,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMin);
                set(handles.EditTMinMinute,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMin);
                set(handles.EditTMinSecond,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMin);

                set(handles.EditTMaxYear,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMax);
                set(handles.EditTMaxMonth,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMax);
                set(handles.EditTMaxDay,     'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMax);
                set(handles.EditTMaxHour,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMax);
                set(handles.EditTMaxMinute,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMax);
                set(handles.EditTMaxSecond,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMax);

                set(handles.EditTTickYear,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearTick);
                set(handles.EditTTickMonth,  'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthTick);
                set(handles.EditTTickDay,    'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayTick);
                set(handles.EditTTickHour,   'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourTick);
                set(handles.EditTTickMinute, 'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteTick);
                set(handles.EditTTickSecond, 'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondTick);

                set(handles.ToggleTGrid,     'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid);

                set(handles.EditYMin,        'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin);
                set(handles.EditYMax,        'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax );
                set(handles.EditYTick,       'String',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick);
                set(handles.SelectDecimY,    'Value', iDecimY);
                set(handles.ToggleYGrid,     'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid);

                set(handles.SelectTTickFormat, 'Value', handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DateFormatNr);

                EnableTAxis(handles);
                DisableXAxis(handles);
                EnableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                EnableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                EnableYScale(handles);
                EnableRightAxis(handles);
                EnableAdjustAxes(handles);
                DisableDrawBox(handles);
                DisableAxesEqual(handles);
                EnableArrows(handles);
                EnableBackgroundColor(handles);
                DisableCoordSys(handles);
                
            case {'image'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',1);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');
                set(handles.PushApplyToAll,  'Enable','off');

                DisableTAxis(handles);
                DisableXAxis(handles);
                DisableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                DisableAdjustAxes(handles);
                EnableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                DisableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'rose'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');
                set(handles.PushApplyToAll,  'Enable','off');

                DisableTAxis(handles);
                DisableXAxis(handles);
                DisableYAxis(handles);
                DisableScale(handles);
                EnableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                DisableAdjustAxes(handles);
                EnableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                DisableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'textbox'}
                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',1);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');
                set(handles.PushApplyToAll,  'Enable','off');

                DisableTAxis(handles);
                DisableXAxis(handles);
                DisableYAxis(handles);
                DisableScale(handles);
                DisableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                DisableAdjustAxes(handles);
                EnableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                EnableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'unknown'}

                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');
                set(handles.PushApplyToAll,  'Enable','off');

                DisableTAxis(handles);
                DisableXAxis(handles);
                DisableYAxis(handles);
                DisableScale(handles);
                DisableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                DisableAdjustAxes(handles);
                DisableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                DisableBackgroundColor(handles);
                DisableCoordSys(handles);

            case {'annotations'}

                set(handles.ToggleMap2D,     'Value',0);
                set(handles.ToggleMap3D,     'Value',0);
                set(handles.ToggleXY,        'Value',0);
                set(handles.ToggleTimeSeries,'Value',0);
                set(handles.ToggleJpg,       'Value',0);
%                 set(handles.ToggleTextBox,   'Value',0);

                set(handles.ToggleMap2D,     'Enable','off');
                set(handles.ToggleMap3D,     'Enable','off');
                set(handles.PushApplyToAll,  'Enable','off');

                DisableTAxis(handles);
                DisableXAxis(handles);
                DisableYAxis(handles);
                DisableScale(handles);
                DisableTitle(handles);
                DisableScaleBar(handles);
                DisableLegend(handles);
                DisableColorScale(handles);
                Disable3DOptions(handles);
                DisableXScale(handles);
                DisableYScale(handles);
                DisableRightAxis(handles);
                DisableAdjustAxes(handles);
                DisableDrawBox(handles);
                DisableAxesEqual(handles);
                DisableArrows(handles);
                DisableBackgroundColor(handles);
                DisableSubplotPosition(handles);
                DisableCoordSys(handles);

        end
    else
        set(handles.EditSubplotPositionX,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditSubplotPositionY,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditSubplotSizeX,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditSubplotSizeY,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextPosition,        'Enable','off');
        set(handles.TextSubplotSize,     'Enable','off');
        set(handles.TextPosX,            'Enable','off');
        set(handles.TextPosY,            'Enable','off');
        set(handles.TextSizeX,           'Enable','off');
        set(handles.TextSizeY,           'Enable','off');
        set(handles.EditTitle, 'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditXLabel,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditYLabel,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        DisableTAxis(handles);
        DisableXAxis(handles);
        DisableYAxis(handles);
        DisableScale(handles);
        DisableScaleBar(handles);
        DisableLegend(handles);
        DisableColorScale(handles);
        DisableTitle(handles);
        Disable3DOptions(handles);
        DisableRightAxis(handles);
        DisableAdjustAxes(handles);
        DisableDrawBox(handles);
        DisableAxesEqual(handles);
        DisableArrows(handles);
        DisableBackgroundColor(handles);
        DisableCoordSys(handles);
        set(handles.ToggleMap2D,     'Value',0);
        set(handles.ToggleMap3D,     'Value',0);
        set(handles.ToggleXY,        'Value',0);
        set(handles.ToggleTimeSeries,'Value',0);
        set(handles.ToggleJpg,       'Value',0);
%         set(handles.ToggleTextBox,   'Value',0);
        set(handles.ToggleMap2D,     'Enable','off');
        set(handles.ToggleMap3D,     'Enable','off');
        set(handles.PushApplyToAll,  'Enable','off');
    end
end

function handles=EnableTAxis(handles)
 
set(handles.EditTMinYear,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMinMonth,   'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMinDay,     'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMinHour,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMinMinute,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMinSecond,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
 
set(handles.EditTMaxYear,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMaxMonth,   'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMaxDay,     'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMaxHour,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMaxMinute,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTMaxSecond,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
 
set(handles.EditTTickYear,   'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTTickMonth,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTTickDay,    'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTTickHour,   'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTTickMinute, 'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditTTickSecond, 'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
 
set(handles.SelectTTickFormat,'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.ToggleTGrid,     'Enable','on');
set(handles.ToggleAddDate,   'Enable','on');
 
set(handles.TextYear,        'Enable','on');
set(handles.TextMonth,       'Enable','on');
set(handles.TextDay,         'Enable','on');
set(handles.TextHour,        'Enable','on');
set(handles.TextMinute,      'Enable','on');
set(handles.TextSecond,      'Enable','on');
set(handles.TextTMin,        'Enable','on');
set(handles.TextTMax,        'Enable','on');
set(handles.TextTTick,       'Enable','on');
set(handles.TextTTickFormat, 'Enable','on');
 
function handles=DisableTAxis(handles)
 
set(handles.EditTMinYear,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMinMonth,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMinDay,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMinHour,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMinMinute,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMinSecond,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
 
set(handles.EditTMaxYear,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMaxMonth,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMaxDay,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMaxHour,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMaxMinute,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTMaxSecond,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
 
set(handles.EditTTickYear,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTTickMonth,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTTickDay,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTTickHour,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTTickMinute, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditTTickSecond, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
 
set(handles.SelectTTickFormat,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.ToggleTGrid,     'Enable','off');
set(handles.ToggleAddDate,   'Enable','off');
 
set(handles.TextYear,        'Enable','off');
set(handles.TextMonth,       'Enable','off');
set(handles.TextDay,         'Enable','off');
set(handles.TextHour,        'Enable','off');
set(handles.TextMinute,      'Enable','off');
set(handles.TextSecond,      'Enable','off');
set(handles.TextTMin,        'Enable','off');
set(handles.TextTMax,        'Enable','off');
set(handles.TextTTick,       'Enable','off');
set(handles.TextTTickFormat, 'Enable','off');
 
function handles=EnableXAxis(handles)
 
set(handles.EditXMin,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditXMax,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditXTick,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.SelectDecimX,    'Enable','on');
set(handles.ToggleXGrid,     'Enable','on');
set(handles.TextXMin,        'Enable','on');
set(handles.TextXMax,        'Enable','on');
set(handles.TextXTick,       'Enable','on');
set(handles.TextXDecimals,   'Enable','on');
set(handles.SelectXAxisScale,'Enable','on');
 
function handles=DisableXAxis(handles)
 
set(handles.EditXMin,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditXMax,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditXTick,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.SelectDecimX,  'Enable','off');
set(handles.ToggleXGrid,   'Enable','off');
set(handles.TextXMin,      'Enable','off');
set(handles.TextXMax,      'Enable','off');
set(handles.TextXTick,     'Enable','off');
set(handles.TextXDecimals, 'Enable','off');
set(handles.SelectXAxisScale,'Enable','off');
 
function handles=EnableYAxis(handles)
 
set(handles.EditYMin,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditYMax,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditYTick,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.SelectDecimY,    'Enable','on');
set(handles.ToggleYGrid,     'Enable','on');
set(handles.TextYMin,        'Enable','on');
set(handles.TextYMax,        'Enable','on');
set(handles.TextYTick,       'Enable','on');
set(handles.TextYDecimals,   'Enable','on');
set(handles.SelectYAxisScale,'Enable','on');
 
function handles=DisableYAxis(handles)
 
set(handles.EditYMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditYMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditYTick,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.SelectDecimY,    'Enable','off');
set(handles.ToggleYGrid,     'Enable','off');
set(handles.TextYMin,        'Enable','off');
set(handles.TextYMax,        'Enable','off');
set(handles.TextYTick,       'Enable','off');
set(handles.TextYDecimals,   'Enable','off');
set(handles.SelectYAxisScale,'Enable','off');
 
function handles=EnableScale(handles)
 
set(handles.EditScale,     'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.TextScale,     'Enable','on');
 
function handles=DisableScale(handles)
 
set(handles.EditScale,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextScale,     'Enable','off');
 
function handles=EnableTitle(handles)
 
set(handles.EditTitle,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditXLabel,      'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.EditYLabel,      'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
set(handles.TextTitle,       'Enable','on');
set(handles.TextXLabel,      'Enable','on');
set(handles.TextYLabel,      'Enable','on');
set(handles.EditTitleFont,   'Enable','on');
set(handles.EditXLabelFont,  'Enable','on');
set(handles.EditYLabelFont,  'Enable','on');
set(handles.PushLabelFont,   'Enable','on');

 
function handles=DisableTitle(handles)
 
set(handles.EditTitle,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditXLabel,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditYLabel,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextTitle,       'Enable','off');
set(handles.TextXLabel,      'Enable','off');
set(handles.TextYLabel,      'Enable','off');
set(handles.EditTitleFont,   'Enable','off');
set(handles.EditXLabelFont,  'Enable','off');
set(handles.EditYLabelFont,  'Enable','off');
set(handles.PushLabelFont,   'Enable','off');

function handles=EnableScaleBar(handles)
 
set(handles.ToggleScaleBar,  'Enable','on');
set(handles.ToggleNorthArrow,   'Enable','on');
set(handles.ToggleVectorLegend,'Enable','on');
set(handles.EditScaleBar,    'Enable','on');
set(handles.EditNorthArrow,     'Enable','on');
set(handles.EditVectorLegend,'Enable','on');
 
function handles=DisableScaleBar(handles)
 
set(handles.ToggleScaleBar,  'Enable','off');
set(handles.ToggleNorthArrow,   'Enable','off');
set(handles.ToggleVectorLegend,'Enable','off');
set(handles.EditScaleBar,    'Enable','off');
set(handles.EditNorthArrow,     'Enable','off');
set(handles.EditVectorLegend,'Enable','off');
 
function handles=EnableLegend(handles)
 
set(handles.ToggleLegend,    'Enable','on');
set(handles.EditLegend,      'Enable','on');
 
function handles=DisableLegend(handles)
 
set(handles.ToggleLegend,    'Enable','off');
set(handles.EditLegend,      'Enable','off');
 
function handles=EnableColorScale(handles)
 
set(handles.ToggleColorBar,  'Enable','on');
set(handles.EditColorBar,    'Enable','on');
set(handles.SelectColorMap,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);

set(handles.EditCMin,            'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin));
set(handles.EditCStep,           'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep));
set(handles.EditCMax,            'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax));

if strcmpi(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ContourType,'custom')
    set(handles.EditCMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditCMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditCStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.TextCMin,        'Enable','off');
    set(handles.TextCMax,        'Enable','off');
    set(handles.TextCStep,       'Enable','off');
else
    set(handles.EditCMin,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
    set(handles.EditCMax,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
    set(handles.EditCStep,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
    set(handles.TextCMin,        'Enable','on');
    set(handles.TextCMax,        'Enable','on');
    set(handles.TextCStep,       'Enable','on');
end
set(handles.ToggleCustomContours,'Enable','on');
set(handles.PushEditCustomContours,  'Enable','on');

 
function handles=DisableColorScale(handles)
 
set(handles.ToggleColorBar,  'Enable','off');
set(handles.EditColorBar,    'Enable','off');
set(handles.SelectColorMap,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditCMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditCMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditCStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextCMin,        'Enable','off');
set(handles.TextCMax,        'Enable','off');
set(handles.TextCStep,       'Enable','off');
set(handles.ToggleCustomContours,'Enable','off');
set(handles.PushEditCustomContours,  'Enable','off');
set(handles.EditCMin,            'String','');
set(handles.EditCStep,           'String','');
set(handles.EditCMax,            'String','');


function handles=Enable3DOptions(handles)
 
set(handles.Push3DOptions,   'Enable','on');
 
function handles=Disable3DOptions(handles)
 
set(handles.Push3DOptions,        'Enable','off');
 
function handles=EnableXScale(handles)
 
set(handles.SelectXAxisScale,   'Enable','on');
 
function handles=DisableXScale(handles)
 
set(handles.SelectXAxisScale,   'Enable','off');
 
function handles=EnableYScale(handles)
 
set(handles.SelectYAxisScale,   'Enable','on');
 
function handles=DisableYScale(handles)
 
set(handles.SelectYAxisScale,   'Enable','off');
 
function handles=EnableRightAxis(handles)
 
set(handles.ToggleRightAxis, 'Enable','on');
set(handles.EditRightAxis,   'Enable','on');

function handles=DisableRightAxis(handles)
 
set(handles.ToggleRightAxis, 'Enable','off');
set(handles.EditRightAxis,   'Enable','off');

function handles=EnableAdjustAxes(handles)
 
set(handles.ToggleAdjustAxes, 'Enable','on');

function handles=DisableAdjustAxes(handles)
 
set(handles.ToggleAdjustAxes, 'Enable','off');

function handles=EnableDrawBox(handles)
 
set(handles.ToggleDrawBox, 'Enable','on');

function handles=DisableDrawBox(handles)
 
set(handles.ToggleDrawBox, 'Enable','off');

function handles=EnableAxesEqual(handles)
set(handles.ToggleAxesEqual, 'Enable','on');
if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual==0
    set(handles.EditScale,             'Enable','off');
    set(handles.TextScale,             'Enable','off');
end

function handles=DisableAxesEqual(handles)

set(handles.ToggleAxesEqual, 'Enable','off');

function handles=EnableCoordSys(handles)
set(handles.toggleGeographic, 'Enable','on');

function handles=DisableCoordSys(handles)
set(handles.toggleGeographic, 'Enable','off');

function handles=EnableArrows(handles)

set(handles.PushAddArrows, 'Enable','on');

function handles=DisableArrows(handles)

set(handles.PushAddArrows, 'Enable','off');

function handles=EnableBackgroundColor(handles)

set(handles.SelectSubplotColor, 'Enable','on');
set(handles.TextSubplotColor,   'Enable','on');

function handles=DisableBackgroundColor(handles)

set(handles.SelectSubplotColor, 'Enable','off');
set(handles.TextSubplotColor,   'Enable','off');

function handles=DisableSubplotPosition(handles)

set(handles.EditSubplotPositionX,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditSubplotPositionY,'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditSubplotSizeX,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.EditSubplotSizeY,    'String','','Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextPosition,        'Enable','off');
set(handles.TextSubplotSize,     'Enable','off');
set(handles.TextPosX,            'Enable','off');
set(handles.TextPosY,            'Enable','off');
set(handles.TextSizeX,           'Enable','off');
set(handles.TextSizeY,           'Enable','off');

