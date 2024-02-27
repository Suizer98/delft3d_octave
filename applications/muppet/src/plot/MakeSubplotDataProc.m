function MakeSubplotDataProc(FigureProperties,DataProperties,PlotOptions,SubplotProperties,ColorMaps,DefaultColors)

nodat=SubplotProperties.Nr;
LeftAxis=gca;
ColBar=0;
VecLeg=0;
NorthArrow=0;
ScaleBar=0;

% % Colors
% SubplotProperties.XLabelFontColor=FindColor(SubplotProperties,'XLabelFontColor',DefaultColors);
% SubplotProperties.YLabelFontColor=FindColor(SubplotProperties,'YLabelFontColor',DefaultColors);
% SubplotProperties.YLabelFontColorRight=FindColor(SubplotProperties,'YLabelFontColorRight',DefaultColors);
% SubplotProperties.TitleFontColor=FindColor(SubplotProperties,'TitleFontColor',DefaultColors);
% SubplotProperties.AxesFontColor=FindColor(SubplotProperties,'AxesFontColor',DefaultColors);
% SubplotProperties.FontColor=FindColor(SubplotProperties,'FontColor',DefaultColors);
% SubplotProperties.LegendColor=FindColor(SubplotProperties,'LegendColor',DefaultColors);
% SubplotProperties.LegendFontColor=FindColor(SubplotProperties,'LegendFontColor',DefaultColors);
% FigureProperties.BackgroundColor=FindColor(FigureProperties,'BackgroundColor',DefaultColors);
% 
% for k=1:nodat
% 
%     % Colors
%     PlotOptions(k).Color=FindColor(PlotOptions(k),'Color',DefaultColors);
%     if strcmp(lower(PlotOptions(k).FillColor),'none')==0
%         PlotOptions(k).FillColor=FindColor(PlotOptions(k),'FillColor',DefaultColors);
%     end
%     PlotOptions(k).VectorColor=FindColor(PlotOptions(k),'VectorColor',DefaultColors);
%     if strcmp(lower(PlotOptions(k).MarkerEdgeColor),'none')==0 & strcmp(lower(PlotOptions(k).MarkerEdgeColor),'auto')==0
%         PlotOptions(k).MarkerEdgeColor=FindColor(PlotOptions(k),'MarkerEdgeColor',DefaultColors);
%     end
%     if strcmp(lower(PlotOptions(k).MarkerFaceColor),'none')==0 & strcmp(lower(PlotOptions(k).MarkerFaceColor),'auto')==0
%         PlotOptions(k).MarkerFaceColor=FindColor(PlotOptions(k),'MarkerFaceColor',DefaultColors);
%     end
%     if strcmp(lower(PlotOptions(k).LineColor),'none')==0 & strcmp(lower(PlotOptions(k).LineColor),'auto')==0
%         PlotOptions(k).LineColor=FindColor(PlotOptions(k),'LineColor',DefaultColors);
%     end
%     PlotOptions(k).FontColor=FindColor(PlotOptions(k),'FontColor',DefaultColors);
%     if strcmp(lower(PlotOptions(k).EdgeColor),'none')==0
%         PlotOptions(k).EdgeColor=FindColor(PlotOptions(k),'EdgeColor',DefaultColors);
%     end
% 
% end    

nbar=0;
nstackedarea=0;
for k=1:nodat
    ii=FindDatasetNr(PlotOptions(k).Name,DataProperties);
    PlotOptions(k).AvailableDatasetNr=ii;
%     switch lower(PlotOptions(k).PlotRoutine),
%         case {'plothistogram'}
%             nbar=nbar+1;
%             BarY(:,nbar)=DataProperties(ii).y;
%             if ischar(PlotOptions(k).EdgeColor)
%                 BarEdgeColor(nbar,:)=[-999 -999 -999];
%             else
%                 BarEdgeColor(nbar,:)=PlotOptions(k).EdgeColor';
%             end
%             if ischar(PlotOptions(k).FillColor)
%                 BarFaceColor(nbar,:)=[-999 -999 -999];
%             else
%                 BarFaceColor(nbar,:)=PlotOptions(k).FillColor';
%             end
%         case {'plotstackedarea'}
%             nstackedarea=nstackedarea+1;
%             StackedAreaY(:,nstackedarea)=DataProperties(ii).y;
%             if ischar(PlotOptions(k).EdgeColor)
%                 AreaEdgeColor(nstackedarea,:)=[-999 -999 -999];
%             else
%                 AreaEdgeColor(nstackedarea,:)=PlotOptions(k).EdgeColor';
%             end
%             if ischar(PlotOptions(k).FillColor)
%                 AreaFaceColor(nstackedarea,:)=[-999 -999 -999];
%             else
%                 AreaFaceColor(nstackedarea,:)=PlotOptions(k).FillColor';
%             end
%     end
end

nobar=0;
nostackedarea=0;

SubplotProperties.MaxZ=10000;
SubplotProperties.xtcklab=[];

for k=1:nodat

    PlotHandles{k}=0;
    
    switch lower(PlotOptions(k).PlotRoutine),
        case {'plottimeseries','plotxy','plotxyseries','plotline','plotspline'},
        if PlotOptions(k).RightAxis
            PlotHandles{k}=PlotLine(FigureProperties,SubplotProperties,DataProperties,PlotOptions(k),'right');
        else
            PlotHandles{k}=PlotLine(FigureProperties,SubplotProperties,DataProperties,PlotOptions(k),'left');
        end
        xtcklab='';

        case {'plothistogram'},
            if nobar==0
                [PlotHandles{k},SubplotProperties]=PlotHistogram(FigureProperties,SubplotProperties,DataProperties,PlotOptions(k),BarY,BarFaceColor,BarEdgeColor);
                nobar=1;
            end
            
        case {'plotstackedarea'},
            if nostackedarea==0
                PlotHandles{k}=PlotStackedArea(FigureProperties,SubplotProperties,DataProperties,PlotOptions(k),StackedAreaY,AreaFaceColor,AreaEdgeColor);
                nostackedarea=1;
            end
            
        case {'plotcontourmap','contourmap','plotcontours','plotcontourmaplines','plotpatches'},
            PlotContourMap(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps,ver);

        case {'plotgrid','drawgrid'},
            PlotGrid(DataProperties,SubplotProperties,PlotOptions(k));
            
        case {'plotannotation'},
            PlotHandles{k}=PlotAnnotation(DataProperties,SubplotProperties,PlotOptions(k));
            
        case {'plotcrosssections'},
            PlotCrossSections(DataProperties,SubplotProperties,PlotOptions(k));
            
        case {'plotsamples'},
            PlotHandles{k}=PlotSamples(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);
            
        case {'plotshadesmap','shadesmap','contourshades','continuousshades','plotpatches'},
            PlotShadesMap(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);
            
        case {'plotcontourlines','contourlines'},
            PlotContourLines(DataProperties,SubplotProperties,PlotOptions(k) );
            
        case {'plotvectors','plotcoloredvectors','plotvector','vector','vectors'},
            PlotVectors(FigureProperties,DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);

        case {'plotcurvedvectors','plotcurvedvector','curvedvector','curvedvectors'},
            SubplotProperties=PlotCurVec(DataProperties,SubplotProperties,PlotOptions(k) );
            
        case {'plotvectormagnitude','plotmagnitude','vectormagnitude'},
            PlotVectorMagnitude(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps,ver);
            
        case {'plotpolygon','plotpolygons','plotlandboundary','fillpolygon','fillpolygons','plotpolyline'},
            PlotHandles{k}=PlotPolygon(DataProperties, PlotOptions(k) );

        case {'plotkub'},
            PlotKub(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);

        case {'plotlint'},
            PlotLint( DataProperties,SubplotProperties,PlotOptions(k) );
            
        case {'plotimage','plotgeoimage'},
            ImageSize=PlotImage(DataProperties,PlotOptions(k));

        case {'plot3dsurface','plot3dsurfacelines'},
            Plot3DSurface(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);
   
        case {'plotpolygon3d'},
            PlotPolygon3D(DataProperties, PlotOptions(k) );

        case {'plotrose'},
            PlotRose(DataProperties, PlotOptions(k) );
            
    end

%     if PlotOptions(k).AddDate
%         switch lower(PlotOptions(k).AddDatePosition),
%             case {'lower-left'},
%                 xpos=SubplotProperties.XMin+0.005*SubplotProperties.Scale;
%                 ypos=SubplotProperties.YMin+0.005*SubplotProperties.Scale;
%                 HorAl='left';
%             case {'lower-right'},
%                 xpos=SubplotProperties.XMax-0.005*SubplotProperties.Scale;
%                 ypos=SubplotProperties.YMin+0.005*SubplotProperties.Scale;
%                 HorAl='right';
%             case {'upper-left'},
%                 xpos=SubplotProperties.XMin+0.005*SubplotProperties.Scale;
%                 ypos=SubplotProperties.YMax-0.005*SubplotProperties.Scale;
%                 HorAl='left';
%             case {'upper-right'},
%                 xpos=SubplotProperties.XMax-0.005*SubplotProperties.Scale;
%                 ypos=SubplotProperties.YMax-0.005*SubplotProperties.Scale;
%                 HorAl='right';
%         end
%         m=PlotOptions(k).AvailableDatasetNr;
%         datestring=[PlotOptions(k).AddDatePrefix datestr(DataProperties(m).DateTime,PlotOptions(k).AddDateFormat)];
%         tx=text(xpos,ypos,datestring);
%         set(tx,'HorizontalAlignment',HorAl);
%         set(tx,'FontSize',8);
%     end
    
%     PlotArrows(SubplotProperties,DefaultColors);
    
end

% if strcmp(lower(SubplotProperties.PlotType),'3d') & SubplotProperties.DrawBox
% else
%     xlabel(SubplotProperties.XLabel,'FontSize',SubplotProperties.XLabelFontSize*FigureProperties.FontRed,'FontName',SubplotProperties.XLabelFont,'Color',SubplotProperties.XLabelFontColor,'FontWeight',SubplotProperties.XLabelFontWeight,'FontAngle',SubplotProperties.XLabelFontAngle);
%     ylabel(SubplotProperties.YLabel,'FontSize',SubplotProperties.YLabelFontSize*FigureProperties.FontRed,'FontName',SubplotProperties.YLabelFont,'Color',SubplotProperties.YLabelFontColor,'FontWeight',SubplotProperties.YLabelFontWeight,'FontAngle',SubplotProperties.YLabelFontAngle);
%     title(SubplotProperties.Title,'FontSize',SubplotProperties.TitleFontSize*FigureProperties.FontRed,'FontName',SubplotProperties.TitleFont,'Color',SubplotProperties.TitleFontColor,'FontWeight',SubplotProperties.TitleFontWeight,'FontAngle',SubplotProperties.TitleFontAngle);
% end

switch lower(SubplotProperties.PlotType),
    
    case {'timeseries'},

        SetHisPlot(FigureProperties,SubplotProperties);
        if SubplotProperties.RightAxis
            set(gca,'Color','white');
            RightAxis=axes;
            SetRightAxis(FigureProperties,SubplotProperties,RightAxis);
        end
        
    case {'xy'},
        SetXYPlot(FigureProperties,SubplotProperties);
        if SubplotProperties.RightAxis
            set(gca,'Color','white');
            RightAxis=axes;
            SetRightAxis(FigureProperties,SubplotProperties,RightAxis);
        end
        
    case {'2d'},
%         for k=1:nodat
%             t1=PlotOptions(k).ContourLabels==1;
%             t2=strcmp(lower(PlotOptions(k).PlotRoutine),'plotcontourlines');
%             t3=strcmp(lower(PlotOptions(k).PlotRoutine),'plotcontourmaplines');
%             if t1 | t2 | t3
%                 SetMapPlot(FigureProperties,SubplotProperties);
%                 PlotContourLabels(DataProperties,SubplotProperties,PlotOptions(k),ColorMaps);
%             end
%         end
%         SetMapPlot(FigureProperties,SubplotProperties);
         axis equal;
        
    case {'image'},
        SetImagePlot(FigureProperties,SubplotProperties,ImageSize);

    case {'unknown'},
        SetUnknownPlot(FigureProperties,SubplotProperties);

    case {'3d'},
        Set3DPlot(FigureProperties,SubplotProperties);

    case {'rose'},
        SetRosePlot(FigureProperties,SubplotProperties);
        
    case {'textbox'},
        SetTextBox(FigureProperties,SubplotProperties);
        
end

if SubplotProperties.PlotColorBar==1
    ShadesBar=0;
    for k=1:nodat
        switch lower(PlotOptions(k).PlotRoutine),
            case{'plotshadesmap','plotpatches'}
                ShadesBar=1;
        end
    end
    ColBar=SetColBar(FigureProperties,SubplotProperties,ColorMaps,ShadesBar);
end

if SubplotProperties.PlotLegend
    SetLegend(FigureProperties,SubplotProperties,PlotOptions,PlotHandles,nodat);
end

if SubplotProperties.PlotVectorLegend
    VecLeg=SetVectorLegend(FigureProperties,SubplotProperties,PlotOptions,nodat);
end

% if SubplotProperties.PlotNorthArrow==1
%     NorthArrow=SetNorthArrow(FigureProperties,SubplotProperties);
% end
% 
% if SubplotProperties.PlotScaleBar==1
%     ScaleBar=SetScaleBar(FigureProperties,SubplotProperties);
% end
% 
% BackgroundColor=FindColor(SubplotProperties,'BackgroundColor',DefaultColors);
% 
% set(LeftAxis,'Color',BackgroundColor);

c=get(LeftAxis,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

% AddAxesMenu(LeftAxis);

