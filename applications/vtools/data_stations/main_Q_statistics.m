%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: main_Q_statistics.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_Q_statistics.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
path_data_stations='C:\Users\chavarri\checkouts\riv\data_stations\';

% path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';

%% ADD OET

addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

flg.write_csv=0;

% data_station=read_data_stations(path_data_stations,'location_clear','Lobith','grootheid','Q');
data_station=read_data_stations(path_data_stations,'location_clear','Baton Rouge','grootheid','WATHTE');

%% CALC

data_station_prob=data_station_probability(data_station);

%% fit

q_sort=data_station_prob.year.max.sort.val;
p_q_max=data_station_prob.year.max.sort.p;

q_lim=8000;
bol_fit=q_sort>q_lim;

x=log(q_sort(bol_fit));
y=log(p_q_max(bol_fit));
% x=q_sort(bol_fit);
% y=p_q_max(bol_fit);

% x_tot=q_sort;
% y_tot=p_q_max;
x_tot=log(q_sort);
y_tot=log(p_q_max);

% [B,fval,y_fit,fcn]=fit_function('exp',x,y,'x0',ones(1,2)/5000);
B=polyfit(x,y,1);
y_fit=B(1).*x+B(2);

% y_fit=polyval(B,x);

figure 
hold on
plot(x_tot,y_tot)
plot(x,y)
plot(x,y_fit,'-*')

%% find Q of certain p

p=0.01;

fcn=@(X)B(1).*X+B(2);
fcn_p=@(X)(fcn(X)-log(p))^2;

opt=optimset('MaxFunEvals',20000,'MaxIter',10000);
[Q_p,fval]=fminsearch(fcn_p,16000,opt);
fcn_p(Q_p)
fcn(exp(Q_p))
Q=exp(Q_p);
fprintf('Q = %f m^3/s has probability of yearly maximum p = %f with return period %f years \n',Q,p,1/p)

%% order each year

tim=data_station_prob.day.mean.tim;
val=data_station_prob.day.mean.val;

time_year=year(tim);
[year_u,year_u_idx1,year_u_idx2]=unique(time_year);

ny=numel(year_u);
q_s=NaN(366,ny);
tim_s=NaT(366,ny);
tim_s.TimeZone='+00:00';

for ky=1:ny
    q_loc=val(year_u_idx2==ky);
    time_loc=tim(year_u_idx2==ky);
    [q_loc_s,idx_s]=sort(q_loc);
    tim_loc_s=time_loc(idx_s);
    
    q_s(1:numel(q_loc_s),ky)=q_loc_s;
    tim_s(1:numel(q_loc_s),ky)=tim_loc_s;
end %ky

%out

%% WRITE

if flg.write_csv
    
%% all

tim_w=tim;
val_w=val;

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_all.csv','w');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f \n',datestr(tim_w(kp),'dd-mm-yyyy HH:MM'),val_w(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

%% daily

tim_w=ttres_d.tim;
val_w=ttres_d.val;

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_daily.csv','w');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f \n',datestr(tim_w(kp),'dd-mm-yyyy'),val_w(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

%% yearly

tim_w=ttres_y.tim;
val_w=ttres_y.val;

if numel(tim_w)~=numel(year_u)
    error('ups')
end
if any(year_u-year(tim_w))
    error('ups2')
end

np=numel(tim_w);
fid=fopen('c:\Users\chavarri\Downloads\lobith_yearly.csv','w');
fprintf(fid,'year, mean, max, day max, min, day min, days no data \n');
for kp=1:np
    if isnan(val_w(kp))
        val_w(kp)=-999;
    end
    fprintf(fid,'%s, %f, %f, %s, %f, %s, %d \n',datestr(tim_w(kp),'yyyy'),val_w(kp),q_year_stat(kp,1),datestr(time_q_year_stat(kp,1),'dd-mm-yyyy'),q_year_stat(kp,2),datestr(time_q_year_stat(kp,2),'dd-mm-yyyy'),empty_days(kp));
    fprintf('done %4.2f%% \n',kp/np*100);
end
fclose(fid);

end

%% PLOT

%% raw

if 0
figure
hold on
plot(year_u,q_year_stat(:,1),'*-')
plot(year_u,q_year_stat(:,2),'*-')
plot(ttres_y_tim,ttres_y.val,'*-')

figure
hold on
plot(ttres_d.tim,ttres_d.val,'*-');
end

%% nice

in_p.fig_print=0; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fname='Q_analysis_day';
in_p.fig_visible=1;
in_p.data_station=data_station;
in_p.lan='en';
% in_p.time_q_year_max=data_station_prob.year.max.tim;
% in_p.q_year_max=data_station_prob.year.max.val;
% in_p.q_sort=data_station_prob.year.max.sort.val;
% in_p.p_q_max=data_station_prob.year.max.sort.p;

in_p.time_q_year_max=data_station_prob.year.min.tim;
in_p.q_year_max=data_station_prob.year.min.val;
in_p.q_sort=data_station_prob.year.min.sort.val;
in_p.p_q_max=data_station_prob.year.min.sort.p;

in_p.q_day_u=data_station_prob.day.unique.val;
in_p.p_q_days=data_station_prob.day.unique.p;

fig_Q_analysis_vertical(in_p);
% fig_Q_analysis_horizontal(in_p);

%% daily mean matrix

in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fname='Q_matrix';
in_p.fig_visible=0;
in_p.lan='en';
in_p.q=q_s;
in_p.tim=year_u;
in_p.lims_q=[600,1200];
in_p.lims_d=[1,60];
in_p.lims_y=[min(year_u),max(year_u)];

fig_Q_matrix(in_p)

%% yearly ordered

in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fname='yearly_ordered';
in_p.fig_visible=0;
in_p.lan='en';
in_p.val=data_station.waarde;
in_p.tim=data_station.time;
in_p.unit=data_station.grootheid;
in_p.tit_str=data_station.location_clear;

fig_yearly_ordered(in_p)
