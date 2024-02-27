L  = 100;
dx = 1;
dt = .05;

wind = slamfat_wind_old('f_mean',3,'f_sigma',2.5,'dt',dt);

source = zeros(L,1);
source(1:20) = 1.5e-7 * dt * dx;

%%

result = slamfat_core_old('wind',wind,'source',source,'dx',dx,'dt',dt);

slamfat_plot_old(result,'slice',100,'window',100);

%%

figure; hold on;
scatter(result.input.wind(:,1), ...
        result.output.transport(:,end) .* result.input.wind(:,1), ...
        10, double(result.output.supply_limited(:,end)));
    

    
xlabel('Wind speed [m/s]');
ylabel('Concentration in transport [kg/m^2]');

%%

nx = 10;
nf = 2;

bc = bedcomposition;

bc.number_of_columns            = nx;
bc.number_of_fractions          = nf;
bc.bed_layering_type            = 2;
bc.base_layer_updating_type     = 1;
bc.number_of_lagrangian_layers  = 0;
bc.number_of_eulerian_layers    = 3;
bc.diffusion_model_type         = 0;
bc.number_of_diffusion_values   = 5;
bc.flufflayer_model_type        = 0;

bc.initialize

bc.thickness_of_transport_layer     = .1 * ones(1,nx);
bc.thickness_of_lagrangian_layers   = .1;
bc.thickness_of_eulerian_layers     = .3;

% bc.fractions(                           ...
%     [1 1 1 1 1 1 1],               ...
%     [1.18 0.6 0.425 0.3 0.212 0.15 0.063]*1e-3,                  ...
%     [1.3400 1.3400 1.3400 1.3400 1.3400 1.3400 1.3400],                    ...
%     [1600 1600 1600 1600 1600 1600 1600]);

% bc.fractions(                           ...
%     [1 1],               ...
%     [1.18 0.6]*1e-3,                  ...
%     [1.3400 1.3400],                    ...
%     [1600 1600]);

sedtyp      = [1 2];            %sediment type: sand (1) or mud (2)
d50         = [0.2 0.05]*1e-3;  %median grain size [m]
logsigma    = [1.34 1.34];      %parameter in computation porosity, default is 1.34 [-]
rho         = [1600 1600];      %dry bed density [kg/m3]]
rhosol      = [2650 2650];      %bed density [kg/m3]

bc.fractions(sedtyp,d50,logsigma,rho)

dt     = 1;
morfac = 1;

th0 = bc.layer_thickness();
%disp(th0);

lyr0 = bc.layer_mass(:,:,:);
disp(squeeze(lyr0(1,:,:)));
disp(squeeze(lyr0(2,:,:)));

mass = .1 * repmat([1 1],nx,1)'; %mass(2,3:5) = 0.001;
massfluff = zeros(nx,2)';

for i = 1:1
dz = bc.deposit(mass,dt,rhosol,massfluff,morfac);

lyr = bc.layer_mass(:,:,:);
disp(squeeze(lyr(1,:,:)));
disp(squeeze(lyr(2,:,:)));

disp('thickness:')
th = bc.layer_thickness();
disp(th);
end
bc.delete