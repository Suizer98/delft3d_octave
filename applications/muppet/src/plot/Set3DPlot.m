function Set3DPlot(FigureProperties,SubplotProperties)
 
if SubplotProperties.Perspective
    set(gca,'Projection','perspective');
end
 
daspect([1/SubplotProperties.DataAspectRatio(1) 1/SubplotProperties.DataAspectRatio(2) 1/SubplotProperties.DataAspectRatio(3)]);

view(gca,[SubplotProperties.CameraAngle(1),SubplotProperties.CameraAngle(2)]);
set(gca,'CameraTarget',SubplotProperties.CameraTarget);
set(gca,'CameraViewAngle',SubplotProperties.CameraViewAngle);

h=light;
set(h,'style','local');
%lightangle(h,-135,55);
lightangle(h,SubplotProperties.LightAzimuth,SubplotProperties.LightElevation);

set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);
set(gca,'Layer','top');

if SubplotProperties.DrawBox==0
    
    set(gca,'XLim',[SubplotProperties.XMin SubplotProperties.XMax]);
    set(gca,'YLim',[SubplotProperties.YMin SubplotProperties.YMax]);
    set(gca,'ZLim',[SubplotProperties.ZMin SubplotProperties.ZMax]);

    if SubplotProperties.XTick~=-999.0
        xtickstart=SubplotProperties.XTick*floor(SubplotProperties.XMin/SubplotProperties.XTick);
        xtickstop=SubplotProperties.XTick*ceil(SubplotProperties.XMax/SubplotProperties.XTick);
        xtick=xtickstart:SubplotProperties.XTick:xtickstop;
        set(gca,'XTick',xtick,'FontSize',10*FigureProperties.FontRed);

        if SubplotProperties.DecimX>=0
            frmt=['%0.' num2str(SubplotProperties.DecimX) 'f'];
            for i=1:size(xtick,2)
                xlabls{i}=sprintf(frmt,xtick(i));
            end
            set(gca,'xticklabel',xlabls);
        end

        if SubplotProperties.DecimX==-999
            for i=1:size(xtick,2)
                xlabls{i}='';
            end
            set(gca,'xticklabel',xlabls);
        end
        
        if SubplotProperties.XGrid
            set(gca,'Xgrid','on');
        else
            set(gca,'Xgrid','off');
        end

    else
        tick(gca,'x','none');
    end

    if SubplotProperties.YTick~=-999.0
        ytickstart=SubplotProperties.YTick*floor(SubplotProperties.YMin/SubplotProperties.YTick);
        ytickstop=SubplotProperties.YTick*ceil(SubplotProperties.YMax/SubplotProperties.YTick);
        ytick=ytickstart:SubplotProperties.YTick:ytickstop;
        set(gca,'YTick',ytick,'FontSize',10*FigureProperties.FontRed);

        if SubplotProperties.DecimY>=0
            frmt=['%0.' num2str(SubplotProperties.DecimY) 'f'];
            for i=1:size(ytick,2)
                ylabls{i}=sprintf(frmt,ytick(i));
            end
            set(gca,'yticklabel',ylabls);
        end

        if SubplotProperties.DecimY==-999
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'zticklabel',ylabls);
        end

        
        if SubplotProperties.YGrid
            set(gca,'Ygrid','on');
        else
            set(gca,'Ygrid','off');
        end

    else
        tick(gca,'y','none');
    end

    if SubplotProperties.ZTick~=-999.0
        ztickstart=SubplotProperties.ZTick*floor(SubplotProperties.ZMin/SubplotProperties.ZTick);
        ztickstop=SubplotProperties.ZTick*ceil(SubplotProperties.ZMax/SubplotProperties.ZTick);
        ztick=ztickstart:SubplotProperties.ZTick:ztickstop;
        set(gca,'ZTick',ztick,'FontSize',10*FigureProperties.FontRed);

        if SubplotProperties.DecimZ>=0
            frmt=['%0.' num2str(SubplotProperties.DecimZ) 'f'];
            for i=1:size(ztick,2)
                zlabls{i}=sprintf(frmt,ztick(i));
            end
            set(gca,'zticklabel',zlabls);
        end

        if SubplotProperties.DecimZ==-999
            for i=1:size(ztick,2)
                zlabls{i}='';
            end
            set(gca,'zticklabel',zlabls);
        end

        if SubplotProperties.ZGrid
            set(gca,'Zgrid','on');
        else
            set(gca,'Zgrid','off');
        end

    else
        tick(gca,'z','none');
    end

else
    
    set(gca,'XLim',[SubplotProperties.XMin SubplotProperties.XMax]);
    set(gca,'YLim',[SubplotProperties.YMin SubplotProperties.YMax]);
    set(gca,'ZLim',[SubplotProperties.ZMin SubplotProperties.ZMax]);

    
    tick(gca,'x','none');
    tick(gca,'y','none');
    tick(gca,'z','none');
    axis off;

%     if FigureProperties.cm2pix==1
% 
%         ax0=gca;
%         ax1=axes;
%         set(ax1,'Units',FigureProperties.Units);
%         set(ax1,'Position',SubplotProperties.Position*FigureProperties.cm2pix);
%         box on;
%         axis on;
%         tick(ax1,'x','none');
%         tick(ax1,'y','none');
%         tick(ax1,'z','none');
%         tit=title(SubplotProperties.Title);
%         set(tit,'HitTest','off');
%         set(ax1,'HitTest','off');
%         
% %         txtx=SubplotProperties.Position(1)+0.5*SubplotProperties.Position(3);
% %         txty=SubplotProperties.Position(2)+SubplotProperties.Position(4)+0.4;
% %         txt=text(txtx,txty,SubplotProperties.Title,'FontSize',SubplotProperties.TitleFontSize*FigureProperties.FontRed,'FontName',SubplotProperties.TitleFont,'Color',SubplotProperties.TitleFontColor,'FontWeight',SubplotProperties.TitleFontWeight,'FontAngle',SubplotProperties.TitleFontAngle,'Clipping','off');
% %         set(txt,'HorizontalAlignment','center');
% %         set(txt,'VerticalAlignment','top');
% 
%         axes(ax0);
%     end


end
