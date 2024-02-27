function call_mx_spiderweb(filename,refdate,tc,radius)

nt=length(tc.track);
t=zeros(nt,1);
x=zeros(nt,1);
y=zeros(nt,1);

nrows=size(tc.track(1).wind_speed,2);
ncols=size(tc.track(1).wind_speed,1);

wind_speed=zeros(nt,nrows,ncols);
wind_direction=zeros(nt,nrows,ncols);
pressure=zeros(nt,nrows,ncols);

for it=1:nt
    t(it,1)=(tc.track(it).time-refdate)*1440.0;
    x(it,1)=tc.track(it).x;
    y(it,1)=tc.track(it).y;
    wind_speed(it,:,:)=tc.track(it).wind_speed';
    wind_direction(it,:,:)=tc.track(it).wind_from_direction';
    pressure(it,:,:)=tc.track(it).pressure_drop';
end

wind_speed=reshape(wind_speed,[nt*nrows*ncols 1]);
wind_direction=reshape(wind_direction,[nt*nrows*ncols 1]);
pressure=reshape(pressure,[nt*nrows*ncols 1]);

mxspiderweb(t,x,y,wind_speed,wind_direction,pressure,nrows,ncols,radius,filename,datestr(refdate,'yyyy-mm-dd HH:MM:SS'));
