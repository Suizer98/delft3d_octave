function result = getDuneErosion_volumetricboundaryprofile(xInitial, zInitial, x2, z2, WL_t, x0min, x0max, x0except, TargetVolume, maxRetreat)
%GETDUNEEROSION_ADDITIONAL  routine to fit additional dune erosion into profile
%
% This routine returns the x-location of the floating profile (x2, z2) to fit
% a TargetVolume between the initial profile and profile (x2, z2)
%
% Syntax:       result = getDuneErosion_additional(xInitial,
%       zInitial, x2, z2, WL_t, x0min, x0max, x0except, TargetVolume)
%
% Input:
%               xInitial  = column array containing x-locations of initial profile [m]
%               zInitial  = column array containing z-locations of initial profile [m]
%               x2        = column array with x2 points (increasing index and positive x in seaward direction)
%               z2        = column array with z2 points
%               WL_t      = Water level [m] w.r.t. NAP
%               x0min     = landward boundary of boundary profile
%               x0max     = seaward boundary of boundary profile
%               x00min    = ultimate landward boundary of boundary profile
%               x0except  = possible exception area because of dune valleys
%               TargetVolume = additional volume to be fitted in profile
%               maxRetreat= maximum horizontal difference between DUROS 1:1
%                               slope and additional profile 1:1 slope
%
% Output:       Eventual output is stored in a structure result
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% --------------------------------------------------------------------------

% $Id: getDuneErosion_volumetricboundaryprofile.m 1815 2009-10-22 07:18:00Z geer $ 
% $Date: 2009-10-22 15:18:00 +0800 (Thu, 22 Oct 2009) $
% $Author: geer $
% $Revision: 1815 $

%% Initiate variables
tic;
getdefaults('TargetVolume',0,1,'x0except',[],0,'maxRetreat',[],0);
result = createEmptyDUROSResult; %#ok<NASGU>

m = size(x0except,1);
x0exceptID(1:m,1) = zeros;

x0 = [x0max x0min]; % predefine both ultimate situations

Iter = 0;               % Iteration number
iterid = 1;             % dummy value for iteration number which gives the best possible solution;
maxiter = DuneErosionSettings('get', 'maxiter');           % specify maximum number of iterations
precision = 1e-2;       % specify maximum error
Volume = NaN*ones(1,maxiter); % Preallocation of variable to store calculated volumes

if TargetVolume == 0
    [result.xActive, result.zActive, result.z2Active] = deal([x0(iterid), zInitial(xInitial==x0(iterid)), zInitial(xInitial==x0(iterid))]);
    return
else
    NextIteration = true;   % Condition of while loop
end

%% Start iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further

while NextIteration
    Iter = Iter + 1;
    x0InValley = false;
    for i = 1:m
        if x0(Iter)>x0except(i,1) && x0(Iter)<x0except(i,2)
            x0(Iter) = x0except(i,x0exceptID(i)+1);
            x0exceptID(i) = x0exceptID(i)+1;
            x0InValley = true;
        end
    end
    xcross = findCrossings(xInitial, zInitial, x0(Iter)+x2, z2, 'keeporiginalgrid');
    if min(z2)~=max(z2)
        LandwardBoundary = min(xcross);
    else
        LandwardBoundary = min(x0(Iter)+x2);
    end
    SeawardBoundary = max(xcross);
    [Volume(Iter),iterresult(Iter)] = getVolume(xInitial, zInitial, [], WL_t, LandwardBoundary, SeawardBoundary, x0(Iter)+x2, z2);  %#ok<AGROW>

    % create conditions for if statement to adjust profile shift x0
    FirstTwoItersCompleted = Iter==numel(x0);
    PrecisionNotReached = abs(diff([TargetVolume Volume(Iter)])) >= abs(precision);
    SolutionPossibleWithinBoundaries = diff(sign(Volume(1:2)-TargetVolume))~=0;
    MaxNrItersReached = Iter==maxiter;
    if FirstTwoItersCompleted && ~x0InValley
        VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<precision;
    else
        VollDiffSmall = false;
    end

    if FirstTwoItersCompleted && PrecisionNotReached && SolutionPossibleWithinBoundaries && ~MaxNrItersReached && ~VollDiffSmall
        % new profile shift has to be calculated.

        % find identifier of Volume closest but larger than TargetVolume
        idpos = find(Volume==min(Volume(Volume>TargetVolume))); % find identifier of Volume closest but larger than TargetVolume
        if length(idpos)>1
            [dummy, IX] = sort(x0(idpos));
            idpos = idpos(IX(1));
        end
        
        % find identifier of Volume closest but smaller than TargetVolume
        idneg = find(Volume==max(Volume(Volume<TargetVolume))); % find identifier of Volume closest but smaller than TargetVolume
        if length(idneg)>1
            [dummy, IX] = sort(x0(idneg));
            idneg = idneg(IX(end));
        end
        
        % interpolation using two Volumes, closest larger and closest
        % smaller value than TargetVolume
        x0(Iter+1) = interp1(Volume([idpos idneg]),x0([idpos idneg]),TargetVolume); % interpolation using two Volumes, closest larger and closest smaller value than TargetVolume
    elseif FirstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)
        
        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterid = find(abs(Volume-TargetVolume)==min(abs(Volume-TargetVolume)),1,'last'); % find the iteration number of the latest iteration which resulted in the best possible solution

        % change while loop condition
        NextIteration = false;
    end
    if dbstate
        dbPlotDuneErosion
    end
end

%% maximise the additional retreat to maxRetreat
AdditionalRetreat = diff([x0(iterid) x0max]);
AdditionalRetreatExceedsmaximum = AdditionalRetreat > maxRetreat;
if AdditionalRetreatExceedsmaximum
    writemessage(42, ['Additional retreat limit of ' num2str(maxRetreat) ' m reached. '...
        'An Additional volume of ' num2str(Volume(iterid), '%.2f') ' m^3/m^1 (TargetVolume=' num2str(TargetVolume, '%.2f') ' m^3/m^1) leads to an additional retreat of ' num2str(AdditionalRetreat, '%.2f') ' m.']);    
    Iter = Iter + 1;
    x0(Iter) = x0max - maxRetreat;
    xcross = findCrossings(xInitial, zInitial, x0(Iter)+x2, z2, 'keeporiginalgrid');
    if isempty(xcross)
        %disp('Erosional length restricted within dunevalley. No additional Erosion volume determined.');
        writemessage(45, 'Erosional length restricted within dunevalley. No additional Erosion volume determined.');
        iterresult(Iter) = createEmptyDUROSResult;
        iterresult(Iter).xLand = xInitial(xInitial<x0(Iter));
        iterresult(Iter).zLand = zInitial(xInitial<x0(Iter));
        iterresult(Iter).xActive= x0(Iter);
        if any(xInitial==x0(Iter))
            iterresult(Iter).zActive = zInitial(xInitial==x0(Iter));
            iterresult(Iter).z2Active = zInitial(xInitial==x0(Iter));
        else
            iterresult(Iter).zActive = interp1(xInitial,zInitial,x0(Iter));
            iterresult(Iter).z2Active = interp1(xInitial,zInitial,x0(Iter));
        end
        iterresult(Iter).xSea = xInitial(xInitial>x0(Iter));
        iterresult(Iter).zSea = zInitial(xInitial>x0(Iter));
        iterresult(Iter).Volumes.Volume = 0; %#ok<NASGU>
    else
        SeawardBoundary = max(xcross);
        LandwardBoundary = min(xcross);
        [Volume(Iter), iterresult(Iter)] = getVolume(xInitial, zInitial, [], WL_t, LandwardBoundary, SeawardBoundary, x0(Iter)+x2, z2);
    end
    iterid = Iter;
    if dbstate
        dbPlotDuneErosion
    end
end

% isolate best result
result = iterresult(iterid);
precision = min(diff([Volume(iterid) TargetVolume])); % precision is the difference between Volume and TargetVolume; positive means TargetVolume>Volume; negative means TargetVolume<Volume
result.info.x0 = x0(iterid);
result.info.precision = precision;
result.info.iter = Iter;
result.info.time = toc;
result.info.resultinboundaries = SolutionPossibleWithinBoundaries;
result.info.ID = 'Additional Erosion';