function handles=ddb_ModelMakerToolbox_XBeach_generateModel(handles, datasets)

% Settings
xori=handles.toolbox.modelmaker.xOri;
nx=handles.toolbox.modelmaker.nX;
dx=handles.toolbox.modelmaker.dX;
yori=handles.toolbox.modelmaker.yOri;
ny=handles.toolbox.modelmaker.nY;
dy=handles.toolbox.modelmaker.dY;
rot=pi*handles.toolbox.modelmaker.rotation/180;
zmax=handles.toolbox.modelmaker.zMax;
dmin=min(dx,dy);

% Find coordinates of corner points
x(1)=xori;
y(1)=yori;
x(2)=x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
y(2)=y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
x(3)=x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
y(3)=y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
x(4)=x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
y(4)=y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);

xl(1)=min(x);
xl(2)=max(x);
yl(1)=min(y);
yl(2)=max(y);
dbuf=(xl(2)-xl(1))/20;
xl(1)=xl(1)-dbuf;
xl(2)=xl(2)+dbuf;
yl(1)=yl(1)-dbuf;
yl(2)=yl(2)+dbuf;

coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

% Get bathymetry in box around model grid
%% Option 1: use only the active bathy
if isempty(datasets)
    
    % Extract
    [xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
    
    % xx and yy are in coordinate system of bathymetry (usually WGS 84)
    % convert bathy grid to active coordinate system
    if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
        dmin=min(dx,dy);
        [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
        [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
        zz=interp2(xx,yy,zz,xgb,ygb);
    else
        xg=xx;
        yg=yy;
    end
    % Make grid
    [x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,100,xg,yg,zz);
else
    
    %% Option 2: use multiple datasets
    % Grid coordinates and type
    [x0,y0]=meshgrid(0:dx:nx*dx,0:dy:ny*dy);
    if rot~=0
        r=[cos(rot) -sin(rot) ; sin(rot) cos(rot)];
        for i=1:size(x0,1)
            for j=1:size(x0,2)
                v0=[x0(i,j) y0(i,j)]';
                v=r*v0;
                x(i,j)=v(1);
                y(i,j)=v(2);
            end
        end
    else
        x=x0;
        y=y0;
    end
    x=x+xori;
    y=y+yori;
    z = ones(size(x));
    gridtype='structured';
    
    % Generate bathymetry
    [x,y,z]=ddb_ModelMakerToolbox_generateBathymetry(handles,x,y,z,datasets,'filename','tst','overwrite',1,'gridtype',gridtype,'modeloffset',0);
    
    % Retrieve FAST bathy
    if handles.toolbox.modelmaker.bathymetry.intertidalbathy == 1
        
        % Get data
        try
            [x,y,zFAST] = ddb_FAST_bathy(x,y,handles.screenParameters.coordinateSystem);
            
            % Show data
            figure(20)
            pcolor(x,y,z); title('Bathymetry without FAST'); shading flat;
            xlabel('x [m]'); ylabel('y [m]'); grid on; box on; colorbar;
            
            figure(21)
            pcolor(x,y,zFAST); title('Intertidal bathymetry map FAST'); shading flat;
            xlabel('x [m]'); ylabel('y [m]'); grid on; box on; colorbar;
            
            % Combine
            znew = zFAST;
            id = isnan(znew);
            znew(id) = z(id);
            
            % Smooth
            [ny, nx] = size(z);
            for ii = 1:ny
                znew1(ii,:) = fastsmooth(znew(ii,:), round(nx/20), 1,1);
            end
            for ii = 1:nx
                znew2(:,ii) = fastsmooth(znew(:,ii), round(ny/20), 1,1);
            end
            znew = znew1*0.5 + znew2*0.5;
            
            figure(22)
            pcolor(x,y,znew); title('Combined bathymetry'); shading flat;
            xlabel('x [m]'); ylabel('y [m]'); grid on; box on; colorbar;
            z = znew;
        catch
            ddb_giveWarning('text',['Something went wrong with retrieving the FAST data. DDB will continu with the available data']);
        end
    end
end

%% 3. Closure
if handles.toolbox.modelmaker.rotation < 0
    rotation = round(360 + handles.toolbox.modelmaker.rotation);
else
    rotation = round(handles.toolbox.modelmaker.rotation);
end

% Does the data need to be flipped?
zmean1 = mean(z);
zmean2 = mean(z');
[p1,S1,mu1] = polyfit([1:length(zmean1)],zmean1,1);
[p2,S2,mu2] = polyfit([1:length(zmean2)],zmean2,1);

% x with number is org, x2 is used for creation
if p2(1) > 0
    z2 = (z');
    x2 = (x');
    y2 = (y');
else
    z2 = (z);
    x2 = (x);
    y2 = (y);
end
rotation_model = rotation;

% Simulation
tsimulation = handles.model.xbeach.domain.tstop;
depthneeded1 = round((handles.toolbox.modelmaker.Hs*3))*-1;
for ii = 1:100
    [c cg n(ii) k] = wavevelocity(handles.toolbox.modelmaker.Tp, ii);
end
id = find(n < 0.8);
depthneeded2 = id(1);
depthneeded = max(depthneeded1, depthneeded2)*-1;

if handles.toolbox.modelmaker.domain1d == 1;
    xtmp = x; ytmp = y; ztmp = z;
    [ny nx] = size(z2);
    x2 = x2 (round(ny/2),:);
    y2 = y2 (round(ny/2),:);
    z2 = z2 (round(ny/2),:);
end

if handles.toolbox.modelmaker.domain1d == 1
    
    % Optimize grid
    xtmp = x2;
    ytmp = y2;
    ztmp = z2;
    
    % Grid
    crossshore = ((x - x(1,1)).^2 + (y - y(1,1)).^2.).^0.5;
    [xopt zopt] = xb_grid_xgrid(crossshore, z);
    xori = x(1); yori = y(1);
    rotation_applied = rotation_model
    yopt = zeros(1,length(xopt));
    xr = xori+ cosd(rotation_applied)*xopt;
    yr = yori+ sind(rotation_applied)*xopt;
    
    % plotting
    plotting = 0;
    if plotting == 1;
        figure; hold on;
        plot(x,y)
        plot(xr,yr,'r--')
        plot(x(1),y(1),'bo')
        plot(x(end),y(end),'bo')
        plot(xr(1),yr(1),'bo')
        legend('org', 'opt')
    end
    
    % Make structure
    xbm = xb_generate_model(...
        'bathy',...
        {'x', xr, 'y', yr, 'z', zopt,...
        'world_coordinates',true,...
        'optimize', false}, ...
        'waves',...
        {'Hm0', [handles.toolbox.modelmaker.Hs], 'Tp', [handles.toolbox.modelmaker.Tp], 'duration', [tsimulation+1] 'mainang', handles.toolbox.modelmaker.waveangle}, ...
        'tide',...
        {'time', [0 tsimulation+1] 'front', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL], 'back', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL]},...
        'settings', ...
        {'outputformat','netcdf',...
        'morfac', 1,...
        'bedfriction', 'manning', ...
        'outputformat', 'netcdf',...
        'front', 'abs_1d', ...
        'back', 'abs_1d', ...
        'dtheta',abs(handles.model.xbeach.domain.thetamax - handles.model.xbeach.domain.thetamin),...
        'thetanaut', 1, ...
        'tstop', tsimulation+1, ...
        'tstart', 0,...
        'tintg', tsimulation/10,...
        'tintm', tsimulation/1,...
        'globalvar',      {'zb', 'zs', 'H', 'u', 'v'} ,...
        'meanvar',        {'zb', 'zs', 'H', 'u', 'v', 'sedero', 'qx', 'hh'}});
    
    
    % Change grid
    xbm = xs_del(xbm, 'xori'); xbm = xs_del(xbm, 'yori');   xbm = xs_del(xbm, 'dx');
    xbm = xb_bathy2input(xbm, xr, yr, zopt); xbm = xs_set(xbm, 'vardx', 1);
    
else
    
    % Optimize grid
    xtmp    = x2;
    ytmp    = y2;
    ztmp    = z2;
    
    % Make
    xbm = xb_generate_model(...
        'bathy',...
        {'x', xtmp, 'y', ytmp, 'z', ztmp,...
        'xgrid', {'dxmin',dx, 'dxmax', handles.toolbox.modelmaker.dxmax},...
        'ygrid', {'dymin',dy, 'dymax', handles.toolbox.modelmaker.dymax, 'area_size', handles.toolbox.modelmaker.areasize/100},...
        'rotate', rotation_model,...
        'crop', false,...
        'world_coordinates',true,...
        'finalise', {'actions', {'seaward_flatten', 'seaward_extend'},'zmin',depthneeded}}, ...
        'waves',...
        {'Hm0', [handles.toolbox.modelmaker.Hs], 'Tp', [handles.toolbox.modelmaker.Tp], 'duration', [tsimulation+1] 'mainang', handles.toolbox.modelmaker.waveangle}, ...
        'tide',...
        {'time', [0 tsimulation+1] 'front', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL], 'back', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL]},...
        'settings', ...
        {'outputformat','netcdf',...
        'morfac', 1,...
        'bedfriction', 'manning', ...
        'front', 'abs_2d', ...
        'back', 'abs_2d', ...
        'dtheta',10,...
        'thetanaut', 1, ...
        'tstop', tsimulation+1, ...
        'outputformat', 'netcdf',...
        'tstart', 0,...
        'tintg', tsimulation/10,...
        'tintm', tsimulation/1,...
        'globalvar',      {'zb', 'zs', 'H', 'u', 'v'} ,...
        'meanvar',        {'zb', 'zs', 'H', 'u', 'v', 'sedero', 'qx', 'hh'}});
end
xbm = xs_del(xbm, 'tidelen');

% Fix
xgrid                   = xs_get(xbm,'xfile.xfile');
ygrid                   = xs_get(xbm,'yfile.yfile');
zgrid                   = xs_get(xbm,'depfile.depfile');

zmin = min(min(min(z)), depthneeded);
id = zgrid < zmin; zgrid(id) = zmin;
id = zgrid > max(max(z)); zgrid(id) = max(max(z)); % nothing higher than org.

% Fix theta
xbm = xs_set(xbm, 'thetamin', handles.model.xbeach.domain(1).thetamin);
xbm = xs_set(xbm, 'thetamax', handles.model.xbeach.domain(1).thetamax);
xbm = xs_set(xbm, 'dtheta',10);
xbm = xs_set(xbm, 'gridform', 'xbeach');

% Lateral
gridcelss = 5;
if handles.toolbox.modelmaker.domain1d ~= 1
    [nx ny] = size(zgrid);
    for i = 1:gridcelss-1
        zgrid(i,:) = zgrid(gridcelss,:);
        zgrid(nx-i+1,:) = zgrid(nx-gridcelss,:);
    end
end

% Back
[nx ny] = size(zgrid);
for i = 1:gridcelss-1
    zgrid(:,ny-i+1) = zgrid(:,ny-gridcelss);
end

% Write
for xijn = 1:length(xbm.data)
    namesinxbm{xijn} = xbm.data(xijn).name;
end
indicesneeded = find(strcmp(namesinxbm, 'depfile'));
xbm.data(indicesneeded).value.data.value = zgrid;

% G. Write the params
xb_write_input('params.txt', xbm);

% Write also the grid and bathy as Delft3D
try
    enc=ddb_enclosure('extract',xgrid',ygrid');
    ddb_wlgrid('write','FileName',['grid_D3D.grd'],'X',xgrid','Y',ygrid','Enclosure',enc,'CoordinateSystem','Cartesian');
    ddb_wldep('write','bed_D3D.dep',zgrid'*-1);
catch
end

%% Update model data
handles.model.xbeach.domain(1).depth       = zgrid;
handles.model.xbeach.domain(1).bathymetry  = zgrid;
handles.model.xbeach.domain(1).grid.x      = xgrid;
handles.model.xbeach.domain(1).grid.y      = ygrid;
