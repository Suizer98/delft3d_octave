% --------------------------------------
% Script to setup a XBeach model for BOI
% --------------------------------------

clear all
close all

% --- add functions. OET tools also required
addpath('../01_setup')
addpath('../02_analyse')

%% input

% --- boundary conditions
Hs          = 9;
Tp          = 16;
Rp          = 5;
D50         = 240;
tidalampl   = 1;
phaseshift  = 0;

% --- path of simulation
destout = 'referentie';

%% BOI settings

D50 = D50/1000000;

INPUT      = struct(...
                  'WLmax',            Rp,           ...             %	[5 m+NAP]               Max. surge level @ peak
                  'Hsmax',            Hs,           ...             % 	[9 m]                   Sign. wave height @ peak
                  'Tpmax',            Tp,           ...             % 	[12 s]                  Wave peak period @ peak
                  'tidalampl',        tidalampl,       ...          % 	[1 m]                   Tidal amplitude (assuming M2)
                  'phaseshift',       phaseshift,      ...          % 	[3.5 hr]        [* ]    Time difference between tidal peak and surge peak (in hours)
                  'stormlength_wl',   44,           ...             % 	[44 hr]         [* ]    Duration of waterlevel from 0 to peak to 0
                  'stormlength_waves',1.25*44,  ...                 % 	[1.25*44 hr]	[* ]    Duration of waves from 0 to peak to 0
                  'simlength',        44,           ...             % 	[44 hr]         [* ]    Simulation length (centered around storm peak!) - excl. optional shortening of timeseries
                  'msl',              0.,           ...           	% 	[0 m+NAP]       [**]    Mean sea level (excl. WL_addition) [affects wl_tide]
                  'dt',               0.5,          ...             % 	[0.5 hr]        [**]	Resolution of output timesteps (in hours)
                  'Hsmin',            0.5,          ...             %   [.5 m]          [**]	Minimum allowed Hs-value in timeseries [affects storm tails])
                  'Tpmin',            2.            ...             %   [5 s]           [**]	Minimum allowed Tp-value in timeseries [affects storm tails])
                ); 

%% bathy
bathy = readtable('data/Referentie.txt','HeaderLines',12);

% --- get profile
% --- flip: xbeach requires land at the right side. 
x = flip(bathy.x * -1); 
z = flip(bathy.z);

% --- plot domain
fig1 = figure
plot(x,z)
hold on
xlabel('X [m+RSP]'); ylabel('z [m+NAP]'); grid on; 

%% offshore water depth

% --- water depth of boundary conditions
d_profile           = 20;
% --- compute required slope en water depth
[d_start, slope]    = check_profile(Hs, Tp, d_profile);

% --- required bed level (w.r.t. 0 m+NAP)
z_start     = (d_start-Rp)*-1;
% --- offshore water depth
d_offshore = z(1) * -1 + Rp;

plot(x, x*0+z_start,'r-')
plot(x,x*0+Rp,'b')

% --- adjust profile
if d_start > d_offshore
    dz  = z(1)-z_start;
    dx  = dz * 1/slope;
    x   = [x(1)-dx; x];
    z   = [z_start; z];
end




%% grid

[xgr zgr] = xb_grid_xgrid2_boi(x,z,'Tm',Tp,'wl',3,'dxmin',1,'ppwl',40);

% --- add cells. Do not use first dx. It is not always representative for
% the dx.
dx = diff(xgr);
dx = dx(2);

xgr = [xgr(1)-dx*2; xgr(1)-dx; xgr];
zgr = [zgr(1); zgr(1); zgr];


plot(x,z,'-')

plot(xgr, zgr,'--')
legend({'profile','required depth','extended profile','grid'})

%% boundary tide

[time_zs_bc,zs_front_bc,zs_back_bc] =  compute_tide(INPUT,z(end));

% --- duration of simulation
duration = time_zs_bc(end);

% --- plot boundary
fig2 = figure()
subplot(3,1,1)
plot(time_zs_bc/3600, zs_front_bc)
hold on
plot(time_zs_bc/3600, zs_back_bc)
xlim([0 duration(end)/3600])
xlabel('Time [hr]'); grid on
legend({'front','back'})
ylabel('zs')

tide = xb_generate_tide('time', time_zs_bc, 'front', zs_front_bc, 'back', zs_back_bc);

%% boundary waves

[time_bc_waves, Hs_bc, Tp_bc] = compute_waves(INPUT);

waves = xb_generate_waves('Hm0', Hs_bc, 'Tp', Tp_bc, 'duration', Hs_bc*0+3600);

subplot(3,1,2)
plot(time_bc_waves/3600, Hs_bc)
hold on
xlabel('Time [hr]'); grid on
ylabel('H_s [m]')
xlim([0 duration(end)/3600])
subplot(3,1,3)
plot(time_bc_waves/3600, Tp_bc)
hold on
xlabel('Time [hr]'); grid on
ylabel('T_p [s]')
xlim([0 duration(end)/3600])

%% params

% --- Make a structure for the bathymetry data
bathymetry = xb_grid_add('x', xgr','y', xgr*0' ,'z', -1*zgr','posdwn',-1,'xori',0,'yori',0);

% --- output variables
vars = {'zb','zs','sedero','H','zswet'};

% --- Define the parameter settings (and define a structure with the info)
pars = xb_generate_settings('xori',0,'yori',0,...                                  
                            'wavemodel', 'surfbeat',...
                            'front','abs_1d','back','abs_1d',...
                            'snells',0,...
                            'epsi',-1,'dtheta',180,...
                            'D50',D50,'D90',D50*1.5,...
                            'rhos',2650,'rho',1025,...
                            'morfac',4,'morstart',0,...
                            'wetslp',0.15,'facSk',0.15,'facAs',0.2,...
                            'fw',0,'gammax',2,'alpha',1.38,'gamma',0.46,...
                            'beta',0.08,...  
                            'tideloc',2,'zs0file','tide.txt',...
                            'CFL',0.95,...
                            'outputformat','netcdf',...
                            'nglobalvar',vars,'tintg',3600,...  % global output
                            'nmeanvar',vars,'tintm',3600,...                                                    
                            'tstart',0,'tstop',duration);             


% --- Merge the structures
xbm_si = xs_join(bathymetry, pars);
xbm_si = xs_join(xbm_si, tide);
xbm_si = xs_join(xbm_si, waves);

mkdir(destout)

saveas( fig1 , [destout,'\domain.png'] ) 
saveas( fig2 , [destout,'\bc.png'] ) 
xb_write_input([destout,'\params.txt'],xbm_si);
