function muppet_set3DPlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

if plt.perspective
    set(gca,'Projection','perspective');
end

daspect(plt.dataaspectratio);

set(gca,'CameraPositionMode','manual');
set(gca,'CameraTargetMode','manual');
set(gca,'CameraViewAngleMode','manual');

% Camera
switch plt.viewmode3d
    case 1
        tar=plt.cameratarget;
        pos=plt.cameraposition;
    case 2
        ang=[plt.cameraangle plt.cameradistance];
        tar=plt.cameratarget;
        pos=cameraview('viewangle',ang,'target',tar,'dataaspectratio',plt.dataaspectratio);
    case 3
        ang=[plt.cameraangle plt.cameradistance];
        pos=plt.cameraposition;
        tar=cameraview('viewangle',ang,'position',pos,'dataaspectratio',plt.dataaspectratio);
end
set(gca,'CameraTarget',tar);
set(gca,'CameraPosition',pos);
set(gca,'CameraViewAngle',plt.cameraviewangle);

% Lights
if plt.light
    h=light;
    set(h,'style','infinite');
    lightangle(h,plt.lightangle(1),plt.lightangle(2));
end

set(gca,'Units',units);
set(gca,'Position',plt.position*cm2pix);
set(gca,'Layer','top');

if plt.drawbox==0
    
    set(gca,'XLim',[plt.xmin plt.xmax]);
    set(gca,'YLim',[plt.ymin plt.ymax]);
    set(gca,'ZLim',[plt.zmin plt.zmax]);

    if plt.xtick~=-999.0
        xtickstart=plt.xtick*floor(plt.xmin/plt.xtick);
        xtickstop=plt.xtick*ceil(plt.xmax/plt.xtick);
        xtick=xtickstart:plt.xtick:xtickstop;
        set(gca,'xtick',xtick,'FontSize',10*fontred);

        if plt.xdecimals>=0
            frmt=['%0.' num2str(plt.xdecimals) 'f'];
            for i=1:size(xtick,2)
                xlabls{i}=sprintf(frmt,xtick(i));
            end
            set(gca,'xticklabel',xlabls);
        end

        if plt.xdecimals==-999
            for i=1:size(xtick,2)
                xlabls{i}='';
            end
            set(gca,'xticklabel',xlabls);
        end
        
        if plt.xgrid
            set(gca,'Xgrid','on');
        else
            set(gca,'Xgrid','off');
        end

    else
        tick(gca,'x','none');
    end

    if plt.ytick~=-999.0
        ytickstart=plt.ytick*floor(plt.ymin/plt.ytick);
        ytickstop=plt.ytick*ceil(plt.ymax/plt.ytick);
        ytick=ytickstart:plt.ytick:ytickstop;
        set(gca,'ytick',ytick,'FontSize',10*fontred);

        if plt.ydecimals>=0
            frmt=['%0.' num2str(plt.ydecimals) 'f'];
            for i=1:size(ytick,2)
                ylabls{i}=sprintf(frmt,ytick(i));
            end
            set(gca,'yticklabel',ylabls);
        end

        if plt.ydecimals==-999
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'zticklabel',ylabls);
        end

        
        if plt.ygrid
            set(gca,'Ygrid','on');
        else
            set(gca,'Ygrid','off');
        end

    else
        tick(gca,'y','none');
    end

    if plt.ztick~=-999.0
        ztickstart=plt.ztick*floor(plt.zmin/plt.ztick);
        ztickstop=plt.ztick*ceil(plt.zmax/plt.ztick);
        ztick=ztickstart:plt.ztick:ztickstop;
        set(gca,'ztick',ztick,'FontSize',10*fontred);

        if plt.zdecimals>=0
            frmt=['%0.' num2str(plt.zdecimals) 'f'];
            for i=1:size(ztick,2)
                zlabls{i}=sprintf(frmt,ztick(i));
            end
            set(gca,'zticklabel',zlabls);
        end

        if plt.zdecimals==-999
            for i=1:size(ztick,2)
                zlabls{i}='';
            end
            set(gca,'zticklabel',zlabls);
        end

        if plt.zgrid
            set(gca,'Zgrid','on');
        else
            set(gca,'Zgrid','off');
        end

    else
        tick(gca,'z','none');
    end

else
    
    tick(gca,'x','none');
    tick(gca,'y','none');
    tick(gca,'z','none');
    axis off;

end
