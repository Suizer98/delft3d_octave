%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: interpolate_timetable.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/interpolate_timetable.m $
%
%Interpolates several time series into a common time vector.
%
%INPUT:
%   -tim_ct: cell array with time of time series
%   -val_ct: cell array with values of time series
%   -dt_disc: time step to interpolate the time series
%
%OUTPUT:
%   -tt_tim: common time of all time series
%   -tt_val: interpolated values of all time series

function val_out=interpolate_timetable(tim_ct,val_ct,tim_re,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'disp',1);

parse(parin,varargin{:});

do_disp=parin.Results.disp;

if ~iscell(tim_ct)
    error('Provide input as cell array')
end

%% CALC

%% synchronize

ng=numel(tim_ct);
tt_all=cell(ng,1);
for kg=1:ng
    if min(size(val_ct{1,kg}))>1
        error('only 1 data column per time serie')
    end
    if ~isdatetime(tim_ct{kg})
        error('input must be in datetime')
    end
    tt_aux=timetable(reshape(tim_ct{kg},[],1),reshape(val_ct{kg},[],1));
    tt_all{kg,1}=tt_aux;
end
tt=synchronize(tt_all{:});

%% retime

nt=numel(tim_re);
val_in=tt.Variables;
tim_in=tt.Time;
val_out=NaN(nt,ng);


%IMPROVE
%Do not allow NaN in <val_in> and do not loop on kg here.
% fprintf('interpolating time %4.2f %% \n',0)
for kg=1:ng
    val_out(:,kg)=interpolate_timeserie(tim_in,val_in(:,kg),tim_re,do_disp);
    %disp
%     fprintf('interpolating time %4.2f %%',kg/ng*100)
end

end %function

%%
%% FUNCTION
%%

function val_out=interpolate_timeserie(tim_in,val_in,tim_re,do_disp)

%%

% tim_in=reshape(tim_in,1,[]);
% val_in=reshape(val_in,1,[]);

%%

if isempty(tim_in.TimeZone) || isempty(tim_re.TimeZone)
    error('Add the timezones to not make a mess!')
end
tim_in.TimeZone=tim_re.TimeZone; %set the values to same timezone
tim_in=datenum(tim_in);
tim_re=datenum(tim_re);
    
%%
bol_nn=~isnan(val_in);
tim_in_c=tim_in(bol_nn);
val_in_c=val_in(bol_nn);
dt_re=diff(cen2cor(tim_re));
nr=numel(tim_re);
val_out=NaN(nr,1);
for kr=1:nr
    t_cell_l=tim_re(kr)-dt_re(kr)/2;
    t_cell_u=tim_re(kr)+dt_re(kr)/2;
    %IMPROVE
    %set an initial guess of the index and from that move one
    %up and done in a while loop to find the limits
    [val_l,~,idx_l]=interp_line_closest(tim_in_c,val_in_c,t_cell_l,NaN,false); %value at lower edge
    [val_u,idx_u,~]=interp_line_closest(tim_in_c,val_in_c,t_cell_u,NaN,false); %value at upper edge
    if isnan(val_l) || isnan(val_u) %we do not make a mean if there is no value above and below the edges
        continue
    elseif idx_l>idx_u %there are no points inside. The first point to the right of the lower edge is larger than the upper edge
%         tim_in_c(idx_l)>t_cell_u %true
        tim_cell=[t_cell_l,t_cell_u]; %cannot concatenate empty datetime arrays
        val_cell=[val_l,val_u];
    else
        tim_cell=[t_cell_l,tim_in_c(idx_l:idx_u)',t_cell_u]; %cannot concatenate empty datetime arrays
        val_cell=[val_l,val_in_c(idx_l:idx_u)',val_u];
    end

    %points between lower limit and upper limit
    tim_cen=cor2cen(tim_cell);
      
    np=numel(tim_cen);
    val_cen=NaN(1,np);
    %IMPROVE
    %loop on kg here because the index are the same for all
    for kp=1:np
        val_cen(1,kp)=interp_line_closest(tim_cell,val_cell,tim_cen(kp),NaN,false); 
    end
    dtim_cell=diff(tim_cell);
    val_out(kr,1)=sum(val_cen.*dtim_cell)./sum(dtim_cell); %sum(seconds(dtim_cell))
    
    %disp
    if do_disp
        fprintf('interpolating time %4.2f %% \n',kr/nr*100)
    end
end

end %function

%% CHECKS

%see the following test to see why I don't use <retime>
% t1=datetime(2000,1,1,0,0,0):hours(1):datetime(2000,1,5,0,0,0); %not fine and shifted
% t1=datetime(2000,1,1,0,0,0)+seconds(1):hours(1):datetime(2000,1,5,0,0,0)-seconds(1); %fine but shifted

% nt=numel(t1);
% v=linspace(0,4,nt);
% % v(2:3:end-1)=NaN;
% 
% tt=timetable(t1',v');
% tt2=retime(tt,'regular','mean','TimeStep',days(1)); 
% 
% tim_ch=datetime(2000,1,1,12,0,0):days(1)/2:datetime(2000,1,5,12,0,0);
% nd=numel(tim_ch);
% val_ch=NaN(nd,1);
% for kd=1:nd
% bol_ti=t1>=tim_ch(kd)-days(1)/2&t1<=tim_ch(kd)+days(1)/2;
% bol_nn=~isnan(v);
% bol_t=bol_ti&bol_nn;
% tim_ch_loc=t1(bol_t);
% if numel(tim_ch_loc)<=1
%     continue
% end
% diff_t_loc=diff(tim_ch_loc);
% t_cor=cen2cor(tim_ch_loc);
% dt_cor=diff(t_cor);
% dt_d=dt_cor;
% dt_d(1)=dt_d(1)/2;
% dt_d(end)=dt_d(end)/2;
% val_ch_aux=sum(v(bol_t).*hours(dt_d))./sum(hours(dt_d));
% val_ch(kd,1)=val_ch_aux;
% end
% 
% 
% figure
% hold on
% plot(t1,v,'-o');
% plot(tt2.Time,tt2.Var1,'-*')
% plot(tim_ch,val_ch,'-s')
