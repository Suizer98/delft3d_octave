load('aa_407m_at_e1.mat');
time=ndate;                               % 'time' is 'Matlab' time
tp=time-datenum(2003,1,1);                % 'tp' is day-of-year 2003 for plotting

% Tidal analysis using t_tide
[nameu,fu,tidecon,u_tide]=t_tide(u,'interval',0.5,'latitude',-71.951,...
    'start time',time(1));
[nameu,fu,tidecon,v_tide]=t_tide(v,'interval',0.5,'latitude',-71.951,...
    'start time',time(1));

u_res=u-u_tide; v_res=v-v_tide;           % residuals from t_tide

% Output files from Ross Sea inverse model ('_m' for 'model')
[u_model,ConList]=tide_pred('d:/tide_models/tmd/DATA/UV_Ross',...
                            'd:/tide_models/tmd/DATA/grid_Ross',...
                            time,lat,lon,'u','xy_ll_S');
[v_model,ConList]=tide_pred('d:/tide_models/tmd/DATA/UV_Ross',...
                            'd:/tide_models/tmd/DATA/grid_Ross',...
                           time,lat,lon,'v','xy_ll_S');

u_res_m=u-u_tide;
v_res_m=v-v_tide;

figure;                    % Plot the model and t_tide tides, data, and model
                           %    and t_tide residuals

subplot(2,1,1);            % u (E/W) velocities
plot(tp,u,'b'); grid on
hold on
plot(tp,u_tide,'r');
plot(tp,u_model,'k');

%set(gca,'XLim',[60 80]);
ylabel('u (East): (cm/s)')

subplot(2,1,2);            % v (N/S) velocities
plot(tp,v,'b'); grid on
hold on
plot(tp,v_tide,'r');
plot(tp,v_model,'k');
%set(gca,'XLim',[60 80]);
ylabel('v (North): (cm/s)')

disp([mean(u) mean(v)])

% Now, let's look at the currents relative to alongslope (30 deg S of E)
%    and cross-slope (30 deg E of N)

% Calculate rotated values ('_r' for 'rotated')
theta=30*pi/180; ct=cos(theta); st=sin(theta); % 30 deg rotation CCW
u_tide_r = u_tide*ct - v_tide*st;
v_tide_r = u_tide*st + v_tide*ct;

u_res_r = u_res*ct - v_res*st;
v_res_r = u_res*st + v_res*ct;

figure;
plot(u_tide,v_tide); axis('equal'); grid on

% Now, estimate the across-slope displacement (in km) based solely on the
%   cross-slope component of tidal current.

Y_tide=zeros(size(v_tide));
for i=2:length(Y_tide);
    Y_tide(i)= Y_tide(i-1)+mean(v_tide_r((i-1):i))*1800/1e5;
end
Y_tide=Y_tide-4.31;  % Subtract 4.31 km so that mean displacement is zero.
figure; 
subplot(2,1,1); plot(tp,Y_tide); grid on
%set(gca,'XLim',[60 80]);
ylabel('Disp. (km)')
subplot(2,1,2); plot(tp,u_res_r,'r'); grid on; hold on
%set(gca,'XLim',[60 80]);
plot(tp,v_res_r,'b'); 
ylabel('Alongslope u_{res} (cm/s)')