function handles=ReadSubplotProperties(handles,txt,itxt,i,j,ifirst,idef)

h=[];

if ifirst==1
    h.PlotType='unknown';
    h.XMin=0.0;
    h.XMax=1.0;
    h.XTick=-999.0;
    h.YMin=0.0;
    h.YMax=1.0;
    h.YTick=-999.0;
    h.ZMin=0.0;
    h.ZMax=1.0;
    h.ZTick=-999.0;
    h.YMinRight=0.0;
    h.YMaxRight=1.0;
    h.YTickRight=-999.0;
    h.XGrid=0;
    h.YGrid=0;
    h.ZGrid=0;
    h.XGridRight=0;
    h.YGridRight=0;
    h.DecimX=-1;
    h.DecimY=-1;
    h.DecimZ=-1;
    h.DecimXRight=-1;
    h.DecimYRight=-1;
    h.DateFormatNr=15;
    h.DateFormat='HH:MM:SS';
    h.XLabel='';
    h.XLabelFont='Helvetica';
    h.XLabelFontSize=8;
    h.XLabelFontAngle='normal';
    h.XLabelFontWeight='normal';
    h.XLabelFontColor='black';
    h.YLabel='';
    h.YLabelFont='Helvetica';
    h.YLabelFontSize=8;
    h.YLabelFontAngle='normal';
    h.YLabelFontWeight='normal';
    h.YLabelFontColor='black';
    h.YLabelRight='';
    h.YLabelFontRight='Helvetica';
    h.YLabelFontSizeRight=8;
    h.YLabelFontAngleRight='normal';
    h.YLabelFontWeightRight='normal';
    h.YLabelFontColorRight='black';
    h.Title='';
    h.TitleFont='Helvetica';
    h.TitleFontSize=10;
    h.TitleFontAngle='normal';
    h.TitleFontWeight='normal';
    h.TitleFontColor='black';
    h.AxesFont='Helvetica';
    h.AxesFontSize=8;
    h.AxesFontAngle='normal';
    h.AxesFontWeight='normal';
    h.AxesFontColor='black';
    h.Scale=10000;
    h.DrawBox=0;
    h.PlotLegend=0;
    h.LegendBorder=1;
    h.LegendPosition='NorthEast';
    h.LegendOrientation='Vertical';
    h.ColorBarPosition=[0 0 0 0];
    h.PlotColorBar=0;
    h.ColMap='jet';
    h.CMin=0.0;
    h.CStep=0.1;
    h.CMax=1.0;
    h.NorthArrow=[0 0 0 0];
    h.PlotNorthArrow=0;
    h.ScaleBar=[0 0 0];
    h.PlotVectorLegend=0;
    h.VectorLegendPosition=[0 0];
    h.ScaleBarText='';
    h.PlotScaleBar=0;
    h.ColorBarDecimals=-1;
    h.ColorBarType=1;
    h.ColorBarLabel='';
    h.ColorBarLabelPosition='top';
    h.ColorBarUnit='';
    h.ColorBarLabelIncrement=1;
    h.CameraTarget=[0 0 0];
    h.CameraAngle=[0 0];
    h.CameraViewAngle=10;
    h.DataAspectRatio=[100 100 1];
    h.LightStrength=0.4;
    h.LightAzimuth=0;
    h.LightElevation=55;
    h.Perspective=1;
    h.XScale='linear';
    h.YScale='linear';
    h.AxesEqual=0;
    h.RightAxis=0;
    h.AddDate=0;
    h.Contours=0;
    h.ContourType='limits';
    h.AdjustAxes=1;
    h.Text{1}='';
    h.NrTextLines=0;
    h.Font='Helvetica';
    h.FontSize=10;
    h.FontAngle='normal';
    h.FontWeight='normal';
    h.FontColor='black';
    h.HorAl='left';
    h.VerAl='top';
    h.ColorBarFont='Helvetica';
    h.ColorBarFontSize=8;
    h.ColorBarFontAngle='normal';
    h.ColorBarFontWeight='normal';
    h.ColorBarFontColor='black';
    h.LegendFont='Helvetica';
    h.LegendFontSize=8;
    h.LegendFontAngle='normal';
    h.LegendFontWeight='normal';
    h.LegendFontColor='black';
    h.LegendColor='white';
    h.VectorLegendFont='Helvetica';
    h.VectorLegendFontSize=8;
    h.VectorLegendFontAngle='normal';
    h.VectorLegendFontWeight='normal';
    h.VectorLegendFontColor='black';
    h.AdjustAxes=0;
    h.YearMin=0;
    h.MonthMin=0;
    h.DayMin=0;
    h.HourMin=0;
    h.MinuteMin=0;
    h.SecondMin=0;
    h.YearMax=0;
    h.MonthMax=0;
    h.DayMax=0;
    h.HourMax=0;
    h.MinuteMax=0;
    h.SecondMax=0;
    h.YearTick=0;
    h.MonthTick=0;
    h.DayTick=0;
    h.HourTick=0;
    h.MinuteTick=0;
    h.SecondTick=0;
    h.DateFormat=15;
    h.BackgroundColor='white';
    h.XTickMultiply=1.0;
    h.YTickMultiply=1.0;
    h.XTickAdd=0.0;
    h.YTickAdd=0.0;
    h.coordinateSystem.name='unknown';
    h.coordinateSystem.type='projected';
end

switch lower(txt{itxt}),

    case {'position'},
        h.Position(1)=str2num(txt{itxt+1});
        h.Position(2)=str2num(txt{itxt+2});
        h.Position(3)=str2num(txt{itxt+3});
        h.Position(4)=str2num(txt{itxt+4});

    case {'backgroundcolor'},
        h.BackgroundColor=txt{itxt+1};

    case {'coordinatesystemname'}
        h.coordinateSystem.name=txt{itxt+1};

    case {'coordinatesystemtype'}
        h.coordinateSystem.type=txt{itxt+1};

    case {'plottype'},
        h.PlotType=txt{itxt+1};
        if strcmp(txt{itxt+1},'2d')
            h.AxesEqual=1;
        end
        if strcmp(h.PlotType,'unknown')
            h.AdjustAxes=0;
        end

    case {'startdate','starttime','tmin'},
        date=str2num(txt{itxt+1});
        time=str2num(txt{itxt+2});
        mattim=MatTime(date,time);
        dat=round(datevec(mattim));
        h.YearMin=dat(1);
        h.MonthMin=dat(2);
        h.DayMin=dat(3);
        h.HourMin=dat(4);
        h.MinuteMin=dat(5);
        h.SecondMin=dat(6);


    case {'stopdate','stoptime','tmax'},
        date=str2num(txt{itxt+1});
        time=str2num(txt{itxt+2});
        mattim=MatTime(date,time);
        dat=round(datevec(mattim));
        h.YearMax=dat(1);
        h.MonthMax=dat(2);
        h.DayMax=dat(3);
        h.HourMax=dat(4);
        h.MinuteMax=dat(5);
        h.SecondMax=dat(6);

    case {'ttick'},
        h.YearTick=str2num(txt{itxt+1});
        h.MonthTick=str2num(txt{itxt+2});
        h.DayTick=str2num(txt{itxt+3});
        h.HourTick=str2num(txt{itxt+4});
        h.MinuteTick=str2num(txt{itxt+5});
        h.SecondTick=str2num(txt{itxt+6});

    case {'xtick'},
        h.XTick=str2num(txt{itxt+1});

    case {'ytick'},
        h.YTick=str2num(txt{itxt+1});

    case {'ztick'},
        h.ZTick=str2num(txt{itxt+1});

    case {'ytickright'},
        h.YTickRight=str2num(txt{itxt+1});

    case {'xaxis'},
        h.XMin=str2num(txt{itxt+1});
        h.XMax=str2num(txt{itxt+2});

    case {'yaxis'},
        h.YMin=str2num(txt{itxt+1});
        h.YMax=str2num(txt{itxt+2});

    case {'zaxis'},
        h.ZMin=str2num(txt{itxt+1});
        h.ZMax=str2num(txt{itxt+2});

    case {'yaxisright'},
        h.YMinRight=str2num(txt{itxt+1});
        h.YMaxRight=str2num(txt{itxt+2});
        h.RightAxis=1;

    case {'xgrid'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.XGrid=1;
            case {'no'}
                h.XGrid=0;
        end

    case {'ygrid'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.YGrid=1;
            case {'no'}
                h.YGrid=0;
        end

    case {'zgrid'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.ZGrid=1;
            case {'no'}
                h.ZGrid=0;
        end

    case {'title'},
        tx=txt{itxt+1};
        isep=strfind(tx,';;');
        if isep>1
            kstart=1;
            for i=1:length(isep)
                kstop=isep(i)-1;
                str{itxt}=tx(kstart:kstop);
                kstart=isep(i)+2;
            end
            str{itxt+1}=tx(kstart:end);
            h.Title=str;
        else
            h.Title=txt{itxt+1};
        end

    case {'xlabel'},
        h.XLabel=txt{itxt+1};

    case {'ylabel'},
        h.YLabel=txt{itxt+1};

    case {'ylabelright'},
        h.YLabelRight=txt{itxt+1};

    case {'decimalsx'},
        h.DecimX=str2num(txt{itxt+1});

    case {'decimalsy'},
        h.DecimY=str2num(txt{itxt+1});

    case {'xtickmultiply'},
        h.XTickMultiply=str2num(txt{itxt+1});

    case {'ytickmultiply'},
        h.YTickMultiply=str2num(txt{itxt+1});

    case {'xtickadd'},
        h.XTickAdd=str2num(txt{itxt+1});

    case {'ytickadd'},
        h.YTickAdd=str2num(txt{itxt+1});

    case {'decimalsz'},
        h.DecimZ=str2num(txt{itxt+1});

    case {'decimalsyright'},
        h.DecimYRight=str2num(txt{itxt+1});

    case {'dateformat'},
        DateFormats=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'dateformats.def']);
        if length(str2num(txt{itxt+1}))>0
            h.DateFormatNr=str2num(txt{itxt+1});
            h.DateFormat=DateFormats{str2num(txt{itxt+1})};
        else
            h.DateFormatNr=strmatch(lower(txt{itxt+1}),lower(DateFormats),'exact');
            h.DateFormat=txt{itxt+1};
        end

    case {'scale'},
        h.Scale=str2num(txt{itxt+1});

    case {'drawbox'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.DrawBox=1;
            case {'no'}
                h.DrawBox=0;
        end

    case {'legend'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.PlotLegend=1;
            case {'no'}
                h.PlotLegend=0;
            otherwise
                h.LegendPosition=txt{itxt+1};
                h.PlotLegend=1;
        end

    case {'legendposition'},
        if length(str2num(txt{itxt+1}(1)))>0
            h.LegendPosition(1)=str2num(txt{itxt+1});
            h.LegendPosition(2)=str2num(txt{itxt+2});
            h.LegendPosition(3)=str2num(txt{itxt+3});
            h.LegendPosition(4)=str2num(txt{itxt+4});
        else
            h.LegendPosition=txt{itxt+1};
        end
        
    case {'legendorientation'},
        h.LegendOrientation=txt{itxt+1};

    case {'legendbox'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.LegendBorder=1;
            case {'no'}
                h.LegendBorder=0;
        end

    case {'colourmap','colormap'},
        h.ColMap=txt{itxt+1};

    case {'colourbar','colorbar'},
        if length(str2num(txt{itxt+1}(1)))>0
            h.ColorBarPosition(1)=str2num(txt{itxt+1});
            h.ColorBarPosition(2)=str2num(txt{itxt+2});
            h.ColorBarPosition(3)=str2num(txt{itxt+3});
            h.ColorBarPosition(4)=str2num(txt{itxt+4});
            h.PlotColorBar=1;
        else
            switch lower(txt{itxt+1}),
                case {'yes'}
                    h.PlotColorBar=1;
                case {'no'}
                    h.PlotColorBar=0;
            end
        end

    case {'colorbarposition'},
        h.ColorBarPosition(1)=str2num(txt{itxt+1});
        h.ColorBarPosition(2)=str2num(txt{itxt+2});
        h.ColorBarPosition(3)=str2num(txt{itxt+3});
        h.ColorBarPosition(4)=str2num(txt{itxt+4});

    case {'bartype'},
        h.ColorBarType=str2num(txt{itxt+1});

    case {'bardecim'},
        h.ColorBarDecimals=str2num(txt{itxt+1});

    case {'contours'},
        h.CMin=str2num(txt{itxt+1});
        h.CStep=str2num(txt{itxt+2});
        h.CMax=str2num(txt{itxt+3});

    case {'northarrow'},
        h.NorthArrow(1)=str2num(txt{itxt+1});
        h.NorthArrow(2)=str2num(txt{itxt+2});
        h.NorthArrow(3)=str2num(txt{itxt+3});
        h.NorthArrow(4)=str2num(txt{itxt+4});
        h.PlotNorthArrow=1;

    case {'scalebar'},
        h.ScaleBar(1)=str2num(txt{itxt+1});
        h.ScaleBar(2)=str2num(txt{itxt+2});
        h.ScaleBar(3)=str2num(txt{itxt+3});
        h.PlotScaleBar=1;

    case {'scalebartext'},
        h.ScaleBarText=txt{itxt+1};

    case {'vectorlegend'},
        if length(str2num(txt{itxt+1}))>0
            h.VectorLegendPosition(1)=str2num(txt{itxt+1});
            h.VectorLegendPosition(2)=str2num(txt{itxt+2});
            h.PlotVectorLegend=1;
        else
            switch lower(txt{itxt+1}),
                case {'yes'}
                    h.PlotVectorLegend=1;
                case {'no'}
                    h.PlotVectorLegend=0;
            end
        end

    case {'vectorlegendposition'},
        h.VectorLegendPosition(1)=str2num(txt{itxt+1});
        h.VectorLegendPosition(2)=str2num(txt{itxt+2});

    case {'cameratarget'},
        h.CameraTarget(1)=str2num(txt{itxt+1});
        h.CameraTarget(2)=str2num(txt{itxt+2});
        h.CameraTarget(3)=str2num(txt{itxt+3});

    case {'cameraangle'},
        h.CameraAngle(1)=str2num(txt{itxt+1});
        h.CameraAngle(2)=str2num(txt{itxt+2});

    case {'cameraviewangle'},
        h.CameraViewAngle=str2num(txt{itxt+1});

%     case {'cameradistance'},
%         h.CameraDistance=str2num(txt{itxt+1});

    case {'dataaspectratio'},
        h.DataAspectRatio(1)=str2num(txt{itxt+1});
        h.DataAspectRatio(2)=str2num(txt{itxt+2});
        h.DataAspectRatio(3)=str2num(txt{itxt+3});

    case {'lightstrength'},
        h.LightStrength=str2double(txt{itxt+1});

    case {'lightazimuth'},
        h.LightAzimuth=str2double(txt{itxt+1});

    case {'lightelevation'},
        h.LightElevation=str2double(txt{itxt+1});

    case {'perspective'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.Perspective=1;
            case {'no'}
                h.Perspective=0;
        end

    case {'xscale'},
        h.XScale=txt{itxt+1};

    case {'yscale'},
        h.YScale=txt{itxt+1};

    case {'xlabelfont'},
        h.XLabelFont=txt{itxt+1};

    case {'xlabelfontsize'},
        h.XLabelFontSize=str2num(txt{itxt+1});

    case {'xlabelfontangle'},
        h.XLabelFontAngle=txt{itxt+1};

    case {'xlabelfontweight'},
        h.XLabelFontWeight=txt{itxt+1};

    case {'xlabelfontcolor'},
        h.XLabelFontColor=txt{itxt+1};

    case {'ylabelfont'},
        h.YLabelFont=txt{itxt+1};

    case {'ylabelfontsize'},
        h.YLabelFontSize=str2num(txt{itxt+1});

    case {'ylabelfontangle'},
        h.YLabelFontAngle=txt{itxt+1};

    case {'ylabelfontweight'},
        h.YLabelFontWeight=txt{itxt+1};

    case {'ylabelfontcolor'},
        h.YLabelFontColor=txt{itxt+1};

    case {'ylabelfontright'},
        h.YLabelFontRight=txt{itxt+1};

    case {'ylabelfontsizeright'},
        h.YLabelFontSizeRight=str2num(txt{itxt+1});

    case {'ylabelfontangleright'},
        h.YLabelFontAngleRight=txt{itxt+1};

    case {'ylabelfontweightright'},
        h.YLabelFontWeightRight=txt{itxt+1};

    case {'ylabelfontcolorright'},
        h.YLabelFontColorRight=txt{itxt+1};

    case {'titlefont'},
        h.TitleFont=txt{itxt+1};

    case {'titlefontsize'},
        h.TitleFontSize=str2num(txt{itxt+1});

    case {'titlefontangle'},
        h.TitleFontAngle=txt{itxt+1};

    case {'titlefontweight'},
        h.TitleFontWeight=txt{itxt+1};

    case {'titlefontcolor'},
        h.TitleFontColor=txt{itxt+1};

    case {'axesfont'},
        h.AxesFont=txt{itxt+1};

    case {'axesfontsize'},
        h.AxesFontSize=str2num(txt{itxt+1});

    case {'axesfontangle'},
        h.AxesFontAngle=txt{itxt+1};

    case {'axesfontweight'},
        h.AxesFontWeight=txt{itxt+1};

    case {'axesfontcolor'},
        h.AxesFontColor=txt{itxt+1};

    case {'adddate'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.AddDate=1;
            case {'no'}
                h.AddDate=0;
        end

    case {'axesequal'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.AxesEqual=1;
            case {'no'}
                h.AxesEqual=0;
        end

    case {'colorbarlabel'},
        h.ColorBarLabel=txt{itxt+1};

    case {'colorbarlabelposition'},
        h.ColorBarLabelPosition=txt{itxt+1};

    case {'colorbarunit'},
        h.ColorBarUnit=txt{itxt+1};
        
    case {'colorbartickincrement'},
        h.ColorBarLabelIncrement=str2num(txt{itxt+1});

    case {'contourtype'},
        h.ContourType=txt{itxt+1};

    case {'startcontours'},

        nocol=0;
        k=itxt+1;
        h.Contours=0;
        while strcmp(lower(txt{k}),'endcontours')==0
            nocol=nocol+1;
            h.Contours(nocol)=str2num(txt{k});
            k=k+1;
        end

    case {'font'},
        h.Font=txt{itxt+1};

    case {'fontsize'},
        h.FontSize=str2num(txt{itxt+1});

    case {'fontweight'},
        h.FontWeight=txt{itxt+1};

    case {'fontangle'},
        h.FontAngle=txt{itxt+1};

    case {'fontcolor'},
        h.FontColor=txt{itxt+1};

    case {'horalignment'},
        h.HorAl=txt{itxt+1};

    case {'veralignment'},
        h.VerAl=txt{itxt+1};

    case {'colorbarfont'},
        h.ColorBarFont=txt{itxt+1};

    case {'colorbarfontsize'},
        h.ColorBarFontSize=str2num(txt{itxt+1});

    case {'colorbarfontangle'},
        h.ColorBarFontAngle=txt{itxt+1};

    case {'colorbarfontweight'},
        h.ColorBarFontWeight=txt{itxt+1};

    case {'colorbarfontcolor'},
        h.ColorBarFontColor=txt{itxt+1};

    case {'legendfont'},
        h.LegendFont=txt{itxt+1};

    case {'legendfontsize'},
        h.LegendFontSize=str2num(txt{itxt+1});

    case {'legendfontangle'},
        h.LegendFontAngle=txt{itxt+1};

    case {'legendfontweight'},
        h.LegendFontWeight=txt{itxt+1};

    case {'legendfontcolor'},
        h.LegendFontColor=txt{itxt+1};

    case {'legendcolor'},
        h.LegendColor=txt{itxt+1};

    case {'vectorlegendfont'},
        h.VectorLegendFont=txt{itxt+1};

    case {'vectorlegendfontsize'},
        h.VectorLegendFontSize=str2num(txt{itxt+1});

    case {'vectorlegendfontangle'},
        h.VectorLegendFontAngle=txt{itxt+1};

    case {'vectorlegendfontweight'},
        h.VectorLegendFontWeight=txt{itxt+1};

    case {'vectorlegendfontcolor'},
        h.VectorLegendFontColor=txt{itxt+1};
        
end


if isstruct(h)
    names=fieldnames(h);
    for ii=1:length(names)
        v=getfield(h,names{ii});
        if idef
            handles.DefaultSubplotProperties.(names{ii})=v;
        else
            if isstruct(v)
                f=fieldnames(v);
                f=f{1};
                handles.Figure(i).Axis(j).(names{ii}).(f)=v.(f);
            else
                handles.Figure(i).Axis(j).(names{ii})=v;
            end
        end
    end
end

