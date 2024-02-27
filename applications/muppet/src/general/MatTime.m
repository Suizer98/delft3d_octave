function dtnum=MatTime(dates,times)
 
years=floor(dates/10000);
months=floor( (dates-years*10000)/100 );
days=dates-years*10000-months*100;
 
hours=floor(times/10000);
minutes=floor( (times-hours*10000)/100 );
seconds=times-hours*10000-minutes*100;
 
dtnum=datenum(years,months,days,hours,minutes,seconds);
 
