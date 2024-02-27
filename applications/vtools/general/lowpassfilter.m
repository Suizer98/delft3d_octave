%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17165 $
%$Date: 2021-04-08 17:36:24 +0800 (Thu, 08 Apr 2021) $
%$Author: chavarri $
%$Id: lowpassfilter.m 17165 2021-04-08 09:36:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/lowpassfilter.m $
%
%Applies low pass filter with passing frequency 'fpass' and
%steepness 'steepness' to time series consisting of 'nt' points 
%with values 'val' at times 'tim'. Data is output at a constant
%time step 'TimeStep' such that it has 'ntf' points.
%
%INPUT:
%   -tim: time of series [datetime(nt,1)]
%   -val: values of series [double(nt,1)]
%   -fpass: passing frequency [double(1,1)] e.g. fpass=1/(2*24*3600)
%   -steepness: filter steepness [double(1,1)] e.g. 0.99999 (i.e., very step filter)
%   -TimeStep: resampling time of the series [duration(1,1)] e.g. minutes(2) (i.e., 2 minutes)
%
%OUTPUT:
%   tim_f: time of filtered series [datetime(ntf,1)];
%   val_f: values of filtered series [double(ntf,1)];

function [tim_f,val_f]=lowpassfilter(tim,val,fpass,steepness,TimeStep)
 
%uniform, unique
data_r=timetable(tim,val);
data_r=rmmissing(data_r);
data_r=sortrows(data_r);
tim_u=unique(data_r.tim);
data_r=retime(data_r,tim_u,'mean'); 
data_r=retime(data_r,'regular','linear','TimeStep',TimeStep);
t1=data_r.tim(1);
data_r.tim=data_r.tim-t1;
data_r.tim.Format='s';

%check
if isregular(data_r)==0
    unique(diff(data_r.tim))
    error('it must be regular')
end
if any(isnan(data_r.val))
    error('it must not contain NaN')
end

%filter
data_f=lowpass(data_r,fpass,'Steepness',steepness,'ImpulseResponse','iir');

tim_f=t1+data_f.tim;
val_f=data_f.val;

%% fourier

% tim_s=data_r.tim;
% y=[data_r.val,data_f.val];
% %         varname_1='water level [m]';
% %         varname_2='spectral power [m^2/s]';
% 
% %         varname_1='streamwise velocity [m/s]';
% %         varname_2='spectral power [m^2/s^3]';
% aux=diff(tim_s);
% dt_s=seconds(aux(1));
% nt=numel(tim_s);
% fs=1/dt_s; %[Hz]
% f=(0:nt-1)*(fs/nt); %[Hz]
% 
% yf=fft(y); 
% % pf=abs(yf).^2/nt;    % power of the DFT (also correct, but check the units above)
% pf=abs(yf).^2/dt_s;    % power of the DFT

