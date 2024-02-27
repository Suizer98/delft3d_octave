function [Volume, result, Boundaries, Redefined] = jarkus_getVolume(varargin)
% JARKUS_GETVOLUME   generic routine to determine volumes on transects
%
%   Routine determines volumes on transects. In case of no second profile (x2, z2),
%   the volume above the lowerboundary, below the profile (x, z) and eventually the upperboundary,
%   and between the landwardboundary and seawardboundary will be computed.
%   In case of a second profile (x2, z2), the volume between the two
%   profiles will be computed, eventually confined by one or more
%   boundaries. Where profile 2 is below profile 1, the volume will be
%   considered as erosion (negative). Where profile 2 is above profile 1,
%   the volume will be considered as accretion (positive).
%   The horizontal boundaries (UpperBoundary and LowerBoundary) do not
%   have to be straight (the x-coordinates of these boundaries have to be ascending).
%   Input can specified in the order of the input list below, or as PropertyName 
%   PropertyValue pairs (or combined, propertyName propertyValue pairs at the end).
%
%   syntax:
%   [Volume, result, Boundaries, Redefined] =
%   getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, x2, z2)
%
%   input:
%       x                   = column array with x points (increasing index and positive x in seaward direction)
%       z                   = column array with z points
%       UpperBoundary       = upper horizontal plane of volume area (not specified please enter [] as argument)
%       LowerBoundary       = lower horizontal plane of volume area (not specified please enter [] as argument)
%       LandwardBoundary    = landward vertical plane of volume area (not specified please enter [] as argument)
%       SeawardBoundary     = seaward vertical plane of volume area (not specified please enter [] as argument)
%       x2                  = column array with x2 points (increasing index and positive x in seaward direction)
%       z2                  = column array with z2 points
%       propertyname propertyvalue pairs:
%           plot                            boolean (true/false)
%           suppressMessEqualBoundaries     boolean (true/false)
%           suppressMessAdaptedBoundaries   boolean (true/false)
%
%   Output:
%   Volume     = resulting volume
%   result     = structure containing the results
%   Boundaries = structure containing the boundary information
%   Redefined  = structure containing booleans showing whether variables
%                   are redefined within this function
%
%   Example
%   jarkus_getVolume
%
%   See also createEmptyDUROSResult, jarkus_getVolumeFast

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 24 Apr 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: jarkus_getVolume.m 13857 2017-10-27 10:07:23Z l.w.m.roest.x $
% $Date: 2017-10-27 18:07:23 +0800 (Fri, 27 Oct 2017) $
% $Author: l.w.m.roest.x $
% $Revision: 13857 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_getVolume.m $
% $Keywords: $

tic;
%% check and inventorise input
% input can be specified directly, provided that the order of the input
% arguments corresponds with propertyName (specified below), or as
% propertyName propertyValue pairs. Also a combination is possible as long
% as it starts with direct input (in the right order), followed by
% propertyName propertyValue pairs (regardless of order).

% derive identifier of the argument just before the first propertyName or 
% alternatively the identifier of the last input argument (if no
% propertyName propertyValue pairs are used)
idPropName = [cellfun(@ischar, varargin) true];
id = find(idPropName, 1, 'first')-1;

% define propertyNames and (default) propertyValues (most are empty by default)
propertyName = {...
    'x'...
    'z'...
    'UpperBoundary'...
    'LowerBoundary'...
    'LandwardBoundary'...
    'SeawardBoundary'...
    'x2'...
    'z2'...
    'plot'...
    'suppressMessEqualBoundaries'...
    'suppressMessAdaptedBoundaries'};
propertyValue = [...
    varargin(1:id)...
    repmat({[]}, 1, length(propertyName)-id-2) false true];

% create property structure, including the directly specified input
OPTstructArgs = reshape([propertyName; propertyValue], 1, 2*length(propertyName));
OPT = struct(OPTstructArgs{:});

% update property structure with input specified as propertyName
% propertyValue pairs
OPT = setproperty(OPT, varargin{id+1:end});

Redefined = cell2struct(repmat({[]}, size(fieldnames(OPT))), fieldnames(OPT));

inputSize = structfun(@size, OPT,...
    'UniformOutput', false);

%% input check
inputAdjusted = false;
if sum(inputSize.x) ~= sum(inputSize.z)
    error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must be of same size');
end

if sum(inputSize.x) <= 2 || all(inputSize.x ~= 1)
    error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must be vectors');
end

if any(isnan(OPT.z))
    % remove NaNs
    ZnonNaN = ~isnan(OPT.z);
    [OPT.x, OPT.z] = deal(OPT.x(ZnonNaN), OPT.z(ZnonNaN));
    
    % check whether the remaining non-NaN part is still a vector
    if sum(size(OPT.x)) <= 2
        error('GETVOLUME:SizeInputs', 'Input arguments "x" and "z" must contain at least two non-NaN data points.');
    end
    inputAdjusted = true;
end

if sum(inputSize.x2) ~= sum(inputSize.z2)
    error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must be of same size');
end

if isscalar(OPT.x2)
    % x2 and z2 must be either empty or vector
    error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must be vectors');
end

if any(isnan(OPT.z2))
    % remove NaNs
    Z2nonNaN = ~isnan(OPT.z2);
    [OPT.x2, OPT.z2] = deal(OPT.x2(Z2nonNaN), OPT.z2(Z2nonNaN));
    
    % check whether the remaining non-NaN part is still a vector
    if sum(size(OPT.x2)) <= 2
        error('GETVOLUME:SizeInputs', 'Input arguments "x2" and "z2" must contain at least two non-NaN data points.');
    end
    inputAdjusted = true;
end

for var = {'x' 'z' 'x2' 'z2'}
    if sign(diff(inputSize.(var{1}))) == 1 % in case of rows
        OPT.(var{1}) = OPT.(var{1})';
        inputAdjusted = true;
    end
end

if inputAdjusted
    inputSize = structfun(@size, OPT,...
        'UniformOutput', false);
end

% create separate variables (conform old version of getVolume) out of the OPT-structure
finalInput = struct2cell(OPT);
[x, z, UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary, x2, z2] = deal(finalInput{1:8});

result = createEmptyDUROSResult;

%% determine Upper and Lower boundaries and set LandwardBoundary and SeawardBoundary
x_min = min(x); x_max = max(x);
if inputSize.UpperBoundary(1)>1; x_min = max([x_min min(UpperBoundary(:,1))]); x_max = min([x_max max(UpperBoundary(:,1))]); end
if inputSize.LowerBoundary(1)>1; x_min = max([x_min min(LowerBoundary(:,1))]); x_max = min([x_max max(LowerBoundary(:,1))]); end
if inputSize.LandwardBoundary(1)>1; LandwardBoundary = LandwardBoundary(1,1); end
if inputSize.SeawardBoundary(1)>1; SeawardBoundary = SeawardBoundary(1,1); end
if inputSize.x2(1)>1; x_min = max([x_min min(x2)]); x_max = min([x_max max(x2)]); end
if isempty(LandwardBoundary)
    LandwardBoundary = x_min;
elseif x_min > LandwardBoundary
    % one or both profiles do not reach the landward boundary
    LandwardBoundary = x_min;
    inputSize.LandwardBoundary(:) = size(LandwardBoundary);
    if ~OPT.suppressMessAdaptedBoundaries
        warning('JARKUS_GETVOLUME:newboundary', 'Landward boundary adapted')
    end
    Redefined.LandwardBoundary = true;
elseif isempty(LandwardBoundary)
    LandwardBoundary = x_min;    
end
if isempty(SeawardBoundary)
    SeawardBoundary = x_max;
elseif x_max < SeawardBoundary
    % one or both profiles do not reach the seaward boundary
    SeawardBoundary = x_max;
    inputSize.SeawardBoundary(:) = size(SeawardBoundary);
    if ~OPT.suppressMessAdaptedBoundaries
        warning('JARKUS_GETVOLUME:newboundary', 'Seaward boundary adapted')
    end
    Redefined.SeawardBoundary = true;
elseif isempty(SeawardBoundary)
    SeawardBoundary = x_max;
end

if LandwardBoundary == SeawardBoundary
    result.xActive = LandwardBoundary;
    [result.z2Active, result.zActive] = deal(interp1(OPT.x, OPT.z, LandwardBoundary));
    [idLand, idSea] = deal(OPT.x<min(result.xActive), OPT.x>max(result.xActive));
    [result.xLand, result.zLand, result.xSea, result.zSea] = deal(OPT.x(idLand), OPT.z(idLand), OPT.x(idSea), OPT.z(idSea));
    [result.Volumes.Volume, Volume, result.Volumes.Accretion, result.Volumes.Erosion] = deal(0);
    result.info.time = toc;
    [Boundaries.Upper, Boundaries.Lower, Boundaries.Landward, Boundaries.Seaward] = deal(UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary);
    if ~OPT.suppressMessEqualBoundaries
        writemessage(-3, 'LandwardBoundary and SeawardBoundary are equal');
    end
    return
end;

%% set UpperBoundary and LowerBoundary
if inputSize.UpperBoundary(1)<2 && inputSize.UpperBoundary(2)<2
    z_max = min([max([max(z) max(z2)]) UpperBoundary]);
    UpperBoundary = [LandwardBoundary SeawardBoundary; z_max z_max]';
elseif inputSize.UpperBoundary(1)==1 && inputSize.UpperBoundary(2)==2
    z_max = min([max([max(z) max(z2)]) UpperBoundary(1,2)]);
    UpperBoundary = [LandwardBoundary SeawardBoundary; z_max z_max]';
end
inputSize.UpperBoundary(:) = size(UpperBoundary);

if inputSize.LowerBoundary(1)==0 && inputSize.LowerBoundary(2)==0
    z_min = max([min([min(z) min(z2)]) LowerBoundary]);
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
elseif inputSize.LowerBoundary(1)==1 && inputSize.LowerBoundary(2)==1
    z_min = LowerBoundary;
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
elseif inputSize.LowerBoundary(1)==1 && inputSize.LowerBoundary(2)==2
    z_min = min([min([min(z) min(z2)]) LowerBoundary(1,2)]);
    LowerBoundary = [LandwardBoundary SeawardBoundary; z_min z_min]';
end
inputSize.LowerBoundary(:) = size(LowerBoundary);

%% get intersections of profiles with x-boundaries and strip profiles
[x, z] = removeDoublePoints(x, z);
z_new = interp1(x, z, [LandwardBoundary SeawardBoundary]);
z = [z_new(1); z(x>LandwardBoundary & x<SeawardBoundary); z_new(2)];
x = [LandwardBoundary; x(x>LandwardBoundary & x<SeawardBoundary); SeawardBoundary];
if inputSize.UpperBoundary(1)>=2 % MvK 06-04-2008: '=' added because points should be added also when UpperBoundary is a horizontal line 
    z_new = interp1(UpperBoundary(:,1), UpperBoundary(:,2), [LandwardBoundary SeawardBoundary]);
    ids = UpperBoundary(:,1)>LandwardBoundary & UpperBoundary(:,1)<SeawardBoundary;
    UpperBoundary = [LandwardBoundary z_new(1); UpperBoundary(ids,:); SeawardBoundary z_new(2)];
end
if inputSize.LowerBoundary(1)>=2 % MvK 06-04-2008: '=' added because points should be added also when LowerBoundary is a horizontal line 
    z_new = interp1(LowerBoundary(:,1), LowerBoundary(:,2), [LandwardBoundary SeawardBoundary]);
    ids = LowerBoundary(:,1)>LandwardBoundary & LowerBoundary(:,1)<SeawardBoundary;
    LowerBoundary = [LandwardBoundary z_new(1); LowerBoundary(ids,:); SeawardBoundary z_new(2)];
end
if ~isempty(x2)
    [x2, z2] = removeDoublePoints(x2, z2);
    id(1) = find(x2<=LandwardBoundary, 1, 'last' );
    id(2) = find(x2>=SeawardBoundary, 1 );
    z2_new = interp1(x2(id(1):id(2)), z2(id(1):id(2)), [LandwardBoundary SeawardBoundary]);
    z2 = [z2_new(1); z2(x2>LandwardBoundary & x2<SeawardBoundary); z2_new(2)];
    x2 = [LandwardBoundary; x2(x2>LandwardBoundary & x2<SeawardBoundary); SeawardBoundary];
end;

%% find intersections, create common x-grid and derive the accompanying z-values
% first match xgrid of upper and lower boundaries
[xcr, zcr, UpperBoundary_new(:,1), UpperBoundary_new(:,2), LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(UpperBoundary(:,1), UpperBoundary(:,2), LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
[UpperBoundary, LowerBoundary] = deal(UpperBoundary_new, LowerBoundary_new); clear UpperBoundary_new LowerBoundary_new
% now match upper boundary with x and z (this will include crossing points)
[xcr, zcr, x, z, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x, z, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
[UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
% now match lower boundary with x and z (this might include crossing points that are not yet in upper boundary)
[xcr, zcr, x, z, LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(x, z, LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
[LowerBoundary] = deal(LowerBoundary_new); clear LowerBoundary_new
% to make sure lower, upper and x and z contain all points match upper with x, z once more (this will NOT include new crossings so no further updating is needed)
[xcr, zcr, x, z, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x, z, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
[UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new

if ~isempty(x2) % now if also an x2 and z2 are available match those too
    % first match x and z with z2 and z2
    [xcr, zcr, x, z, x2, z2] = findCrossings(x, z, x2, z2,'synchronizegrids');
    % now match upper boundary with x2 and z2 (this will include crossing points)
    [xcr, zcr, x2, z2, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x2, z2, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
    [UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
    % now match lower boundary with x2 and z2 (this might include crossing points that are not yet in upper boundary)
    [xcr, zcr, x2, z2, LowerBoundary_new(:,1), LowerBoundary_new(:,2)] = findCrossings(x2, z2, LowerBoundary(:,1), LowerBoundary(:,2),'synchronizegrids');
    [LowerBoundary] = deal(LowerBoundary_new); clear LowerBoundary_new

    % to make sure lower, upper and x2 and z2 contain all points match
    % upper with x2, z2 once more (this will NOT include new crossings so no further updating is needed)
    [xcr, zcr, x2, z2, UpperBoundary_new(:,1), UpperBoundary_new(:,2)] = findCrossings(x2, z2, UpperBoundary(:,1), UpperBoundary(:,2),'synchronizegrids');
    [UpperBoundary] = deal(UpperBoundary_new); clear UpperBoundary_new
    % to make sure x and z and x2 and z2 contain all points match x, z with x2, z2 once more (this will NOT include new crossings so no further updating is needed)
    [xcr, zcr, x, z, x2, z2] = findCrossings(x, z, x2, z2,'synchronizegrids');
end



%% create columns containing all z-values available
% add z values related to: x, upper, lower
Z = [z UpperBoundary(:,2) LowerBoundary(:,2)];
% if exists add z values related to: x2
if ~isempty(x2)
    Z = [Z z2];
end

%% determine Zlimits (find out what lies over what)
if isempty(x2)
    Zlimits = Z(:,[3 1]); % lower limit = LowerBoundary; upper limit = z
    ids = Z(:,2)<=Z(:,1);
    Zlimits(ids,2) = Z(ids,2); % replace z by UpperBoundary in areas where the UpperBoundary is below the z
    ids = Zlimits(:,2)<=Zlimits(:,1);
    Zlimits(ids,2) = Zlimits(ids,1); % replace resulting upper limit by LowerBoundary in areas where the upper limit is below the LowerBoundary
else
    Zlimits = Z(:,[1 4]); % lower limit = z; upper limit = z2
    ids = Z(:,2)<=Z(:,1);
    Zlimits(ids,1) = Z(ids,2); % replace z by UpperBoundary in areas where the UpperBoundary is below the z
    ids = Z(:,2)<=Z(:,4);
    Zlimits(ids,2) = Z(ids,2); % replace z2 by UpperBoundary in areas where the UpperBoundary is below the z2
    ids = Z(:,3)>=Z(:,1);
    Zlimits(ids,1) = Z(ids,3); % replace z by LowerBoundary in areas where the LowerBoundary is above the z
    ids = Z(:,3)>=Z(:,4);
    Zlimits(ids,2) = Z(ids,3); % replace z2 by LowerBoundary in areas where the LowerBoundary is above the z2
end

%% get the volume
diffX = diff(x);
Xvolume = zeros(length(diffX),1);
volume = zeros(length(diffX),1);
for i = 1:length(diffX)
    volume(i,1) = (mean(Zlimits(i:i+1,2))-mean(Zlimits(i:i+1,1)))*diffX(i);
    Xvolume(i) = mean(x(i:i+1));
end

% [OPT.x, OPT.z] = deal(x, z);

[idLand, idSea] = deal(OPT.x<min(x), OPT.x>max(x));
[result.xLand, result.zLand, result.xActive, result.zActive, result.z2Active, result.xSea, result.zSea] = deal(OPT.x(idLand), OPT.z(idLand), x, Zlimits(:,1), Zlimits(:,2), OPT.x(idSea), OPT.z(idSea));
[Volume, result.Volumes.Volume] = deal(sum(volume));
[result.Volumes.volumes, result.Volumes.Accretion, result.Volumes.Erosion] = deal(volume, sum(volume(volume>0)), -sum(volume(volume<0)));
result.info.time = toc;
[Boundaries.Upper, Boundaries.Lower, Boundaries.Landward, Boundaries.Seaward] = deal(UpperBoundary, LowerBoundary, LandwardBoundary, SeawardBoundary);

%% Plot the result
if OPT.plot;%dbstate
    figure;clf;hold on
    lh(1) = plot(UpperBoundary(:,1),UpperBoundary(:,2),'-oc');
    lh(2) = plot(LowerBoundary(:,1),LowerBoundary(:,2),'-dg');
    lh(3) = plot([SeawardBoundary SeawardBoundary],get(gca,'YLim'),'m');
    lh(4) = plot([LandwardBoundary LandwardBoundary],get(gca,'YLim'),'y');
    try
        lh(5) = plot(x,z,'-xk');
        lh(6) = plot(x2,z2,':+r');
        lh(7) = plot(OPT.x,OPT.z,'pk');
        lh(8) = plot(OPT.x2,OPT.z2,'hr');
    end
    hold on
    color = {'b'};
    for i = 1 : length(result)
        if ~isempty(result(i).z2Active)
            volumepatch = [result(i).xActive' fliplr(result(i).xActive'); result(i).z2Active' fliplr(result(i).zActive')]';
            hp(i) = patch(volumepatch(:,1), volumepatch(:,2), ones(size(volumepatch(:,2)))*-(length(result)-i),color{i},'edgeColor','none');
        end
    end
    legendtxt = {'Upperboundary','Lowerboundary','Seawardboundary','Landwardboundary','Profile','Profile 2','Data 1','Data 2'};
    l = legend(lh,legendtxt,'location','northwest');
    set(l,'fontsize',8,'fontweight','bold');
    legend  boxoff;

    set(gca,'XDir','reverse')
    xlabel('Crossshore location (m wrt RSP)');
    ylabel('Profile height (m wrt NAP)', 'Rotation', 270, 'VerticalAlignment', 'top');
    box on
%     dbstopcurrent
end

%%
function [x, z] = removeDoublePoints(x, z)
[x, sortid] = sort(x);
z = z(sortid);

threshold = 1e-10;
if length(unique(x))~=length(x)
    xz = unique([x z], 'rows');
    if size(xz,1)==length(unique(x))
        [x, z] = deal(xz(:,1), xz(:,2));
    else
        ids = find(diff(x)==0);
        for idd = 1:length(ids)
            id=ids(idd);
            if id<length(x) && abs(diff(z(id:id+1)))<threshold
                z(id+1) = NaN;
            end
        end
        [x, z] = deal(x(~isnan(z)), z(~isnan(z)));
    end
    %disp('Warning: Duplicate point(s) skipped');
end