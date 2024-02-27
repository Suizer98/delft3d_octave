function h=muppet_plot2DSurface(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

data.x=data.x(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.y=data.y(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.z=data.z(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.zz=data.zz(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);

switch(lower(opt.plotroutine))
    case{'patches','shades map','contour map','contour map and lines'}
        % Contours from axis properties
        if ~plt.usecustomcontours
            col=plt.cmin:plt.cstep:plt.cmax;
        else
            col=plt.customcontours;
        end
    case{'contour lines'}
        % Contours from plot properties
        if ~opt.usecustomcontours
            col=opt.cmin:opt.cstep:opt.cmax;
        else
            col=opt.customcontours;
        end
end

c1=col(1);
c2=col(end);
dc=col(2)-col(1);

switch(lower(opt.plotroutine))
    case{'patches'}
        x=data.x;
        y=data.y;
%         z(isnan(data.zz))=NaN;
%         y(isnan(data.zz))=NaN;
        z=data.zz;
        
        if ~plt.usecustomcontours
            zc=z;
            cax=[col(1) col(end)];
        else
            isn=isnan(z);
            zc=z;
            zc=max(zc,col(1));
            zc=min(zc,col(end));
            zc=interp1(col,1:length(col),zc);
            zc(isn)=NaN;
            cax=[1 length(col)-1];
        end
        
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        colormap(clmap);
        
%         plot(data.x,data.y,'o');
        h=pcolor(x,y,zc);
        shading flat;
        caxis(cax);
    case{'contour map','contour map and lines'}
        z=max(data.z,c1-dc);
        z=min(z,c2+dc);
        z(isnan(data.z))=NaN;
        x=data.x;
        y=data.y;
        xmean=mean(x(isfinite(x)));
        ymean=mean(y(isfinite(y)));
        x(isnan(x))=xmean;
        y(isnan(y))=ymean+10000;
%        y(isnan(y))=ymean;
%         x(isnan(x))=0;
%         y(isnan(y))=0;
        z(isnan(x))=NaN;
%         z(isnan(x))=0;
%        z(isnan(z))=0;
        if ~plt.usecustomcontours
            zc=z;
            cax=[col(1)-dc col(end)];
            contours=col(1)-dc:dc:col(end)+dc;
        else
            isn=isnan(z);
            zc=z;
            zc=max(zc,col(1));
            zc=min(zc,col(end));
            zc=interp1(col,1:length(col),zc);
            zc(isn)=NaN;
            cax=[1 length(col)-1];
            contours=1:length(col)-1;
        end
        [c,h,wp]=muppet_contourf_mvo(x,y,zc,contours);
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        caxis(cax);
        colormap(clmap);
    case{'shades map'}
        x=data.x;
        y=data.y;
        z=data.z;
        ncol=128;

        if ~plt.usecustomcontours
            zc=z;
            cax=[col(1) col(end)];
        else
            isn=isnan(z);
            zc=z;
            zc=max(zc,col(1));
            zc=min(zc,col(end));
            zc=interp1(col,1:length(col),zc);
            zc(isn)=NaN;
            cax=[1 length(col)-1];
        end
        
        clmap=muppet_getColors(handles.colormaps,plt.colormap,ncol);
        colormap(clmap);
        h=pcolor(x,y,zc);
        shading interp;
        caxis(cax);
    case{'contour lines'}
        x=data.x;
        y=data.y;
        z=data.z;
        [c,h]=contour(x,y,z,col);
        if strcmpi(opt.linecolor,'auto')==0
            set(h,'LineColor',colorlist('getrgb','color',opt.linecolor));
        end
        set(h,'LineStyle',opt.linestyle);
        set(h,'LineWidth',opt.linewidth);
end

hold on;

if strcmpi(opt.plotroutine,'contour map and lines')
    [c,h]=contour(x,y,z,col);
    if strcmpi(opt.linecolor,'auto')==0
        set(h,'LineColor',colorlist('getrgb','color',opt.linecolor));
    else
        set(h,'LineColor','k');
    end
    set(h,'LineStyle',opt.linestyle);
    set(h,'LineWidth',opt.linewidth);
end

if opt.contourlabels
    switch lower(opt.plotroutine)
        case{'contour map','patches'}
            [c,h]=contour(x,y,z,col);
            set(h,'LineStyle','none');
    end
    clabel(c,h,'LabelSpacing',opt.labels.spacing, ...
    'FontName',opt.labels.font.weight,'FontSize',opt.labels.font.size*handles.figures(ifig).figure.fontreduction, ...
    'FontWeight',opt.labels.font.weight,'FontAngle',opt.labels.font.angle, ...
    'Color',colorlist('getrgb','color',opt.labels.font.color));
end
