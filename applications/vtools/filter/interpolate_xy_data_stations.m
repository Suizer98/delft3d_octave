%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: interpolate_xy_data_stations.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/interpolate_xy_data_stations.m $
%

function [xm,ym,val_int_s]=interpolate_xy_data_stations(data_stations,x_v,t_v)

x=[data_stations.raai];
[x,idx_s]=sort(x);
data_stations=data_stations(idx_s);

nx=numel(x);

% t_v=t0:1/24/60*10:tend;
% t_v=t0:1/24:tend;
% x_v=x(1):1000:x(end); 
% t_thres=1/24; %[days]
t_thres=1; %[days]

%filter input to interpolateion
% val_f=val;
t_dnum=cell(nx,1);
t_dnum_f=cell(nx,1);
% t_dtime=cell(nx,1);
tzone='+00:00';
for kx=1:nx
    t{kx}=data_stations(kx).time;
    val_f{kx}=data_stations(kx).waarde;
    
    t{kx}.TimeZone=tzone; %operate datenum in UTC
%     t_dnum{kx}=datenum(t{kx});
    t_dnum{kx}=t{kx};
    t_dnum_f{kx}=t_dnum{kx}>t_v(end) | t_dnum{kx}<t_v(1);
    
    val_f{kx}(t_dnum_f{kx})=[];
    t_dnum{kx}(t_dnum_f{kx})=[];
    % t_dtime{kx}=t{kx}(~t_dnum_f{kx});

    %unique data
    [~,idu1,~]=unique(t_dnum{kx});
    t_dnum{kx}=t_dnum{kx}(idu1);
    % t_dtime{kx}=t_dtime{kx}(idu1);
    val_f{kx}=val_f{kx}(idu1);

    %would be good to check that uniqueness does not mean data was crap.
end    

%interpolate
[xm,ym,val_int_s]=interpolate_xy(x,t_dnum,val_f,x_v,t_v,t_thres);

end