function  KPZSS_setupXBeachParams(x_Jrk,z_Jrk,Rp_bc,Hs_bc,Tp_bc,D50_bc,dest)
% Setup Xbeach parameters

%% settings
% time settings XBeach
nrTimeSteps = 32;   % digits
timeStep = 3600;    % digits, seconds
spinup = 1200;      % digits, seconds

%% Setup timeseries

% setup timeseries
tstart = spinup;
tstop = tstart+nrTimeSteps*timeStep; %e.g. 32 hours
t = tstart:timeStep:tstop;

%% Setup boundary conditions

% Obtain boundary conditions from local file
D90 = D50_bc * 1.5; % simple assumption

% Create boundary conditions
% cd U:\Matlab\XBeach\Setup\Randvoorwaarden
Rp = computeWaterlevel(t, Rp_bc, spinup);
Tp = computePeriod(t, Tp_bc, spinup);
Hs = computeWaves(t, Hs_bc, spinup);

%% Set up Grid

% set up grid so that starts at x=0 at seaward boundary
x_Jrk = flip(x_Jrk)'; z_Jrk = flip(z_Jrk)';
x_Jrk = (x_Jrk - x_Jrk(1)) .* -1;

% Extend profile to minimum required depth
    %           Het is in deze BOI fase nog in twijfel of dit diepte is 
    %           tov 1) NAP of 2) NAP + max stormvloedpeil of 3) NAP + min
    %           stormvloedpeil (de laatste gebruik ik hier)
[d_start, slope, check] = checkProfile(max(Hs), max(Tp), abs(z_Jrk(1)) + min(Rp));
if isnan(slope)
    x = x_Jrk; z = z_Jrk;
elseif abs(z_Jrk(1)) +  min(Rp) < d_start
    z_tmp = -(d_start-min(Rp));
    x_tmp = x_Jrk(1) +  (z_tmp-z_Jrk(1)) ./ slope;
    x = [x_tmp, x_Jrk];
    z = [z_tmp, z_Jrk];
else
    x = x_Jrk; z = z_Jrk;   
end

% Create xbeach grid for all profiles and extend offshore boundary
[xgr, zgr] = xb_grid_xgrid2(x(:), z(:),'dxmin',1,'ppwl', 40, ...
                            'Tm',min(Tp),'wl', 3); % min(Rp)

%add 4 grid cells seaward to the x and z grids
dx = xgr(2)-xgr(1);
fillx = [xgr(1)-(dx*4) xgr(1)-(dx*3) xgr(1)-(dx*2) xgr(1)-(dx*1)];
fillz = [zgr(1) zgr(1) zgr(1) zgr(1)];
xgr = [fillx xgr'];
zgr = [fillz zgr'];

%% save Jarkus data and boundary files

if ~exist([dest, '\Jarkus'],'dir'); mkdir([dest, '\Jarkus']); end
if ~exist([dest, '\input'],'dir'); mkdir([dest, '\input']); end
writematrix(x_Jrk', [dest, '\Jarkus\xJrk.txt']);
writematrix(z_Jrk', [dest, '\Jarkus\zJrk.txt']);
writematrix([Rp_bc; Hs_bc; Tp_bc; D50_bc], [dest, '\Jarkus\randvoorwaarden.txt']);

%% Set-up XBeach input file

% add bathyemtry in Xbeach file
bathymetry = xb_grid_add('x', xgr, 'z', zgr);

% Create XBeach setup file 
xs = xs_empty();
xs1 = xs_set(xs,'wavemodel', 'surfbeat',...
            'wbctype', 'jonstable','bcfile', 'jonswap.txt',... 
            'epsi', -1, 'tidetype', 'hybrid',... %for constant conditions, epsi=0
            'tideloc',2, 'zs0file', 'tide.txt',...
			... % Grid parameters
            'left', 'wall', 'right', 'wall',...
            'random', 1, 'nx',length(xgr)-1,'ny',0,...
            'alfa', 0, 'yori', 0,...
            'thetamin',-90, 'thetamax',90,'dtheta',180,...
			... % Transport and morphology on
            'sedtrans', 1, 'morphology', 1,...
            ... % Sediment
            'D50',D50_bc,'D90',D90,...
            ... % Flow
            'bedfriction','Manning','bedfriccoef', 0.02,...
            ... % Sediment transport and morphology
            'waveform', 'vanthiel',...
            'facAs', 0.25, 'facSk', 0.15, 'wetslp', 0.18,... 
            ... % Wave breaking
            'break', 'roelvink_daly','gamma', 0.46, 'gamma2', 0.34,...
			'alpha', 1.38, 'beta', 0.08,... 
			... % General 
			...% 'alphad50',1.6,'wbcScaleEnergy',0,'wbcRemoveStokes',0,... % NEW PARAMETER FOR XBeach version (5846)
			'wbcEvarreduce', 0.3, 'fixedavaltime', 0,'snells',1,...
            'nuhfac', 0,'CFL',0.95,...
			... % Computational reduction morphology
			'morfac',4,... % In calibration proces, morfac was set at 1
            ... % Other parameters
			'single_dir',0,...
            'tstart', tstart, 'tstop', tstop, 'morstart', tstart,...
            'oldhmin', 0, 'oldTsmin', 0, 'deltahmin', 0.1,...
			... % Output parameters
            'outputformat', 'netcdf', 'tintm', timeStep, 'tintg', timeStep,...%output
            'globalvariables', {'H', 'u', 'zs', 'zb'},... 
            'meanvariables', {'H', 'u', 'zs', 'zb'});

% join bathymetry in the file
xs2 = xs_join(bathymetry, xs1);

% write jonswap.txt to a single file
xb_write_input([dest '\input\params.txt'],xs2); 
fileID = fopen([dest '\input\' 'jonswap.txt'], 'w');
fprintf(fileID, '%f %f %f %f %f %f %f \n', [Hs(1) Tp(1) 270 3.3 6 tstart 1]);
for it=1:length(t)
    fprintf(fileID, '%f %f %f %f %f %f %f \n', [Hs(it) Tp(it) 270 3.3 6 3600 1]);
end
fclose(fileID);

% append water level land side to tide.txt
wlev_land = min(zgr(end)-0.5, min(Rp)) * ones(1,length(t));
fid=fopen([dest '\input\' 'tide.txt'],'w');
fprintf(fid, '%f %f %f \n', [0 Rp(1) wlev_land(1)]);
fprintf(fid, '%f %f %f \n', [t' Rp' wlev_land']');
fclose(fid);

% save whether the 'checkprofile' displayed an error
% fid2=fopen([dest '\' 'check.txt'],'w');
% fprintf(fid2, '%d', check);
% fclose(fid2);

    
end