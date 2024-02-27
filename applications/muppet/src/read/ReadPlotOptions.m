function handles=ReadPlotOptions(handles,txt,itxt,i,j,k,ifirst,idef)

h=[];

if ifirst==1
    h.VectorColor='k';
    h.LineColor='k';
    h.LineStyle='-';
    h.MarkerSize=10;
    h.MarkerColor='k';
    h.FieldThinningFactor1=1;
    h.FieldThinningFactor2=1;
    h.VerticalVectorScaling=1;
    h.FieldThinningType='None';
    h.LegendText='';
    h.TimeBar=[0 0];
    h.FillPolygons=0;
    h.FillColor=[0.8 1.0 0.8];
    h.EdgeColor='black';
    h.UnitVector=20;
    h.OneColor=0;
    h.Color=[0.8 1.0 0.8];
    h.LineWidth=0.5;
    h.WhiteVal=0.9;
    h.AreaText=1;
    h.Decim=0;
    h.KubFill=1;
    h.LintFill=1;
    h.LintScale=1;
    h.ArrowColor='red';
    h.Multiply=1;
    h.dx=0;
    h.dy=0;
    h.dt=300;
    h.ArrowThickness=0.05;
    h.HeadThickness=0.15;
    h.CMin=0;
    h.CStep=0.1;
    h.CMax=1;
    h.ColorMap='jet';
    h.Contours=0;
    h.hdthck=1.0;
    h.ContourLabels=0;
    h.LabelSpacing=72;
    h.Transparency=1.0;
    h.SpecularStrength=0.0;
    h.Shading='interp';
    h.Draw3DGrid=0;
    h.Elevations=[-20 20];
    h.Font='Helvetica';
    h.FontSize=10;
    h.FontWeight='normal';
    h.FontAngle='normal';
    h.FontColor='black';
    h.HorAl='center';
    h.VerAl='baseline';
    h.RightAxis=0;
    h.Elevation=0;
    h.PolygonElevation=1000;
    h.VectorLegendLength=1.0;
    h.VectorLegendText='';
    h.DxCurVec=30;
    h.DtCurVec=30;
    h.NoFramesStationaryCurVec=0;
    h.LifeSpanCurVec=50;
    h.RelSpeedCurVec=1.0;
    h.NpCurVec=10;
    h.NoCurVec=20;
    h.ContourType='limits';
    h.Animate=1;
    h.AddText=0;
    h.AddDate=0;
    h.AddDatePosition='upper-left';
    h.AddDatePrefix='Date: ';
    h.AddDateSuffix='';
    h.AddDateFormat=31;
    h.AddDateFont='Helvetica';
    h.AddDateFontSize=10;
    h.AddDateFontWeight='normal';
    h.AddDateFontAngle='normal';
    h.AddDateFontColor='black';
    h.ColoredWindRose=1;
    h.AddWindRoseTotals=1;
    h.AddWindRoseLegend=1;
    h.MaxRadius=16;
    h.RadiusStep=4;
    h.Marker='none';
    h.MarkerEdgeColor='black';
    h.MarkerFaceColor='black';
    h.TextPosition='East';
    h.TimeBar=[0 0];
    h.LineStyle1='-';
    h.LineStyle2='-';
    h.LineStyle3='-';
    h.LineStyle4='-';
    h.LineStyle5='--';
    h.LineStyle6='--';
    h.LineStyle7='--';
    h.LineStyle8='--';
    h.LineColor1='black';
    h.LineColor2='red';
    h.LineColor3='blue';
    h.LineColor4='green';
    h.LineColor5='black';
    h.LineColor6='red';
    h.LineColor7='blue';
    h.LineColor8='green';
    h.LineWidth1=0.5;
    h.LineWidth2=0.5;
    h.LineWidth3=0.5;
    h.LineWidth4=0.5;
    h.LineWidth5=0.5;
    h.LineWidth6=0.5;
    h.LineWidth7=0.5;
    h.LineWidth8=0.5;
    h.Marker1='none';
    h.Marker2='none';
    h.Marker3='none';
    h.Marker4='none';
    h.Marker5='none';
    h.Marker6='none';
    h.Marker7='none';
    h.Marker8='none';
    h.FillColor1='lightgreen';
    h.FillColor2='red';
    h.FillColor3='lightblue';
    h.FillColor4='green';
    h.FillColor5='black';
    h.FillColor6='red';
    h.FillColor7='blue';
    h.FillColor8='green';
    h.HeadWidth=4;
    h.ArrowWidth=2;
    h.PlotColorBar=0;
    h.ColorBarPosition=[0 0 0 0];
    h.ColorBarDecimals=-1;
    h.ColorBarType=1;
    h.ColorBarLabel='';
    h.ColorBarUnit='';
    h.ColorBarLabelPosition='top';
    h.ColorBarLabelIncrement=1;
    h.ColorBarFont='Helvetica';
    h.ColorBarFontSize=8;
    h.ColorBarFontAngle='normal';
    h.ColorBarFontWeight='normal';
    h.ColorBarFontColor='black';
    h.MaxDistance=0;
    h.UnitArrow=0;
end

switch lower(txt{itxt}),
    
    case {'plotroutine'},
        h.PlotRoutine=txt{itxt+1};

    case {'linestyle'},
        h.LineStyle=txt{itxt+1};
        h.PolylineStyle=txt{itxt+1};

    case {'linecolor'},
        if isnan(str2double(txt{itxt+1}))
            h.LineColor=txt{itxt+1};
        else
            h.LineColor=[];
            h.LineColor(1)=str2num(txt{itxt+1});
            h.LineColor(2)=str2num(txt{itxt+2});
            h.LineColor(3)=str2num(txt{itxt+3});
        end

    case {'marker'},
        if size(txt{itxt+1},1)>0
            h.Marker=txt{itxt+1};
        else
            h.Marker='none';
        end            

    case {'legendtext'},
        h.LegendText=txt{itxt+1};

    case {'colour','color'},
        if isnan(str2double(txt{itxt+1}))
            h.LineColor=txt{itxt+1};
        else
            h.Color(1)=str2num(txt{itxt+1});
            h.Color(2)=str2num(txt{itxt+2});
            h.Color(3)=str2num(txt{itxt+3});
            h.OneColor=1;
        end
        
    case {'lengthunitvector','unitvector'},
        h.UnitVector=str2num(txt{itxt+1});

    case {'fieldthinningtype','thinningtype'},
        h.FieldThinningType=txt{itxt+1};

    case {'fieldthinningfactor1','fieldthinningfactor'},
        h.FieldThinningFactor1=str2num(txt{itxt+1});

    case {'fieldthinningfactor2'},
        h.FieldThinningFactor2=str2num(txt{itxt+1});

    case {'verticalscaling'},
        h.VerticalVectorScaling=str2num(txt{itxt+1});

    case {'vectorcolour','vectorcolor'},
        h.VectorColor=txt{itxt+1};

    case {'gridcolour','gridcolor'},
        h.gridcolour=txt{itxt+1};

    case {'timebar'},
        if str2num(txt{itxt+1})>100000
            h.TimeBar(1)=str2num(txt{itxt+1});
            h.TimeBar(2)=str2num(txt{itxt+2});
        else
            h.TimeBar=[0 0];
        end

    case {'fillpolygons'},
        switch txt{itxt+1},
            case {'yes'}
                h.FillPolygons=1;
            case {'no'}
                h.FillPolygons=0;
        end

    case {'fillcolour','fillcolor'},
        if isnan(str2double(txt{itxt+1}))
            h.FillColor=txt{itxt+1};
        else
            h.FillColor(1)=str2num(txt{itxt+1});
            h.FillColor(2)=str2num(txt{itxt+2});
            h.FillColor(3)=str2num(txt{itxt+3});
        end
        
    case {'edgecolor'},
        if isnan(str2double(txt{itxt+1}))
            h.EdgeColor=txt{itxt+1};
        else
            h.EdgeColor(1)=str2num(txt{itxt+1});
            h.EdgeColor(2)=str2num(txt{itxt+2});
            h.EdgeColor(3)=str2num(txt{itxt+3});
        end
        
    case {'areatext'},
        switch lower(txt{itxt+1}),
            case {'quantity'}
                h.AreaText=1;
            case {'areanumber'}
                h.AreaText=2;
            case {'none'}
                h.AreaText=3;
        end

    case {'parameter'},
        h.KubPar=txt{itxt+1};

    case {'fillareas'},
        switch lower(txt{itxt+1}),
            case {'yes'}
                h.KubFill=1;
            case {'no'}
                h.KubFill=0;
        end

    case {'decimals','decimal'},
        h.Decim=str2num(txt{itxt+1});

    case {'multiply'},
        h.Multiply=str2num(txt{itxt+1});

    case {'whitevalue','whiteval'},
        h.WhiteVal=str2num(txt{itxt+1});

    case {'linewidth','width'},
        h.LineWidth=str2num(txt{itxt+1});

    case {'dx'},
        h.dx=str2num(txt{itxt+1});

    case {'dy'},
        h.dy=str2num(txt{itxt+1});

    case {'dt'},
        h.dt=str2num(txt{itxt+1});

    case {'arrowthickness'},
        h.ArrowThickness=str2num(txt{itxt+1});

    case {'headthickness'},
        h.HeadThickness=str2num(txt{itxt+1});

    case {'contours','contourlines'},
        h.CMin=str2num(txt{itxt+1});
        h.CStep=str2num(txt{itxt+2});
        h.CMax=str2num(txt{itxt+3});

    case {'colormap'},
        h.ColorMap=txt{itxt+1};
        
    case {'contourlabels'},
        switch txt{itxt+1},
            case {'yes'}
                h.ContourLabels=1;
            case {'no'}
                h.ContourLabels=0;
        end

    case {'labelspacing'},
        h.LabelSpacing=str2num(txt{itxt+1});

    case {'transparency'},
        h.Transparency=str2num(txt{itxt+1});

    case {'specularstrength'},
        h.SpecularStrength=str2num(txt{itxt+1});

    case {'shading'},
        h.Shading=txt{itxt+1};

    case {'draw3dgrid'},
        switch txt{itxt+1},
            case {'yes'}
                h.Draw3DGrid=1;
            case {'no'}
                h.Draw3DGrid=0;
        end

    case {'elevation'},
        h.Elevation=str2num(txt{itxt+1});
        h.PolygonElevation=str2num(txt{itxt+1});

    case {'elevations'},
        h.Elevations(1)=str2num(txt{itxt+1});
        h.Elevations(2)=str2num(txt{itxt+2});

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

    case {'fillarrows'},
        switch txt{itxt+1},
            case {'yes'}
                h.FillPolygons=1;
            case {'no'}
                h.FillPolygons=0;
        end

    case {'arrowcolor'},
        h.ArrowColor=txt{itxt+1};

    case {'addtext'},
        switch txt{itxt+1},
            case {'yes'}
                h.AddText=1;
            case {'no'}
                h.AddText=0;
        end

    case {'lintscale'},
        h.LintScale=str2num(txt{itxt+1});

    case {'unitarrow'},
        h.UnitArrow=str2num(txt{itxt+1});
        
    case {'axis'},
        switch txt{itxt+1},
            case {'right'}
                h.RightAxis=1;
        end

    case {'vectorlegendlength'},
        h.VectorLegendLength=str2num(txt{itxt+1});

    case {'vectorlegendtext'},
        h.VectorLegendText=txt{itxt+1};

    case {'dtcurvec'},
        h.DtCurVec=str2num(txt{itxt+1});

    case {'dxcurvec'},
        h.DxCurVec=str2num(txt{itxt+1});

    case {'lifespancurvec'},
        h.LifeSpanCurVec=str2num(txt{itxt+1});

    case {'relspeedcurvec'},
        h.RelSpeedCurVec=str2num(txt{itxt+1});

    case {'noframesstationarycurvec'},
        h.NoFramesStationaryCurVec=str2num(txt{itxt+1});

    case {'npcurvec'},
        h.NpCurVec=str2num(txt{itxt+1});

    case {'nocurvec'},
        h.NoCurVec=str2num(txt{itxt+1});

    case {'contourtype'},
        h.ContourType=txt{itxt+1};

    case {'startcontours'},

        nocol=0;
        kk=itxt+1;
        while strcmpi(txt{kk},'endcontours')==0
            nocol=nocol+1;
            h.Contours(nocol)=str2double(txt{kk});
            kk=kk+1;
        end

    case {'adddate'},
        h.AddDate=1;
        h.AddDatePosition=txt{itxt+1};

    case {'adddateprefix'},
        h.AddDatePrefix=txt{itxt+1};

    case {'adddatesuffix'},
        h.AddDateSuffix=txt{itxt+1};

    case {'adddatefont'},
        h.AddDateFont=txt{itxt+1};

    case {'adddatefontsize'},
        h.AddDateFontSize=str2num(txt{itxt+1});

    case {'adddatefontweight'},
        h.AddDateFontWeight=txt{itxt+1};

    case {'adddatefontangle'},
        h.AddDateFontAngle=txt{itxt+1};

    case {'adddatefontcolor'},
        h.AddDateFontColor=txt{itxt+1};        
        
    case {'adddateformat'},
        h.AddDateFormat=str2num(txt{itxt+1});

    case {'radiusstep'},
        h.RadiusStep=str2num(txt{itxt+1});

    case {'maximumradius'},
        h.MaxRadius=str2num(txt{itxt+1});

    case {'coloredwindrose'},
        switch txt{itxt+1},
            case {'yes'}
                h.ColoredWindRose=1;
            case {'no'}
                h.ColoredWindRose=0;
        end

    case {'plotwindrosetotals'},
        switch txt{itxt+1},
            case {'yes'}
                h.AddWindRoseTotals=1;
            case {'no'}
                h.AddWindRoseTotals=0;
        end

    case {'addwindroselegend'},
        switch txt{itxt+1},
            case {'yes'}
                h.AddWindRoseLegend=1;
            case {'no'}
                h.AddWindRoseLegend=0;
        end

    case {'markersize'},
        h.MarkerSize=str2num(txt{itxt+1});

    case {'markeredgecolor'},
        h.MarkerEdgeColor=txt{itxt+1};

    case {'markerfacecolor'},
        h.MarkerFaceColor=txt{itxt+1};

    case {'textposition'},
        h.TextPosition=txt{itxt+1};

    case {'headwidth'},
        h.HeadWidth=str2num(txt{itxt+1});
        
    case {'arrowwidth'},
        h.ArrowWidth=str2num(txt{itxt+1});

    case {'colorbar'},
        if ~isempty(str2num(txt{itxt+1}(1)))
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
        
    case {'colorbarlabel'},
        h.ColorBarLabel=txt{itxt+1};

    case {'colorbarlabelposition'},
        h.ColorBarLabelPosition=txt{itxt+1};

    case {'colorbarunit'},
        h.ColorBarUnit=txt{itxt+1};

    case {'colorbartickincrement'},
        h.ColorBarLabelIncrement=str2num(txt{itxt+1});

    case {'maxdistance'},
        h.MaxDistance=str2num(txt{itxt+1});
        
end

if size(txt{itxt},1)>0
    if size(str2num(txt{itxt}(end)),1)>0
        kk=txt{itxt}(end);
        switch lower(txt{itxt}(1:end-1)),
            case {'linestyle'},
                h.(['LineStyle' kk])=txt{itxt+1};
            case {'linecolor'},
                h.(['LineColor' kk])=txt{itxt+1};
            case {'linewidth'},
                h.(['LineWidth' kk])=str2num(txt{itxt+1});
            case {'marker'},
                h.(['Marker' kk])=txt{itxt+1};
            case {'fillcolor'},
                h.(['FillColor' kk])=txt{itxt+1};
        end
    end
end

if isstruct(h)
    names=fieldnames(h);
    for ii=1:length(names)
        v=getfield(h,names{ii});
        if idef
            handles.DefaultPlotOptions.(names{ii})=v;
        else
            handles.Figure(i).Axis(j).Plot(k).(names{ii})=v;
        end
    end
end
