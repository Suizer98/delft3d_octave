function SelectAxis(varargin)

h=get(gcf,'CurrentObject');

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

ax=findall(gcf,'Tag','textbox');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','rectangle');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','ellipse');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','line');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','arrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','doublearrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

set(h,'Selected','on');
set(h,'SelectionHighlight','on');

set(gcf,'WindowButtonMotionFcn',{@MoveMouse,h});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MoveMouse(imagefig, varargins,h)

tg=get(h,'Tag');
switch(tg),
    case{'arrow','doublearrow','line'}
        if strcmp(version,'7.1.0.246 (R14) Service Pack 3');
            xx=get(h,'X');
            yy=get(h,'Y');
            posgca=[xx(1) yy(1) xx(2)-xx(1) yy(2)-yy(1)];
        else
            posgca = get(h,'Position');
        end
    otherwise
        posgca = get(h,'Position');
end
posgcf = get(gcf, 'CurrentPoint');

switch(tg),
    case{'textbox','rectangle','ellipse','arrow','doublearrow','line'}
        figsz=get(gcf,'Position');
        posgca(1)=posgca(1)*figsz(3);
        posgca(2)=posgca(2)*figsz(4);
        posgca(3)=posgca(3)*figsz(3);
        posgca(4)=posgca(4)*figsz(4);
end
switch(tg),
    case{'arrow','doublearrow','line'}
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
            set(gcf,'WindowButtonDownFcn',{@StartChangeAxisPosition,h,iclosest,posgca});
        elseif dist<5
            setptr(gcf,'fleur');
            set(gcf,'WindowButtonDownFcn',{@StartChangeAxisPosition,h,9,posgca});
        else
            set(gcf,'WindowButtonDownFcn',[]);
            set(gcf,'WindowButtonDownFcn',{@DeselectAll});
            setptr(gcf,'arrow');
        end

    otherwise
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
            switch iclosest,
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
            set(gcf,'WindowButtonDownFcn',{@StartChangeAxisPosition,h,iclosest,posgca});
        elseif nearaxis
            setptr(gcf,'fleur');
            set(gcf,'WindowButtonDownFcn',{@StartChangeAxisPosition,h,9,posgca});
        else
            set(gcf,'WindowButtonDownFcn',{@DeselectAll});
            setptr(gcf,'arrow');
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StartChangeAxisPosition(imagefig, varargins,h,iclosest,posgca)

posgcf = get(gcf, 'CurrentPoint');
set(h,'ButtonDownFcn',[]);
set(gcf, 'WindowButtonUpFcn',     {@StopChangeAxisPosition,h});
set(gcf, 'WindowButtonMotionFcn', {@ChangeAxisPosition,h,iclosest,posgcf,posgca});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ChangeAxisPosition(imagefig, varargins,h,iclosest,posgcf0,posgca0)

posgcf = get(gcf, 'CurrentPoint');
tg=get(h,'Tag');
switch(tg),
    case{'textbox','rectangle','ellipse','arrow','doublearrow','line'}
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

switch(tg),
    case{'arrow','doublearrow','line'}
        if strcmp(version,'7.1.0.246 (R14) Service Pack 3')
            switch iclosest,
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
            switch iclosest,
                case 1
                    set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) posgca0(3)-posgcf(1)+posgcf0(1) posgca0(4)-posgcf(2)+posgcf0(2)]);
                case 2
                    set(h,'Position',[posgca0(1) posgca0(2) posgca0(3)+posgcf(1)-posgcf0(1) posgca0(4)+posgcf(2)-posgcf0(2)]);
                case 9
                    set(h,'Position',[posgca0(1)+posgcf(1)-posgcf0(1) posgca0(2)+posgcf(2)-posgcf0(2) posgca0(3) posgca0(4)]);
            end
        end
    otherwise
        switch iclosest,
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StopChangeAxisPosition(imagefig, varargins,h) 

tg=get(h,'Tag');
switch(tg),
    case{'colorbar'}
        handles=guidata(findobj('Name','Muppet'));
        usd=get(h,'UserData');
        i=usd(1);
        j=usd(2);
        pos=get(h,'Position')/handles.Figure(i).cm2pix;
        if length(usd)==2
            handles.Figure(i).Axis(j).ColorBarPosition=pos;
            h=SetColorBar(handles,i,j);
        else
            k=usd(3);
            handles.Figure(i).Axis(j).Plot(k).ColorBarPosition=pos;
            h=SetColorBar(handles,i,j,k);
        end
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'scalebar'}
        handles=guidata(findobj('Name','Muppet'));
        usd=get(h,'UserData');
        i=usd(1);
        j=usd(2);
        pos=get(h,'Position')/handles.Figure(i).cm2pix;
        handles.Figure(i).Axis(j).ScaleBar(1)=pos(1);
        handles.Figure(i).Axis(j).ScaleBar(2)=pos(2);
        len=0.01*pos(3)*handles.Figure(i).Axis(j).Scale;
        handles.Figure(i).Axis(j).ScaleBar(3)=len;
        handles.Figure(i).Axis(j).ScaleBarText=[num2str(round(len)) ' m'];
        h=SetScaleBar(handles,i,j);
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'vectorlegend'}
        handles=guidata(findobj('Name','Muppet'));
        usd=get(h,'UserData');
        i=usd(1);
        j=usd(2);
        pos=get(h,'Position')/handles.Figure(i).cm2pix;
        handles.Figure(i).Axis(j).VectorLegendPosition=[pos(1) pos(2)];
        h=SetVectorLegend(handles,i,j);
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
    case{'northarrow'}
        handles=guidata(findobj('Name','Muppet'));
        usd=get(h,'UserData');
        i=usd(1);
        j=usd(2);
        pos=get(h,'Position')/handles.Figure(i).cm2pix;
        handles.Figure(i).Axis(j).NorthArrow(1)=pos(1);
        handles.Figure(i).Axis(j).NorthArrow(2)=pos(2);
        handles.Figure(i).Axis(j).NorthArrow(3)=min(pos(3),pos(4));
        h=SetNorthArrow(handles,i,j);
        set(h,'Selected','on');
        set(h,'SelectionHighlight','on');
end

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse,h});
set(gcf,'WindowButtonDownFcn',{@DeselectAll});
set(gcf, 'windowbuttonupfcn',[]);
set(h,'ButtonDownFcn',{@SelectAxis});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DeselectAll(imagefig, varargins)

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

ax=findall(gcf,'Tag','textbox');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','rectangle');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','ellipse');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','line');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','arrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');
ax=findall(gcf,'Tag','doublearrow');
set(ax,'Selected','off');
set(ax,'SelectionHighlight','off');

set(gcf, 'windowbuttonmotionfcn',[]);
