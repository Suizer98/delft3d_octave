%% basic

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

w = slamfat_wind('duration',3600);
s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

source = zeros(length(s.profile),1);
source(1:20) = 1.5e-3 * w.dt * s.dx;

s.bedcomposition = slamfat_bedcomposition_basic;
s.bedcomposition.source             = source;
s.bedcomposition.grain_size         = .3*1e-3;

s.max_threshold = slamfat_threshold_basic;
s.max_threshold.time = 0:3600;

s.run;
s.show_performance;

%% advanced

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

w = slamfat_wind('duration',3600);
s = slamfat('wind',w,'profile',profile,'animate',true); %,'output_file','slamfat.nc');

source = zeros(length(s.profile),1);
source(1:100) = 1.5e-2 * w.dt * s.dx;

s.bedcomposition = slamfat_bedcomposition;
s.bedcomposition.source             = source;
s.bedcomposition.layer_thickness    = 5e-4;
s.bedcomposition.number_of_layers   = 3;
s.bedcomposition.grain_size         = [1.18 0.6 0.425 0.3 0.212 0.15 0.063]*1e-3;
s.bedcomposition.distribution       = [0.63 0.94 6.80 51.35 30.73 8.07 1.43];

s.max_threshold = slamfat_threshold;
s.max_threshold.time = 0:3600;
s.max_threshold.tide = 0.25 * sin(s.max_threshold.time * 2 * pi / 600);
s.max_threshold.solar_radiation = 1e4;

s.max_source    = 'initial_profile';

s.run;
s.show_performance;

%% knmi and waterbase data

close all; clear classes; clear w; clear s;

load('environment.mat');

t0 = datenum('2013-06-21 00:00');
t1 = datenum('2013-06-28 00:00');

idx1 = meteo.time >= t0 & meteo.time < t1;
idx2 = tide.time >= t0 & tide.time < t1;

n       = 300;
n_foot  = 280;
z_start = -1.5;
z_foot  = 3;
z_crest = 15;
profile             = zeros(1,n);
profile(1:n_foot)   = linspace(z_start,z_foot,n_foot);
profile(n_foot:end) = linspace(z_foot,z_crest,n-n_foot+1);

w = slamfat_wind('duration',3600 * ones(sum(idx1),1), 'velocity_mean', meteo.wind(idx1) / 10);
s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false,'output_file','slamfat.nc');

source = zeros(length(s.profile),1) + 1.5e-4 * w.dt * s.dx;

s.bedcomposition = slamfat_bedcomposition_basic;
s.bedcomposition.source             = source;
s.bedcomposition.grain_size         = .255*1e-3;

t = tide.time(idx2);

s.max_threshold = slamfat_threshold;
s.max_threshold.time = (t - min(t)) * 24 * 3600;
s.max_threshold.tide = tide.tide(idx2) / 100; % 100 is conversion from cm to m
s.max_threshold.rain = interp1(meteo.time, meteo.rain, t) / 10 / 6; % 10 is conversion from .1mm to mm; 6 is factor between diff(tide.time) and diff(meteo.time)
s.max_threshold.solar_radiation = interp1(meteo.time, meteo.sun, t) * 1e4 / 6; % 1e4 is conversion from J/cm2 to J/m2; 6 is factor between diff(tide.time) and diff(meteo.time)

%s.run;
%s.show_performance;

%% async

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

duration = 60 * ones(1,60);
velocity = 4+4*sin((cumsum(duration)-30)/600*2*pi);
velstd   = 0;
w = slamfat_wind('duration',duration,'velocity_mean',velocity,'velocity_std',velstd);

%% threshold amplitude

phi = linspace(-pi,pi,21);
A   = [3 4 5]; %2:6; %0:2:8;

for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d.mat',phi(i),A(j));
        
        if ~exist(fullfile(pwd,fname),'file')
    
            disp(fname);
            
            clear s;
            s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

            source = zeros(length(s.profile),1);
            source(1:20) = 1.5e-4 * w.dt * s.dx;

            s.bedcomposition = slamfat_bedcomposition_basic;
            s.bedcomposition.source             = source;
            s.bedcomposition.grain_size         = .3*1e-3;

            s.max_threshold = slamfat_threshold_basic;
            s.max_threshold.time      = 0:3600;
            s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

            s.run;

            save(fname,'s');
        end
    end
end

%% T=0

phi = linspace(-pi,pi,21);
A   = 3;

for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d_T=0.mat',phi(i),A(j));
        
        if ~exist(fullfile(pwd,fname),'file')
    
            disp(fname);
            
            clear s;
            s = slamfat('wind',w,'profile',profile,'relaxation',0.05,'animate',false,'progress',false);

            source = zeros(length(s.profile),1);
            source(1:20) = 1.5e-4 * w.dt * s.dx;

            s.bedcomposition = slamfat_bedcomposition_basic;
            s.bedcomposition.source             = source;
            s.bedcomposition.grain_size         = .3*1e-3;

            s.max_threshold = slamfat_threshold_basic;
            s.max_threshold.time      = 0:3600;
            s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

            s.run;

            save(fname,'s');
        end
    end
end

%% S = small

phi = linspace(-pi,pi,21);
A   = 3;
S   = [3e-5 1.5e-5 3e-6 1.5e-6];

for k = 1:length(S)
    for j = 1:length(A)
        for i = 1:length(phi)
            fname = sprintf('s_phi%3.2f_A%d_S=%3.2e.mat',phi(i),A(j),S(k));

            if ~exist(fullfile(pwd,fname),'file')

                disp(fname);

                clear s;
                s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

                source = zeros(length(s.profile),1);
                source(1:20) = S(k) * w.dt * s.dx;

                s.bedcomposition = slamfat_bedcomposition_basic;
                s.bedcomposition.source             = source;
                s.bedcomposition.grain_size         = .3*1e-3;

                s.max_threshold = slamfat_threshold_basic;
                s.max_threshold.time      = 0:3600;
                s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/600*2*pi + phi(i));

                s.run;

                save(fname,'s');
            end
        end
    end
end

%% plot results

close all;

figure; hold on;

clr = 'rgbcymk';

phi = linspace(-pi,pi,21);
A   = 3:5; %0:2:8;
S   = [3e-5 1.5e-5 3e-6 1.5e-6];

transport = zeros(length(phi),length(A),1);
for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d.mat',phi(i),A(j));
        
        if exist(fname,'file')
            disp(fname);
            try
                load(fname);
                transport(i,j,:) = squeeze(s.data.total_transport(end,end,:));
            end
        end
    end
    
    t = squeeze(transport(:,j,:));
    if ~all(t==0)
        plot(phi/pi*180,t/t(1),'-','Color',clr(j));
    end
end

transport = zeros(length(phi),length(A),1);
for j = 1:length(A)
    for i = 1:length(phi)
        fname = sprintf('s_phi%3.2f_A%d_T=0.mat',phi(i),A(j));
        
        if exist(fname,'file')
            disp(fname);
            load(fname);
            transport(i,j,:) = squeeze(s.data.total_transport(end,end,:));
        end
    end
    
    t = squeeze(transport(:,j,:));
    if ~all(t==0)
        plot(phi/pi*180,t/t(1),':','Color',clr(j));
    end
end

transport = zeros(length(phi),length(A),length(S),1);
for k = 1:length(S)
    for j = 1:length(A)
        for i = 1:length(phi)
            fname = sprintf('s_phi%3.2f_A%d_S=%3.2e.mat',phi(i),A(j),S(k));

            if exist(fname,'file')
                disp(fname);
                load(fname);
                transport(i,j,k,:) = squeeze(s.data.total_transport(end,end,:));
            end
        end

        t = squeeze(transport(:,j,k,:));
        if ~all(t==0)
            plot(phi/pi*180,t/t(1),'--','Color',clr(j));
        end
    end
end

xlabel('phase difference between threshold and wind velocity [^o]')
ylabel('relative transport volume w.r.t. 180^o phase difference [-]')

xlim([-180 180]);

legend([arrayfun(@(x) sprintf('threshold amplitude = %d',x), A, 'UniformOutput', false) ...
    {'no relaxation' 'decreasing supply'}], ...
    'Location','SouthWest');

grid on;
box on;

set(findobj(gca,'Type','line'),'LineWidth',2)

%% plot supply

load('s_phi0.00_A3.mat');

figure;
pcolor(s.data.supply);
shading flat;
colorbar;
title(sprintf('S = %d', 1.4e-4));

fnames = dir('s_phi0.00_A3_S=*.mat');

for i = 1:length(fnames)
    fname = fnames(i).name;
    
    re = regexp(fname, 's_phi0.00_A3_S=([\d-+\.e]+).mat', 'tokens');
    
    if ~isempty(re)
        load(fname);
        
        figure;
        pcolor(s.data.threshold);
        shading flat;
        colorbar;
        title(sprintf('S = %d', str2double(re{1}{1})));
    end
end

%% plot supply

figure;

fnames = dir('s_phi*_A3.mat');

n = ceil(length(fnames)/2);
ny = ceil(sqrt(n));
nx = ceil(n/ny);

si = 1;
ax = [];
for i = 1:length(fnames)
    fname = fnames(i).name;
    
    re = regexp(fname, 's_phi([\d-+\.e]+)_A3.mat', 'tokens');
    
    if ~isempty(re)
        phi = str2double(re{1}{1});
        
        if phi >= 0
        
            load(fname);

            ax(si) = subplot(ny,nx,si);
            pcolor(s.data.supply);
            shading flat;
            title(sprintf('\\phi = %1.2f', phi));
            
            si = si + 1;
        end
    end
end

cl = cell2mat(arrayfun(@clim, ax, 'UniformOutput', false)');
arrayfun(@(x) clim(x, [min(cl(:,1)) max(cl(:,2))]), ax);

%% theoretical phase difference effect

figure;
s1 = subplot(2,2,1); hold on;

x = linspace(0,6*pi,1000);

plot(x,sin(x),'-k');
plot(x,.6*sin(x+20/180*pi),'-r');
plot(x,.6*sin(x-20/180*pi),'-b');

s2 = subplot(2,2,3); hold on;
plot(x,max(0,sin(x)-.6*sin(x+20/180*pi)),'-r');
plot(x,max(0,sin(x)-.6*sin(x-20/180*pi)),'-b');

s3 = subplot(2,2,2); hold on;

s_plus = load('s_phi0.63_A3.mat');
s_min  = load('s_phi-0.63_A3.mat');

plot(s_plus.s.output_time, s_plus.s.data.wind,'-k');
plot(s_plus.s.output_time, s_plus.s.data.threshold(:,1),'-r');
plot(s_min.s.output_time, s_min.s.data.threshold(:,1),'-b');

plot(s_plus.s.wind.time,s_plus.s.wind.time_series,'--k')

duration = 60 * ones(1,60);
velocity = 4+4*sin(cumsum(duration)/600*2*pi);
%plot(cumsum(duration), velocity,'-k');

s4 = subplot(2,2,4); hold on;

plot(s_plus.s.output_time, max(0,s_plus.s.data.wind(:,1) - s_plus.s.data.threshold(:,1)),'-r');
plot(s_min.s.output_time, max(0,s_plus.s.data.wind(:,1) - s_min.s.data.threshold(:,1)),'-b');

t1 = interp1(s_plus.s.output_time,s_plus.s.data.threshold(:,1),s_plus.s.wind.time);
t2 = interp1(s_plus.s.output_time,s_min.s.data.threshold(:,1),s_plus.s.wind.time);

plot(s_plus.s.wind.time, max(0,s_plus.s.wind.time_series - t1),'--r');
plot(s_plus.s.wind.time, max(0,s_plus.s.wind.time_series - t2),'--b');

linkaxes([s1 s2],'x');
linkaxes([s3 s4],'x');

%xlim(minmax(x));

%% frequency difference

close all; clear classes; clear w; clear s;

n = 90;
profile        = zeros(1,100);
profile(1:n)   = linspace(-1,1,n);
profile(n:end) = linspace(1,15,100-n+1);

duration = 60 * ones(1,60);
velocity = 4+4*sin((cumsum(duration)-30)/600*2*pi); % 24 * 3600 = 86400 s -> 600 s -> 0.0069444 -> 310 s tidal period
velstd   = 0;
w = slamfat_wind('duration',duration,'velocity_mean',velocity,'velocity_std',velstd);

%% threshold frequency

freq = [0:10:600]; %[0 150:20:600]; %[600 450 300 310 150]; % linspace(-pi,pi,21);
A    = [3]; % 4 5]; %2:6; %0:2:8;

for j = 1:length(A)
    for i = 1:length(freq)
        fname = sprintf('s_freq%d_A%d.mat',freq(i),A(j));
        
        if ~exist(fullfile(pwd,fname),'file')
    
            disp(fname);
            
            clear s;
            s = slamfat('wind',w,'profile',profile,'animate',false,'progress',false);

            source = zeros(length(s.profile),1);
            source(1:20) = 1.5e-4 * w.dt * s.dx;

            s.bedcomposition = slamfat_bedcomposition_basic;
            s.bedcomposition.source             = source;
            s.bedcomposition.grain_size         = .3*1e-3;

            s.max_threshold = slamfat_threshold_basic;
            s.max_threshold.time      = 0:3600;
            
            if freq(i) == 0
                s.max_threshold.threshold = A(j)*0.9549;
            else
                s.max_threshold.threshold = A(j)*sin(s.max_threshold.time/freq(i)*2*pi);
            end

            s.run;

            save(fname,'s');
        end
    end
end

%% plot time series

figure; hold on;

fnames = dir('s_freq*_A3.mat');

n = 0;
for i = 1:length(fnames)
    fname = fnames(i).name;
    
    re = regexp(fname, 's_freq(\d+)_A3.mat', 'tokens');
    
    if ~isempty(re)
        load(fname);
        
        if n == 0
            plot(s.wind.time, s.wind.time_series,'-k');
        end
        
        plot(s.max_threshold.time,max(0,s.max_threshold.threshold),'-r');
        
        disp(mean(max(0,s.max_threshold.threshold)));
        
        n = n + 1;
    end
end

%% plot transport

fnames = dir('s_freq*_A3.mat');

f = [];
T = [];
Tr = [];
Y = [];
n = 1;
for i = 1:length(fnames)
    fname = fnames(i).name;
    
    re = regexp(fname, 's_freq(\d+)_A3.mat', 'tokens');
    
    if ~isempty(re)
        load(fname);
        
        t1 = s.wind.time;
        t2 = s.max_threshold.time;
        
        Y(n) = mean(max(0,s.wind.time_series - interp1(t2,max(0,s.max_threshold.threshold),t1)));
        
        f(n) = str2double(re{1}{1});
        T(n) = s.data.cummulative_transport(end,end);
        Tr(n) = s.data.cummulative_transport(end,end) * mean(max(0,s.max_threshold.threshold));
        Tc(n) = s.data.cummulative_transport(end,end) * mean(max(0,s.max_threshold.threshold)) * Y(n)/Y(1);
        
        n = n + 1;
    end
end

[f, idx] = sort(f);

close all;

figure; hold on;
plot(f/600,T(idx),':k');
plot(f/600,Tr(idx),'-xk');
plot(f/600,Tc(idx),'-xr');
%plot(f/600,Tr(idx)./Tc(idx),'-xg');

xlabel('Threshold period relative to wind period [-]');
ylabel('Transport [m^3/hr]');

%% Aeolian Sand and Sand Dunes By Kenneth Pye, Haim Tsoar

% threshold velocity (Bagnold, 1941)
% u_t = A * sqrt((rho_p - rho_a) * g * D / rho_p)
%
% A     = constant [0.08 - 0.10]
% rho_p = grain density [kg/m^3]
% rho_a = air density [kg/m^3]
% g     = gravitational acceleration [m/s^2]
% D     = grain diameter [m]

% bed slope (Howard, 1977)
% u_ts = F^2 * D * [sqrt(tan(psi)^2 * cos(phi)^2 - sin(ksi)^2 * sin(phi)^2) - cos(ksi) * sin(phi)]
%
% F     = beta * sqrt((rho_p - rho_a) * g / rho_p)
% beta  = constant [0.31]
% psi   = angle of internal friction [-]
% phi   = bed slope [-]
% ksi   = angle between local wind direction and maximum bed slope direction [-]

% bed slope (Howard, 1978)
% u_ts = E * (F/k) * sqrt(D) * [sqrt(tan(psi)^2 * cos(phi)^2 - sin(ksi)^2 * sin(phi)^2) - cos(ksi) * sin(phi)]
%
% E     = constant [-]
% k     = von Karman constant [0.4]

% bed slope (Dyer, 1986)
% u_ts = sqrt(tan(psi) - tan(phi)/tan(psi) - cos(phi))

% surface moisture (Belly, 1964 and Johnson, 1965)
% u_tw = u_t * (1.8 + 0.6 * log(W))
%
% W     = moisture content percentage [0.05% - 4%]

% surface moisture (Hotta et al, 1985) 0.2 - 0.8 mm grain size
% u_tw = u_t + 7.5*W*I_w
%
% I_w   = function for evaporation rate [0 - 1]

% salt crusts (Nickling and Ecclestone, 1981)
% u_t = A * (0.95 * exp(0.1031 * S)) * sqrt((rho_p - rho_a) * g * D / rho_p)
%
% S     = salt content [mg/g]

% evaporation (Penman, 1984 and Shuttleworth, 1993)
% E_m = (m * R_n + gamma * 6.43 * (1 + 0.536 * U_2) * delta) / (lamda_v * (m + gamma))
%
% E_m      = evaporation rate [mm/day]
% m        = slope of the vaporation pressure curve [kPa/K]
% R_n      = net irradiance [MJ/m^2/day]
% gamma    = (0.0016286 * P) / lambda_v = psychrometric constant [kPa/K]
% U_2      = wind speed [m/s]
% delta    = vapor pressure deficit [kPa]
% lambda_v = latent heat of vaporation [MJ/kg]