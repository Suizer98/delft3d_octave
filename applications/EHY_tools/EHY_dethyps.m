function [area_pol, volume_pol, varargout] = EHY_dethyps(x,y,z,varargin)

% Function EHY_dethyps
% 
% determine hysometric curve inside a polygon based upon scatter data
% positive direction upwards

%% Initialisation
OPT.interface = [];
OPT.spherical = false;
OPT.filePol   = '';
OPT.noLevels  = 100;
OPT           = setproperty(OPT,varargin);

SemiMajorAxis = 6378137;
Eccentricity  = 0.0818191908426215;
WGS84         = [SemiMajorAxis Eccentricity]; % ToDo: retrieve those values from EPSG.mat  

%% Create triangulation network, determine incentres, depth at centers and areas of the triangle 
TR          = delaunayTriangulation(x,y);
centre      = incenter (TR);

%% load the polygon and determine which points inside
if ~isempty(OPT.filePol)
    [pol]     = readldb  (OPT.filePol);
else
    % entire model domain
    index = boundary(x,y,1);
    pol.x = x(index);
    pol.y = y(index);
end

inside    = inpolygon(centre(:,1),centre(:,2),pol.x,pol.y);
CL        = TR.ConnectivityList(inside,:);
centre    = centre(inside,:);
x_tri     = TR.Points(:,1);
y_tri     = TR.Points(:,2);

%% Determine areas and Volumes
no_points = size(CL,1);
for i_pnt = 1: no_points
    if ~OPT.spherical
        area (i_pnt) = polyarea(x_tri(CL(i_pnt,:)),y_tri(CL(i_pnt,:)));
    else
        area (i_pnt) = geodarea(x_tri(CL(i_pnt,:)),y_tri(CL(i_pnt,:)),WGS84);
        area(i_pnt)  = sign(area(i_pnt))*area(i_pnt);
    end
    level(i_pnt) = mean(z(CL(i_pnt,:)));
end

%% Maximum and minimum depth inside polygon
if isempty (OPT.interface)
    min_level = min(level)-0.001;
    max_level = max(level)+0.001;
    OPT.interface = min_level:(max_level - min_level)/OPT.noLevels:max_level;
end
varargout{1}  = OPT.interface;
no_interfaces = length(OPT.interface);

%% Cycle over interfaces
area_pol   (1:no_interfaces) = 0.;
volume_pol (1:no_interfaces) = 0.;
for i_interface = 1: no_interfaces
    
    % Determine areas and volumes inside a polygon below a certain interface
    for i_point = 1: no_points
        if level(i_point) <= OPT.interface(i_interface)
            area_pol   (i_interface) = area_pol   (i_interface) + area (i_point);
            volume_pol (i_interface) = volume_pol (i_interface) + (OPT.interface(i_interface) - level(i_point))*area (i_point);
        end
    end
end
