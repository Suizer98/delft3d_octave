function kmAxis(axh,step);
% kmAxis(axh,step);
% sets  ticks and ticklabels of axis with handle axh in kilometers with 
% specified step = [stepx stepy] in km.
% BvV 2005

% tmpax=axh;
% axes(axh);

stepx=step(1); % km
xlimits=get(axh,'xlim');
if rem(xlimits(1),stepx*1000)==0
   xtcksstart=xlimits(1)/1000;
else
   xtcksstart=floor(xlimits(1)/1000)+stepx-rem(floor(xlimits(1)/1000),stepx);   
end
%xtcksend=floor(xlimits(2)/1000);
xtcksend=floor(xlimits(2)/1000)+(floor((xlimits(2)/1000-floor(xlimits(2)/1000))/stepx))*stepx*1000;
xtcks=xtcksstart:stepx:xtcksend;
set(axh,'xtick',1000*xtcks);
xtcks=get(axh,'xtick');
set(axh,'xticklabel',[xtcks/1000]);

stepy=step(2); % km
ylimits=get(axh,'ylim');
if rem(ylimits(1),(stepy*1000))==0
   ytcksstart=ylimits(1)/1000;
else
   ytcksstart=floor(ylimits(1)/1000)+stepy-rem(floor(ylimits(1)/1000),stepy);
end
%ytcksend=floor(ylimits(2)/1000);
ytcksend=floor(ylimits(2)/1000)+(floor((ylimits(2)/1000-floor(ylimits(2)/1000))/stepy))*stepy*1000;
ytcks=ytcksstart:stepy:ytcksend;
set(axh,'ytick',1000*ytcks);
ytcks=get(axh,'ytick');
set(axh,'yticklabel',[ytcks/1000]);

% axes(tmpax);