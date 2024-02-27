function muppet_makeFrame(handles,ifig)

fig=handles.figures(ifig).figure;

height=fig.height*fig.cm2pix;
width=fig.width*fig.cm2pix;

k=strmatch(lower(fig.frame),lower(handles.frames.names),'exact');

if isempty(k)
    disp('Warning: frame in session file does not exist!');
    return
end

frame=handles.frames.frame(k).frame;

if ~isfield(frame,'box')
    frame.box=[];
end
if ~isfield(frame,'text')
    frame.text=[];
end
if ~isfield(frame,'logo')
    frame.logo=[];
end

% Adjust box positions
for ii=1:length(frame.box)
    frame.box(ii).box.position=frame.box(ii).box.position*fig.cm2pix;
    if strcmpi(fig.orientation,'landscape')
        boxposition{ii}(1)=frame.box(ii).box.position(2);
        boxposition{ii}(2)=fig.height*fig.cm2pix-(frame.box(ii).box.position(1)+frame.box(ii).box.position(3));
        boxposition{ii}(3)=frame.box(ii).box.position(4);
        boxposition{ii}(4)=frame.box(ii).box.position(3);
    else
        boxposition{ii}=frame.box(ii).box.position;
    end
end
    
% Adjust text positions
for ii=1:length(frame.text)
    frame.text(ii).text.position=frame.text(ii).text.position*fig.cm2pix;
    if strcmpi(fig.orientation,'landscape')
        textposition{ii}(1)=frame.text(ii).text.position(2);
        textposition{ii}(2)=fig.height*fig.cm2pix-frame.text(ii).text.position(1);
        rotation=270;
    else
        textposition{ii}=frame.text(ii).text.position;
        rotation=0;
    end
end

for ii=1:length(frame.box)
    
    framebox=axes;
    set(framebox,'Units',fig.units);
    pos=boxposition{ii};
    set(framebox,'Position',pos);
    set(framebox,'LineWidth',frame.box(ii).box.linewidth);
    set(framebox,'color','none');
    tick(framebox,'x','none');
    tick(framebox,'y','none');
    box on;

    set(framebox,'HitTest','off');
    c=get(framebox,'Children');
    ff=findall(c,'HitTest','on');
    set(ff,'HitTest','off');

    set(framebox,'Tag','framebox','UserData',[ifig,ii]);
    
end
clear c;

ax=axes;
set(ax,'Units',fig.units);
set(ax,'Position',[0.0 0.0 width height]);
set(ax,'color','none');
set(gca,'xlim',[0 width]);
set(gca,'ylim',[0 height]);
tick(ax,'x','none');
tick(ax,'y','none');
box off;
axis off;
set(ax,'Tag','frametextaxis','UserData',ifig);

for ii=1:length(frame.text)
    if ~isempty(deblank(fig.frametext(ii).frametext.text)) || fig.cm2pix==1
        tx=text(textposition{ii}(1),textposition{ii}(2),fig.frametext(ii).frametext.text);hold on;
        set(tx,'Color',colorlist('getrgb','color',frame.text(ii).text.fontcolor));
    else
        tx=text(textposition{ii}(1),textposition{ii}(2),['Frametext ' num2str(ii)]);hold on;
        set(tx,'Color',[0.8 0.8 0.8]);
    end        
    set(tx,'FontSize',frame.text(ii).text.fontsize*fig.fontreduction);
    set(tx,'FontAngle',frame.text(ii).text.fontangle);
    set(tx,'FontName',frame.text(ii).text.fontname);
    set(tx,'Rotation',rotation);
    set(tx,'HorizontalAlignment',frame.text(ii).text.horizontalalignment);
    set(tx,'VerticalAlignment','baseline');
    set(tx,'Tag','frametext','UserData',[ifig,ii]);
    set(tx,'ButtonDownFcn',@selectFrameText);
end
set(ax,'HitTest','off');
set(ax,'Tag','frametextaxis');

for j=1:length(frame.logo)
    logoplot=axes;
    fname=[handles.settingsdir 'logos' filesep frame.logo(j).logo.file];
    jpeg=jpg(fname,1.0,1);
    if strcmpi(fig.orientation,'landscape')
        pos(1)=frame.logo(j).logo.position(2);
        pos(2)=fig.height-(frame.logo(j).logo.position(1)+frame.logo(j).logo.position(3));
        pos(3)=frame.logo(j).logo.position(3)*size(jpeg.x,2)/size(jpeg.x,1);
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
        pos=frame.logo(j).logo.position;
        pos(4)=pos(3)*size(jpeg.x,2)/size(jpeg.x,1);
    end
    % TODO change to image
    surf(jpeg.x,jpeg.y,jpeg.z,jpeg.c);shading interp;hold on;axis equal;view(2);
    set(logoplot,'Units',fig.units);
    set(logoplot,'Position',pos*fig.cm2pix);
    set(logoplot,'color','none');
    tick(logoplot,'x','none');
    tick(logoplot,'y','none');
    box off;axis off;
    
    set(logoplot,'HitTest','off');
    c=get(logoplot,'Children');
    ff=findobj(c,'HitTest','on');
    set(ff,'HitTest','off');
    set(logoplot,'Tag','logoaxis','UserData',[ifig,j]);
    
end

%%
function selectFrameText(src,eventdata)
double_click = strcmp(get(gcf,'SelectionType'),'open');
if double_click
    fig=getappdata(gcf,'figure');
    % Find matching frame
    handles=getHandles;
    k=strmatch(lower(fig.frame),lower(handles.frames.names),'exact');
    frame=handles.frames.frame(k).frame;
    [fig,ok]=muppet_selectFrameText(fig,frame);
    if ok
        fig.changed=1;
        setappdata(gcf,'figure',fig);
        nr=fig.number;
        nft=length(fig.frametext);
        for ift=1:nft
            h=findobj(gcf,'tag','frametext','UserData',[nr,ift]);
            if ~isempty(h) && ~isempty(fig.frametext(ift).frametext.text)
                set(h,'String',fig.frametext(ift).frametext.text);
                set(h,'Color',[0 0 0]);
            else
                set(h,'String',['Frametext ' num2str(ift)]);
                set(h,'Color',[0.8 0.8 0.8]);
            end
        end
    end
end
