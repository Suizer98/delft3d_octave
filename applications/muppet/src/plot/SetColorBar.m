function clrbar=SetColorBar(handles,ii,jj,varargin)


FigureProperties=handles.Figure(ii);
if nargin==3
    h=findobj(gcf,'Tag','colorbar','UserData',[ii,jj]);
    delete(h);
    SubplotProperties=handles.Figure(ii).Axis(jj);
else
    kk=varargin{1};
    h=findobj(gcf,'Tag','colorbar','UserData',[ii,jj,kk]);
    delete(h);
    SubplotProperties=handles.Figure(ii).Axis(jj).Plot(kk);
    SubplotProperties.ColMap=handles.Figure(ii).Axis(jj).Plot(kk).ColorMap;
end

if strcmpi(SubplotProperties.ContourType,'limits')
    contours=[SubplotProperties.CMin:SubplotProperties.CStep:SubplotProperties.CMax];
else
    contours=SubplotProperties.Contours;
end
notick=size(contours,2)-1;
if SubplotProperties.ShadesBar==0
    nocol=size(contours,2)-1;
else
    nocol=64;
end

clmap=GetColors(handles.ColorMaps,SubplotProperties.ColMap,nocol);

clrbar=axes;
 
if SubplotProperties.ColorBarType==1
 
    if SubplotProperties.ColorBarPosition(4)>SubplotProperties.ColorBarPosition(3)
 
        for i=1:nocol
            col=clmap(i,:);
            x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
            y(1)=(i-1)/nocol;
            y(2)=y(1);
            y(3)=i/nocol;
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
 
        set(clrbar,'xlim',[0 1],'ylim',[0 1]);
        set(clrbar,'Units',FigureProperties.Units);
        set(clrbar,'Position',SubplotProperties.ColorBarPosition*FigureProperties.cm2pix);
        set(clrbar,'XTick',[]);
        set(clrbar,'YTick',[0:(1/(notick)):1],'FontSize',8*FigureProperties.FontRed);
        set(clrbar,'YAxisLocation','right');

        for i=1:size(contours,2)
            ylabls{i}='';
        end

        if SubplotProperties.ColorBarDecimals>=0
            frmt=['%0.' num2str(SubplotProperties.ColorBarDecimals) 'f'];
            for i=1:SubplotProperties.ColorBarLabelIncrement:size(contours,2)
                ylabls{i}=[sprintf(frmt,contours(i)) ' ' SubplotProperties.ColorBarUnit];
            end
        else
            for i=1:SubplotProperties.ColorBarLabelIncrement:size(contours,2)
                ylabls{i}=[num2str(contours(i)) ' ' SubplotProperties.ColorBarUnit];
            end
        end
        set(gca,'yticklabel',ylabls);
        set(gca,'Layer','top');
        set(gca,'FontName',SubplotProperties.ColorBarFont);
        set(gca,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(gca,'FontWeight',SubplotProperties.ColorBarFontWeight);
        set(gca,'FontAngle',SubplotProperties.ColorBarFontAngle);
        set(gca,'YColor',SubplotProperties.ColorBarFontColor);

        txx=-0.5/(SubplotProperties.ColorBarPosition(3));
        txy=0.5;
        ylab=text(txx,txy,SubplotProperties.ColorBarLabel);

%        ylab=title(SubplotProperties.ColorBarLabel);

        set(ylab,'Rotation',90);
        set(ylab,'HorizontalAlignment','center','VerticalAlignment','middle');

        set(ylab,'FontName',SubplotProperties.ColorBarFont);
        set(ylab,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(ylab,'FontWeight',SubplotProperties.ColorBarFontWeight);
        set(ylab,'FontAngle',SubplotProperties.ColorBarFontAngle);
        set(ylab,'Color',SubplotProperties.ColorBarFontColor);
        
    else
 
        for i=1:nocol;
            col=clmap(i,:);
            x(1)=(i-1)/nocol;
            x(2)=i/nocol;
            x(3)=x(2);
            x(4)=x(1);
            x(5)=x(1);
            y(1)=0;y(2)=0;y(3)=1;y(4)=1;y(5)=0;
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
 
        set(clrbar,'xlim',[0 1],'ylim',[0 1]);
        set(clrbar,'Units',FigureProperties.Units);
        set(clrbar,'Position',SubplotProperties.ColorBarPosition*FigureProperties.cm2pix);
        set(clrbar,'XTick',[0:(1/(notick)):1],'FontSize',8*FigureProperties.FontRed);
        set(clrbar,'YTick',[]);

        for i=1:size(contours,2)
            xlabls{i}='';
        end
        
        if SubplotProperties.ColorBarDecimals>=0
            frmt=['%0.' num2str(SubplotProperties.ColorBarDecimals) 'f'];
            for i=1:SubplotProperties.ColorBarLabelIncrement:size(contours,2)
                xlabls{i}=sprintf(frmt,contours(i));
            end
        else
            for i=1:SubplotProperties.ColorBarLabelIncrement:size(contours,2)
                xlabls{i}=num2str(contours(i));
            end
        end
        set(gca,'xticklabel',xlabls);
        set(gca,'Layer','top');
        set(gca,'FontName',SubplotProperties.ColorBarFont);
        set(gca,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(gca,'FontWeight',SubplotProperties.ColorBarFontWeight);
        set(gca,'FontAngle',SubplotProperties.ColorBarFontAngle);
        set(gca,'XColor',SubplotProperties.ColorBarFontColor);
        
        xlab=title(SubplotProperties.ColorBarLabel);
        set(xlab,'FontName',SubplotProperties.ColorBarFont);
        set(xlab,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(xlab,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(xlab,'FontWeight',SubplotProperties.ColorBarFontWeight);
        set(xlab,'FontAngle',SubplotProperties.ColorBarFontAngle);
        set(xlab,'Color',SubplotProperties.ColorBarFontColor);
 
    end
 
else
    
    if strcmp(lower(SubplotProperties.ContourType),'limits')
        contours=[SubplotProperties.CMin:(SubplotProperties.CStep*SubplotProperties.ColorBarLabelIncrement):SubplotProperties.CMax];
    else
        contours=SubplotProperties.Contours;
    end
%    contours=contours(1:SubplotProperties.ColorBarLabelIncrement:end);
    notick=size(contours,2)-1;
    nocol=size(contours,2)-1;

    clmap=GetColors(handles.ColorMaps,SubplotProperties.ColMap,nocol);
 
    xsize=SubplotProperties.ColorBarPosition(3);
    ysize=SubplotProperties.ColorBarPosition(4);
    border=0.1;
    blsize=SubplotProperties.ColorBarFontSize*0.3/8;
    xdist=SubplotProperties.ColorBarFontSize*1.3/8;
    ydist=SubplotProperties.ColorBarFontSize*0.2/8;
 
    ny=min(round((ysize-(2*border))/(blsize+ydist)),nocol);
    ny=max(ny,1);
    nx=ceil(nocol/ny);
 
    k=0;
    for i=1:nx
        for j=1:ny
            k=k+1;
            col=clmap(k,:);
            x(1)=border+(i-1)*(xdist+blsize);
%            x(2)=x(1)+blsize*2;
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
            set(fl,'FaceColor',col);
 
            if k==1
                str1='< ';
                val=SubplotProperties.CMin+SubplotProperties.CStep;
                val=contours(k+1);
            else
                str1='> ';
                val=SubplotProperties.CMin+(k-1)*SubplotProperties.CStep;
                val=contours(k);
            end
 
            if SubplotProperties.ColorBarDecimals>=0
                frmt=['%0.' num2str(SubplotProperties.ColorBarDecimals) 'f'];
                str2=num2str(val,frmt);
            else
                str2=num2str(val);
            end
 
            str=[str1 str2 ' ' SubplotProperties.ColorBarUnit];
            tx=text(x(2)+0.1,0.5*(y(1)+y(3)),str);

            set(tx,'FontName',SubplotProperties.ColorBarFont);
            set(tx,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
            set(tx,'FontWeight',SubplotProperties.ColorBarFontWeight);
            set(tx,'FontAngle',SubplotProperties.ColorBarFontAngle);
            set(tx,'Color',SubplotProperties.ColorBarFontColor);

            if k==nocol
                break
            end
        end
        
        xlab=title(SubplotProperties.ColorBarLabel);
        set(xlab,'FontName',SubplotProperties.ColorBarFont);
        set(xlab,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(xlab,'FontSize',SubplotProperties.ColorBarFontSize*FigureProperties.FontRed);
        set(xlab,'FontWeight',SubplotProperties.ColorBarFontWeight);
        set(xlab,'FontAngle',SubplotProperties.ColorBarFontAngle);
        set(xlab,'Color',SubplotProperties.ColorBarFontColor);

    end
 
    xsize1=min(xsize,(2*border+nx*(xdist+blsize)));
    set(clrbar,'xlim',[0 xsize1],'ylim',[0 ysize]);
    set(clrbar,'Units',FigureProperties.Units);
    x0=SubplotProperties.ColorBarPosition(1);
    y0=SubplotProperties.ColorBarPosition(2);
    x1=SubplotProperties.ColorBarPosition(3);
    y1=SubplotProperties.ColorBarPosition(4);
    set(clrbar,'Position',[x0 y0 xsize1 y1]*FigureProperties.cm2pix);
 
    if SubplotProperties.ColorBarType==2
        tick(gca,'x','none');
        tick(gca,'y','none');
        box on;
    else
        tick(gca,'x','none');
        tick(gca,'y','none');
        if FigureProperties.cm2pix==1
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
    set(clrbar,'Tag','colorbar','UserData',[ii,jj]);
    set(clrbar,'ButtonDownFcn',{@SelectColorBar,1});
else
    set(clrbar,'Tag','colorbar','UserData',[ii,jj,kk]);
    set(clrbar,'ButtonDownFcn',{@SelectColorBar,2});
end

c=get(clrbar,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

