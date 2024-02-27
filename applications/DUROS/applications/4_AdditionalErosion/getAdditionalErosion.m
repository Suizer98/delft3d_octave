function varargout = getAdditionalErosion(x, z, varargin)
%GETADDITIONALEROSION  iteratively fit additional erosion in cross-shore profile
%
%   Routine iteratively fits a predefined volume into a cross-shore
%   profile. This routine is applicable both for positive landward and
%   positive seaward oriented profiles. If the x-direction of the profile
%   is not specified, this property will be derived using
%   checkCrossShoreProfile.
%
%   Syntax:
%   varargout = getAdditionalErosion(x,z,varargin)
%
%   Input:
%   x         = The x-coordinates of the input profile
%   z         = The z-coordinates of the input progile
%   varargin  = 'PropertyName' PropertyValue pairs (optional)
%                 'TargetVolume' - volume to enclose (default = 0)
%                 'poslndwrd'    - x-direction: positive landward is -1 or 1
%                 'zmin'         - lower boundary of enclosed volume (default is minimum of profile)
%                 'slope'        - landward slope of enclosed profile (default = 1, meaning a 1:1 slope)
%                 'x0max'        - maximum boundary that is used in the optimisation. If this is not 
%                                  specified, the function will derive the maximum allowed by the profile.
%                 'x0min'        - minimum boundary that is used in the optimisation. If not specified, 
%                                  the function uses the minimum allower by the profile.
%                 'precision'    - precision criterium for iteration (default = 1e-2)
%                 'maxiter'      - maximum number of iterations (default = 50)
%               
%   Output:
%   varargout = DUROS result structure
%
%   Example
%   getAdditionalErosion
%
%   See also checkCrossShoreProfile

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer / Pieter van Geer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 24 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: getAdditionalErosion.m 10274 2014-02-24 12:38:13Z bieman $
% $Date: 2014-02-24 20:38:13 +0800 (Mon, 24 Feb 2014) $
% $Author: bieman $
% $Revision: 10274 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/4_AdditionalErosion/getAdditionalErosion.m $
% $Keywords:

%% Check varargin
OPT = struct(...
    'TargetVolume', 0,...
    'poslndwrd', [],...
    'zmin', min(z),...
    'slope', 1,...
    'x0max',nan,...
    'x0min',nan,...
    'precision', 1e-2,...
    'maxiter', 50);

OPT = setproperty(OPT, varargin{:});

%% initialize result struct
result = createEmptyDUROSResult(...
    'xSea',[],...
    'xLand',[],...
    'xActive',[],...
    'zSea',[],...
    'zLand',[],...
    'zActive',[],...
    'z2Active',[],...
    'Volume',0,...
    'volumes',0,...
    'Accretion',0,...
    'Erosion',0,...
    'precision',nan,...
    'ID','Addirional Erosion',...
    'iter',0,...
    'resultinboundaries',false);
result.info.input.WL_t = OPT.zmin;

%% derive x-direction (poslndwrd) if not specified
if isempty(OPT.poslndwrd)
    [x z OPT.poslndwrd] = checkCrossShoreProfile(x, z);
end

%% switch direction of the profile such that seaward is positive
% If the profile is flipped, it will be flipped back at the end of the
% function.
profileSwitched = false;
if OPT.poslndwrd == 1
    x = 0-x;
    profileSwitched = true;
    OPT.poslndwrd = -1;
    x0maxtemp = 0 - OPT.x0min;
    x0mintemp = 0 - OPT.x0max;
    OPT.x0max = x0maxtemp;
    OPT.x0min = x0mintemp;
end

%% Determine crossings with initial profile.
[xcr zcr x1_new_out z1_new_out x2_new_out z2_new_out crossdir] = findCrossings(x, z, x, repmat(OPT.zmin,size(x)),'keeporiginalgrid');

if isempty(xcr)
    % No profile points above the waterlevel
    result.xSea = x;
    result.zSea = z;
    varargout = {result};
    return
end

%% determine x0except, x0min and x0max
% dune face is defined as the last upward crossing of the zmin level
% with the profile
idDuneFace = find(sign(crossdir) == 1, 1, 'last');
x0max = xcr(idDuneFace);

% all upward and downward crossings landward of the dune face are
% potential dune valley indicators
idValley = crossdir ~= 0;
idValley(idDuneFace:end) = false;
if crossdir(find(crossdir.*idValley~=0,1,'last')) == 1
    % Dune face is located right at a horizontal part of the profile that lies exactly at the
    % waterline
   idValley(find(crossdir.*idValley~=0,1,'last')) = false;
end

% take cumsum to filter for horizontal profile parts at the zmin level
temp = cumsum(flipud(crossdir.*idValley));
idValleydwnwrd = flipud([NaN; temp(1:end-1)] == 0) & idValley;
idValleyupwrd = flipud(temp == 0) & idValley;

mostLandwardPointAboveZmin = z(x==min(x)) > OPT.zmin;
if ~mostLandwardPointAboveZmin
    % landward end of profile is below zmin level. Assign most landward
    % crossing as x0min
    x0min = xcr(find(idValleydwnwrd, 1, 'first'));
    % skip this crossing as valley indicator
    idValley(find(idValleydwnwrd, 1, 'first')) = false;
else
    % landward end of profile is above zmin level. Take most landward
    % profile point as x0min
    x0min = min(x);
end

if isempty(idDuneFace)
    % no dune face is detected
    varargout = {[]};
    return
end

if x0max == max(x)
    % end of profile is above zmin
    x0max = max(x) + diff([OPT.zmin z(x == max(x))])/OPT.slope;
end

if x0min == min(x)
    % begin of profile is above zmin
    x0min = min(x) + diff([OPT.zmin z(x == min(x))])/OPT.slope;
end

%% check if x0max and x0min were (correctly) specified
if ~isnan(OPT.x0max)
    if OPT.x0max > x0max
        % x0max outside of possible calculation range
        OPT.x0max = x0max;
        writemessage(23, 'Original x0max outside of possible calculation range; x0max adjusted');
    else
        OPT.x0max = x0max;
    end
end
if ~isnan(OPT.x0min)
    if OPT.x0min < x0min
        % x0min outside of possible calculation range
        OPT.x0min = x0min;
        writemessage(24, 'Original x0min outside of possible calculation range; x0min adjusted');
    else
        OPT.x0min = x0min;
    end
end

%% get iteration boundaries
x0 = [OPT.x0max OPT.x0min]; % predefine both ultimate situations

if diff(x0) >= 0
    %% No erosion within iteration boundaries
    result.xSea = [];
    result.xLand = [];
    result.xActive = [];
    result.zSea = [];
    result.zLand = [];
    result.zActive = [];
    result.z2Active = [];
    result.info.ID = 'Additional Erosion';
    result.info.iter = 0;
    result.info.resultinboundaries = false;
    result.info.input.WL_t = OPT.zmin;
    result.info.messages = {};
    varargout = {result};
    return
end

%% get x0except (valley stretches)
% idToIgnore = xcr >= max(x0) | xcr <= min(x0);
% OPT.x0except = [xcr(idValleyupwrd & idValley & ~idToIgnore) xcr(idValleydwnwrd & idValley & ~idToIgnore)];
OPT.x0except = [xcr(idValleyupwrd & idValley) xcr(idValleydwnwrd & idValley)];
m = size(OPT.x0except,1);
x0exceptID = ones(m,1)*2;

%% Initialize iteration parameters
Iter = 0;               % Iteration number
iterid = 1;             % dummy value for iteration number which gives the best possible solution;
[Volume xmax xmin] = deal(NaN(1, OPT.maxiter)); % Preallocation of variable to store calculated volumes
NextIteration = true;
x2 = [diff([min(x) max(x)]) 0 -diff([OPT.zmin max(z)])/OPT.slope];
z2 = [OPT.zmin OPT.zmin max(z)];
iterresult = createEmptyDUROSResult;

%% iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further
while NextIteration
    Iter = Iter + 1;
    
    x0InValley = false;
    if ~isempty(OPT.x0except)
        % check whether x0 is in any valley
        x0InValley =  x0(Iter) > OPT.x0except(:,1) & x0(Iter) < OPT.x0except(:,2);
    end
        
    if any(x0InValley) 
        % set x0 to one of the boundaries of the exception area
        % starting from the seaward boundary
        x0(Iter) = OPT.x0except(x0InValley,x0exceptID(x0InValley));
        % by lowering the x0exceptID by 1, next time, the landward
        % boundary will be chosen
        x0exceptID(x0InValley) = max(1,x0exceptID(x0InValley)-1);
    end
    
    xcross = findCrossings(x, z, x0(Iter)+x2, z2, 'keeporiginalgrid');
    if ~isempty(xcross)
    [xmin(Iter) xmax(Iter)] = deal(min(xcross), max(xcross));
    [Volume(Iter) iterresult(Iter)] = getVolume(x, z,...
        'LowerBoundary', OPT.zmin,...
        'LandwardBoundary', xmin(Iter),...
        'SeawardBoundary', xmax(Iter),...
        'x2', x0(Iter)+x2,...
        'z2', z2);
    else
        Volume(Iter)=NaN;
        iterresult(Iter)=createEmptyDUROSResult;
    end
    
    % create conditions for if statement to adjust profile shift x0
    FirstTwoItersCompleted = Iter==numel(x0); % after the second iteration, x0 is extended for each next iteration
    PrecisionNotReached = abs(diff([OPT.TargetVolume Volume(Iter)])) >= abs(OPT.precision);
    SolutionPossibleWithinBoundaries = diff(sign(Volume(1:2)-OPT.TargetVolume))~=0 | ~PrecisionNotReached;
    MaxNrItersReached = Iter == OPT.maxiter;
    if FirstTwoItersCompleted && ~any(x0InValley)
        % difference between last two iterations is smaller than precision
        VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<OPT.precision;
    else
        VollDiffSmall = false;
    end

    if FirstTwoItersCompleted && PrecisionNotReached && SolutionPossibleWithinBoundaries && ~MaxNrItersReached && ~VollDiffSmall
        % new profile shift has to be calculated.

        % find identifier of Volume closest but larger than TargetVolume
        idpos = find(Volume==min(Volume(Volume>=OPT.TargetVolume)));
        if length(idpos)>1
            % to prevent a vector of idpos
            [dummy IX] = sort(x0(idpos)*OPT.poslndwrd); % take poslndwrd into account to always find the most landward idpos
            idpos = idpos(IX(end)); % take the last one
        end

        % find identifier of Volume closest but smaller than TargetVolume
        idneg = find(Volume==max(Volume(Volume<OPT.TargetVolume))); % find identifier of Volume closest but smaller than TargetVolume
        if length(idneg)>1
            % to prevent a vector of idneg
            [dummy IX] = sort(x0(idneg)*OPT.poslndwrd); % take poslndwrd into account to always find the most seaward idneg
            idneg = idneg(IX(1)); % take the first one
        end

        % interpolation using two Volumes, closest larger and closest
        % smaller value than TargetVolume
        x0(Iter+1) = interp1(Volume([idpos idneg]), x0([idpos idneg]), OPT.TargetVolume); % interpolation using two Volumes, closest larger and closest smaller value than TargetVolume
    elseif FirstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)

        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterid = find(abs(Volume-OPT.TargetVolume)==min(abs(Volume-OPT.TargetVolume)),1,'last'); % find the iteration number of the latest iteration which resulted in the best possible solution

        % change while loop condition
        NextIteration = false;
    end
end

result = iterresult(iterid);
precision = abs(diff([Volume(iterid) OPT.TargetVolume])); % precision is the difference between Volume and TargetVolume; positive means TargetVolume>Volume; negative means TargetVolume<Volume
result.info.x0 = x0(iterid);
result.info.precision = precision;
result.info.iter = Iter;
result.info.time = toc;
result.info.resultinboundaries = SolutionPossibleWithinBoundaries;
result.info.ID = 'Additional Erosion';
result.info.input.WL_t = OPT.zmin;

%% add valleys to solution (were removed for volume calculation
xInValleyId = x>min(result.xActive) & x<max(result.xActive) & z<=OPT.zmin;
idRemove = ismember(result.xActive,x(xInValleyId));
result.xActive(idRemove) = [];
result.zActive(idRemove) = [];
result.z2Active(idRemove) = [];
[result.xActive sortid] = sort(cat(1,result.xActive,x(xInValleyId)));
result.zActive = cat(1,result.zActive,z(xInValleyId));
result.zActive = result.zActive(sortid);
result.z2Active = cat(1,result.z2Active,z(xInValleyId));
result.z2Active = result.z2Active(sortid);

result.VTVinfo.Xp = max([result.info.x0,min(result.xActive)]);
result.VTVinfo.Zp = result.z2Active(result.xActive==result.VTVinfo.Xp);
result.VTVinfo.Xr = min(result.xActive);
result.VTVinfo.Zr = result.z2Active(result.xActive==result.VTVinfo.Xr);

%% Switch back the profile
if profileSwitched
    result.info.x0 = 0 - result.info.x0;
    result.xActive = 0 - result.xActive;
    result.xLand = 0 - result.xLand;
    result.xSea = 0 - result.xSea;
    result.VTVinfo.Xp = 0 - result.VTVinfo.Xp;
    result.VTVinfo.Xr = 0 - result.VTVinfo.Xr;
end
varargout = {result};