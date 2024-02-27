%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: tidal_values.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/tidal_values.m $
%
%

function [tim_f,data_max]=tidal_values(time_dtime,data,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'T',hours(12));
addOptional(parin,'do_disp',0);

parse(parin,varargin{:});

T=parin.Results.T;
do_disp=parin.Results.do_disp;

%% CALC

%preallocate
npre=1000;
data_max=NaN(npre,1);
tim_f=NaT(npre,1);
tim_f.TimeZone=time_dtime.TimeZone;

%initialize
t0=time_dtime(1);
kc=1;

%first is different because time series may not start at a maximum

%max water level
bol=time_dtime>t0 & time_dtime<t0+T; %different than in loop
tim_loc=time_dtime(bol);
[data_max(kc),idx_loc_max]=max(data(bol));
tim_f(kc)=tim_loc(idx_loc_max);

%update
t0=tim_f(kc); %t0 is a maximum 
kc=kc+1;

% %% BEGIN DEBUG
% 
% figure
% hold on
% plot(time_dtime,data)
% 
% %% END DEBUG

while t0+2*T<time_dtime(end)
    
    %maximum
    bol=time_dtime>t0+3/4*T & time_dtime<t0+3/2*T;
    tim_loc=time_dtime(bol);
    [data_max(kc),idx_loc_max]=max(data(bol));
    tim_f(kc)=tim_loc(idx_loc_max);
    
    %preallocate
    if kc==numel(tim_f)
        tim_prea=NaT(npre,1);
        tim_prea.TimeZone=time_dtime.TimeZone;

        tim_f=cat(1,tim_f,tim_prea);
        data_max=cat(1,data_max,NaN(npre,1));
        tim_sal_min=cat(1,tim_sal_min,tim_prea);
        sal_min=cat(1,sal_min,NaN(npre,1));
    end
    
    %display
    if do_disp
        pdone=(tim_f(kc)-time_dtime(1))/(time_dtime(end)-time_dtime(1)); 
        fprintf('done %4.2f %% \n',pdone*100)
    end
    
%     %% BEGIN DEBUG
%     
%     scatter(t0+3/4*T,data_max(kc),'r')
%     scatter(t0+3/2*T,data_max(kc),'g')
%     scatter(tim_f(kc),data_max(kc),'b')
%     
%     %% END DEBUG
    
    %update
%     t0=t0+T;
    t0=tim_f(kc);
    kc=kc+1;
    
end

%cut
tim_f=tim_f(1:kc-1);
data_max=data_max(1:kc-1);

%% BEGIN DEBUG

% figure
% hold on
% plot(time_dtime,data)
% scatter(tim_f,data_max)
% % pause
% close(gcf)

%% END DEBUG

end %function
