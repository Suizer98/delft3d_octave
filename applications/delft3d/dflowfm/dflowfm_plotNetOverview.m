function dflowfm_plotNetOverview(grd,x_lim,y_lim)

%% Plots an overview of a Delft3D-FM network
% The following is visualised:
% Face numbers
% Node numbers
% Flowlink number (between face circumcenters)
% Netlink number (between nodes)
%
% required input:
% grd = network information resulting from dflowfm.readNet (U-grid) or dflowfm.readNetOld (non U-grid).
%
% optional input (recommended, because otherwise plotting may take a long time):
% x_lim = x-coordinate limits for plotting
% y_lim = y-coordinate limits for plotting

fontSizeTxT = 7;
kmTicks = [0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000];

%% prepare x and y coordinates for plotting netlinks (before cutcellpolygon.lst operation if applicable)
xNetlink = grd.node.x(grd.edge.NetLink);
yNetlink = grd.node.y(grd.edge.NetLink);
xNetlink(3,:)=NaN;
yNetlink(3,:)=NaN;

xNetlinkTxt = (xNetlink(2,:)-xNetlink(1,:))*0.6+xNetlink(1,:);
yNetlinkTxt = (yNetlink(2,:)-yNetlink(1,:))*0.6+yNetlink(1,:);

%% prepare x and y coordinates for plotting face contours (after cutcellpolygon.lst operation if applicable)
xFaceContour = grd.face.FlowElemCont_x;
yFaceContour = grd.face.FlowElemCont_y;

xDummy = repmat(xFaceContour(1,:),size(xFaceContour,1),1);
yDummy = repmat(yFaceContour(1,:),size(yFaceContour,1),1);
IDNaN = find(isnan(xFaceContour));
xFaceContour(IDNaN) = xDummy(IDNaN);
yFaceContour(IDNaN) = yDummy(IDNaN);
xFaceContour(size(xFaceContour,1)+1,:) = NaN;
yFaceContour(size(yFaceContour,1)+1,:) = NaN;

%% prepare x and y coordinates for plotting flowlinks
try
    xFlowLink = grd.face.FlowElem_x(grd.edge.FlowLink);
    yFlowLink = grd.face.FlowElem_y(grd.edge.FlowLink);
    xFlowLink(3,:)=NaN;
    yFlowLink(3,:)=NaN;
    
    xFlowLinkTxt = (xFlowLink(2,:)-xFlowLink(1,:))*0.6+xFlowLink(1,:);
    yFlowLinkTxt = (yFlowLink(2,:)-yFlowLink(1,:))*0.6+yFlowLink(1,:);
    includeFlowLinks = 1;
catch
    includeFlowLinks = 0;
end
%% define x_lim and y_lim
if ~exist('x_lim','var')
    x_lim = [min(grd.node.x) max(grd.node.x)];
    y_lim = [min(grd.node.y) max(grd.node.y)];
end

%% selecting nodes, faces and netlinks within defined x_lim and y_lim
checkNodes = 1;
while checkNodes
    IDnodes = find(grd.node.x > x_lim(1) & grd.node.x < x_lim(2) & grd.node.y > y_lim(1) & grd.node.y < y_lim(2));
    IDfaces = find(grd.face.FlowElem_x > x_lim(1) & grd.face.FlowElem_x < x_lim(2) & grd.face.FlowElem_y > y_lim(1) & grd.face.FlowElem_y < y_lim(2));
    IDnetlink = find(xNetlinkTxt > x_lim(1) & xNetlinkTxt < x_lim(2) & yNetlinkTxt > y_lim(1) & yNetlinkTxt < y_lim(2));
    if includeFlowLinks
        IDflowlink = find(xFlowLinkTxt > x_lim(1) & xFlowLinkTxt < x_lim(2) & yFlowLinkTxt > y_lim(1) & yFlowLinkTxt < y_lim(2));
    end
    if length(IDnodes) < 500
        checkNodes = 0;
    else
        out = questdlg(['Number of nodes to be plotted > 500 (',num2str(length(IDnodes)),'). This may take a long time. Do you want to proceed or (re)define the x and y limits?'],'Warning','Proceed','(re)define focus area','Proceed')
        if strcmpi(out,'(re)define focus area')
            figure
            axis equal
            plot(xFaceContour(:),yFaceContour(:),'b','LineWidth',0.5,'DisplayName','Netlinks final (after cutcellpolygon.lst)');
            jj=menu({'Zoom into desired focus area and click Ok when ready'},'Ok');
            x_lim = get(gca,'XLim');
            y_lim = get(gca,'YLim');
            close all
        else
            checkNodes = 0;
        end
    end
end

% check if it is a spherical or cartesian model
if max(abs(grd.node.x))<=180 & max(abs(grd.node.y))<= 180
    modelType = 'spherical';
else
    modelType = 'cartesian';
end

switch modelType
    case 'cartesian'
        % find best km tick
        kmTick = kmTicks(nearestpoint(diff(x_lim)/5,kmTicks*1000));
        x_label = 'Easting [km]';
        y_label = 'Northing [km]';
    case 'spherical'
        x_label = 'Longitude [^o]';
        y_label = 'Latitude [^o]';
end

%% plotting (first plot without numbers, second plot including numbers)
for qq = 1:2
    figure
    axis equal
    hold on
    
    hP(1) = plot(xNetlink(:),yNetlink(:),'r','LineWidth',0.5,'DisplayName','Netlinks original');
    hP(2) = plot(xFaceContour(:),yFaceContour(:),'b','LineWidth',0.5,'DisplayName','Netlinks final (after cutcellpolygon.lst)');
    if includeFlowLinks
        hP(3) = plot(xFlowLink(:),yFlowLink(:),'Color',[0.9 0.9 0.9],'LineWidth',0.5,'DisplayName','Flow link');
    end
    
    xlim(x_lim);
    ylim(y_lim);
    
    if qq == 1
        hP(length(hP)+1) = plot(grd.face.FlowElem_x,grd.face.FlowElem_y,'m.','Markersize',10,'DisplayName','Flow element');
        hP(length(hP)+1) = plot(grd.node.x,grd.node.y,'k.','Markersize',10,'DisplayName','Net node');
    else
        % plot face numbers
        for ff = 1:length(IDfaces)
            text(grd.face.FlowElem_x(IDfaces(ff)),grd.face.FlowElem_y(IDfaces(ff)),num2str(IDfaces(ff)),'Color','m','FontSize',fontSizeTxT,'HorizontalAlignment','center')
        end
        
        % plot node numbers
        for nn = 1:length(IDnodes)
            text(grd.node.x(IDnodes(nn)),grd.node.y(IDnodes(nn)),num2str(IDnodes(nn)),'Color','k','FontSize',fontSizeTxT,'HorizontalAlignment','center')
        end
        
        % plot netlinks numbers
        for nn = 1:length(IDnetlink)
            text(xNetlinkTxt(IDnetlink(nn)),yNetlinkTxt(IDnetlink(nn)),num2str(IDnetlink(nn)),'Color','b','FontSize',fontSizeTxT,'HorizontalAlignment','center')
        end
        
        % plot flowlinks numbers
        if includeFlowLinks
            for ff = 1:length(IDflowlink)
                text(xFlowLinkTxt(IDflowlink(ff)),yFlowLinkTxt(IDflowlink(ff)),num2str(IDflowlink(ff)),'Color',[0.5 0.5 0.5],'FontSize',fontSizeTxT,'HorizontalAlignment','center')
            end
        end
    end
    
    hL = legend(hP)
    
    xlabel(x_label)
    ylabel(y_label)
    if strcmpi(modelType,'cartesian')
        kmAxis(gca,[kmTick kmTick]);
    end
end
