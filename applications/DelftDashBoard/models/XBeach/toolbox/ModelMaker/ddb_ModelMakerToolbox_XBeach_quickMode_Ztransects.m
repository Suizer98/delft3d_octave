function [handles] = ddb_ModelMakerToolbox_XBeach_quickMode_Ztransects(handles, ii, plotting)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%% Get bathy data
% Find coordinates of corner points
x = [handles.toolbox.modelmaker.xb_trans.xoff(ii) handles.toolbox.modelmaker.xb_trans.xback(ii)];
y = [handles.toolbox.modelmaker.xb_trans.yoff(ii) handles.toolbox.modelmaker.xb_trans.yback(ii)];
dxmin = handles.toolbox.modelmaker.dX;

% Sizes
xl(1)=min(x);
xl(2)=max(x);
yl(1)=min(y);
yl(2)=max(y);
dbuf=(xl(2)-xl(1))/20;
xl(1)=xl(1)-dbuf;
xl(2)=xl(2)+dbuf;
yl(1)=yl(1)-dbuf;
yl(2)=yl(2)+dbuf;


% Coordinate coversion
coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

% Get bathymetry in box around model grid
[xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',10);

% xx and yy are in coordinate system of bathymetry (usually WGS 84)
% convert bathy grid to active coordinate system
if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
    dmin=dxmin;
    [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
    [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
    zz=interp2(xx,yy,zz,xgb,ygb);
else
    xg=xx;
    yg=yy;
end

xline = linspace(x(1), x(2),1000); yline =  linspace(y(1), y(2),1000);
id = ~isnan(zz);    F1 = scatteredInterpolant(xg(id), yg(id), zz(id),'natural', 'none');
zline = F1(xline, yline); zline = naninterp_simple(zline, 1,'nearest');

%% Apply DEM is possible
try
    ~isempty(handles.toolbox.modelmaker.xb_trans.DEM)
    applydem = 1;
catch
    applydem = 0;
end
if applydem == 1;
    [X,Y,Z] = arcgridread(handles.toolbox.modelmaker.xb_trans.DEM);
    id = ~isnan(X);
    F1 = scatteredInterpolant(X(id), Y(id), Z(id), 'natural', 'nearest'); 
    zline2 = F1(xline, yline);
    id1 = zline > 0; id2 = isnan(zline); zline(id1 | id2) = zline2(id1 | id2);
end

depth = min(zline);

%% Create Dean profile
depthneeded  = handles.toolbox.modelmaker.depth;
D50 = handles.toolbox.modelmaker.D50;
D = D50*10^-3;
A = -0.21*D^0.48;
crossshore = ((xline - xline(1,1)).^2 + (yline - yline(1,1)).^2.).^0.5;
xs = linspace(0, max(crossshore)*10, 1000);
h = A*xs.^(2/3);
id = find (h < depthneeded*-1);
xs = xs(1:id(1)); h = h(1:id(1));

if handles.toolbox.modelmaker.dean == 1

    % Apply if Dean
    id = find( zline > 0);
    zline_TMP = zline(id(1):end);
    X_TMP = crossshore(id(1):end); X_TMP = X_TMP - min(X_TMP);
    X_TMP2 = [xs X_TMP+max(xs)+0.01];
    Z_TMP2 = [fliplr(h) zline_TMP];

    % Store
    crossshore = X_TMP2;
    zline = Z_TMP2;

else

    % Check created grid 
    if min(zline) > depthneeded*-1;
        dz = round(abs(depthneeded - min(zline)));

        % Determine slope
        id = find( (depthneeded + min(zline))/2 > h);
        slope = (h(id(1)+1) - h(id(1)) )/  (xs(id(1)+1) - xs(id(1)) );
        slope = -1/slope;

        dx = dz * slope; % slope of 1/100;
        zline = [depthneeded*-1 zline];
        crossshore = [-dx crossshore];
    end
end

%% Get average depth
try
handles.toolbox.modelmaker.Zvalues(ii) = depth;
catch
handles.toolbox.modelmaker.Zvalues(ii) = depth;
end

%% Draw a line
% Delete all figures
if plotting == 0
    for xxx =1 :100
        try
        delete(handles.toolbox.modelmaker.hfigure(xxx))
        end
    end
else
    hfigure(ii) = figure(ii+20); hold on;
    plot(crossshore, zline); title(['Transect ', num2str(ii)]);
    xlabel('cross-shore distance [m]'); ylabel('z_b [m]'); grid on; box on;
    handles.toolbox.modelmaker.hfigure(ii) = hfigure(ii) ;
end

%% Save
handles.toolbox.modelmaker.xbeach(ii).crossshore = crossshore;
handles.toolbox.modelmaker.xbeach(ii).zline = zline;

end

