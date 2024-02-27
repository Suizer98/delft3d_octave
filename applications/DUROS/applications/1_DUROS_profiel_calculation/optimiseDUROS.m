function result = optimiseDUROS(xInitial, zInitial, WL_t, x0min, x0max, x0except, Hsig_t, Tp_t, w, SeawardBoundaryofInterest, channelslope_xpoints)
%OPTIMISEDUROS  routine to position the DUROS profile to get a balance
%
% This routine returns the optimalised position of the DUROS (-plus)
% profile and the volume balance. Optionally, a profile fluctuation can be
% simulated by using a non-zero balance (=ProfileFluct)
%
% Syntax:       result = optimiseDUROS(xInitial, zInitial, WL_t,
%                       x0min, x0max, x0except, Hsig_t, Tp_t, w, ProfileFluct)
%
% Input:
%               xInitial  = column array containing x-locations of initial profile [m]
%               zInitial  = column array containing z-locations of initial profile [m]
%               WL_t      = Water level [m] w.r.t. NAP
%               x0min     = landward boundary of boundary profile
%               x0max     = seaward boundary of boundary profile
%               x0except  = possible exception area because of dune valleys
%               Hsig_t    = Significant wave height [m]
%               Tp_t      = Peak wave period [s]
%               w         = Fall velocity of sediment in water
%
% Output:       Eventual output is stored in a structure result
%
%   See also getDuneErosion getDuneErosion_DUROS

% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.1, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% --------------------------------------------------------------------------

% $Id: optimiseDUROS.m 3860 2011-01-12 23:21:10Z m.vankoningsveld@tudelft.nl $ 
% $Date: 2011-01-13 07:21:10 +0800 (Thu, 13 Jan 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 3860 $
% $Keywords: dune dunes erosion optimise DUROS DUROS+

%% Initiate variables
tic;
% apply defaults if input not specified
getdefaults('x0except',[],0,...
    'channelslope_xpoints',[],0);

% load settings / Flags
PreventLandwardTransport = DuneErosionSettings('PreventLandwardTransport');
ChannelSlopes = DuneErosionSettings('ChannelSlopes');
ProfileFluct = DuneErosionSettings('ProfileFluct');

% initiate calculation coefficients, constants and counters
Iter = 0;                                           % Iteration number
iterid = 1;                                         % dummy value for iteration number which gives the best possible solution;
maxiter = DuneErosionSettings('get', 'maxiter');    % specify maximum number of iterations
precision = 1e-2;                                   % specify maximum error
NextIteration = true;                               % Condition of while loop

% initiate arrays to store the results
result = createEmptyDUROSResult;                    % create empty result structure
[x0precision Volume] = deal(NaN(1,maxiter));        % Preallocation of variable to store calculated volumes
CorrectionApplied = false(1, maxiter);              % preallocation of variable to know if volume correction has been applied

% construct first two iterations (ultimate situations
x0 = [x0max x0min];                                 % predefine both ultimate situations

%% Start iteration loop
% First perform two iterations with the most landward and seaward profiles possible,
% then iterate further
while NextIteration
    Iter=Iter+1;
    % Get DUROS profile based on hydraulic conditions and profile shift x0.
    result(Iter) = getDUROSprofile(xInitial, zInitial, x0(Iter), Hsig_t, Tp_t, WL_t, w, SeawardBoundaryofInterest,false);
    Volume(Iter) = result(Iter).Volumes.Volume;
    % precision holds for a volume. Dividing this by the height of the
    % erosion profile gives a precision for the horizontal length scale
    x0precision(Iter) = precision / ((result(Iter).z2Active(1) - result(Iter).z2Active(end))/2);

    % create conditions if statement
    SecondIter = Iter==2;
    dProfileFluct = ProfileFluct ~= 0;

    if SecondIter && dProfileFluct
        if Volume(1)+ProfileFluct < 0
            % Volume(1) corresponds with maximum deposition
            disp(['Warning: variable "ProfileFluct" has been changed from ',num2str(ProfileFluct,'%.2f'),' to ',num2str(-Volume(1),'%.2f')]);
            ProfileFluct = -Volume(1);
        elseif Volume(2)+ProfileFluct > 0
            % Volume(2) corresponds with maximum erosion
            disp(['Warning: variable "ProfileFluct" has been changed from ',num2str(ProfileFluct,'%.2f'),' to ',num2str(-Volume(2),'%.2f')]);
            ProfileFluct = -Volume(2);
        end
    end

    % create conditions for if statement to adjust profile shift x0
    FirstTwoItersCompleted = Iter==numel(x0);
    PrecisionNotReached = all(abs(Volume(1:Iter) - ProfileFluct) > abs(precision));
    SolutionPossibleWithinBoundaries = diff(sign(Volume(1:2)-ProfileFluct))~=0 || any(abs(Volume(1:2)) < abs(precision));
    MaxNrItersReached = Iter==maxiter;
    if FirstTwoItersCompleted
        VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<precision;
        % The following code is not tested (with various cases). Errors
        % therefore could occur. If so, just comment this statement and
        % comment the if statment (line 114) as well. The code will slow
        % down but definitely work...
        ChannelSlopeEffect = ...
            any(...
            find(...
            abs((Volume - Volume(Iter))) < precision... Volume difference small
            &...
            (cat(2,abs((x0 - x0(Iter))),nan(1,maxiter-Iter)) - x0precision) < 0 ... x0 difference small
            )...
            ~=Iter); % excluding the iteration position itself of course....
    end

    if FirstTwoItersCompleted &&...
            PrecisionNotReached &&...
            SolutionPossibleWithinBoundaries &&...
            ~MaxNrItersReached &&...
            ~VollDiffSmall &&...
            ~ChannelSlopeEffect
        % new profile shift has to be calculated.

        x0(Iter+1) = getNextx0(Volume,ProfileFluct,x0);
    elseif FirstTwoItersCompleted
        % either no solution is possible between the boundaries, the
        % maximum number of solutions is reached or the precision has been
        % reached (--> a satisfying solution)

        % find the iteration number of the latest iteration which resulted
        % in the best possible solution
        iterid = find(abs(Volume-ProfileFluct)==min(abs(Volume-ProfileFluct)),1,'last');

        % change while loop condition
        NextIteration = false;
    end

    % plot intermediate solution if dbstate is true
    if dbstate
        dbPlotDuneErosion('update parab')
    end
end

%% #1 - Check solution for landward transport.
if PreventLandwardTransport && ProfileFluct >=0
    IterateWithLandwardTransport = false;
    if PrecisionNotReached
        [Volumechange CorrectionApplied DuneCorrected] = deal(zeros(1,Iter),false(1,Iter),false(1,Iter));
        for i = 1 : Iter
            % Correct volume in case of landward directed transport
            [Volume(i), Volumechange(i), CorrectionApplied(i), DuneCorrected(i),  result(i).xActive, result(i).zActive, result(i).z2Active] = getVolumeCorrection(result(i).xActive, result(i).zActive, result(i).z2Active, WL_t); % check for landward directed transport
        end
        if any(CorrectionApplied)
            IterateWithLandwardTransport = true;
        end
        iterid = find(abs(Volume-ProfileFluct)==min(abs(Volume-ProfileFluct)),1,'last');
    else
        % Correct volume in case of landward directed transport
        [Volume(iterid), Volumechange(iterid), CorrectionApplied(iterid), DuneCorrected(iterid), result(iterid).xActive, result(iterid).zActive, result(iterid).z2Active] = getVolumeCorrection(result(iterid).xActive, result(iterid).zActive, result(iterid).z2Active, WL_t); % check for landward directed transport
        if CorrectionApplied(iterid)
            for i = 1 : Iter
                % Correct volume in case of landward directed transport
                [Volume(i), Volumechange(i), CorrectionApplied(i), DuneCorrected(i),  result(i).xActive, result(i).zActive, result(i).z2Active] = getVolumeCorrection(result(i).xActive, result(i).zActive, result(i).z2Active, WL_t); % check for landward directed transport
            end
            IterateWithLandwardTransport = true;
            iterid = find(abs(Volume-ProfileFluct)==min(abs(Volume-ProfileFluct)),1,'last');
        end
    end

    % if IterateWithLandwardTransport, volumes need to be corrected.
    % A new iteration including volume correction has
    % to be started that uses the "optimal" point
    % found sofar as starting point.
    if IterateWithLandwardTransport
        %% prepare new while loop with optimalisation that includes volume
        %% correction.

        %         SolutionPossibleWithinBoundaries =
        %         diff(sign(Volume(1:2)-ProfileFluct))~=0 || any(abs(Volume(1:2)) <
        %         abs(precision));
        
        % In case of correction for landward transport above the waterline
        % for one of the boundary solutions checking only the first two
        % solutions could lead to problems. It could be possible that in
        % between the boundaries a solution can be found (without 
        % correction above the waterline). It would be even better to check
        % for landward corrected transport above the water line, but for
        % now all the iteration steps are checked for their sign.
        SolutionPossibleWithinBoundaries = (any(sign(Volume-ProfileFluct)==1) && any(sign(Volume-ProfileFluct)==-1))...
            || any(abs(Volume(1:2)) < abs(precision));

        % initiate while loop conditions
        PrecisionNotReached = abs(diff([ProfileFluct Volume(iterid)])) >= abs(precision);
        MaxIterNotReached = Iter < maxiter;

        if PrecisionNotReached && MaxIterNotReached && SolutionPossibleWithinBoundaries
            x0(Iter+1) = getNextx0(Volume,ProfileFluct,x0);
        end
        
        % maybe the volume difference between the last two solutions is
        % small, but that does not mean that we have to cancel new
        % iterations. After all, the solutions are corrected and maybe the
        % best solution is not the last iteration.
        VollDiffSmall = false;

        while PrecisionNotReached && MaxIterNotReached && SolutionPossibleWithinBoundaries && ~VollDiffSmall
            % start new calculation
            Iter = Iter+1;
            [result(Iter)] = getDUROSprofile(xInitial, zInitial, x0(Iter), Hsig_t, Tp_t, WL_t, w, SeawardBoundaryofInterest, false);

            % Correct volume for landward transport landward directed transport
            [Volume(Iter), Volumechange, CorrectionApplied(Iter), DuneCorrected(Iter),  result(Iter).xActive, result(Iter).zActive, result(Iter).z2Active] = getVolumeCorrection(result(Iter).xActive, result(Iter).zActive, result(Iter).z2Active, WL_t); % check for landward directed transport

            % In this while loop no iteration boundaries are
            % included. This is because of the fact that the
            % solution is close to the optimal solution and
            % only needs to be corrected.
            if dbstate
                dbPlotDuneErosion('update parab')
            end

            x0(Iter+1) = getNextx0(Volume,ProfileFluct,x0);

            PrecisionNotReached = abs(diff([ProfileFluct Volume(Iter)])) >= abs(precision);
            MaxIterNotReached = Iter < maxiter;
            VollDiffSmall = abs(diff(Volume(Iter-1:Iter)))<precision;
        end
        %         iterid = find(abs(Volume-ProfileFluct)==min(abs(Volume-ProfileFluct)),1,'last');
    end
end

%% isolate best result

% find the iteration number of the latest iteration which resulted in the
% best possible solution.
iterid = find(abs(Volume-ProfileFluct)==min(abs(Volume-ProfileFluct)),1,'last');


%% #2 - Check whether solution has been influenced steep channel slopes
SteepPointsExist = ~isempty(channelslope_xpoints);
if ChannelSlopes && SteepPointsExist...
        && SolutionPossibleWithinBoundaries && PrecisionNotReached
    [dum idpos idneg] = getNextx0(Volume,ProfileFluct,x0);
    xpos = x0(idpos);
    xneg = x0(idneg);
    if any(channelslope_xpoints(:,1)<xpos & channelslope_xpoints(:,1)>xneg)
        % compare the x0 positions of the closest solutions to x0 positions of
        % possible channel problems. If one of the channelslope_points x0
        % positions is between the x0 of the solutions closest to
        % ProfileFluct (positive and negative), influence of a channelslope
        % is present.
        chpid = find(channelslope_xpoints(:,1)<xpos & channelslope_xpoints(:,1)>xneg,1,'first');
        if ~isempty(chpid)
            % in this case the problems are caused by a channel slope.
            writemessage(-6, ['Solution influenced by non-erodible channel slope at = (',num2str(channelslope_xpoints(chpid,2),'%.2f'),', ',num2str(channelslope_xpoints(chpid,3),'%.2f'),') [m]']);
            Iter = Iter+1;
            x0(Iter) = channelslope_xpoints(chpid,1);
            result(Iter) = getDUROSprofile(xInitial, zInitial, x0(Iter), Hsig_t, Tp_t, WL_t, w, SeawardBoundaryofInterest,true);
            [Volume(Iter), Volumechange, CorrectionApplied(Iter), DuneCorrected(Iter),  result(Iter).xActive, result(Iter).zActive, result(Iter).z2Active] = getVolumeCorrection(result(Iter).xActive, result(Iter).zActive, result(Iter).z2Active, WL_t); % check for landward directed transport
            iterid = Iter;
            SolutionPossibleWithinBoundaries = true;
        end
    end
end

%% Post message if a correction was applied
if CorrectionApplied(iterid)
    % disp('Warning: Landward directed transport in iteration prevented')
    writemessage(-4, 'Warning: Landward directed transport in iteration prevented');
    if DuneCorrected(iterid)
        % disp('Error: Part of the correction is made above the water line')
        writemessage(-5, 'Error: Part of the correction for landward transport is made above the water line');
    end
end


%% isolate best result

solutionprecision = min(diff([Volume(iterid) ProfileFluct])); % precision is the difference between Volume and ProfileFluct; positive means ProfileFluct>Volume; negative means ProfileFluct<Volume

if ~SolutionPossibleWithinBoundaries && abs(precision) < abs(solutionprecision)
    % tweede conditie wellicht overbodig...(precisie is per definitie niet gehaald als er geen oplossing is)??
    msgs = writemessage('get');
    SeawardBoundaryBasedOnWLOrProfileShape = any(ismember([msgs{:,1}],[14 22]));
    if iterid==1 && SeawardBoundaryBasedOnWLOrProfileShape
        result = result(iterid);
        result.info.ID = 'No Erosion';
        result.info.x0 = x0(iterid);
        result.info.precision = 0;
        result.info.iter = Iter;
        result.info.time = toc;
        result.info.resultinboundaries = true;
        x0Solution = x0(iterid);
        if any([msgs{:,1}]==22)
            z0Solution = interp1(xInitial,zInitial,x0Solution);
            [xInitial sid] = unique(cat(1,xInitial,x0Solution));
            zInitial = cat(1,zInitial,z0Solution);
            zInitial = zInitial(sid);
        else
            z0Solution = WL_t;
        end
        [result.VTVinfo.Xp result.VTVinfo.Xr] = deal(x0Solution);
        [result.VTVinfo.Zp result.VTVinfo.Zr] = deal(z0Solution );
        result.xLand = xInitial(xInitial < x0Solution);
        result.xSea = xInitial(xInitial > x0Solution);
        result.xActive = x0Solution;
        result.zLand = zInitial(xInitial < x0Solution);
        result.zSea = zInitial(xInitial > x0Solution);
        result.zActive = z0Solution;
        result.z2Active = z0Solution;
        [result.Volumes.Accretion, result.Volumes.Erosion, result.Volumes.Volume, result.Volumes.volumes] = deal(0);
        if dbstate
            dbPlotDuneErosion('final parab')
        end
        return
    else
        writemessage(-7, 'No solution found within iteration boundaries');
    end
end

result = result(iterid);
result.info.x0 = x0(iterid);
result.info.precision = solutionprecision;
result.info.iter = Iter;
result.info.time = toc;
result.info.resultinboundaries = SolutionPossibleWithinBoundaries;
result.VTVinfo.Xp = max([min(result.xActive),result.info.x0]);
result.VTVinfo.Zp = result.z2Active(result.xActive == result.VTVinfo.Xp);
result.VTVinfo.Xr = min(result.xActive);
result.VTVinfo.Zr = result.z2Active(result.xActive == result.VTVinfo.Xr);

if dbstate
    dbPlotDuneErosion('final parab')
end

end
%% subfunction getNextx0

function [nextx0 idpos idneg] = getNextx0(Volume,ProfileFluct,x0)

% find identifier of Volume closest but larger than ProfileFluct
idpos = find(x0==min(x0(Volume>ProfileFluct)));
if length(idpos)>1
    % prevent a vector of idpos
    [dummy IX] = sort(x0(idpos));
    idpos = idpos(IX(1)); % take the first one
end

% find identifier of Volume closest but smaller than ProfileFluct
idneg = find(x0==max(x0(Volume<ProfileFluct)));
if length(idneg)>1
    % prevent a vector of idpos
    [dummy IX] = sort(x0(idneg));
    idneg = idneg(IX(end)); % take the last one
end

% use linear interpolation to estimate next x0
nextx0 = interp1(Volume([idpos idneg]), x0([idpos idneg]), ProfileFluct);

end