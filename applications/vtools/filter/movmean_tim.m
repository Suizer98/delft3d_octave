%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: movmean_tim.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/movmean_tim.m $
%
%Moving mean based on time
%
%INPUT:
%   -time_dnum: time [dnum]
%   -data: data [nt,ns]
%   -window_w: [s] time to make the window average
%
%OUTPUT:
%   -filtered signal

function [fil,tim_re]=movmean_tim(time_dtime,data,window_s)

[tim_re,data]=uniform_data(time_dtime,data);

if isvector(data)
    data=reshape(data,[],1);
end

dt=diff(tim_re);

num_ave=round((window_s/24/3600)/dt(1)); 
[np,nS]=size(data);
fil=NaN(np,nS);
for kS=1:nS
    fil(:,kS)=movmean(data,num_ave);
    fil(1:num_ave,kS)=NaN;
    fil(end-num_ave:end,kS)=NaN;
end

end %function