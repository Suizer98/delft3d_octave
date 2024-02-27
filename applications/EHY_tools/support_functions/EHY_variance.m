function Info =  EHY_variance(zCen,val,varargin)

% Determines mean, variance and PEA (only relevant in case of density) on
% simple profile data
%
%% Initialise
g             = 9.81;
Info.mean     = NaN;
Info.variance = NaN;

OPT.PEA       = false;
OPT           = setproperty(OPT,varargin);
if OPT.PEA Info.PEA = NaN; end

%% Ensure row vectore
if size(zCen,2) == 1 zCen = zCen'; end
if size(val,2)  == 1 val  = val' ; end

%% Restrict to valid points:
zCen = zCen(~isnan(val));
val  = val (~isnan(val));

if ~isempty(val)
    
    %% Lowest point first (might be needed for measurements)
    [~,index] = sort(zCen);
    zCen = zCen(index);
    val  = val (index);
    
    %% Interfaces, Layer Thickness and resulting depth
    if length (zCen) > 1
        zInt      = center2corner1(zCen);
    else
        zInt      = [-100 0];
    end
    dz        = zInt(2:end) - zInt(1:end - 1);
    depth     = zInt(end)   - zInt(1);
    
    %% Mean(weighed)
    Info.mean = sum(dz.*val)/depth;
    
    %% Variance
    Info.variance = sum(dz.*(val - Info.mean).^2)/depth;
    
    %% PEA
    if OPT.PEA
        Info.PEA = -1.*sum(dz.*zCen.*(val - Info.mean))*(g/depth);
    end
end

