function muppet_refreshColorMap(handles)

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;

if plt.usecustomcontours
    col=plt.contours;
else
    col=plt.cmin:plt.cstep:plt.cmax;
end

ncol=size(col,2)-1;
clmap=muppet_getColors(handles.colormaps,plt.colormap,ncol);

colormap(clmap);
 
for i=1:ncol
    xp(1,i)=i-1;
    xp(2,i)=i;
    xp(3,i)=i;
    xp(4,i)=i-1;
    yp(:,i)=[0 ; 0 ; 1 ; 1];
end
zp=col(1:end-1);

ax=findobj(gcf,'tag','colormapaxis');
if ~isempty(ax)
    axes(ax);
    cla;
    
    for i=1:ncol
        patch(xp(:,i),yp(:,i),zp(i),'clipping','on');shading flat;hold on;
    end
    
    set(ax,'xlim',[0 ncol-0.1],'ylim',[0.1 0.9]);
    tick(ax,'x','none');
    tick(ax,'y','none');
    box off;
end
