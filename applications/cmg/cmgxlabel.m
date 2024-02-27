function cmgxlabel(jd,varargin)
% CMGXLABEL. relabel the time axis from Julian day (or datenum) label
% to gregorian
% 
% Syntax: cmgxlabel(jd, [hand])
% 	input: jd= true julian day or datenum
% 	hand= graphic handle, optional, default is gca
% 	output: none
% 	
% jpx @ usgs, 07-26-01
% 

if nargin<2
	hand=gca;
else
	hand=varargin{1};
end;

if jd<1e6 % jd is presumably a datenum (safe for at least 700 years)
	jd=jd+1721059; %change to true julian day
end;

xt=get(hand,'xtick');
xt_sep=max(diff(xt(:)));
xlabtext=[];

if ( xt_sep > 250 )
    gregax( jd,hand,'year' );
elseif (xt_sep > 20) 
    gregax( jd,hand, 'month' );
elseif (xt_sep > .4)
    gregax( jd ,hand, 'day');
elseif (xt_sep > .02)
    gregax( jd,hand,'hour' );
else
    gregax( jd,hand,'minute' );
end


return;	

function gregax( jd,xhandle, flags )
month_label = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';...
                'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];

% First figure out the height of the bottom plot in points.
% Then allow for 3 lines to fit here.
old_units = get ( xhandle, 'Units' );
set ( xhandle, 'Units', 'Points' );
pos = get(xhandle, 'Position' );
set ( xhandle, 'Units', old_units )
height = pos(2);

% Fontsize should be the same as the ylabel.
fsize = get ( get(xhandle,'YLabel'), 'Fontsize' );

% Now figure the height of the bottom plot in user coords.
ylim = get ( xhandle, 'YLim' );
cfactor = diff(ylim) / pos(4);

xt = get ( xhandle, 'XTick' );
greg = gregorian ( xt(:) );
xlim = get(xhandle,'xlim');

% Make sure that the minute ticks start right on the day,
% and not in the middle.
% Stop the ticks somewhere around the end of xlim.  Don't really
% care so much about this.
jd0 = gmin(jd(:)); 
jd1 = xlim(2);
start = gregorian(jd0);
stop = gregorian(jd1);

% We need to know how many labels to write.
% Assume that we want a maximum of 50 pts between labels.
max_width = 40;
point_width = pos(3);  
dx = diff(xlim);
scale_factor = dx/point_width;  % number of days per point

switch flags
case 'day'
	start = [start(1:3) 0 0 0];
	tics = max ( max_width*scale_factor, 1 );
	tics = ceil(tics);
	if ( (tics >= 4) & (tics <6) )
	    tics = 5;
	elseif ( (tics >= 6) & (tics <8.5) )
	    tics = 7;
	elseif ( (tics >= 8.5) & (tics <12) )
	    tics = 10;
	elseif ( (tics >= 12) & (tics <16) )
	    tics = 14;
	end
	jd0 = julian(start);
	xt = [jd0:tics:jd1];
case 'hour'	
	start = [start(1:4) 0 0];
	tics = max_width*scale_factor;
	tics=ceil(tics*24)/24;
	jd0 = julian(start);
	xt = [jd0:tics:jd1];
case 'minute'	
	start = [start(1:5) 0];
	tics = max_width*scale_factor;
	tics=ceil(tics*24*60)/24/60;
	jd0 = julian(start);
	xt = [jd0:tics:jd1];
case 'month'	
	start = [start(1:2) 1 0 0 0];
	tics = ceil(max_width*scale_factor/31);
	gticks = start;
	last_gtick = gticks;
	last_jtick = julian(last_gtick);
	while ( last_jtick <= xlim(2) )
		this_month = last_gtick(2);
		this_year = last_gtick(1);
		if ( (this_month - 1 + tics) >= 12 )
			this_year = this_year+1;
		end
		next_month = mod ( this_month -1 + tics, 12) + 1;
		last_gtick = [this_year next_month 1 0 0 0];
		last_jtick = julian(last_gtick);
		gticks = [gticks; last_gtick ];
	end
	xt = julian(gticks);
case 'year'	
	start1=start(1);
	if tics==5 & mod(start1,5)>0
		start1=start1+5 - mod(start1,5);
	elseif tics==10 & mod(start1,10)
		start1=start1+10 - mod(start1,10);
	end;	
	start = [start1 1  1 0 0 0];
	tics = ceil(max_width*scale_factor/365.24);
	if tics>3 & tics <=5
		tics=5;
	elseif tics>5
		tics=10;
	end;
	gyears = start;
	last_gyear = start; 
	last_jyear = julian(start);
	while ( last_jyear <= jd1 )
		last_gyear(1) = last_gyear(1) + tics;
		last_jyear = julian(last_gyear);
		gyears = [gyears; last_gyear];
	end
	xt = julian(gyears);
end; % of switch	

ifind = find((xt>=xlim(1)) & (xt<=xlim(2)));
if ~isempty(ifind)
	xt = xt(ifind);
	set ( xhandle, ...
	        'XTick', xt, ...
	        'XTickLabel', [] );
	
	greg = gregorian(xt);
	% Now label the xticks
	year_str = num2str(greg(1,1));
	day_str = sprintf ( '%s %2.0f', month_label(greg(1,2),:), greg(1,3) );
	switch flags
	case 'day'
		dum=3;
		gt_string = {     num2str(greg(1,3)); ...
		                month_label(greg(1,2),:); ...
		                num2str(greg(1,1)) };
	case 'hour'
		dum=4;				
		hour_str = sprintf ( '%02i:00', greg(1,4) );
		gt_string = { hour_str; day_str; year_str };
	case 'minute'
		dum=5;
		min_str = sprintf ( '%.0f:%02i', greg(1,4), greg(1,5) );
		gt_string = { min_str; day_str; year_str };
	case 'month'
		dum=2;
		month_str = month_label(greg(1,2),:);
		gt_string = { month_str; year_str };
	end;
	ypoint = ylim(1) - 0.5*fsize*cfactor;
	if isequal(get(xhandle,'ydir'),'reverse')
		ypoint = ylim(2) + 0.5*fsize*cfactor;
	end;
	if isequal(flags,'year')
		year_labels = num2str(greg(:,1));
		set ( xhandle, 'XTickLabel', year_labels );
	else	
		xt_label(1) = text ( xt(1), ypoint, 0, gt_string );
	end;
	
	% Keep track of where to put a label for a new month or year
	% by differencing the gregorian dates.  Any entry that is not zero
	% means that the entry changed from the previous.
	tdiff = diff(greg(:,1:dum));
	thislong=size(tdiff,2);
	for i = 2:length(xt)
	    if ( tdiff(i-1,1)  )
	        year_str = num2str(greg(i,1));
	    else
	        year_str = '';
	    end;
		if thislong>1
		    if ( tdiff(i-1,2)  )
		        month_str = month_label(greg(i,2),:);
		    else
		        month_str = '';
		    end
		end;
		if thislong>2
		    if ( tdiff(i-1,3) )
		        day_str = num2str(greg(i,3));
		    else
		        day_str = '';
		    end
		end;
		if thislong>3
			if ( tdiff(i-1,4)  )
				hour_str = sprintf ( '%02i:00', greg(i,4) );
			else
				hour_str = '';
			end
		end;
		if thislong>4
			if ( tdiff(i-1,5) )
				min_str = sprintf ( '%.0f:%02i', greg(i,4), greg(i,5) );
			else
				min_str = '';
			end
		end;
		switch flags
		case 'day'
		    gt_string = { day_str; month_str; year_str };
		case 'hour'
		    gt_string = { hour_str; day_str; year_str };
		case 'minute'
		    gt_string = { min_str; day_str; year_str };
		case 'month'
		    gt_string = { month_str; year_str };
		end;
	    xt_label(i) = text ( xt(i), ypoint, 0, gt_string );
	end
	set ( xt_label, ...
	        'Fontsize', fsize, ...
	        'HorizontalAlignment', 'Center', ...
	        'VerticalAlignment', 'cap', ...
			'Tag', 'xtick labels');

end;
return;


function xnew=gmin(x)
%function xnew=gmin(x)
% just like min, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
   good=find(finite(x(:,j)));
   if length(good)>0
       xnew(j)=min(x(good,j));
   else
       xnew(j)=NaN;
   end
end


function xnew=gmax(x)
%function xnew=gmax(x)
% just like max, except that it skips over bad points
[imax,jmax]=size(x);

for j=1:jmax
       good=find(finite(x(:,j)));
       if length(good)>0
          xnew(j)=max(x(good,j));
       else
          xnew(j)=NaN;
       end
end
