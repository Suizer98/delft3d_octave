function muppet_selectAxis(varargin)

h=get(gcf,'CurrentObject');

% De-select everything
ax=findobj(gcf,'Tag','axis');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','colorbar');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','scalebar');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','northarrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','legend');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','vectorlegend');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','annotation');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

% And select current object
set(h,'Selected','on');
set(h,'SelectionHighlight','on');

set(gcf,'WindowButtonMotionFcn',{@moveMouse,h});

%%
function moveMouse(imagefig, varargins,h)

tg=get(h,'Tag');

switch(tg)
    case{'annotation'}
        stl=getappdata(h,'style');
        switch(lower(stl))
            case{'arrow','double arrow','single line'}
                lineelement=1;
            otherwise
                lineelement=0;
        end
    otherwise
        lineelement=0;
end

if lineelement
    if strcmp(version,'7.1.0.246 (R14) Service Pack 3');
        xx=get(h,'X');
        yy=get(h,'Y');
        posgca=[xx(1) yy(1) xx(2)-xx(1) yy(2)-yy(1)];
    else
        posgca = get(h,'Position');
    end
else
    posgca = get(h,'Position');
end
posgcf = get(gcf, 'CurrentPoint');

switch(tg)
    case{'annotation'}
        figsz=get(gcf,'Position');
        posgca(1)=posgca(1)*figsz(3);
        posgca(2)=posgca(2)*figsz(4);
        posgca(3)=posgca(3)*figsz(3);
        posgca(4)=posgca(4)*figsz(4);
end

if lineelement
    pos(1,:)=[posgca(1) posgca(2)];
    pos(2,:)=[posgca(1)+posgca(3) posgca(2)+posgca(4)];
    for i=1:2
        dist(i)=sqrt((posgcf(1)-pos(i,1))^2 + (posgcf(2)-pos(i,2))^2);
    end
    [distcorners,iorder]=sort(dist);
    iclosest=iorder(1);
    
    x0=posgcf;
    x1=[posgca(1) posgca(2)];
    x2=[posgca(1)+posgca(3) posgca(2)+posgca(4)];
    pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
    dist=abs(det([x2-x1 ; x1-x0])/pt);
    
    if distcorners(1)<5
        setptr(gcf,'right');
        set(gcf,'WindowButtonDownFcn',{@startChangeAxisPosition,h,iclosest,posgca});
    elseif dist<5
        setptr(gcf,'fleur');
        set(gcf,'WindowButtonDownFcn',{@startChangeAxisPosition,h,9,posgca});
    else
        set(gcf,'WindowButtonDownFcn',[]);
        set(gcf,'WindowButtonDownFcn',{@deselectAll});
        setptr(gcf,'arrow');
    end
    
else
    pos(1,:)=[posgca(1) posgca(2)];
    pos(2,:)=[posgca(1)+posgca(3) posgca(2)];
    pos(3,:)=[posgca(1) posgca(2)+posgca(4)];
    pos(4,:)=[posgca(1)+posgca(3) posgca(2)+posgca(4)];
    
    pos(5,:)=[posgca(1)+0.5*posgca(3) posgca(2)];
    pos(6,:)=[posgca(1)+0.5*posgca(3) posgca(2)+posgca(4)];
    pos(7,:)=[posgca(1) posgca(2)+0.5*posgca(4)];
    pos(8,:)=[posgca(1)+posgca(3) posgca(2)+0.5*posgca(4)];
    
    for i=1:8
        dist(i)=sqrt((posgcf(1)-pos(i,1))^2 + (posgcf(2)-pos(i,2))^2);
    end
    [distcorners,iorder]=sort(dist);
    iclosest=iorder(1);
    
    outerx=[posgca(1)-5 posgca(1)+posgca(3)+5 posgca(1)+posgca(3)+5 posgca(1)-5];
    outery=[posgca(2)-5 posgca(2)-5 posgca(2)+posgca(4)+5 posgca(2)+posgca(4)+5];
    innerx=[posgca(1)+5 posgca(1)+posgca(3)-5 posgca(1)+posgca(3)-5 posgca(1)+5];
    innery=[posgca(2)+5 posgca(2)+5 posgca(2)+posgca(4)-5 posgca(2)+posgca(4)-5];
    nearaxis=inpolygon(posgcf(1),posgcf(2),outerx,outery) & ~inpolygon(posgcf(1),posgcf(2),innerx,innery);
    
    if distcorners(1)<5
        switch iclosest
            case 1
                setptr(gcf,'botl');
            case 2
                setptr(gcf,'botr');
            case 3
                setptr(gcf,'topl');
            case 4
                setptr(gcf,'topr');
            case 5
                setptr(gcf,'bottom');
            case 6
                setptr(gcf,'top');
            case 7
                setptr(gcf,'left');
            case 8
                setptr(gcf,'right');
        end
        set(gcf,'WindowButtonDownFcn',{@startChangeAxisPosition,h,iclosest,posgca});
    elseif nearaxis
        setptr(gcf,'fleur');
        set(gcf,'WindowButtonDownFcn',{@startChangeAxisPosition,h,9,posgca});
    else
        set(gcf,'WindowButtonDownFcn',{@deselectAll});
        setptr(gcf,'arrow');
    end
end

%%
function startChangeAxisPosition(imagefig, varargins,h,iclosest,posgca)

posgcf = get(gcf, 'CurrentPoint');
set(h,'ButtonDownFcn',[]);
set(gcf, 'WindowButtonUpFcn',     {@stopChangeAxisPosition,h});
set(gcf, 'WindowButtonMotionFcn', {@changeAxisPosition,h,iclosest,posgcf,posgca});

%%
function changeAxisPosition(imagefig, varargins,h,iclosest,posgcf0,posgca0)

posgcf = get(gcf, 'CurrentPoint');
tg=get(h,'Tag');
switch(tg)
    case{'annotation'}
        figsz=get(gcf,'Position');
        posgca0(1)=posgca0(1)/figsz(3);
        posgca0(2)=posgca0(2)/figsz(4);
        posgca0(3)=posgca0(3)/figsz(3);
        posgca0(4)=posgca0(4)/figsz(4);
        posgcf0(1)=posgcf0(1)/figsz(3);
        posgcf0(2)=posgcf0(2)/figsz(4);
        posgcf(1)=posgcf(1)/figsz(3);
        posgcf(2)=posgcf(2)/figsz(4);
        mxz=0.005;
    otherwise
        mxz=5;
end

switch(tg)
    case{'annotation'}
        stl=getappdata(h,'style');
        switch(lower(stl))
            case{'arrow','double arrow','single line'}
                lineelement=1;
            otherwise
                lineelement=0;
        end
    otherwise
        lineelement=0;
end

if lineelement
    % Line element
    if strcmp(version,'7.1.0.246 (R14) Service Pack 3')
        switch iclosest
            case 1
                set(h,'X',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(1)+posgca0(3)]);
                set(h,'Y',[posgca0(2)+posgcf(2)-posgcf0(2) posgca0(2)+posgca0(4)]);
            case 2
                set(h,'X',[posgca0(1) posgca0(1)+posgca0(3)+posgcf(1)-posgcf0(1)]);
                set(h,'Y',[posgca0(2) posgca0(2)+posgca0(4)+posgcf(2)-posgcf0(2)]);
            case 9
                set(h,'X',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(1)+posgca0(3)+posgcf(1)-posgcf0(1)]);
                set(h,'Y',[posgca0(2)+posgcf(2)-posgcf0(2) posgca0(2)+posgca0(4)+posgcf(2)-posgcf0(2)]);
        end
    else
        switch iclosest
            case 1
                set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) posgca0(3)-posgcf(1)+posgcf0(1) posgca0(4)-posgcf(2)+posgcf0(2)]);
            case 2
                set(h,'Position',[posgca0(1) posgca0(2) posgca0(3)+posgcf(1)-posgcf0(1) posgca0(4)+posgcf(2)-posgcf0(2)]);
            case 9
                set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) posgca0(3) posgca0(4)]);
        end
    end
else
    % Box element
    switch iclosest
        case 1
            set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) max(posgca0(3)-posgcf(1)+posgcf0(1),mxz) max(posgca0(4)-posgcf(2)+posgcf0(2),mxz)]);
        case 2
            set(h,'Position',[posgca0(1) posgca0(2)+posgcf(2)-posgcf0(2) max(posgca0(3)+posgcf(1)-posgcf0(1),mxz) max(posgca0(4)-posgcf(2)+posgcf0(2),mxz)]);
        case 3
            set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2) max(posgca0(3)-posgcf(1)+posgcf0(1),mxz) max(posgca0(4)+posgcf(2)-posgcf0(2),mxz)]);
        case 4
            set(h,'Position',[posgca0(1) posgca0(2) max(posgca0(3)+posgcf(1)-posgcf0(1),mxz) max(posgca0(4)+posgcf(2)-posgcf0(2),mxz)]);
        case 5
            set(h,'Position',[posgca0(1) posgca0(2)+posgcf(2)-posgcf0(2) max(posgca0(3),mxz) max(posgca0(4)-posgcf(2)+posgcf0(2),mxz)]);
        case 6
            set(h,'Position',[posgca0(1) posgca0(2) max(posgca0(3),mxz) max(posgca0(4)+posgcf(2)-posgcf0(2),mxz)]);
        case 7
            set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2) max(posgca0(3)-posgcf(1)+posgcf0(1),mxz) max(posgca0(4),mxz)]);
        case 8
            set(h,'Position',[posgca0(1) posgca0(2) max(posgca0(3)+posgcf(1)-posgcf0(1),mxz) max(posgca0(4),mxz)]);
        case 9
            set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) max(posgca0(3),mxz) max(posgca0(4),mxz)]);
    end
end

%%
function stopChangeAxisPosition(imagefig, varargins,h) 

tg=get(h,'Tag');

% Get figure structure from appdata
fig=getappdata(gcf,'figure');
fig.changed=1;

switch tg
    case{'legend'}
        legenddata=getappdata(h,'legenddata');
        ifig=legenddata.i;
        isub=legenddata.j;        
    case{'annotation'}
        usd=get(h,'UserData');
        ifig=usd(1);
        % last subplot
        isub=fig.nrsubplots;
        id=usd(2);        
    otherwise
        usd=get(h,'UserData');
        ifig=usd(1);
        isub=usd(2);        
end

pos=get(h,'Position')/fig.cm2pix;

switch(tg)
    case{'annotation'}
        pos=get(h,'Position');
        fig.subplots(isub).subplot.datasets(id).dataset.position(1)=pos(1)*fig.width;
        fig.subplots(isub).subplot.datasets(id).dataset.position(2)=pos(2)*fig.height;
        fig.subplots(isub).subplot.datasets(id).dataset.position(3)=pos(3)*fig.width;
        fig.subplots(isub).subplot.datasets(id).dataset.position(4)=pos(4)*fig.height;
        fig.annotationschanged=1;        
    case{'axis'}
        switch fig.subplots(isub).subplot.type
            case{'map'}
                fig.subplots(isub).subplot.position=pos;
                fig.subplots(isub).subplot=muppet_updateLimits(fig.subplots(isub).subplot,'editsubplotsize');
                set(gca,'xlim',[fig.subplots(isub).subplot.xminproj fig.subplots(isub).subplot.xmaxproj], ...
                    'ylim',[fig.subplots(isub).subplot.yminproj fig.subplots(isub).subplot.ymaxproj]);
            fig.subplots(isub).subplot.limitschanged=1;
        end
        fig.subplots(isub).subplot.position=pos;
        fig.subplots(isub).subplot.positionchanged=1;
    case{'legend'}
        fig.subplots(isub).subplot.legend.position='Custom';
        fig.subplots(isub).subplot.legend.customposition=pos;
        fig.subplots(isub).subplot.legend.changed=1;
    case{'colorbar'}
        if length(usd)==2
            % Color bar belong to subplot
            fig.subplots(isub).subplot.colorbar.position=pos;
            fig.subplots(isub).subplot.colorbar.changed=1;
            h=muppet_setColorBar(fig,ifig,isub);
        else
            % Color bar belong to dataset in subplot
            k=usd(3);
            fig.subplots(isub).subplot.datasets(k).dataset.colorbar.position=pos;
            h=muppet_setColorBar(fig,ifig,isub,k);
            fig.subplots(isub).subplot.datasets(k).dataset.colorbar.changed=1;
        end
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'scalebar'}
        fig.subplots(isub).subplot.scalebar.position(1)=pos(1)-fig.subplots(isub).subplot.position(1);
        fig.subplots(isub).subplot.scalebar.position(2)=pos(2)-fig.subplots(isub).subplot.position(2);
        len=0.01*pos(3)*fig.subplots(isub).subplot.scale;
        fig.subplots(isub).subplot.scalebar.position(3)=len;
        fig.subplots(isub).subplot.scalebar.text=[num2str(round(len)) ' m'];
        fig.subplots(isub).subplot.scalebar.changed=1;
        h=muppet_setScaleBar(fig,ifig,isub);
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'vectorlegend'}
        fig.subplots(isub).subplot.vectorlegend.position=[pos(1) pos(2)];
        h=muppet_setVectorLegend(fig,ifig,isub);
        fig.subplots(isub).subplot.vectorlegend.changed=1;
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'northarrow'}
        fig.subplots(isub).subplot.northarrow.position(1)=pos(1)-fig.subplots(isub).subplot.position(1);
        fig.subplots(isub).subplot.northarrow.position(2)=pos(2)-fig.subplots(isub).subplot.position(2);
        fig.subplots(isub).subplot.northarrow.position(3)=min(pos(3),pos(4));
        fig.subplots(isub).subplot.northarrow.changed=1;
        h=muppet_setNorthArrow(fig,ifig,isub);
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
end

setappdata(gcf,'figure',fig);

set(gcf, 'windowbuttonmotionfcn', {@moveMouse,h});
set(gcf,'WindowButtonDownFcn',{@deselectAll});
set(gcf, 'windowbuttonupfcn',[]);
set(h,'ButtonDownFcn',{@muppet_selectAxis});

%%
function deselectAll(imagefig, varargins)

ax=findobj(gcf,'Tag','axis');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','colorbar');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','scalebar');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','northarrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','legend');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','vectorlegend');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

ax=findobj(gcf,'Tag','annotation');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

set(gcf, 'windowbuttonmotionfcn',[]);
