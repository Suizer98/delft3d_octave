function [amp,phase,period,offset]=time2har(time,func,ncomp,tstart,tstop);
%% time2har   : convert timeseries to harmonic components 
%               and write period, amp and phase to 'temp.bc'
% time       : regularly spaced time, in minutes
% func       : time series to be analyzed
% ncomp      : number of harmonic components
% tstart     : start of analysis period
% tstop      : end of analysis period
% amp        : amplitudes of components
% phase      : phase of components
% period     : periods of components (longest is tstop-tstart)
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 IHE Delft / Deltares
%       Dano Roelvink
%
%       d.roelvink@un-ihe.org
%
%       Westvest 7
%       2611AX Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.
yesplot=1;
f=func(time>=tstart&time<=tstop);
t=time(time>=tstart&time<=tstop);
fmean=mean(f);
offset=fmean;
f=f-fmean;
omega0=2*pi/(tstop-tstart);
for i=1:ncomp
    omega(i)=i*omega0;
    period(i)=2*pi/omega(i);
    a(i)=sum(f.*cos(omega(i)*t))/sum((cos(omega(i)*t)).^2);
    b(i)=sum(f.*sin(omega(i)*t))/sum((sin(omega(i)*t)).^2);
end
amp=sqrt(a.^2+b.^2);
amp(3:2:end)=0;
phase=atan2(b,a);
f2=zeros(size(f));
f3=zeros(size(func));
f4=zeros(size(f));
for i=1:ncomp
    f2=f2+a(i)*cos(omega(i)*t)+b(i)*sin(omega(i)*t);
    f3=f3+a(i)*cos(omega(i)*time)+b(i)*sin(omega(i)*time);
    f4=f4+amp(i)*cos(omega(i)*t-phase(i));
end
phase=mod(phase*180/pi,360);
if yesplot
    figure;
    plot(time,func,'b',time,f3+offset,'g',t,f4+offset,'k','linewidth',2)
    legend('original','harmonic 1','harmonic')
    xlim([tstart-(tstop-tstart),tstop+(tstop-tstart)])
end
out(:,1)=period;
out(:,2)=amp;
out(:,3)=phase;
save('temp.bc','out','-ascii')