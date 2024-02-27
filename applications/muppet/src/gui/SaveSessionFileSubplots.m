function SaveSessionFileSubplots(handles,fid,ifig,j,iLayout)

Axis=handles.Figure(ifig).Axis(j);

txt=['   Subplot   "' Axis.Name '"'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

txt=['      Position   ' num2str(Axis.Position)];
fprintf(fid,'%s \n',txt);

if strcmpi(Axis.BackgroundColor,'white')==0
    txt=['      BackgroundColor "' Axis.BackgroundColor '"'];
    fprintf(fid,'%s \n',txt);
end

if iLayout==0
    
    if strcmpi(Axis.PlotType,'unknown')==0
        txt=['      PlotType   "' Axis.PlotType '"'];
        fprintf(fid,'%s \n',txt);
    end
    
    PlotType=lower(Axis.PlotType);

    if max(strcmp(PlotType,{'2d','3d','xy'}))
        txt=['      XAxis      ' num2str(Axis.XMin) ' ' num2str(Axis.XMax)];
        fprintf(fid,'%s\n',txt);
    end

    switch lower(PlotType)
        case{'timeseries','timestack'}
            txt1=['      TMin       ' num2str(Axis.YearMin,'%0.4i')];
            txt2=[num2str(Axis.MonthMin,'%0.2i')];
            txt3=[num2str(Axis.DayMin,'%0.2i') ' '];
            txt4=[num2str(Axis.HourMin,'%0.2i')];
            txt5=[num2str(Axis.MinuteMin,'%0.2i')];
            txt6=[num2str(Axis.SecondMin,'%0.2i')];
            txt=[txt1,txt2,txt3,txt4,txt5,txt6];
            fprintf(fid,'%s\n',txt);

            txt1=['      TMax       ' num2str(Axis.YearMax,'%0.4i')];
            txt2=[num2str(Axis.MonthMax,'%0.2i')];
            txt3=[num2str(Axis.DayMax,'%0.2i') ' '];
            txt4=[num2str(Axis.HourMax,'%0.2i')];
            txt5=[num2str(Axis.MinuteMax,'%0.2i')];
            txt6=[num2str(Axis.SecondMax,'%0.2i')];
            txt=[txt1,txt2,txt3,txt4,txt5,txt6];
            fprintf(fid,'%s\n',txt);

            txt1=['      TTick      ' num2str(Axis.YearTick) ' '];
            txt2=[num2str(Axis.MonthTick) ' '];
            txt3=[num2str(Axis.DayTick) ' '];
            txt4=[num2str(Axis.HourTick) ' '];
            txt5=[num2str(Axis.MinuteTick) ' '];
            txt6=[num2str(Axis.SecondTick)];
            txt=[txt1,txt2,txt3,txt4,txt5,txt6];
            fprintf(fid,'%s\n',txt);

            if Axis.AddDate
                txt=['      AddDate    yes'];
                fprintf(fid,'%s\n',txt);
            end

            txt=['      DateFormat "' Axis.DateFormat '"'];
            fprintf(fid,'%s\n',txt);

    end

    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','timestack'}))
        txt=['      YAxis      ' num2str(Axis.YMin) ' ' num2str(Axis.YMax)];
        fprintf(fid,'%s\n',txt);
    end

    if strcmp(PlotType,'3d')
        txt=['      ZAxis      ' num2str(Axis.ZMin) ' ' num2str(Axis.ZMax)];
        fprintf(fid,'%s\n',txt);
    end

    if max(strcmp(PlotType,{'2d','3d','xy'}))
        txt=['      XTick      ' num2str(Axis.XTick)];
        fprintf(fid,'%s\n',txt);
    end

    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','timestack'}))
        txt=['      YTick      ' num2str(Axis.YTick)];
        fprintf(fid,'%s\n',txt);
    end

    if strcmp(PlotType,'3d')
        txt=['      ZTick      ' num2str(Axis.ZTick)];
        fprintf(fid,'%s\n',txt);
    end

    if max(strcmp(PlotType,{'2d','3d','xy'}))
        txt=['      DecimalsX  ' num2str(Axis.DecimX)];
        fprintf(fid,'%s\n',txt);
    end

    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','timestack'}))
        txt=['      DecimalsY  ' num2str(Axis.DecimY)];
        fprintf(fid,'%s\n',txt);
    end

    if max(strcmp(PlotType,{'3d'}))
        txt=['      DecimalsZ  ' num2str(Axis.DecimZ)];
        fprintf(fid,'%s\n',txt);
    end

    if Axis.XTickMultiply~=1
        txt=['      XTickMultiply ',num2str(Axis.XTickMultiply)];
        fprintf(fid,'%s\n',txt);
    end

    if Axis.YTickMultiply~=1
        txt=['      YTickMultiply ',num2str(Axis.YTickMultiply)];
        fprintf(fid,'%s\n',txt);
    end

    if Axis.XTickAdd~=0
        txt=['      XTickAdd   ',num2str(Axis.XTickAdd)];
        fprintf(fid,'%s\n',txt);
    end

    if Axis.YTickAdd~=0
        txt=['      YTickAdd   ',num2str(Axis.YTickAdd)];
        fprintf(fid,'%s\n',txt);
    end
    
    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','timestack'}))

        if ~strcmpi(Axis.AxesFont,'helvetica')
            txt=['      AxesFont       "' Axis.AxesFont '"'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.AxesFontSize~=8
            txt=['      AxesFontSize   ' num2str(Axis.AxesFontSize)];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.AxesFontAngle,'normal')
            txt=['      AxesFontAngle  "' Axis.AxesFontAngle '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.AxesFontWeight,'normal')
            txt=['      AxesFontWeight "' Axis.AxesFontWeight '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.AxesFontColor,'black')
            txt=['      AxesFontColor  "' Axis.AxesFontColor '"'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'2d'}))

        if Axis.AxesEqual
            txt=['      Scale      ' num2str(Axis.Scale)];
            fprintf(fid,'%s\n',txt);
        else
            txt=['      AxesEqual  no'];
            fprintf(fid,'%s\n',txt);
        end
    end

    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','timestack'}))

        if Axis.XGrid
            txt=['      XGrid      yes'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['      XGrid      no'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.YGrid
            txt=['      YGrid      yes'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['      YGrid      no'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'3d'}))

        if Axis.ZGrid
            txt=['      ZGrid      yes'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['      ZGrid      no'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'3d'}))
        txt=['      CameraTarget    ' num2str(Axis.CameraTarget)];
        fprintf(fid,'%s\n',txt);
        txt=['      CameraAngle     ' num2str(Axis.CameraAngle)];
        fprintf(fid,'%s\n',txt);
        txt=['      CameraViewAngle ' num2str(Axis.CameraViewAngle)];
        fprintf(fid,'%s\n',txt);
        txt=['      DataAspectRatio ' num2str(Axis.DataAspectRatio)];
        fprintf(fid,'%s\n',txt);
        txt=['      LightStrength   ' num2str(Axis.LightStrength)];
        fprintf(fid,'%s\n',txt);
        txt=['      LightAzimuth    ' num2str(Axis.LightAzimuth)];
        fprintf(fid,'%s\n',txt);
        txt=['      LightElevation  ' num2str(Axis.LightElevation)];
        fprintf(fid,'%s\n',txt);
        if Axis.Perspective==0
            txt='      Perspective     no';
            fprintf(fid,'%s\n',txt);
        end
    end

    if max(strcmp(PlotType,{'2d','xy','timeseries'}))

        if strcmp(Axis.XScale,'linear')==0
            txt=['      XScale     ' Axis.XScale];
            fprintf(fid,'%s\n',txt);
        end


        if strcmp(Axis.YScale,'linear')==0
            txt=['      YScale     ' Axis.YScale];
            fprintf(fid,'%s\n',txt);
        end
    end
    
    if max(strcmp(PlotType,{'2d','xy','timeseries','3d','rose','timestack'}))
        
        txt=['      Title      "' Axis.Title '"'];
        fprintf(fid,'%s\n',txt);

        if ~strcmpi(Axis.TitleFont,'helvetica')
            txt=['      TitleFont       "' Axis.TitleFont '"'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.TitleFontSize~=10
            txt=['      TitleFontSize   ' num2str(Axis.TitleFontSize)];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.TitleFontAngle,'normal')
            txt=['      TitleFontAngle  "' Axis.TitleFontAngle '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.TitleFontWeight,'normal')
            txt=['      TitleFontWeight "' Axis.TitleFontWeight '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.TitleFontColor,'black')
            txt=['      TitleFontColor  "' Axis.TitleFontColor '"'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'2d','3d','xy','timeseries','rose','timestack'}))

        if size(Axis.XLabel,2)>0
            txt=['      XLabel     "' Axis.XLabel '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.XLabelFont,'helvetica')
            txt=['      XLabelFont       "' Axis.XLabelFont '"'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.XLabelFontSize~=8
            txt=['      XLabelFontSize   ' num2str(Axis.XLabelFontSize)];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.XLabelFontAngle,'normal')
            txt=['      XLabelFontAngle  "' Axis.XLabelFontAngle '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.XLabelFontWeight,'normal')
            txt=['      XLabelFontWeight "' Axis.XLabelFontWeight '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.XLabelFontColor,'black')
            txt=['      XLabelFontColor  "' Axis.XLabelFontColor '"'];
            fprintf(fid,'%s\n',txt);
        end

        if size(Axis.YLabel,2)>0
            txt=['      YLabel     "' Axis.YLabel '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.YLabelFont,'helvetica')
            txt=['      YLabelFont       "' Axis.YLabelFont '"'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.YLabelFontSize~=8
            txt=['      YLabelFontSize   ' num2str(Axis.YLabelFontSize)];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.YLabelFontAngle,'normal')
            txt=['      YLabelFontAngle  "' Axis.YLabelFontAngle '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.YLabelFontWeight,'normal')
            txt=['      YLabelFontWeight "' Axis.YLabelFontWeight '"'];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.YLabelFontColor,'black')
            txt=['      YLabelFontColor  "' Axis.YLabelFontColor '"'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'2d','3d','timestack'}))

        txt=['      Colormap   "' num2str(Axis.ColMap) '"'];
        fprintf(fid,'%s\n',txt);

        if Axis.PlotColorBar==1

            txt=['      ColorBar   yes'];
            fprintf(fid,'%s\n',txt);

            txt=['      ColorBarPosition ' num2str(Axis.ColorBarPosition)];
            fprintf(fid,'%s\n',txt);

            if ~isempty(Axis.ColorBarLabel)
                txt=['      ColorBarLabel "' Axis.ColorBarLabel '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.ColorBarLabelIncrement>1
                txt=['      ColorBarTickIncrement ' num2str(Axis.ColorBarLabelIncrement)];
                fprintf(fid,'%s\n',txt);
            end

            if ~isempty(Axis.ColorBarUnit)
                txt=['      ColorBarUnit "' Axis.ColorBarUnit '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.ColorBarType>1
                txt=['      BarType    ' num2str(Axis.ColorBarType)];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.ColorBarFont,'helvetica')
                txt=['      ColorBarFont       "' Axis.ColorBarFont '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.ColorBarFontSize~=8
                txt=['      ColorBarFontSize   ' num2str(Axis.ColorBarFontSize)];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.ColorBarFontAngle,'normal')
                txt=['      ColorBarFontAngle  "' Axis.ColorBarFontAngle '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.ColorBarFontWeight,'normal')
                txt=['      ColorBarFontWeight "' Axis.ColorBarFontWeight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.ColorBarFontColor,'black')
                txt=['      ColorBarFontColor  "' Axis.ColorBarFontColor '"'];
                fprintf(fid,'%s\n',txt);
            end

            txt=['      BarDecim   ' num2str(Axis.ColorBarDecimals)];
            fprintf(fid,'%s\n',txt);

        end

        if strcmpi(Axis.ContourType,'custom')
            txt=['      ContourType "' Axis.ContourType '"'];
            fprintf(fid,'%s\n',txt);
            txt=['      StartContours'];
            fprintf(fid,'%s\n',txt);
            for k=1:size(Axis.Contours,2)
                txt=['          ' num2str(Axis.Contours(k))];
                fprintf(fid,'%s\n',txt);
            end
            txt=['      EndContours'];
            fprintf(fid,'%s\n',txt);
        else
            txt=['      Contours   ' num2str(Axis.CMin) ' ' num2str(Axis.CStep) ' ' num2str(Axis.CMax)];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'2d'}))

        if Axis.PlotScaleBar==1
            txt=['      Scalebar  ' num2str(Axis.ScaleBar)];
            fprintf(fid,'%s\n',txt);
            txt=['      ScalebarText  "' Axis.ScaleBarText '"'];
            fprintf(fid,'%s\n',txt);
        end

        if Axis.PlotNorthArrow==1
            txt=['      NorthArrow  ' num2str(Axis.NorthArrow)];
            fprintf(fid,'%s\n',txt);
        end

        if ~strcmpi(Axis.coordinateSystem.name,'unknown')
            txt=['      CoordinateSystemName  "' Axis.coordinateSystem.name '"'];
            fprintf(fid,'%s\n',txt);
            txt=['      CoordinateSystemType  "' Axis.coordinateSystem.type '"'];
            fprintf(fid,'%s\n',txt);

        end
        
%         if strcmpi(Axis.coordinateSystem.type,'geographic')
%             txt='      CoordinateSystemType  "geographic"';
%             fprintf(fid,'%s\n',txt);
%         end

        if Axis.PlotVectorLegend==1

            txt=['      VectorLegend  yes'];
            fprintf(fid,'%s\n',txt);
            txt=['      VectorLegendPosition ' num2str(Axis.VectorLegendPosition)];
            fprintf(fid,'%s\n',txt);

            if ~strcmpi(Axis.VectorLegendFont,'helvetica')
                txt=['      VectorLegendFont "' Axis.VectorLegendFont '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.VectorLegendFontSize~=8
                txt=['      VectorLegendFontSize ' num2str(Axis.VectorLegendFontSize)];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.VectorLegendFontAngle,'normal')
                txt=['      VectorLegendFontAngle "' Axis.VectorLegendFontAngle '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.VectorLegendFontWeight,'normal')
                txt=['      VectorLegendFontWeight "' Axis.VectorLegendFontWeight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.VectorLegendFontColor,'black')
                txt=['      VectorLegendFontColor "' Axis.VectorLegendFontColor '"'];
                fprintf(fid,'%s\n',txt);
            end
        end

    end


    if max(strcmp(PlotType,{'xy','timeseries','2d'}))
        if Axis.PlotLegend==1
            
            txt=['      Legend     yes'];
            fprintf(fid,'%s\n',txt);

            if ischar(Axis.LegendPosition)
                txt=['      LegendPosition  "' Axis.LegendPosition '"'];
                fprintf(fid,'%s\n',txt);
            else
                txt=['      LegendPosition  ' num2str(Axis.LegendPosition)];
                fprintf(fid,'%s\n',txt);
            end

            if strcmpi(Axis.LegendOrientation,'vertical')==0
                txt=['      LegendOrientation "' Axis.LegendOrientation '"'];
                fprintf(fid,'%s\n',txt);
            end

            switch lower(Axis.LegendBorder),
                case {0}
                    txt=['      LegendBox  no'];
                    fprintf(fid,'%s\n',txt);
                case {1}
                    txt=['      LegendBox  yes'];
                    fprintf(fid,'%s\n',txt);
            end

            if strcmpi(Axis.LegendColor,'white')==0
                txt=['      LegendColor "' Axis.LegendColor '"'];
                fprintf(fid,'%s \n',txt);
            end

            if ~strcmpi(Axis.LegendFont,'helvetica')
                txt=['      LegendFont "' Axis.LegendFont '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.LegendFontSize~=8
                txt=['      LegendFontSize ' num2str(Axis.LegendFontSize)];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.LegendFontAngle,'normal')
                txt=['      LegendFontAngle "' Axis.LegendFontAngle '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.LegendFontWeight,'normal')
                txt=['      LegendFontWeight "' Axis.LegendFontWeight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.LegendFontColor,'black')
                txt=['      LegendFontColor "' Axis.LegendFontColor '"'];
                fprintf(fid,'%s\n',txt);
            end

        end
    end

    if max(strcmp(PlotType,{'textbox','image','rose','3d'}))
        if Axis.DrawBox==1
            txt='      DrawBox    yes';
            fprintf(fid,'%s\n',txt);
        else
            txt='      DrawBox    no';
            fprintf(fid,'%s\n',txt);
        end
    end

    if max(strcmp(PlotType,{'2d'}))
        if Axis.DrawBox==0
            txt='      DrawBox    no';
            fprintf(fid,'%s\n',txt);
        end
    end
    
    if max(strcmp(PlotType,{'textbox'}))
        txt=['      Font       "' Axis.Font '"'];
        fprintf(fid,'%s \n',txt);
        txt=['      FontSize   ' num2str(Axis.FontSize)];
        fprintf(fid,'%s \n',txt);
        txt=['      FontWeight ' Axis.FontWeight];
        fprintf(fid,'%s \n',txt);
        txt=['      FontAngle  ' Axis.FontAngle];
        fprintf(fid,'%s \n',txt);
        txt=['      FontColor  ' Axis.FontColor];
        fprintf(fid,'%s \n',txt);
        txt=['      HorAlignment ' Axis.HorAl];
        fprintf(fid,'%s \n',txt);
        txt=['      VerAlignment ' Axis.VerAl];
        fprintf(fid,'%s \n',txt);
        for k=1:Axis.NrTextLines
            txt=['      Text "' Axis.Text{k} '"'];
            fprintf(fid,'%s\n',txt);
        end

    end

    if max(strcmp(PlotType,{'xy','timeseries','timestack'}))
        if Axis.RightAxis
            txt=['      YAxisRight ' num2str(Axis.YMinRight) ' ' num2str(Axis.YMaxRight)];
            fprintf(fid,'%s\n',txt);
            txt=['      YTickRight ' num2str(Axis.YTickRight)];
            fprintf(fid,'%s\n',txt);
            txt=['      DecimalsYRight  ' num2str(Axis.DecimYRight)];
            fprintf(fid,'%s\n',txt);
            txt=['      YLabelRight "' Axis.YLabelRight '"'];
            fprintf(fid,'%s\n',txt);
            
            if ~strcmpi(Axis.YLabelFontRight,'helvetica')
                txt=['      YLabelFontRight       "' Axis.YLabelFontRight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if Axis.YLabelFontSizeRight~=8
                txt=['      YLabelFontSizeRight   ' num2str(Axis.YLabelFontSizeRight)];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.YLabelFontAngleRight,'normal')
                txt=['      YLabelFontAngleRight  "' Axis.YLabelFontAngleRight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.YLabelFontWeightRight,'normal')
                txt=['      YLabelFontWeightRight "' Axis.YLabelFontWeightRight '"'];
                fprintf(fid,'%s\n',txt);
            end

            if ~strcmpi(Axis.YLabelFontColorRight,'black')
                txt=['      YLabelFontColorRight  "' Axis.YLabelFontColorRight '"'];
                fprintf(fid,'%s\n',txt);
            end
        end
    end

    
    txt='';
    fprintf(fid,'%s \n',txt);

    for k=1:Axis.Nr
        SaveSessionFilePlotOptions(handles,fid,ifig,j,k);
    end

else
        
    txt='';
    fprintf(fid,'%s \n',txt);

end

txt=['   EndSubplot'];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);
