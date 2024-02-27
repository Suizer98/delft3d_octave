function handles=ddb_ModelMakerToolbox_XBeach_generateTransects(handles)

% Settings
dxmin = handles.toolbox.modelmaker.dX;
dxmax = handles.toolbox.modelmaker.dxmax;
Tmean = handles.toolbox.modelmaker.Tp/1.1;
depthneeded  = handles.toolbox.modelmaker.depth;
D50 = handles.toolbox.modelmaker.D50;
tsimulation = handles.model.xbeach.domain(1).tstop;
ntransects = handles.toolbox.modelmaker.xb_trans.ntransects;
mainfolder = pwd;

try
for ii = 1:ntransects
    
    %% Get zline
    error = 0;
    try
    [handles] = ddb_ModelMakerToolbox_XBeach_quickMode_Ztransects(handles, ii, 0);
    catch
    error = 1;    
    end
    if error == 1;
        ddb_giveWarning('text',['Something went wrong with drawing the transects. Make sure the bathy has information in this area or bathy is above MSL']);
    end
    zline = handles.toolbox.modelmaker.xbeach(ii).zline;
    crossshore = handles.toolbox.modelmaker.xbeach(ii).crossshore;

    % Trow away Nans
	id = isnan(zline);
    zline(id) = []; crossshore(id) = [];    
    
    %% Optimalise grid
    [xopt zopt] = xb_grid_xgrid(crossshore, zline, 'dxmin', dxmin, 'dxmax', dxmax, 'Tm', Tmean, 'CFL', 0.7);   
    xori = handles.toolbox.modelmaker.xb_trans.xoff(ii);  xback = handles.toolbox.modelmaker.xb_trans.xback(ii); 
    yori = handles.toolbox.modelmaker.xb_trans.yoff(ii);  yback = handles.toolbox.modelmaker.xb_trans.yback(ii); 
    rotation_applied = handles.toolbox.modelmaker.xb_trans.coast(ii);
    yopt = zeros(1,length(xopt));
    
    % Determine orientation
    dx = (xori-xback);     dy = (yori-yback);
    if dx > 0 && dy < 0 
    xr = xori- sind(rotation_applied)*xopt;
    yr = yori+ cosd(rotation_applied)*xopt;
    end
    
    if dx < 0 && dy < 0
    xr = xori- sind(360-rotation_applied)*xopt;
    yr = yori+ cosd(360-rotation_applied)*xopt;
    end
    
    if dx > 0 && dy > 0
    xr = xori+ sind(360-rotation_applied)*xopt;
    yr = yori- cosd(360-rotation_applied)*xopt;
    end
    
    if dx < 0 && dy > 0
    xr = xori+ sind(rotation_applied)*xopt;
    yr = yori- cosd(rotation_applied)*xopt;
    end
    
    %% Make first and last three grids cells flat
    nx = length(zopt);
    for jj = 1:3
        zopt(nx-jj+1) = zopt(nx-3);
    end
    for jj = 1:3
        zopt(jj) = zopt(1);
    end
    
    %% Make structure
    
    xbm = xb_generate_model(...
    'bathy',...
            {'x', xr, 'y', yr, 'z', zopt,...
            'world_coordinates',true,...
            'optimize', false}, ...
    'waves',...
            {'Hm0', handles.toolbox.modelmaker.Hs, 'Tp', [handles.toolbox.modelmaker.Tp], 'duration', [tsimulation] 'mainang', [handles.toolbox.modelmaker.waveangle]}, ...
    'tide',... 
            {'time', [0 tsimulation] 'front', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL], 'back', 0},...
    'settings', ...
            {'outputformat','netcdf',... 
            'morfac', 1,...
            'morstart', 0, ...
            'bedfriction', 'manning', ...
            'CFL', handles.model.xbeach.domain(1).CFL,...
            'front', 'abs_1d', ...
            'back', 'abs_1d', ...
            'outputformat', 'netcdf',...
            'dtheta',abs(handles.model.xbeach.domain(1).thetamax - handles.model.xbeach.domain(1).thetamin),...
            'thetanaut', 1, ...
            'tideloc', 1,...
            'tstop', tsimulation, ...
            'tstart', 0,...
            'tintg', tsimulation/100,...
            'tintm', tsimulation/5,...
            'epsi',-1,...                   
            'meanvar',          {'zs', 'H','ue', 've', 'hh'} ,...
            'globalvar',        {'zb', 'zs', 'H', 'ue', 've', 'sedero', 'hh'}});        

    % Create folder
    cd(mainfolder)
    if ii > 99
        filename = ['Transect_', num2str(ii)];
    end
    if ii > 9
        filename = ['Transect_0', num2str(ii)];
    else
        filename = ['Transect_00', num2str(ii)];
    end
    mkdir(filename); cd(filename);
    modeldirs{ii} = [mainfolder, '\', filename];
        
    % Change grid
    xbm.data(1).value = length(xr)-1;
    xbm.data(2).value = 0;
    xbm.data(3).value = 0;  xbm.data(4).value = 0; 
    xbm.data(7).value.data.value = xr;
    xbm.data(8).value.data.value = yr;

    % Fix
    xgrid                   = xs_get(xbm,'xfile.xfile');
    ygrid                   = xs_get(xbm,'yfile.yfile');
    zgrid                   = xs_get(xbm,'depfile.depfile');

    zmin = min(min(min(zopt)), depthneeded);
    id = zgrid < zmin; zgrid(id) = zmin;
    id = zgrid > max(max(zopt)); zgrid(id) = max(max(zopt)); % nothing higher than org.

    % Write
    xbm.data(9).value.data.value = zgrid;
    xbm = xs_del(xbm, 'tidelen');

    % G. Write the params
    xb_write_input('params.txt', xbm);  
end

% Save multi-processes run
cd ..
generate_multiprocess_xbeach_runs([handles.model.xbeach.exedir, 'xbeach.exe'],modeldirs, 4,'_run_XBeach_batch.bat')

catch
    ddb_giveWarning('text',['Something went wrong. Try again with different vertices']);
end
end
