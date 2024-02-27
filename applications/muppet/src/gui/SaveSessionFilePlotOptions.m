function SaveSessionFilePlotOptions(handles,fid,ifig,j,k)

Plt=handles.Figure(ifig).Axis(j).Plot(k);

txt=['      Dataset "' Plt.Name '"'];
fprintf(fid,'%s\n',txt);

txt=['         PlotRoutine   "' Plt.PlotRoutine '"'];
fprintf(fid,'%s\n',txt);

switch lower(Plt.PlotRoutine),

    case {'plotcontourmap'}

        if Plt.ContourLabels==1
            txt=['         ContourLabels yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         LabelSpacing  ' num2str(Plt.LabelSpacing)];
            fprintf(fid,'%s \n',txt);
            txt=['         Font       "' Plt.Font '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontSize   ' num2str(Plt.FontSize)];
            fprintf(fid,'%s \n',txt);
            txt=['         FontWeight "' Plt.FontWeight '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontAngle  "' Plt.FontAngle '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontColor  "' Plt.FontColor '"'];
            fprintf(fid,'%s \n',txt);
        end
        if Plt.FieldThinningFactor1~=1
            txt=['         FieldThinningFactor  ' num2str(Plt.FieldThinningFactor1)];
            fprintf(fid,'%s\n',txt);
        end

    case {'plotcontourmaplines'}

        if Plt.ContourLabels==1
            txt=['         ContourLabels yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         LabelSpacing  ' num2str(Plt.LabelSpacing)];
            fprintf(fid,'%s \n',txt);
            txt=['         Font       "' Plt.Font '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontSize   ' num2str(Plt.FontSize)];
            fprintf(fid,'%s \n',txt);
            txt=['         FontWeight "' Plt.FontWeight '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontAngle  "' Plt.FontAngle '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontColor  "' Plt.FontColor '"'];
            fprintf(fid,'%s \n',txt);
        end
        if Plt.FieldThinningFactor1~=1
            txt=['         FieldThinningFactor  ' num2str(Plt.FieldThinningFactor1)];
            fprintf(fid,'%s\n',txt);
        end

        txt=['         LineColor     "' Plt.LineColor '"'];
        fprintf(fid,'%s \n',txt);

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);

        if Plt.LineWidth~=0.5
            txt=['         LineWidth     ' num2str(Plt.LineWidth)];
            fprintf(fid,'%s \n',txt);
        end


    case {'plot3dsurface','plot3dsurfacelines'}

        txt=['         Shading       "' Plt.Shading '"'];
        fprintf(fid,'%s \n',txt);

        if Plt.OneColor==1
            txt=['         Color         ' num2str(Plt.Color)];
            fprintf(fid,'%s \n',txt);
        end

        txt=['         Transparency  ' num2str(Plt.Transparency)];
        fprintf(fid,'%s \n',txt);
        txt=['         SpecularStrength  ' num2str(Plt.SpecularStrength)];
        fprintf(fid,'%s \n',txt);

        if Plt.Draw3DGrid==1
            txt=['         Draw3DGrid    yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         LineColor     "' Plt.LineColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         LineColor     "' Plt.LineColor '"'];
            fprintf(fid,'%s \n',txt);

            txt=['         LineStyle     "' Plt.LineStyle '"'];
            fprintf(fid,'%s \n',txt);

            if Plt.LineWidth~=0.5
                txt=['         LineWidth     ' num2str(Plt.LineWidth)];
                fprintf(fid,'%s \n',txt);
            end

        else
            txt=['         DrawGrid      no'];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotsamples'}

        txt=['         Marker     "' Plt.Marker '"'];
        fprintf(fid,'%s \n',txt);

        if strcmpi(Plt.Marker,'none')==0
            txt=['         MarkerEdgeColor "' Plt.MarkerEdgeColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         MarkerFaceColor "' Plt.MarkerFaceColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         MarkerSize ' num2str(Plt.MarkerSize )];
            fprintf(fid,'%s \n',txt);
        end
        
        if Plt.AddText==1
            txt=['         AddText    yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         Font       "' Plt.Font '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontSize   ' num2str(Plt.FontSize)];
            fprintf(fid,'%s \n',txt);
            txt=['         FontWeight "' Plt.FontWeight '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontAngle  "' Plt.FontAngle '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontColor  "' Plt.FontColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         TextPosition "' Plt.TextPosition '"'];
            fprintf(fid,'%s \n',txt);
        else
            txt=['         AddText    no'];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotannotation'}

        if Plt.AddText==1
            txt=['         AddText    yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         Font       "' Plt.Font '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontSize   ' num2str(Plt.FontSize)];
            fprintf(fid,'%s \n',txt);
            txt=['         FontWeight "' Plt.FontWeight '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontAngle  "' Plt.FontAngle '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontColor  "' Plt.FontColor '"'];
            fprintf(fid,'%s \n',txt);
            if strcmpi(Plt.Marker,'none')
                txt=['         HorAlignment  ' Plt.HorAl];
                fprintf(fid,'%s \n',txt);
                txt=['         VerAlignment  ' Plt.VerAl];
                fprintf(fid,'%s \n',txt);
            else
                txt=['         TextPosition "' Plt.TextPosition '"'];
                fprintf(fid,'%s \n',txt);
            end
        else
            txt=['         AddText    no'];
            fprintf(fid,'%s \n',txt);
        end

        if strcmpi(Plt.Marker,'none')==0
            txt=['         Marker   "' Plt.Marker '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         MarkerEdgeColor "' Plt.MarkerEdgeColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         MarkerFaceColor "' Plt.MarkerFaceColor '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         MarkerSize      ' num2str(Plt.MarkerSize )];
            fprintf(fid,'%s \n',txt);
        else
        end
        
        if ~isempty(Plt.LegendText)
            txt=['         LegendText    "' Plt.LegendText '"'];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotcrosssections'}

        txt=['         Font       "' Plt.Font '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontSize   ' num2str(Plt.FontSize)];
        fprintf(fid,'%s \n',txt);
        txt=['         FontWeight "' Plt.FontWeight '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontAngle  "' Plt.FontAngle '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontColor  "' Plt.FontColor '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         LineColor  "' Plt.LineColor '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         LineStyle  "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);
        if Plt.LineWidth~=0.5
            txt=['         LineWidth     ' num2str(Plt.LineWidth)];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotvectors','plotcoloredvectors'}

        txt=['         UnitVector    ' num2str(Plt.UnitVector)];
        fprintf(fid,'%s \n',txt);
        if handles.Figure(ifig).Axis(j).PlotVectorLegend==1
            txt=['         VectorLegendLength  ' num2str(Plt.VectorLegendLength)];
            fprintf(fid,'%s\n',txt);
            txt=['         VectorLegendText    "' Plt.VectorLegendText '"'];
            fprintf(fid,'%s\n',txt);
        end
        if strcmpi(Plt.FieldThinningType,'none')==0
            txt=['         FieldThinningType   "' Plt.FieldThinningType '"'];
            fprintf(fid,'%s\n',txt);
            if Plt.FieldThinningFactor1~=1
                txt=['         FieldThinningFactor1 ' num2str(Plt.FieldThinningFactor1)];
                fprintf(fid,'%s\n',txt);
            end
            if Plt.FieldThinningFactor2~=1
                txt=['         FieldThinningFactor2 ' num2str(Plt.FieldThinningFactor2)];
                fprintf(fid,'%s\n',txt);
            end
        end
        if Plt.VerticalVectorScaling~=1
            txt=['         VerticalScaling      ' num2str(Plt.VerticalVectorScaling)];
            fprintf(fid,'%s\n',txt);
        end
        if strcmpi(Plt.VectorColor,'k')==0 && strcmpi(Plt.PlotRoutine,'plotcoloredvectors')==0
            txt=['         VectorColor   "' Plt.VectorColor '"'];
            fprintf(fid,'%s\n',txt);
        end
        
        if strcmpi(Plt.PlotRoutine,'plotcoloredvectors')
            if Plt.PlotColorBar==1
                txt=['         ColorBar       yes'];
                fprintf(fid,'%s\n',txt);
                txt=['         ColorBarPosition ' num2str(Plt.ColorBarPosition)];
                fprintf(fid,'%s\n',txt);
                if size(Plt.ColorBarLabel)>0
                    txt=['         ColorBarLabel "' Plt.ColorBarLabel '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarLabelIncrement>1
                    txt=['         ColorBarTickIncrement ' num2str(Plt.ColorBarLabelIncrement)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~isempty(Plt.ColorBarUnit)
                    txt=['         ColorBarUnit "' Plt.ColorBarUnit '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarType>1
                    txt=['         BarType    ' num2str(Plt.ColorBarType)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFont,'helvetica')
                    txt=['         ColorBarFont       "' Plt.ColorBarFont '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarFontSize~=8
                    txt=['         ColorBarFontSize   ' num2str(Plt.ColorBarFontSize)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontAngle,'normal')
                    txt=['         ColorBarFontAngle  "' Plt.ColorBarFontAngle '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontWeight,'normal')
                    txt=['         ColorBarFontWeight "' Plt.ColorBarFontWeight '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontColor,'black')
                    txt=['         ColorBarFontColor  "' Plt.ColorBarFontColor '"'];
                    fprintf(fid,'%s\n',txt);
                end
                txt=['         BarDecim       ' num2str(Plt.ColorBarDecimals)];
                fprintf(fid,'%s\n',txt);
            end
        end

    case {'plotcurvedarrows','plotcoloredcurvedarrows'}

        if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')
            txt=['         Contours       ' num2str(Plt.CMin) ' ' num2str(Plt.CStep) ' ' num2str(Plt.CMax)];
            fprintf(fid,'%s\n',txt);
            txt=['         ColorMap       "' Plt.ColorMap '"'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['         FillColor      ' Plt.FillColor];
            fprintf(fid,'%s \n',txt);
        end
        txt=['         LineColor      ' Plt.LineColor];
        fprintf(fid,'%s \n',txt);
        txt=['         DxCurVec       ' num2str(Plt.DxCurVec)];
        fprintf(fid,'%s \n',txt);
        txt=['         DtCurVec       ' num2str(Plt.DtCurVec)];
        fprintf(fid,'%s \n',txt);
        txt=['         LifeSpanCurVec ' num2str(Plt.LifeSpanCurVec)];
        fprintf(fid,'%s \n',txt);
        if Plt.RelSpeedCurVec~=1
            txt=['         RelSpeedCurVec ' num2str(Plt.RelSpeedCurVec)];
            fprintf(fid,'%s \n',txt);
        end
        if Plt.NoFramesStationaryCurVec>0
            txt=['         NoFramesStationaryCurVec ' num2str(Plt.NoFramesStationaryCurVec)];
            fprintf(fid,'%s \n',txt);
        end
        txt=['         HeadThickness  ' num2str(Plt.HeadThickness)];
        fprintf(fid,'%s \n',txt);
        txt=['         ArrowThickness ' num2str(Plt.ArrowThickness)];
        fprintf(fid,'%s \n',txt);

        if handles.Figure(ifig).Axis(j).PlotVectorLegend==1
            txt=['         VectorLegendLength  ' num2str(Plt.VectorLegendLength)];
            fprintf(fid,'%s\n',txt);
            txt=['         VectorLegendText    "' Plt.VectorLegendText '"'];
            fprintf(fid,'%s\n',txt);
        end
        
        if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')
            if Plt.PlotColorBar==1
                txt=['         ColorBar       yes'];
                fprintf(fid,'%s\n',txt);
                txt=['         ColorBarPosition ' num2str(Plt.ColorBarPosition)];
                fprintf(fid,'%s\n',txt);
                if size(Plt.ColorBarLabel)>0
                    txt=['         ColorBarLabel "' Plt.ColorBarLabel '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarLabelIncrement>1
                    txt=['         ColorBarTickIncrement ' num2str(Plt.ColorBarLabelIncrement)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~isempty(Plt.ColorBarUnit)
                    txt=['         ColorBarUnit "' Plt.ColorBarUnit '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarType>1
                    txt=['         BarType    ' num2str(Plt.ColorBarType)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFont,'helvetica')
                    txt=['         ColorBarFont       "' Plt.ColorBarFont '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if Plt.ColorBarFontSize~=8
                    txt=['         ColorBarFontSize   ' num2str(Plt.ColorBarFontSize)];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontAngle,'normal')
                    txt=['         ColorBarFontAngle  "' Plt.ColorBarFontAngle '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontWeight,'normal')
                    txt=['         ColorBarFontWeight "' Plt.ColorBarFontWeight '"'];
                    fprintf(fid,'%s\n',txt);
                end
                if ~strcmpi(Plt.ColorBarFontColor,'black')
                    txt=['         ColorBarFontColor  "' Plt.ColorBarFontColor '"'];
                    fprintf(fid,'%s\n',txt);
                end
                txt=['         BarDecim       ' num2str(Plt.ColorBarDecimals)];
                fprintf(fid,'%s\n',txt);
            end
        end

    case {'plotcontourlines'}

        if strcmpi(Plt.ContourType,'custom')
            txt=['         ContourType "' Plt.ContourType '"'];
            fprintf(fid,'%s\n',txt);
        end

        if strcmpi(Plt.ContourType,'custom')
            txt=['         StartContours'];
            fprintf(fid,'%s\n',txt);
            for k=1:size(Plt.Contours,2)
                txt=['             ' num2str(Plt.Contours(k))];
                fprintf(fid,'%s\n',txt);
            end
            txt=['         EndContours'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['         Contours  ' num2str(Plt.CMin) ' ' num2str(Plt.CStep) ' ' num2str(Plt.CMax)];
            fprintf(fid,'%s\n',txt);
        end

        if Plt.ContourLabels==1
            txt=['         ContourLabels yes'];
            fprintf(fid,'%s \n',txt);

            txt=['         LabelSpacing  ' num2str(Plt.LabelSpacing)];
            fprintf(fid,'%s \n',txt);
            txt=['         Font       "' Plt.Font '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontSize   ' num2str(Plt.FontSize)];
            fprintf(fid,'%s \n',txt);
            txt=['         FontWeight "' Plt.FontWeight '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontAngle  "' Plt.FontAngle '"'];
            fprintf(fid,'%s \n',txt);
            txt=['         FontColor  "' Plt.FontColor '"'];
            fprintf(fid,'%s \n',txt);

        end

        txt=['         LineColor     "' Plt.LineColor '"'];
        fprintf(fid,'%s \n',txt);

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);

        if Plt.LineWidth~=0.5
            txt=['         LineWidth     ' num2str(Plt.LineWidth)];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotline','plotspline'}

        txt=['         LineColor     "' Plt.LineColor '"'];
        fprintf(fid,'%s \n',txt);

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);

        txt=['         Marker        "' Plt.Marker '"'];
        fprintf(fid,'%s \n',txt);

        if Plt.LineWidth~=0.5
            txt=['         LineWidth     ' num2str(Plt.LineWidth)];
            fprintf(fid,'%s \n',txt);
        end

        txt=['         LegendText    "' Plt.LegendText '"'];
        fprintf(fid,'%s \n',txt);

        if Plt.RightAxis
            txt=['         Axis          right'];
            fprintf(fid,'%s \n',txt);
        end

        if Plt.TimeBar(1)>0;
            tim=MatTime(Plt.TimeBar(1),Plt.TimeBar(2));
            datestring=datestr(tim,'yyyymmdd');
            timestring=datestr(tim,'HHMMSS');
            txt=['         TimeBar       ' datestring ' ' timestring];
            fprintf(fid,'%s \n',txt);
        end

    case {'plothistogram'}

        txt=['         LegendText    "' Plt.LegendText '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FillColor         "' Plt.FillColor '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         EdgeColor         "' Plt.EdgeColor '"'];
        fprintf(fid,'%s \n',txt);

    case {'plotstackedarea'}

        txt=['         LegendText    "' Plt.LegendText '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FillColor         "' Plt.FillColor '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         EdgeColor         "' Plt.EdgeColor '"'];
        fprintf(fid,'%s \n',txt);

    case {'plotpolyline','plotgrid'}

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         LineWidth     ' num2str(Plt.LineWidth)];
        fprintf(fid,'%s \n',txt);

        if ischar(Plt.LineColor)==1
            txt=['         LineColor     "' Plt.LineColor '"'];
            fprintf(fid,'%s \n',txt);
        else
            txt=['         LineColor     ' num2str(Plt.LineColor)];
            fprintf(fid,'%s \n',txt);
        end

        if Plt.FillPolygons==1
            txt=['         FillPolygons  yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         FillColor     "' Plt.FillColor '"'];
            fprintf(fid,'%s \n',txt);
            if Plt.MaxDistance~=0
                txt=['         MaxDistance   ' num2str(Plt.MaxDistance)];
                fprintf(fid,'%s \n',txt);
            end
        end
        if Plt.PolygonElevation~=1000
            txt=['         Elevation     ' num2str(Plt.PolygonElevation)];
            fprintf(fid,'%s \n',txt);
        end
        if size(Plt.LegendText,2)>0
            txt=['         LegendText    "' Plt.LegendText '"'];
            fprintf(fid,'%s \n',txt);
        end

    case {'plotpolygon3d','plotpolyline3d'}

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         LineWidth     ' num2str(Plt.LineWidth)];
        fprintf(fid,'%s \n',txt);
        txt=['         LineColor     "' Plt.LineColor '"'];
        fprintf(fid,'%s \n',txt);
        if Plt.FillPolygons==1
            txt=['         FillPolygons  yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         FillColor     ' num2str(Plt.FillColor)];
            fprintf(fid,'%s \n',txt);
        end
        %                 if Plt.PolygonElevation~=1000
        %                     txt=['      Elevation     ' num2str(Plt.PolygonElevation)];
        %                     fprintf(fid,'%s \n',txt);
        %                 end
        txt=['         Elevations    ' num2str(Plt.Elevations)];
        fprintf(fid,'%s \n',txt);

    case {'plotkub'}

        switch Plt.KubFill,
            case 0
                txt=['         FillAreas     no'];
            case 1
                txt=['         FillAreas     yes'];
        end
        fprintf(fid,'%s \n',txt);

        txt=['         LineWidth     ' num2str(Plt.LineWidth)];
        fprintf(fid,'%s \n',txt);
        txt=['         LineColor     ' Plt.LineColor];
        fprintf(fid,'%s \n',txt);

        switch Plt.AreaText,
            case 1
                txt=['         AreaText      Quantity'];
            case 2
                txt=['         AreaText      AreaNumber'];
            case 3
                txt=['         AreaText      none'];
        end
        fprintf(fid,'%s \n',txt);

        txt=['         Decimals      ' num2str(Plt.Decim)];
        fprintf(fid,'%s \n',txt);
        txt=['         Multiply      ' num2str(Plt.Multiply)];
        fprintf(fid,'%s \n',txt);

        txt=['         Font          "' Plt.Font '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontSize      ' num2str(Plt.FontSize)];
        fprintf(fid,'%s \n',txt);
        txt=['         FontWeight    ' Plt.FontWeight];
        fprintf(fid,'%s \n',txt);
        txt=['         FontAngle     ' Plt.FontAngle];
        fprintf(fid,'%s \n',txt);
        txt=['         FontColor     ' Plt.FontColor];
        fprintf(fid,'%s \n',txt);

    case {'plotlint'}

        switch Plt.FillPolygons,
            case 0
                txt=['         FillArrows    no'];
                fprintf(fid,'%s \n',txt);
            case 1
                txt=['         FillArrows    yes'];
                fprintf(fid,'%s \n',txt);
                txt=['         ArrowColor    ' Plt.ArrowColor];
                fprintf(fid,'%s \n',txt);
        end
        txt=['         LintScale     ' num2str(Plt.LintScale)];
        fprintf(fid,'%s \n',txt);
        if Plt.UnitArrow~=0
            txt=['         UnitArrow    ' num2str(Plt.UnitArrow)];
            fprintf(fid,'%s \n',txt);
        end            
        txt=['         LineWidth     ' num2str(Plt.LineWidth)];
        fprintf(fid,'%s \n',txt);
        txt=['         LineColor     ' Plt.LineColor];
        fprintf(fid,'%s \n',txt);

        switch Plt.AddText,
            case 0
                txt=['         AddText       no'];
            case 1
                txt=['         AddText       yes'];
        end
        fprintf(fid,'%s \n',txt);

        txt=['         Decimals      ' num2str(Plt.Decim)];
        fprintf(fid,'%s \n',txt);
        txt=['         Multiply      ' num2str(Plt.Multiply)];
        fprintf(fid,'%s \n',txt);

        txt=['         Font          "' Plt.Font '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontSize      ' num2str(Plt.FontSize)];
        fprintf(fid,'%s \n',txt);
        txt=['         FontWeight    ' Plt.FontWeight];
        fprintf(fid,'%s \n',txt);
        txt=['         FontAngle     ' Plt.FontAngle];
        fprintf(fid,'%s \n',txt);
        txt=['         FontColor     ' Plt.FontColor];
        fprintf(fid,'%s \n',txt);

    case {'plotimage'}

        txt=['         Transparency  ' num2str(Plt.Transparency)];
        fprintf(fid,'%s \n',txt);
        txt=['         WhiteValue    ' num2str(Plt.WhiteVal)];
        fprintf(fid,'%s \n',txt);

    case {'plotgeoimage'}

        txt=['         Elevation     ' num2str(Plt.Elevation)];
        fprintf(fid,'%s \n',txt);
        txt=['         Transparency  ' num2str(Plt.Transparency)];
        fprintf(fid,'%s \n',txt);
        txt=['         WhiteValue    ' num2str(Plt.WhiteVal)];
        fprintf(fid,'%s \n',txt);

    case {'plotrose'}
        txt=['         MaximumRadius ' num2str(Plt.MaxRadius)];
        fprintf(fid,'%s \n',txt);
        txt=['         RadiusStep    ' num2str(Plt.RadiusStep)];
        fprintf(fid,'%s \n',txt);

        if Plt.ColoredWindRose==0
            txt=['         ColoredWindRose no'];
        else
            txt=['         ColoredWindRose yes'];
        end
        fprintf(fid,'%s \n',txt);

        if Plt.AddWindRoseLegend==0
            txt=['         AddWindRoseLegend no'];
            fprintf(fid,'%s \n',txt);
        else
            txt=['         AddWindRoseLegend yes'];
            fprintf(fid,'%s \n',txt);
        end

        if Plt.AddWindRoseTotals==0
            txt=['         PlotWindRoseTotals no'];
        else
            txt=['         PlotWindRoseTotals yes'];
        end
        fprintf(fid,'%s \n',txt);
        
    case {'plottext'}
        txt=['         Font          "' Plt.Font '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         FontSize      ' num2str(Plt.FontSize)];
        fprintf(fid,'%s \n',txt);
        txt=['         FontWeight    ' Plt.FontWeight];
        fprintf(fid,'%s \n',txt);
        txt=['         FontAngle     ' Plt.FontAngle];
        fprintf(fid,'%s \n',txt);
        txt=['         FontColor     ' Plt.FontColor];
        fprintf(fid,'%s \n',txt);
        txt=['         HorAlignment  ' Plt.HorAl];
        fprintf(fid,'%s \n',txt);
        txt=['         VerAlignment  ' Plt.VerAl];
        fprintf(fid,'%s \n',txt);

    case {'drawpolyline','drawspline'}

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);
        txt=['         LineWidth     ' num2str(Plt.LineWidth)];
        fprintf(fid,'%s \n',txt);

        if ischar(Plt.LineColor)==1
            txt=['         LineColor     "' Plt.LineColor '"'];
            fprintf(fid,'%s \n',txt);
        else
            txt=['         LineColor     ' num2str(Plt.LineColor)];
            fprintf(fid,'%s \n',txt);
        end

        if Plt.FillPolygons==1
            txt=['         FillPolygons  yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         FillColor     "' Plt.FillColor '"'];
            fprintf(fid,'%s \n',txt);
        end
        if Plt.PolygonElevation~=1000
            txt=['         Elevation     ' num2str(Plt.PolygonElevation)];
            fprintf(fid,'%s \n',txt);
        end
        if size(Plt.LegendText,2)>0
            txt=['         LegendText    "' Plt.LegendText '"'];
            fprintf(fid,'%s \n',txt);
        end

    case {'drawcurvedarrow','drawcurveddoublearrow'}

        txt=['         ArrowWidth    ' num2str(Plt.ArrowWidth)];
        fprintf(fid,'%s \n',txt);

        txt=['         HeadWidth     ' num2str(Plt.HeadWidth)];
        fprintf(fid,'%s \n',txt);

        txt=['         LineStyle     "' Plt.LineStyle '"'];
        fprintf(fid,'%s \n',txt);

        if ischar(Plt.LineColor)==1
            txt=['         LineColor     "' Plt.LineColor '"'];
            fprintf(fid,'%s \n',txt);
        else
            txt=['         LineColor     ' num2str(Plt.LineColor)];
            fprintf(fid,'%s \n',txt);
        end

        if Plt.FillPolygons==1
            txt=['         FillPolygons  yes'];
            fprintf(fid,'%s \n',txt);
            txt=['         FillColor     "' Plt.FillColor '"'];
            fprintf(fid,'%s \n',txt);
        end
        if Plt.PolygonElevation~=1000
            txt=['         Elevation     ' num2str(Plt.PolygonElevation)];
            fprintf(fid,'%s \n',txt);
        end
        if size(Plt.LegendText,2)>0
            txt=['         LegendText    "' Plt.LegendText '"'];
            fprintf(fid,'%s \n',txt);
        end

end

if Plt.AddDate
    txt=['         AddDate       "' Plt.AddDatePosition '"'];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDatePrefix "' Plt.AddDatePrefix '"'];
    fprintf(fid,'%s \n',txt);
    if ~isempty(deblank(Plt.AddDateSuffix))
        txt=['         AddDateSuffix "' Plt.AddDateSuffix '"'];
        fprintf(fid,'%s \n',txt);
    end
    txt=['         AddDateFormat ' num2str(Plt.AddDateFormat)];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDateFont          "' Plt.AddDateFont '"'];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDateFontSize      ' num2str(Plt.AddDateFontSize)];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDateFontWeight    ' Plt.AddDateFontWeight];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDateFontAngle     ' Plt.AddDateFontAngle];
    fprintf(fid,'%s \n',txt);
    txt=['         AddDateFontColor     ' Plt.AddDateFontColor];
    fprintf(fid,'%s \n',txt);
end

txt=['      EndDataset'];
fprintf(fid,'%s\n',txt);

txt='';
fprintf(fid,'%s \n',txt);

