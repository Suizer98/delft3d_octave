function Result = boundaryprofilevolumetric(xInitial,zInitial,waterLevel,x0StartingPoint,varargin)
% BOUNDARYPROFILEVOLUMETRIC  routine to fit a volumetric boundary profile into an arbitrary dune profile
%
% This routine calculates a volumetric boundary profile in an input profile by starting at x0 and
% moving a vertical line landwards until the volume enclosed by this vertical line, the profile, 
% the water level and the vertical line through x0 equals a target volume.
%
% Syntax:       
%       Result = boundaryprofilevolumetric(xInitial, zInitial,...
%                           waterLevel, x0StartingPoint,...
%                           'TargetVolume', targetVolume);
%       Result = boundaryprofilevolumetric(xInitial, zInitial,...
%                           waterLevel, x0StartingPoint,...
%                           'Hs', significantWaveHeight,...
%                           'Tp', peakPeriod);
%       Result  = boundaryprofilevolumetric(..., 'x0except',x0ValleyPoints);
%
% Input:
%               xInitial     = column array containing x-locations of initial profile [m]
%               zInitial     = column array containing z-locations of initial profile [m]
%               waterLevel   = Water level [m] w.r.t. NAP
%               x0StartingPoint = 
%                              seaward boundary of boundary profile
%               TargetVolume = additional volume to be fitted in profile. If the targetVolume is
%                              provided, this will be used as a target. If the targetvolume is not
%                              present the function takes Hs and Tp to calculate the target volume.
%               x0ValleyPoints = 
%                              possible exception area because of dune valleys. If not entered the
%                              function will use "valleypoints" to determine the valleypoints
%                              (former x0except).
%               significantWaveHeight = 
%                              Input wave height that is used (together with the peakPeriod) to
%                              calculate a targetVolume if the targetVolume is not specified in the
%                              input.
%               peakPeriod =   Input wave peak period that is used (together with the waveHeight) to
%                              calculate a targetVolume if the targetVolume is not specified in the
%                              input.
%
% Output:       Eventual output is stored in a structure Result. See createEmptyDurosResult for more
%               details on the struct.
%
%   See also boundaryprofile createEmptyDUROSResult TRDA
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, November 2009 (Version 1.0, November 2009)
% By:           <Pieter van Geer (email: Pieter.VanGeer@deltares.nl)>
% --------------------------------------------------------------------------

% $Id: boundaryprofilevolumetric.m 4334 2011-03-25 08:40:23Z geer $ 
% $Date: 2011-03-25 16:40:23 +0800 (Fri, 25 Mar 2011) $
% $Author: geer $
% $Revision: 4334 $
% $Keywords:$

%% Parse Input
OPT = struct(...
    'TargetVolume',[],...
    'Hs',[],...
    'Tp',[],...
    'x0except',[]);
[OPT Set] = setproperty(OPT,varargin);

if ~Set.TargetVolume
    %% Calculate TargetVolume from input
    if ~Set.Hs || ~Set.Tp
        error('TRDA:Input','Input parameter TargetVolume is missing.');
    end
    profileHeight = max([2.5 .12*OPT.Tp*sqrt(OPT.Hs)]);
    OPT.TargetVolume = -(3/2 * profileHeight^2 + 3*profileHeight);
end
targetVolume = OPT.TargetVolume;

x0 = [x0StartingPoint min(xInitial)]; % predefine both ultimate situations
if ~Set.x0except
    % Calculate exceptions
    OPT.x0except = valleypoints(xInitial,zInitial,waterLevel,...
        'SeawardBoundary',max(x0),...
        'LandwardBoundary',min(x0));
end

%% Initiate iteration variables

tic;
Result = createEmptyDUROSResult;

m = size(OPT.x0except,1);
x0exceptID(1:m,1) = zeros;

[x2, z2] = deal([0; max(xInitial)-min(xInitial)], [waterLevel; waterLevel]);



nIter = 0;               % Iteration number
iterId = 1;             % dummy value for iteration number which gives the best possible solution;
maxIter = DuneErosionSettings('get', 'maxiter');           % specify maximum number of iterations
precision = 1e-2;       % specify maximum error
volume = NaN*ones(1,maxIter); % Preallocation of variable to store calculated volumes

if OPT.TargetVolume == 0
    [Result.xActive, Result.zActive, Result.z2Active] = deal([x0(iterId), zInitial(xInitial==x0(iterId)), zInitial(xInitial==x0(iterId))]);
    return
end

%% Start iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further

nextIteration = true;
while nextIteration
    nIter = nIter + 1;
    x0InValley = false;
    for i = 1:m
        if x0(nIter) > OPT.x0except(i,1) ...
                && x0(nIter) < OPT.x0except(i,2)
            
            x0(nIter) = OPT.x0except(i,x0exceptID(i)+1);
            x0exceptID(i) = x0exceptID(i)+1;
            x0InValley = true;
        end
    end
    xCrossings = findCrossings(xInitial, zInitial, x0(nIter)+x2, z2, 'keeporiginalgrid');

    landwardBoundary = min(x0(nIter)+x2);
    seawardBoundary = max(xCrossings);
    [volume(nIter),IterResult(nIter)] = getvolume(xInitial, zInitial, [], waterLevel, landwardBoundary, seawardBoundary, x0(nIter)+x2, z2);  %#ok<AGROW>

    % create conditions for if statement to adjust profile shift x0
    firstTwoItersCompleted = nIter==numel(x0);
    precisionNotReached = abs(diff([targetVolume volume(nIter)])) >= abs(precision);
    solutionPossibleWithinBoundaries = diff(sign(volume(1:2)-targetVolume))~=0;
    maxNrItersReached = nIter==maxIter;
    if firstTwoItersCompleted && ~x0InValley
        vollDiffSmall = abs(diff(volume(nIter-1:nIter)))<precision;
    else
        vollDiffSmall = false;
    end

    if firstTwoItersCompleted && precisionNotReached && solutionPossibleWithinBoundaries && ~maxNrItersReached && ~vollDiffSmall
        % new profile shift has to be calculated.

        % find identifier of Volume closest but larger than TargetVolume
        idPos = find(volume==min(volume(volume>targetVolume))); % find identifier of Volume closest but larger than TargetVolume
        if length(idPos)>1
            [dummy, IX] = sort(x0(idPos));
            idPos = idPos(IX(1));
        end
        
        % find identifier of Volume closest but smaller than TargetVolume
        idNeg = find(volume==max(volume(volume<targetVolume))); % find identifier of Volume closest but smaller than TargetVolume
        if length(idNeg)>1
            [dummy, IX] = sort(x0(idNeg));
            idNeg = idNeg(IX(end));
        end
        
        % interpolation using two Volumes, closest larger and closest
        % smaller value than TargetVolume
        x0(nIter+1) = interp1(volume([idPos idNeg]),x0([idPos idNeg]),targetVolume); % interpolation using two Volumes, closest larger and closest smaller value than TargetVolume
    elseif firstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)
        
        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterId = find(abs(volume-targetVolume)==min(abs(volume-targetVolume)),1,'last'); % find the iteration number of the latest iteration which resulted in the best possible solution

        % change while loop condition
        nextIteration = false;
    end
end

% isolate best result
Result = IterResult(iterId);
precision = min(diff([volume(iterId) OPT.TargetVolume])); % precision is the difference between Volume and TargetVolume; positive means TargetVolume>Volume; negative means TargetVolume<Volume
Result.info.x0 = x0(iterId);
Result.info.precision = precision;
Result.info.iter = nIter;
Result.info.time = toc;
Result.info.resultinboundaries = solutionPossibleWithinBoundaries;
Result.info.ID = 'Boundary Profile';

%% Add x0StartingPoint to the profile and split seaward and landward part.
[xFinalActive sid] = unique(cat(1,Result.xActive,Result.xSea,x0StartingPoint));
zFinalActive = cat(1,Result.z2Active,Result.zSea,waterLevel);
zFinalActive = zFinalActive(sid);
Result.xSea = xFinalActive(xFinalActive > x0StartingPoint);
Result.zSea = interp1(xInitial,zInitial,Result.xSea);
Result.xActive = xFinalActive(xFinalActive <= x0StartingPoint);
Result.z2Active = zFinalActive(xFinalActive <= x0StartingPoint);
Result.zActive = interp1(xInitial,zInitial,Result.xActive);
Result.zActive(Result.zActive<waterLevel) = waterLevel;