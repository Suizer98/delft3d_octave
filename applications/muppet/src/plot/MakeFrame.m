function handles=MakeFrame(handles,ifig)

FigureProperties=handles.Figure(ifig);
DefaultColors=handles.DefaultColors;
Frames=handles.Frames;

PaperSize=FigureProperties.PaperSize*FigureProperties.cm2pix;
 
noframes=size(Frames,2);

k=0;

for i=1:noframes
    if strcmpi(FigureProperties.Frame,Frames(i).Name)
        k=i;
    end
end

if k==0
    disp('Warning: frame in session file does not exist!');
end

if FigureProperties.Orientation=='l'
    for i=1:Frames(k).Number
        FrameBoxPosition{i}(1)=Frames(k).Frame(i).Position(2);
        FrameBoxPosition{i}(2)=FigureProperties.PaperSize(2)-(Frames(k).Frame(i).Position(1)+Frames(k).Frame(i).Position(3));
        FrameBoxPosition{i}(3)=Frames(k).Frame(i).Position(4);
        FrameBoxPosition{i}(4)=Frames(k).Frame(i).Position(3);
    end
    for i=1:Frames(k).TextNumber
        FrameTextPosition{i}(1)=Frames(k).Text(i).Position(2);
        FrameTextPosition{i}(2)=FigureProperties.PaperSize(2)-Frames(k).Text(i).Position(1);
    end
    rotation=270;
else
    for i=1:Frames(k).Number
        FrameBoxPosition{i}=Frames(k).Frame(i).Position;
    end
    for i=1:Frames(k).TextNumber
        FrameTextPosition{i}=Frames(k).Text(i).Position;
    end
    rotation=0;
end

for i=1:Frames(k).Number

    FrameBox=axes;
    set(FrameBox,'Units',FigureProperties.Units);
    Pos=FrameBoxPosition{i};

    set(FrameBox,'Position',FigureProperties.cm2pix*Pos);
    set(FrameBox,'LineWidth',[1]);
    set(FrameBox,'color','none');
    tick(FrameBox,'x','none');
    tick(FrameBox,'y','none');
    box on;

    set(FrameBox,'HitTest','off');
    c=get(FrameBox,'Children');
    ff=findall(c,'HitTest','on');
    set(ff,'HitTest','off');

    set(FrameBox,'Tag','framebox','UserData',[ifig,i]);
    
end
clear c;

ax=axes;
set(ax,'Units',FigureProperties.Units);
set(ax,'Position',[0.0 0.0 PaperSize(1) PaperSize(2)]);
set(ax,'color','none');
set(gca,'xlim',[0 FigureProperties.PaperSize(1)]);
set(gca,'ylim',[0 FigureProperties.PaperSize(2)]);
tick(ax,'x','none');
tick(ax,'y','none');
box off;
axis off;
set(ax,'Tag','frametextaxis','UserData',[ifig]);

for i=1:Frames(k).TextNumber
    Color=FindColor(FigureProperties.FrameText(i),'Color',DefaultColors);
    if ~isempty(FigureProperties.FrameText(i).Text) || FigureProperties.cm2pix==1
        tx=text(FrameTextPosition{i}(1),FrameTextPosition{i}(2),FigureProperties.FrameText(i).Text);hold on;
        set(tx,'Color',Color);
    else
        tx=text(FrameTextPosition{i}(1),FrameTextPosition{i}(2),['Frametext ' num2str(i)]);hold on;
        set(tx,'Color',[0.8 0.8 0.8]);
    end        
    set(tx,'FontSize',FigureProperties.FrameText(i).Size*FigureProperties.FontRed);
    set(tx,'FontAngle',FigureProperties.FrameText(i).Angle);
    set(tx,'FontName',FigureProperties.FrameText(i).Font);
    set(tx,'Rotation',rotation);
    set(tx,'HorizontalAlignment',Frames(k).Text(i).HorizontalAlignment);
    set(tx,'VerticalAlignment','baseline');
    set(tx,'Tag','frametext','UserData',[ifig,i]);
    set(tx,'ButtonDownFcn',{@SelectFrameText});
end
set(ax,'HitTest','off');
set(ax,'Tag','frametextaxis');

if Frames(k).NumberLogos>0
    for j=1:Frames(k).NumberLogos
        LogoPlot(j)=axes;
        jpeg=jpg(Frames(k).Logo(j).File,1.0,1);
        if FigureProperties.Orientation=='l'
            pos(1)=Frames(k).Logo(j).Position(2);
            pos(2)=FigureProperties.PaperSize(2)-(Frames(k).Logo(j).Position(1)+Frames(k).Logo(j).Position(3));
            pos(3)=Frames(k).Logo(j).Position(3)*size(jpeg.x,2)/size(jpeg.x,1);
            pos(4)=pos(3)*size(jpeg.x,1)/size(jpeg.x,2);
            rot=3;
            jpeg.x0=rot90(jpeg.y,rot);
            jpeg.y=rot90(jpeg.x,1);
            jpeg.x=jpeg.x0;
            jpeg.z=rot90(jpeg.z,rot);
            c1=squeeze(jpeg.c(:,:,1));
            c2=squeeze(jpeg.c(:,:,2));
            c3=squeeze(jpeg.c(:,:,3));
            c1=rot90(c1,rot);
            c2=rot90(c2,rot);
            c3=rot90(c3,rot);
            clear jpeg.c
            c(:,:,1)=c1;
            c(:,:,2)=c2;
            c(:,:,3)=c3;
            jpeg.c=c;
        else
            pos=Frames(k).Logo(j).Position;
            pos(4)=pos(3)*size(jpeg.x,2)/size(jpeg.x,1);
        end
        surf(jpeg.x,jpeg.y,jpeg.z,jpeg.c);shading interp;hold on;axis equal;view(2);
        set(LogoPlot(j),'Units',FigureProperties.Units);
        set(LogoPlot(j),'Position',[pos*FigureProperties.cm2pix]);
        set(LogoPlot(j),'color','none');
        tick(LogoPlot(j),'x','none');
        tick(LogoPlot(j),'y','none');
        box off;axis off;

        set(LogoPlot(j),'HitTest','off');
        c=get(LogoPlot(j),'Children');
        ff=findall(c,'HitTest','on');
        set(ff,'HitTest','off');
        set(LogoPlot(j),'Tag','logoaxis','UserData',[ifig,j]);

    end
end

