function cosmos_timeSeriesPlot(fname,data,varargin)

timelabel=[];
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'title'}
                ttl=varargin{i+1};
            case{'ylabel'}
                ylbl=varargin{i+1};
            case{'xticks'}
                xticks=varargin{i+1};
            case{'yticks'}
                yticks=varargin{i+1};
            case{'xlim'}
                tlim=varargin{i+1};
            case{'ylim'}
                ylim=varargin{i+1};
            case{'timelabel'}
                timelabel=varargin{i+1};
        end
    end
end

pps=[11 4.5];

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');

set(h,'PaperSize',pps);
set(h,'PaperPositionMode','manual');
set(h,'PaperPosition',[0 0 pps]);

ax=axes;

set(ax,'Units','centimeters');

for i=1:length(data)
    plot(data(i).x,data(i).y,data(i).color);hold on;
end

set(gca,'XLim',tlim,'YLim',ylim);
set(gca,'XGrid','on','YGrid','on');
set(gca,'XMinorTick','on');
set(gca,'FontSize',5);

set(gca,'XTick',xticks);
set(gca,'YTick',yticks);

datetick(gca,'x',15,'keepticks');


dy=ylim(2)-ylim(1);
roundticks=find(round(xticks)==xticks);
for it=1:length(roundticks)
    itt=roundticks(it);
    tx=text(xticks(itt),ylim(1)-0.15*dy,datestr(xticks(itt),'yyyy/mm/dd'));
    set(tx,'FontSize',5,'HorizontalAlignment','center');
end

if ~isempty(timelabel)
    tx=text(0.5*(tlim(1)+tlim(2)),ylim(1)-0.22*dy,timelabel);
    set(tx,'FontSize',5,'HorizontalAlignment','center');
end

set(gca,'XLim',tlim,'YLim',ylim);

% Legend
for i=1:length(data)
    legstr{i}=data(i).name;
end
leg=legend(gca,'Location','NorthEastOutside');
set(leg,'String',legstr);
set(leg,'FontSize',6,'Position',[8.7 3.1814 1.3 0.8108],'OuterPosition',[8.7 3.1285 1.0 0.8637],'Box','off');

% Labels
ylabel(gca,ylbl);
title(gca,ttl);
tt=get(ax,'Title');
set(tt,'FontSize',7);

set(ax,'Position',[1.0 0.85 9.3 3.2]);

print(h,'-dpng',fname);

close(h);
