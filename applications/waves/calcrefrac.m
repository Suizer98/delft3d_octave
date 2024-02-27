function [Kr,alfa]=calcrefrac(d,T,alfa0)
% calcrefrac refraction coefficient and angle of incidence
%
% [Kr,alfa]=calcrefrac(d,T,alfa0)
%
% Calculates refraction coefficient and angle of incidence
% (between wave crests and bottom contours)
% for parallel, straight bottom contours
%
% d     = water depth (shallow water)
% T     = wave period (seconds)
% alfa0 = angle of incidence in degrees (deep water)
%
% Kr    = refraction coefficient
% alfa  = wave angle at shallow water site
%
%see also: waves, swan

% Based on script by James Hu


[L,e,c] = wavelength(T,d,0,0,0,1e-6);
alfa0=alfa0*pi/180;
k=2*pi./L;
for ii=1:length(alfa0)
    if length(d)>1
        dind=ii;
    else
        dind=1;
    end
    if alfa0(ii)>=0 && alfa0(ii)<=pi/2
%         alfa(ii)=asin(tanh(k(ii)*d(dind)))*sin(alfa0(ii));
        alfa(ii)=asin(tanh(k(ii)*d(dind))*sin(alfa0(ii)));
        Kr(ii)=sqrt(cos(alfa0(ii))/cos(alfa(ii)));
    elseif alfa0(ii)>pi/2 && alfa0(ii)<pi
        alfa0(ii)=pi-alfa0(ii);
%         alfa(ii)=asin(tanh(k(ii)*d(dind)))*sin(alfa0(ii));
        alfa(ii)=asin(tanh(k(ii)*d(dind))*sin(alfa0(ii)));
        Kr(ii)=sqrt(cos(alfa0(ii))/cos(alfa(ii)));
        alfa(ii)=pi-alfa(ii);
    else
        Kr(ii)=0;
        alfa(ii)=0;
    end
    alfa(ii)=alfa(ii)*180/pi;
end
