function clrbar=muppet_setColorBar(fig,ifig,isub,varargin)

handles=getHandles;

if nargin==3
    % Color bar belonging to subplot
    h=findobj(gcf,'Tag','colorbar','UserData',[ifig,isub]);
    delete(h);
    plt=fig.subplots(isub).subplot;
else
    % Color bar belonging to dataset in subplot
    kk=varargin{1};
    h=findobj(gcf,'Tag','colorbar','UserData',[ifig,isub,kk]);
    % Delete existing color bar
    delete(h);
    plt=fig.subplots(isub).subplot.datasets(kk).dataset;
end

fontred=fig.fontreduction;
units=fig.units;
cm2pix=fig.cm2pix;

if ~plt.usecustomcontours
    contours=plt.cmin:plt.cstep:plt.cmax;
else
    contours=plt.customcontours;
end
notick=size(contours,2)-1;
if plt.shadesbar==0
    nocol=size(contours,2)+1;
else
    nocol=64;
end

clmap=muppet_getColors(handles.colormaps,plt.colormap,nocol);

clrbar=axes;
 
if plt.colorbar.type==1

    if isempty(plt.colorbar.position)
        pos(1)=fig.subplots(isub).subplot.position(1)+1;
        pos(2)=fig.subplots(isub).subplot.position(2)+1;
        pos(3)=0.5;
        pos(4)=fig.subplots(isub).subplot.position(4)-2;
        plt.colorbar.position=pos;
    end
    
    if plt.colorbar.position(4)>plt.colorbar.position(3)

        % Vertical orientation
        
        wdt=plt.colorbar.position(3);
        len=plt.colorbar.position(4);
        sztri=1*wdt/len;

        % First two triangles
        % Bottom
        col=clmap(1,:);
        x(1)=0;x(2)=1;x(3)=0.5;
        y(1)=0;
        y(2)=0;
        y(3)=-sztri;
        fl=fill(x,y,'b');hold on;
        set(fl,'FaceColor',col,'EdgeColor',colorlist('getrgb','color',plt.colorbar.font.color),'LineStyle','-');
        set(fl,'Clipping','off');
        % Top
        col=clmap(end,:);
        x(1)=0;x(2)=1;x(3)=0.5;
        y(1)=1;
        y(2)=1;
        y(3)=1+sztri;
        fl=fill(x,y,'b');hold on;
        set(fl,'FaceColor',col,'EdgeColor',colorlist('getrgb','color',plt.colorbar.font.color),'LineStyle','-');
        set(fl,'Clipping','off');
        
        ipos=0;
        for icol=2:nocol-1
            ipos=ipos+1;
            col=clmap(icol,:);
            x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
            y(1)=(ipos-1)/(nocol-2);
            y(2)=y(1);
            y(3)=ipos/(nocol-2);
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
 
        set(clrbar,'xlim',[0.0 1.0],'ylim',[0 1]);
        set(clrbar,'units',units);
        set(clrbar,'position',plt.colorbar.position*cm2pix);
        set(clrbar,'XTick',[]);
        set(clrbar,'YTick',0:(1/(notick)):1,'FontSize',8*fontred);
        set(clrbar,'YAxisLocation','right');
        set(clrbar,'Color','none');
        set(clrbar,'clipping','off');
        
        for i=1:size(contours,2)
            ylabls{i}='';
        end

        if plt.colorbar.decimals>=0
            frmt=['%0.' num2str(plt.colorbar.decimals) 'f'];
            for i=1:plt.colorbar.tickincrement:size(contours,2)
                ylabls{i}=[sprintf(frmt,contours(i)) ' ' plt.colorbar.unit];
            end
        else
            for i=1:plt.colorbar.tickincrement:size(contours,2)
                ylabls{i}=[num2str(contours(i)) ' ' plt.colorbar.unit];
                if contours(i)<0
                    ylabls{i}=['10^-^' num2str(-contours(i))];
                else
                    ylabls{i}=['10^' num2str(contours(i))];
                end
            end
        end
        set(gca,'yticklabel',ylabls);
        set(gca,'Layer','top');
        set(gca,'FontName',plt.colorbar.font.name);
        set(gca,'FontSize',plt.colorbar.font.size*fontred);
        set(gca,'FontWeight',plt.colorbar.font.weight);
        set(gca,'FontAngle',plt.colorbar.font.angle);
        set(gca,'YColor',colorlist('getrgb','color',plt.colorbar.font.color));

        txx=-0.25/(plt.colorbar.position(3));
        txy=0.5;
        ylab=text(txx,txy,plt.colorbar.label);

        set(ylab,'Rotation',90);
        set(ylab,'HorizontalAlignment','center','VerticalAlignment','middle');

        set(ylab,'FontName',plt.colorbar.font.name);
        set(ylab,'FontSize',plt.colorbar.font.size*fontred);
        set(ylab,'FontWeight',plt.colorbar.font.weight);
        set(ylab,'FontAngle',plt.colorbar.font.angle);
        set(ylab,'Color',colorlist('getrgb','color',plt.colorbar.font.color));
        
    else

        
        wdt=plt.colorbar.position(3);
        len=plt.colorbar.position(4);
        sztri=1*len/wdt;
        
        % First two triangles
        % Left
        col=clmap(1,:);
        x(1)=0;x(2)=0;x(3)=-sztri;
        y(1)=0;
        y(2)=1;
        y(3)=0.5;
        fl=fill(x,y,'b');hold on;
        set(fl,'FaceColor',col,'EdgeColor',colorlist('getrgb','color',plt.colorbar.font.color),'LineStyle','-');
        set(fl,'Clipping','off');
        % Right
        col=clmap(end,:);
        x(1)=1;x(2)=1;x(3)=1+sztri;
        y(1)=0;
        y(2)=1;
        y(3)=0.5;
        fl=fill(x,y,'b');hold on;
        set(fl,'FaceColor',col,'EdgeColor',colorlist('getrgb','color',plt.colorbar.font.color),'LineStyle','-');
        set(fl,'Clipping','off');
        
        ipos=0;
        for icol=2:nocol-1
            ipos=ipos+1;
            col=clmap(icol,:);
            x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
            y(1)=(ipos-1)/(nocol-2);
            y(2)=y(1);
            y(3)=ipos/(nocol-2);
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
        
        ipos=0;
        for icol=2:nocol-1
            ipos=ipos+1;
            col=clmap(icol,:);
            x(1)=(ipos-1)/(nocol-2);
            x(2)=ipos/(nocol-2);
            x(3)=x(2);
            x(4)=x(1);
            x(5)=x(1);
            y(1)=0;y(2)=0;y(3)=1;y(4)=1;y(5)=0;
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
 
        set(clrbar,'xlim',[0 1],'ylim',[0 1]);
        set(clrbar,'units',units);
        set(clrbar,'position',plt.colorbar.position*cm2pix);
        set(clrbar,'XTick',[0:(1/(notick)):1],'FontSize',8*fontred);
        set(clrbar,'YTick',[]);

        for i=1:size(contours,2)
            xlabls{i}='';
        end
        
        if plt.colorbar.decimals>=0
            frmt=['%0.' num2str(plt.colorbar.decimals) 'f'];
            for i=1:plt.colorbar.tickincrement:size(contours,2)
%                xlabls{i}=sprintf(frmt,contours(i));
                xlabls{i}=[sprintf(frmt,contours(i)) '' plt.colorbar.unit];
            end
        else
            for i=1:plt.colorbar.tickincrement:size(contours,2)
%                xlabls{i}=num2str(contours(i));
                xlabls{i}=[num2str(contours(i)) '' plt.colorbar.unit];
            end
        end

        set(gca,'xticklabel',xlabls);
        set(gca,'Layer','top');
        set(gca,'FontName',plt.colorbar.font.name);
        set(gca,'FontSize',plt.colorbar.font.size*fontred);
        set(gca,'FontWeight',plt.colorbar.font.weight);
        set(gca,'FontAngle',plt.colorbar.font.angle);
        set(gca,'XColor',colorlist('getrgb','color',plt.colorbar.font.color));

        
        xlab=title(plt.colorbar.label);

        set(xlab,'FontName',plt.colorbar.font.name);
        set(xlab,'FontSize',plt.colorbar.font.size*fontred);
        set(xlab,'FontWeight',plt.colorbar.font.weight);
        set(xlab,'FontAngle',plt.colorbar.font.angle);
        set(xlab,'Color',colorlist('getrgb','color',plt.colorbar.font.color));

    end
 
else
    
    nocol=size(contours,2)+1;

    clmap=muppet_getColors(handles.colormaps,plt.colormap,nocol);
 
    xsize=plt.colorbar.position(3);
    ysize=plt.colorbar.position(4);
    border=0.1;
    blsize=plt.colorbar.font.size*0.3/8;
    xdist=plt.colorbar.font.size*1.3/8;
    ydist=plt.colorbar.font.size*0.2/8;
 
    ny=min(round((ysize-(2*border))/(blsize+ydist)),nocol);
    ny=max(ny,1);
    nx=ceil(nocol/ny);
 
    k=0;
    for i=1:nx
        for j=1:ny
            k=k+1;
            col=clmap(k,:);
            x(1)=border+(i-1)*(xdist+blsize);
            x(2)=x(1)+blsize;
            x(3)=x(2);
            x(4)=x(1);
            x(5)=x(1);
            y(1)=ysize-border-(j-1)*(ydist+blsize);
            y(2)=y(1);
            y(3)=y(1)-blsize;
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'Clipping','off');
 
            if k==1
                str1='< ';
                val=contours(k);
            else
                str1='> ';
                val=contours(k-1);
            end
 
            if plt.colorbar.decimals>=0
                frmt=['%0.' num2str(plt.colorbar.decimals) 'f'];
                str2=num2str(val,frmt);
            else
                str2=num2str(val);
            end
 
            str=[str1 str2 ' ' plt.colorbar.unit];
            tx=text(x(2)+0.1,0.5*(y(1)+y(3)),str);


            set(tx,'FontName',plt.colorbar.font.name);
            set(tx,'FontSize',plt.colorbar.font.size*fontred);
            set(tx,'FontWeight',plt.colorbar.font.weight);
            set(tx,'FontAngle',plt.colorbar.font.angle);
            set(tx,'Color',colorlist('getrgb','color',plt.colorbar.font.color));
            
            if k==nocol
                break
            end
        end
        
        xlab=title(plt.colorbar.label);
        set(xlab,'FontName',plt.colorbar.font.name);
        set(xlab,'FontSize',plt.colorbar.font.size*fontred);
        set(xlab,'FontWeight',plt.colorbar.font.weight);
        set(xlab,'FontAngle',plt.colorbar.font.angle);
        set(xlab,'Color',colorlist('getrgb','color',plt.colorbar.font.color));
        
    end
 
    xsize1=min(xsize,(2*border+nx*(xdist+blsize)));
    set(clrbar,'xlim',[0 xsize1],'ylim',[0 ysize]);
    set(clrbar,'units',units);
    x0=plt.colorbar.position(1);
    y0=plt.colorbar.position(2);
    x1=plt.colorbar.position(3);
    y1=plt.colorbar.position(4);
    set(clrbar,'position',[x0 y0 xsize1 y1]*cm2pix);
 
    if plt.colorbar.type==2
        tick(gca,'x','none');
        tick(gca,'y','none');
        box on;
    else
        tick(gca,'x','none');
        tick(gca,'y','none');
        if cm2pix==1
            box off;
            axis off;
        else
            set(gca,'Color','none');
            set(gca,'XColor',[0.8 0.8 0.8]);
            set(gca,'YColor',[0.8 0.8 0.8]);
            box on;
        end
    end
 
end

if nargin==3
    set(clrbar,'Tag','colorbar','UserData',[ifig,isub]);
else
    set(clrbar,'Tag','colorbar','UserData',[ifig,isub,kk]);
end

c=get(clrbar,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');
