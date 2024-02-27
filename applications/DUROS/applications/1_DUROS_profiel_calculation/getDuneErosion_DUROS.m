function [result, AVolume, x00min, x0max, x0except, x0min] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, DuneBreachOccured)
%GETDUNEEROSION_DUROS routine to find the balanced location of the DUROS profile
%
% This routine returns the x-location of the DUROS profile such that
% the sediment balance is equal to the ProfileFluct (usually 0)
%
% Syntax:       [result, AVolume, x00min, x0max, x0except] = getDuneErosion_DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, ProfileFluct)
%
% Input:
%               xInitial  = column array containing x-locations of initial profile [m]
%               zInitial  = column array containing z-locations of initial profile [m]
%               D50       = Grain size [m]
%               WL_t      = Water level [m] w.r.t. NAP
%               Hsig_t    = wave height [m]
%               DuneBreachOccured
%                         = Optional value (true / false) that is used
%                         internally to denote whether the routine called
%                         itself in case of a dune breach calculation
%
% Output:       Eventual output is stored in a variables AVolume, result, x00min, x0max, x0except
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% --------------------------------------------------------------------------

Plus = DuneErosionSettings('get','Plus');
if nargin<7
    DuneBreachOccured = false;
end
result=createEmptyDUROSResult;
NoDUROSResult=false;
xInitial=xInitial(~isnan(zInitial));
zInitial=zInitial(~isnan(zInitial)); %keep only the z-values which are non-NaN

DuneBreachMethod = DuneErosionSettings('DuneBreachCalculation'); % perform next calculation in case of breaching

if dbstate
    dbPlotDuneErosion;
end

%% Check input

% Todo change xSea, xActive and xLand to one array and arrays with
% logicals!!
[AVolume,x00min, x0max, x0except]=deal([]);
[result(1).xActive result(1).zActive]=deal(xInitial,zInitial);

if max(zInitial) < WL_t
    % disp('Not enough profile information above water level');
    writemessage(1,'Not enough profile information above water level');
    result(1).info.resultinboundaries = false;
    return
end

%% STEP 1; get DUROS profile
FallvelocityArgs = [DuneErosionSettings('get', 'FallVelocity') {D50}];
w = feval(FallvelocityArgs{:});
[FloatingProfile zparabmin] = getDUROSprofile(xInitial, [], 0, Hsig_t, Tp_t, WL_t, w, [],false);

ParabZminUnderLowestPointProfile = zparabmin < min(zInitial);
if ParabZminUnderLowestPointProfile
    % disp('Warning: parabolic profile reaches below initial profile');
    writemessage(3, 'Parabolic profile reaches below initial profile');
end

%% STEP 2; get iteration boundaries
[x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, channelslope_xpoints]...
    = getIterationBoundaries(xInitial, zInitial, FloatingProfile.xActive, FloatingProfile.z2Active, Hsig_t, Tp_t, WL_t, w);
   
[xcrossWL_t, zcrossWL_t, xInitial, zInitial] = findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*WL_t, 'keeporiginalgrid');  % intersections of initial profile with WL_t

if all(~isempty([x00min, x0min, x0max]))
    IterationBoundaries = true;
else
    IterationBoundaries = false;
end

%% STEP 3; optimise DUROS profile
if IterationBoundaries
    result = optimiseDUROS(xInitial, zInitial, WL_t, x0min, x0max, [], Hsig_t, Tp_t, w, SeawardBoundaryofInterest, channelslope_xpoints);
    SolutionPossibleBetweenBoundaries = result.info.resultinboundaries;
else
    result = createEmptyDUROSResult;
    result.xActive = xInitial;
    result.zActive = zInitial;
    result.VTVinfo.Xr = xcrossWL_t(end);
    result.VTVinfo.Zr = zcrossWL_t(end);
    SolutionPossibleBetweenBoundaries = false;
end

if ~SolutionPossibleBetweenBoundaries
    if result.info.x0 == x0min
        writemessage(5, 'Landward iteration boundary reached, solution not possible');
    elseif result.info.x0 == x0max
        writemessage(6, 'Seaward iteration boundary reached, solution not possible');
    end
end

messgs=writemessage('get');
CorrAboveWL = any([messgs{:,1}]==-5);
if isempty(result(1).z2Active) || ~SolutionPossibleBetweenBoundaries %|| CorrAboveWL
    NoDUROSResult=true;
    [AVolume,x00min, x0max, x0except]=deal([]);
end

if ~isempty(x0except) && result.info.x0 < max(x0except(:,2))
    breachnr = find(result.info.x0 < x0except(:,2), 1, 'last' );
    % disp(['Warning: Dune row number ',int2str(breachnr),' has been breached']);
    writemessage(60, ['Dune row number ',int2str(breachnr),' has been breached']);
    if DuneBreachMethod
        [ValleyDepth, ValleyWidth] = deal(0);
        for i = 1 : breachnr
            ValleyDepth(i) = WL_t - min(zInitial(xInitial>=x0except(i,1) & xInitial<=x0except(i,2)));
            ValleyWidth(i) = diff(x0except(i,:));
        end
        ResultInValley = any(result.info.x0 > x0except(:,1) & result.info.x0 < x0except(:,2));
        if max(ValleyWidth)>=100 && ResultInValley
            Hsig_t_new = min([max([.5 .7 * max(ValleyDepth(ValleyWidth>=100))]) Hsig_t]); % Hsig_t_new = .7*Valleydepth, but minimal .5 m and maximal Hsig_t
            % disp(['New wave height Hsig_t_new has been set to ',num2str(Hsig_t_new,'%.2f'),' m']);
            writemessage(61, ['New wave height Hsig_t_new has been set to ',num2str(Hsig_t_new,'%.2f'),' m']);
            [xInitial_new, zInitial_new] = deal([result.xLand; result.xActive; result.xSea], [result.zLand; result.z2Active; result.zSea]);
            result_new = getDuneErosion_DUROS(xInitial_new, zInitial_new, D50, WL_t, Hsig_t_new, Tp_t, true);
            if isempty(result_new(1).z2Active)
                NoDUROSResult=true;
                IterationBoundaries = false;
                [AVolume,x00min, x0max, x0except]=deal([]);
            else
                iter = result(1).info.iter;

                xActiveLimitsRes2 = [result_new(1).xActive(1) result_new(1).xActive(end)];
                xActiveLimitsRes1 = [result(1).xActive(1) result(1).xActive(2)];
                betweenresultsid = xInitial<min(xActiveLimitsRes1) & xInitial>max(xActiveLimitsRes2);
                result1id = result(1).xActive > max(xActiveLimitsRes2);
                
                % Construct combined active profile
                result_new(1).xActive  = [result_new(1).xActive;...
                    xInitial(betweenresultsid);...
                    result(1).xActive(result1id)];
                result_new(1).z2Active = [result_new(1).z2Active;...
                    zInitial(betweenresultsid);...
                    result(1).z2Active(result1id)];
                result_new(1).zActive  = interp1(xInitial,zInitial,result_new(1).xActive);

                % add other properties and profiles to result.
                result_new(1).zSea = result(1).zSea;
                result_new(1).xSea = result(1).xSea;
                result = result_new(1);
                result.info.iter = result.info.iter + iter;
            end
        end
    end
elseif isempty(x0except)
    ResultAvailable = ~isempty(result(1).info.x0);
    if ResultAvailable
        if result(1).info.x0 <= xInitial(1)
%             TwoCrossingsWithWL_t = length(xcrossWL_t) == 2;
            if result.info.x0 < xcrossWL_t(1)
                breachnr = 1;
                % disp(['Warning: Dune row number ',int2str(breachnr),' has been breached']);
                writemessage(60, ['Dune row number ',int2str(breachnr),' has been breached']);
            end
        end
    end
end
result(end).info.ID = ['DUROS',Plus];

%% STEP 4; get final DUROS profile and find AVolume

if DuneBreachOccured
    return
end
if ~NoDUROSResult
    writemessage(200,'Start second step: Fit A volume');
    [AVolume, result(end+1)] = getVolume(xInitial, zInitial, [], WL_t, min(result(end).xActive), max(xcrossWL_t), [result(end).xActive; result(end).xSea], [result(end).z2Active; result(end).zSea],...
        'suppressMessEqualBoundaries', true); %TODO: combine several active profiles in case of breach
    result(end).VTVinfo.AVolume = AVolume;
    if AVolume<0
        result(end).info.ID = [result(end-1).info.ID,' Erosion above SSL'];
    else
        result(end).info.ID = [result(end-1).info.ID,' No erosion'];
        writemessage(43, 'No erosion');
    end
elseif ~IterationBoundaries
    result(1).info.resultinboundaries = false;
else
    ErosionUntillMostLandwardProfilePoint = result.xActive(1) == xInitial(1);
    if ErosionUntillMostLandwardProfilePoint
        writemessage(2, 'Not enough profile information at landward side');
    end
end
