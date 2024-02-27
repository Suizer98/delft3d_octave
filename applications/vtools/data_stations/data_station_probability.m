%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: data_station_probability.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/data_station_probability.m $
%

function data_station_prob=data_station_probability(data_station)

%% yearly and daily values

%this should be checked, I don't like <retime>

tim=data_station.time;
val=data_station.waarde;

tt=timetable(tim,val);
ttres_d=retime(tt,'daily','mean');
ttres_y=retime(tt,'yearly','mean');
ttres_y_tim=year(ttres_y.tim);

%out
data_station_prob.day.mean.val=ttres_d.val;
data_station_prob.day.mean.tim=ttres_d.tim;

data_station_prob.year.mean.val=ttres_y.val;
data_station_prob.year.mean.tim=ttres_y.tim;

%% maximum and minimum per year

time_year=year(tim);
[year_u,year_u_idx1,year_u_idx2]=unique(time_year);

ny=numel(year_u);
q_year_stat=NaN(ny,2);
time_q_year_stat=NaT(ny,2);
time_q_year_stat.TimeZone='+00:00';
for ky=1:ny
    q_loc=val(year_u_idx2==ky);
    time_loc=tim(year_u_idx2==ky);
    [q_year_stat(ky,1),idx_max]=max(q_loc);
    [q_year_stat(ky,2),idx_min]=min(q_loc);
%     q_year_stat(ky,3)=std(q_loc); %use the daily discharges for this
    time_q_year_stat(ky,1)=time_loc(idx_max);
    time_q_year_stat(ky,2)=time_loc(idx_min);
end %ky

%out
data_station_prob.year.max.val=q_year_stat(:,1);
data_station_prob.year.max.tim=time_q_year_stat(:,1);

data_station_prob.year.min.val=q_year_stat(:,2);
data_station_prob.year.min.tim=time_q_year_stat(:,2);

%% probability of yearly maximum

[q_sort,q_sort_idx]=sort(q_year_stat(:,1));
p_q_max=(ny:-1:1)'/(ny+1);

tim_w=ttres_y.tim;

if numel(tim_w)~=numel(year_u)
    error('ups')
end
if any(year_u-year(tim_w))
    error('ups2')
end

%out
data_station_prob.year.max.sort.val=q_sort;
data_station_prob.year.max.sort.tim=time_q_year_stat(q_sort_idx,1);
data_station_prob.year.max.sort.p=p_q_max;

%% probability of yearly minimum 

[q_sort,q_sort_idx]=sort(q_year_stat(:,2));
q_sort=flipud(q_sort);
p_q_max=(ny:-1:1)'/(ny+1);

tim_w=ttres_y.tim;

if numel(tim_w)~=numel(year_u)
    error('ups')
end
if any(year_u-year(tim_w))
    error('ups2')
end

%out
data_station_prob.year.min.sort.val=q_sort;
data_station_prob.year.min.sort.tim=time_q_year_stat(q_sort_idx,2);
data_station_prob.year.min.sort.p=p_q_max;

%% probability of daily discharge

[q_day_u,~,~]=unique(ttres_d.val(~isnan(ttres_d.val)));
nud=numel(q_day_u);
q_day_days=NaN(nud,1);
for kud=1:nud
    q_day_days(kud)=sum(ttres_d.val==q_day_u(kud));
end
q_day_days_cs=cumsum(q_day_days);
p_q_days=q_day_days_cs./(q_day_days_cs(end)+1);

%out
data_station_prob.day.unique.val=q_day_u;
data_station_prob.day.unique.p=p_q_days;

%% days with no data

tim_w=ttres_d.tim;
val_w=ttres_d.val;

empty_days=zeros(ny,1);

np=numel(tim_w);
for kp=1:np
    if isnan(val_w(kp))
        year_n=year(tim_w(kp));
        idx_y=find(year_n==ttres_y_tim);
        empty_days(idx_y)=empty_days(idx_y)+1;
    end
end

data_station_prob.year.days_nodata.val=empty_days;
data_station_prob.year.days_nodata.tim=ttres_y_tim;

end %function
