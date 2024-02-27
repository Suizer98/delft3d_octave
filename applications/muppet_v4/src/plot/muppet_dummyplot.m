function muppet_dummyplot(curax)

pos=get(curax,'Position');
units=get(curax,'Units');
xl=get(curax,'XLim');
yl=get(curax,'YLim');
xticks=get(curax,'xtick');
yticks=get(curax,'ytick');
xgrd=get(curax,'xgrid');
ygrd=get(curax,'ygrid');
% Make dummy plot

p=axes;
set(p,'xlim',xl,'ylim',yl);
set(p,'XColor',[0 0 0]);
set(p,'YColor',[0 0 0]);

set(p,'xtick',xticks);
if ~isempty(xticks)
for i=1:size(xticks,2)
    xlabls{i}='';
end
set(p,'xticklabel',xlabls);
end
%
set(p,'ytick',yticks);
if ~isempty(xticks)
for i=1:size(yticks,2)
    ylabls{i}='';
end
set(p,'yticklabel',ylabls);
end

set(p,'xgrid',xgrd);
set(p,'ygrid',ygrd);
set(p,'Units',units);
set(p,'Position',pos);
set(p,'Layer','top');
set(p,'Box','on');
set(p,'Color','none');
set(p,'HitTest','off');
set(gcf,'CurrentAxes',curax);
uistack(p,'top');
