function EHY_stampTime(times,values,stamp,timeNow,varargin)
%  Adds a small "stamp" with the computed water levels at a certain station in combination with a vertical bar at the current time
%  After execution, contral is given back to the original (current) axes.
%
%  First beta version
%% Initialise
pos_stamp = stamp.Position;
TLim      = stamp.TLim;
YLim      = stamp.YLim;
YTick     = stamp.YTick;
Title     = stamp.Title;
nrSeries  = size(values,2);

OPT.YLabel = 'Water level';
OPT        = setproperty(OPT,varargin);

%% Begin Time plot: Start with setting original axes to normalized
originalAxes = gca;
set(gca,'Units','normalized');

%% Define new axis in the existing axes (for some reason retrieving 'Position' directly from gca doe not always work??????)
tmp      = get(gca);
position = tmp.Position;
newAxes  = axes('Units','normalized','Position',[position(1) + pos_stamp(1)*position(3)   position(2) + pos_stamp(2)*position(4)  pos_stamp(3)*position(3)  pos_stamp(4)*position(4)]);

%% First, water levels
for i_series = 1: nrSeries
    plot(times,values(:,i_series));
    hold on;
end
       
%% Then TimeNow
plot ([timeNow timeNow],YLim,'r','Linewidth',1.5);

%% Set axis etc (make Figure nicer)
set (gca,'Xlim'    ,TLim);
set (gca,'Ylim'    ,YLim);
if ~isempty(YTick) set(gca,'YTick',YTick); end
set (gca,'FontSize',3   );
set (gca,'XGrid'   ,'on');
set (gca,'YGrid'   ,'on');

Text = get (gca,'YLabel');
set(Text,'string',OPT.YLabel);
if ~isempty(Title) Text = get(gca,'Title'); set(Text,'string',Title); end
timeticks('x',TLim(1),TLim(2),'custom'); 

%% Restore to original axes
set(gcf,'CurrentAxes',originalAxes);

end
