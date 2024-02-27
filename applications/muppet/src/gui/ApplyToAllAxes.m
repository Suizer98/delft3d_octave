function handles=ApplyToAllAxes(handles)

ifig=handles.ActiveFigure;

if handles.Figure(ifig).NrSubplots>0
 
    k=handles.ActiveSubplot;
    PlotType=lower(handles.Figure(ifig).Axis(k).PlotType);

    for i=1:handles.Figure(handles.ActiveFigure).NrSubplots

        if strcmp(lower(handles.Figure(ifig).Axis(i).PlotType),lower(PlotType)) & i~=k
 
            switch PlotType,
                case {'2d'}

                    handles.Figure(ifig).Axis(i).XMin=handles.Figure(ifig).Axis(k).XMin;
                    handles.Figure(ifig).Axis(i).XMax=handles.Figure(ifig).Axis(k).XMax;
                    handles.Figure(ifig).Axis(i).YMin=handles.Figure(ifig).Axis(k).YMin;
                    handles.Figure(ifig).Axis(i).YMax=handles.Figure(ifig).Axis(k).YMax;
                    handles.Figure(ifig).Axis(i).Scale=handles.Figure(ifig).Axis(k).Scale;
                    handles.Figure(ifig).Axis(i).XTick=handles.Figure(ifig).Axis(k).XTick;
                    handles.Figure(ifig).Axis(i).YTick=handles.Figure(ifig).Axis(k).YTick;
                    handles.Figure(ifig).Axis(i).XGrid=handles.Figure(ifig).Axis(k).XGrid;
                    handles.Figure(ifig).Axis(i).YGrid=handles.Figure(ifig).Axis(k).YGrid;
                    handles.Figure(ifig).Axis(i).DecimX=handles.Figure(ifig).Axis(k).DecimX;
                    handles.Figure(ifig).Axis(i).DecimY=handles.Figure(ifig).Axis(k).DecimY;
                    handles.Figure(ifig).Axis(i).XScale=handles.Figure(ifig).Axis(k).XScale;
                    handles.Figure(ifig).Axis(i).YScale=handles.Figure(ifig).Axis(k).YScale;
 
                case {'xy'}
                    handles.Figure(ifig).Axis(i).XMin=handles.Figure(ifig).Axis(k).XMin;
                    handles.Figure(ifig).Axis(i).XMax=handles.Figure(ifig).Axis(k).XMax;
                    handles.Figure(ifig).Axis(i).YMin=handles.Figure(ifig).Axis(k).YMin;
                    handles.Figure(ifig).Axis(i).YMax=handles.Figure(ifig).Axis(k).YMax;
                    handles.Figure(ifig).Axis(i).XTick=handles.Figure(ifig).Axis(k).XTick;
                    handles.Figure(ifig).Axis(i).YTick=handles.Figure(ifig).Axis(k).YTick;
                    handles.Figure(ifig).Axis(i).XGrid=handles.Figure(ifig).Axis(k).XGrid;
                    handles.Figure(ifig).Axis(i).YGrid=handles.Figure(ifig).Axis(k).YGrid;
                    handles.Figure(ifig).Axis(i).DecimX=handles.Figure(ifig).Axis(k).DecimX;
                    handles.Figure(ifig).Axis(i).DecimY=handles.Figure(ifig).Axis(k).DecimY;
                    handles.Figure(ifig).Axis(i).XScale=handles.Figure(ifig).Axis(k).XScale;
                    handles.Figure(ifig).Axis(i).YScale=handles.Figure(ifig).Axis(k).YScale;
 
                case {'timeseries'}
                    handles.Figure(ifig).Axis(i).YearMin=handles.Figure(ifig).Axis(k).YearMin;
                    handles.Figure(ifig).Axis(i).YearMax=handles.Figure(ifig).Axis(k).YearMax;
                    handles.Figure(ifig).Axis(i).MonthMin=handles.Figure(ifig).Axis(k).MonthMin;
                    handles.Figure(ifig).Axis(i).MonthMax=handles.Figure(ifig).Axis(k).MonthMax;
                    handles.Figure(ifig).Axis(i).DayMin=handles.Figure(ifig).Axis(k).DayMin;
                    handles.Figure(ifig).Axis(i).DayMax=handles.Figure(ifig).Axis(k).DayMax;
                    handles.Figure(ifig).Axis(i).HourMin=handles.Figure(ifig).Axis(k).HourMin;
                    handles.Figure(ifig).Axis(i).HourMax=handles.Figure(ifig).Axis(k).HourMax;
                    handles.Figure(ifig).Axis(i).MinuteMin=handles.Figure(ifig).Axis(k).MinuteMin;
                    handles.Figure(ifig).Axis(i).MinuteMax=handles.Figure(ifig).Axis(k).MinuteMax;
                    handles.Figure(ifig).Axis(i).SecondMin=handles.Figure(ifig).Axis(k).SecondMin;
                    handles.Figure(ifig).Axis(i).SecondMax=handles.Figure(ifig).Axis(k).SecondMax;
                    handles.Figure(ifig).Axis(i).YearTick=handles.Figure(ifig).Axis(k).YearTick;
                    handles.Figure(ifig).Axis(i).MonthTick=handles.Figure(ifig).Axis(k).MonthTick;
                    handles.Figure(ifig).Axis(i).DayTick=handles.Figure(ifig).Axis(k).DayTick;
                    handles.Figure(ifig).Axis(i).HourTick=handles.Figure(ifig).Axis(k).HourTick;
                    handles.Figure(ifig).Axis(i).MinuteTick=handles.Figure(ifig).Axis(k).MinuteTick;
                    handles.Figure(ifig).Axis(i).SecondTick=handles.Figure(ifig).Axis(k).SecondTick;
                    handles.Figure(ifig).Axis(i).DateFormat=handles.Figure(ifig).Axis(k).DateFormat;
                    handles.Figure(ifig).Axis(i).YMin=handles.Figure(ifig).Axis(k).YMin;
                    handles.Figure(ifig).Axis(i).YMax=handles.Figure(ifig).Axis(k).YMax;
                    handles.Figure(ifig).Axis(i).YTick=handles.Figure(ifig).Axis(k).YTick;
                    handles.Figure(ifig).Axis(i).XGrid=handles.Figure(ifig).Axis(k).XGrid;
                    handles.Figure(ifig).Axis(i).YGrid=handles.Figure(ifig).Axis(k).YGrid;
                    handles.Figure(ifig).Axis(i).DecimY=handles.Figure(ifig).Axis(k).DecimY;
                    handles.Figure(ifig).Axis(i).XScale=handles.Figure(ifig).Axis(k).XScale;
                    handles.Figure(ifig).Axis(i).YScale=handles.Figure(ifig).Axis(k).YScale;
 
            end
        end
    end
end
