function [points] = getSteepPoints(xprofile,zprofile,gradmax,zmax,xmin,flag, flag2)
% GETSTEEPPOINTS isolates coordinates of points where the steepness is larger than specified
%
% routine to isolate coordinates of points where the steepness is larger than a predefined value. Optional the search area can be limited by a maximum z-level and a minimum x-location. In addition, there is the possibility to select either only the first (most landward) or the last (most seaward) point with at least the specific steepness.
%
% Syntax:
% [points] = getSteepPoints(xprofile,zprofile,gradmax,zmax,xmin,flag)
%
% Input:
% xprofile = column vector with x-values
% zprofile = column area with z-values
% gradmax  = steepness to look for
% zmax     = maximum level of search area
% xmin     = minimum x-location of search area
% flag     = either 'first' for most landward or 'last' for most seaward point
%
% Output:
% points   = matrix of x-locations (first column) and z-levels (second column)
%
% See also: diff optimiseDUROS
%
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.2, March 2008 (Version 1.0, December 2007)
% By:      <Pieter van Geer and Kees den Heijer    (email: Pieter.vanGeer@deltares.nl / Kees.denHeijer@deltares.nl)>
%--------------------------------------------------------------------------------
 
%% Check input
getdefaults('zmax',-2,1, 'xmin',min(xprofile),1,'gradmax',-1/12.5,1);
flagvals = {'first' 'last' ''};
if exist('flag','var') && sum(strcmpi(flag, flagvals))~=1
    error('GETSTEEPPOINTS:UnknownFlag', 'Unrecognized option.');
end
if exist('flag2','var') && strcmpi(flag2,'exclude ripples')
    excludeRipples = true;
elseif exist('flag2','var') && ~isempty(flag2) && ~strcmpi(flag2,'exclude ripples')
    error('GETSTEEPPOINTS:UnknownFlag', 'Unrecognized option.');
else
    excludeRipples = false;
end


%% find points with gradient larger than gradmax
points=[xprofile(diff(zprofile)./diff(xprofile)<gradmax) zprofile(diff(zprofile)./diff(xprofile)<gradmax)];
if dbstate
    scatter(points(:,1),points(:,2),'*b')
end

%% optional: exclude ripples
if excludeRipples
    for i = 1:size(points,1)
        id = find (xprofile == points(i,1));
        if id+2 <= length(zprofile) % only check points if they are at least more than 1 points away from the seaward end of the profile
            if zprofile(id+2)> zprofile(id+1) % to exclude ripples, check if next two points are descending or equal
                points(i,:) = nan;
            end
            % else: last or one but last point: will be seaward boundary
            % anyway
        end
    end
end

points = points(~isnan(points(:,1)),:);


%% filter for zmax and xmin
points = points(points(:,1)>xmin,:);
points = points(points(:,2)<zmax,:);

if dbstate
    scatter(points(:,1),points(:,2),'or','MarkerFaceColor','r')
end

%% option to select only the first or last occurrence
if size(points,1)>1 && exist('flag','var')
    switch flag
        case 'first'
            points = points(1,:);
        case 'last'
            points = points(end,:);
        case 'all'
            % case all is not necessary, is already in variable
    end
end

%% make points empty if no points are left
if min(size(points)) == 0
    points = [];
end