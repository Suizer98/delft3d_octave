function [thetamin,thetamax]=get_thetarange(out2d,hthreshold)

% This program reads in the structure of 2d spectral data and alfa and
% calculates thetamin and thetamax for input into the params.txt file.

%   Inputs:
%     hthreshold = threshold wave height value to search for directional
%     range (this is converted to S and all cells with energy less than
%     this value are not considered).
%     out2d = timeseries of output 2D spectral data stored in the following
%             format.
%     out2d = array with 2D spectral data
%     out2d.t = matlab datenumber
%     out2d.f = frequencies 
%     out2d.d = directions 
%     out2d.s = variance densities,
%     size(out2d.s) = [length(out2d.f) length(out2d.dir) length(out2d.time)]     

%   Outputs:
%     thetamin = minimum angle in Cartesian coordinate system for input
%     into params.txt assuming thetanaut=1 (ex: ' 250)
%     thetamax = maximum angle in XBeach coordinate system for input into
%     params.txt assuming thetanaut=1 (ex: '290')

thetamin=[];
thetamax=[];

st=sum(out2d.s,3);
stt=sum(st,1);

sttt=sum(stt);
if sttt>0
    
    d=out2d.d;
    
    if d(end)<d(1)
        d=fliplr(d);
        stt=fliplr(stt);
    end
    
    d=[d d+360 d+720];
    stt=[stt stt stt];
    dd=d(2)-d(1);
    
    maxs=max(stt);
    ipeak=find(stt==maxs);
    ipeak=ipeak(2);
    
    imin=ipeak-ceil(180/dd);
    imax=ipeak+ceil(180/dd);
    
    d=d(imin:imax);
    stt=stt(imin:imax);

    maxs=max(stt);
    ip=find(stt==maxs);

%     figure(2);
%     plot(d,stt);hold on;

%     plot([d(ip) d(ip)],[0 stt(ip)],'r');

    imin=1;
    imax=length(d);

    stot=0.5*stt(ip);
    s1=sum(stt(1:ip-1));
    for i=ip-1:-1:1
        stot=stot+stt(i);
        if stot>hthreshold*(s1+0.5*stt(ip));
            imin=i;
            break;
        end    
    end

    stot=0.5*stt(ip);
    s2=sum(stt(ip+1:end));
    for i=ip+1:length(d)
        stot=stot+stt(i);
        if stot>hthreshold*(s2+0.5*stt(ip));
            imax=i;
            break;
        end    
    end

%     plot([d(imin) d(imin)],[0 stt(imin)],'g');
%     plot([d(imax) d(imax)],[0 stt(imax)],'g');
    
    thetamin=d(imin);
    thetamax=d(imax);
    
    thetamin=mod(thetamin,360);
    thetamax=mod(thetamax,360);

end

