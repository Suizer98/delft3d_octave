function trackt=interpolate_track_data(track,t)

% Interpolates track data to point in time. Also computes foreward speed and heading.
te=track.time;
track.x=track.x;
track.y=track.y;

xe=track.x;
ye=track.y;

if length(te)>2
    for it=2:length(te)-1        
        dx1=xe(it)-xe(it-1);
        dy1=ye(it)-ye(it-1);
        dt1=(te(it)-te(it-1))*24; % hours
        dx2=xe(it+1)-xe(it);
        dy2=ye(it+1)-ye(it);
        dt2=(te(it+1)-te(it))*24; % hours
        
        v1=sqrt(dx1^2+dy1^2)/dt1;
        v2=sqrt(dx2^2+dy2^2)/dt2;
        vtt(it)=0.5*(v1+v2);
        dxt(it)=0.5*(dx1+dx2);
        dyt(it)=0.5*(dy1+dy2);
        
    end
    vtt(1)=vtt(2);
    dxt(1)=dxt(2);
    dyt(1)=dyt(2);
    vtt(end+1)=vtt(end);
    dxt(end+1)=dxt(end);
    dyt(end+1)=dyt(end);
    
else
    dx1=xe(2)-xe(1);
    dy1=ye(2)-ye(1);
    dt1=(te(2)-te(1))*24; % hours
    v1=sqrt(dx1^2+dy1^2)/dt1;
    vtt=[v1;v1];
    dxt=[dx1;dx1];
    dyt=[dy1;dy1];
end

% First compute foreward speed and angle for each required time point

% Interpolate track data to output times
trackt.x=interp1(te,track.x,t);
trackt.y=interp1(te,track.y,t);
trackt.vmax=interp1(te,track.vmax,t);
trackt.rmax=interp1(te,track.rmax,t);
trackt.r35=interp1(te,track.r35,t);
trackt.phi_in=interp1(te,track.phi_in,t);
trackt.latitude=interp1(te,track.latitude,t);

dxr=interp1(te,dxt,t);
dyr=interp1(te,dyt,t);
trackt.forward_speed=interp1(te,vtt,t);
trackt.heading=atan2(dyr,dxr)*180/pi; % cartesian, degrees
