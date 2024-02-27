function resultout = getDuneErosion_additional(xInitial,zInitial,DUROSresult,WL_t,TargetVolume,AVolume,maxRetreat,x0except)
%GETDUNEEROSION_ADDITIONAL  routine to fit additional dune erosion into profile
%
% This routine returns the x-location of the floating profile (x2, z2) to fit
% a TargetVolume between the initial profile and profile (x2, z2)
%
% Syntax:       result = getDuneErosion_additional(xInitial,
%       zInitial, x2, z2, WL_t, x0min, x0max, x0except, TargetVolume)
%
% Input:
%               xInitial  = column array containing x-locations of initial (for this particular step) profile [m]
%               zInitial  = column array containing z-locations of initial (for this particular step) profile [m]
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
%               x0DUROS   = x-location of origin of DUROS-profile
%               AVolume   = Erosion volume above SSL (DUROS-profile)
%
% Output:       Eventual output is stored in a structure result
%
%   See also getDuneErosion_DUROS
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 2.0, April 2008 (Version 1.0, December 2007)
% By:           <Pieter van Geer (email: Pieter.vanGeer@deltares.nl)>
% --------------------------------------------------------------------------

% $Id: getDuneErosion_additional.m 4763 2011-07-06 09:17:29Z geer $
% $Date: 2011-07-06 17:17:29 +0800 (Wed, 06 Jul 2011) $
% $Author: geer $
% $Revision: 4763 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/4_AdditionalErosion/getDuneErosion_additional.m $

%% Initiate variables

tic;
getdefaults('TargetVolume', 0, 1,...
    'maxRetreat', [], 0);

if TargetVolume < 0
    % determine maximum iteration boundary
    x0max = DUROSresult.VTVinfo.Xp;
    x0maxBoundary = {'XpDUROS'};
    
    % determine minimum x0 that can be placed in the profile
    x0endBound = {'endofprofile'};
    if zInitial(1) > WL_t
        x0endofprofile = min(xInitial) + zInitial(xInitial==min(xInitial))-WL_t;
    else
        x0endofprofile = min(findCrossings(xInitial,zInitial,[min(xInitial),max(xInitial)],ones(1,2)*WL_t,'keeporiginalgrid'));
        if ~isempty(maxRetreat)
            if (x0endofprofile - min(xInitial)) > maxRetreat
                x0endBound = {'dunevalley'};
            end
        end
    end
    
    % construct the x0min
    if ~isempty(maxRetreat)
        % calculate maximum Xr point
        newXr = DUROSresult.VTVinfo.Xr - maxRetreat;
        newZr = interp1(xInitial,zInitial,newXr);
        
        % add point to profile
        if ~ismember(newXr, xInitial) && newXr > max(xInitial)
            [xInitial sid] = sort(cat(1,xInitial,newXr));
            zInitial = cat(1,zInitial,newZr);
            zInitial = zInitial(sid);
        end
        % construct x0min.
        % 1. If the new Xr point lies above the water level, the corresponding
        %    x0 point lies at the water line. The slope of the dune is 1:1,
        %    therefore the change of the x position equals newZr-WL_t.
        %    In case the new Zr point lies below the water line, no dune front
        %    is present. The x0 position is than virtually above the new Xr.
        % 2. If the profile does not have enough information the x0min is
        %    restricted by the profile information (x0endofprofile) and not
        %    limited by the maximum retreat.
        if newZr> WL_t
            x0min = max([newXr + newZr-WL_t,...
                x0endofprofile]);
        else
            x0min = max([newXr,x0endofprofile]);
        end
        if x0min == x0endofprofile
            x0minBoundary = x0endBound;
        else
            x0minBoundary = {'maxRetreat'};
        end
    else
        x0min = x0endofprofile;
        x0minBoundary = x0endBound;
    end
elseif TargetVolume > 0
    writemessage(40, 'Warning: Additional erosion volume is positive, this reduces the retreat distance');
    
    % determin x0max as the most seaward intersection of the initial profile with WL_t
    x0max = max(findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*WL_t, 'keeporiginalgrid'));  
    x0maxBoundary = {'WLcrossing'};
    
    % determine x0min
    x0min = DUROSresult.VTVinfo.Xp;
    x0minBoundary = {'XpDUROS'};
else
    %% target volume is zero
    % We do not have to make a calculation. The result of this calculation
    % can easily be ontained from the result of the DUROS calculation.
    xDUROS = DUROSresult.xActive;
    zDUROS = DUROSresult.z2Active;
    Xr = DUROSresult.VTVinfo.Xr;
    Zr = DUROSresult.VTVinfo.Zr;
    resultout = createEmptyDUROSResult(...
        'xLand', [xInitial(xInitial<min(xDUROS)); xDUROS(xDUROS<Xr)],...
        'zLand', [zInitial(xInitial<min(xDUROS)); zDUROS(xDUROS<Xr)],...
        'xActive', Xr,...
        'zActive', Zr,...
        'z2Active', Zr,...
        'xSea', [xDUROS(xDUROS>Xr); xInitial(xInitial>max(xDUROS))],...
        'zSea', [zDUROS(xDUROS>Xr); zInitial(xInitial>max(xDUROS))],...
        'Xr', Xr,...
        'Zr', Zr,...
        'Xp', DUROSresult.VTVinfo.Xp,...
        'Zp', DUROSresult.VTVinfo.Zp,...
        'TVolume',0,...
        'Volume', 0,...
        'volumes', 0,...
        'Accretion', 0,...
        'Erosion', 0,...
        'ID', 'Additional Erosion',...
        'x0', DUROSresult.info.x0,...
        'iter', 0,...
        'precision', 0);
    return
end

if ~isempty(x0except)
    id = x0max > x0except(:,1) & x0max < x0except(:,2);
    if sum(id)>0
        % x0max lies inside a dune valley
        x0max = min(x0except(id,:));
        x0maxBoundary = cat(1,x0maxBoundary,{'dunevalley'});
    end
    id = x0min > x0except(:,1) & x0min < x0except(:,2);
    if sum(id)>0
        % x0min lies inside a dune valley
        x0min = max(x0except(id,:));
        x0minBoundary = cat(1,x0minBoundary,{'dunevalley'});
    end
end

%% Check iteration boundaries. If non consistent: find out why and return

% add iteration boundaries to profile
xInitial2 = unique(cat(1,xInitial,x0min,x0max));
if length(xInitial2) ~= length(xInitial)
    zInitial = interp1(xInitial,zInitial,xInitial2);
    xInitial = xInitial2;
end

IterationBoundariesConsistent = x0max > x0min;
NoPointsAtOrAboveWaterline = all(zInitial(xInitial>=x0min & xInitial<=x0max) <= WL_t);
if ~IterationBoundariesConsistent || NoPointsAtOrAboveWaterline
    xDUROS = DUROSresult.xActive;
    zDUROS = DUROSresult.z2Active;
    Xr = DUROSresult.VTVinfo.Xr;
    resultout = createEmptyDUROSResult(...
            'xLand', [xInitial(xInitial<min(xDUROS)); xDUROS(xDUROS<Xr)],...
            'zLand', [zInitial(xInitial<min(xDUROS)); zDUROS(xDUROS<Xr)],...
            'xActive', Xr,...
            'zActive', DUROSresult.VTVinfo.Zr,...
            'z2Active', DUROSresult.VTVinfo.Zr,...
            'xSea', [xDUROS(xDUROS>Xr); xInitial(xInitial>max(xDUROS))],...
            'zSea', [zDUROS(xDUROS>Xr); zInitial(xInitial>max(xDUROS))],...
            'Xr', Xr,...
            'Zr', DUROSresult.VTVinfo.Zr,...
            'Xp', DUROSresult.VTVinfo.Xp,...
            'Zp', DUROSresult.VTVinfo.Zp,...
            'ID', 'Additional Erosion');
        
    if strcmp(x0minBoundary{end},'dunevalley') && strcmp(x0maxBoundary{end},'dunevalley')
        writemessage(45, ['Erosional length restricted within dunevalley. An additional erosion volume of 0 m^3/m^1 (TargetVolume = ' num2str(TargetVolume) ' m^3/m^1) leads to an additional retreat of 0 m.']);
        % complete erosion volume is inside a valley (DUROS result as
        % well). This can only occur if no restriction is applied. No
        % calculation is necessary. We already know the answer.
        resultout.VTVinfo.TVolume = 0;
        resultout.Volumes.Volume = 0;
        resultout.Volumes.volumes = 0;
        resultout.Volumes.Accretion = 0;
        resultout.info.precision = -TargetVolume;
        resultout.info.x0 = Xr;
        resultout.info.resultinboundaries = true;
        resultout.info.input.WL_t = WL_t;
    elseif any(strcmp(x0minBoundary,'endofprofile'))
        % there is no part of the erosion profile above the waterlevel
        % after a DUROS calculation.
        writemessage(41,'No additional erosion possible');
        writemessage(17,'No result possible, not enough profile information at landward side available');
        resultout.info.x0 = Xr;
    elseif TargetVolume > 0 && AVolume == 0
        % (In this case also xmin == xmax)
        % No additional erosion whereas we have no erosion and a positive
        % additional erosion volume
        resultout.VTVinfo.TVolume = 0;
        resultout.Volumes.Volume = 0;
        resultout.Volumes.volumes = 0;
        resultout.Volumes.Accretion = 0;
        resultout.Volumes.Erosion = 0;
        resultout.info.x0 = DUROSresult.info.x0;
        resultout.info.iter = 0;
        resultout.info.precision = TargetVolume;
    elseif NoPointsAtOrAboveWaterline && any(strcmp(x0minBoundary,'maxRetreat'))
        % No points above the water line within the retreat distance. Result is 0
        writemessage(45, ['Erosional length restricted within dunevalley. An additional erosion volume of 0 m^3/m^1 (TargetVolume = ' num2str(TargetVolume) ' m^3/m^1) leads to an additional retreat of 0 m.']);
        resultout.VTVinfo.TVolume = 0;
        resultout.Volumes.Volume = 0;
        resultout.Volumes.volumes = 0;
        resultout.Volumes.Accretion = 0;
        resultout.info.precision = -TargetVolume;
        resultout.info.x0 = Xr;
        resultout.info.resultinboundaries = true;
        resultout.info.input.WL_t = WL_t;
    else
        % something else is wrong.
        TODO('Figure out what is the case and which message to give');
        writemessage(-99,'Iteration boundaries are non-consistent');
    end
    return
end

%% iterate the Additional erosion
resultout = getAdditionalErosion(xInitial,zInitial,...
    'TargetVolume',TargetVolume + AVolume,...
    'poslndwrd',-1,...
    'zmin',WL_t,...
    'slope',1,...
    'x0max',x0max,...
    'x0min',x0min,...
    'precision',1e-2,...
    'maxiter',DuneErosionSettings('maxiter'));

% strangely enough:
%
% resultout.Volumes.Volume - (AVolume + TargetVolume)
%
% equals the precision of the solution, whereas:
%
% resultout.Volumes.Volume - AVolume - TargetVolume
%
% gives a slightly different result (O e-14).

%% Create correct patches
% construct DUROS profile
[xDUROS uid] = unique(cat(1,DUROSresult.xSea,DUROSresult.xLand,DUROSresult.xActive));
zDUROS = cat(1,DUROSresult.zSea,DUROSresult.zLand,DUROSresult.z2Active);
zDUROS = zDUROS(uid);
xextrapoints = [resultout.VTVinfo.Xp;resultout.VTVinfo.Xr];
zDUROSextrapoints = interp1(xDUROS,zDUROS,xextrapoints);
[xDUROS uid] = unique(cat(1,xDUROS,xextrapoints));
zDUROS = cat(1,zDUROS,zDUROSextrapoints);
zDUROS = zDUROS(uid);

if TargetVolume < 0
    % construct Additional erosion profile
    [xResultout uid] = unique(cat(1,...
        resultout.xLand,...
        resultout.xActive(resultout.xActive < DUROSresult.VTVinfo.Xp),...
        DUROSresult.xActive(DUROSresult.xActive>=DUROSresult.VTVinfo.Xp),...
        DUROSresult.xSea)...
        );
    zResultout = cat(1,...
        resultout.zLand,...
        resultout.z2Active(resultout.xActive<DUROSresult.VTVinfo.Xp),...
        DUROSresult.z2Active(DUROSresult.xActive>=DUROSresult.VTVinfo.Xp),...
        DUROSresult.zSea...
        );
    zResultout = zResultout(uid);
    xextrapoints = [DUROSresult.VTVinfo.Xp;DUROSresult.VTVinfo.Xr];
    zoutextrapoints = interp1(xResultout,zResultout,xextrapoints);
    [xResultout uid] = unique(cat(1,xResultout,xextrapoints));
    zResultout = cat(1,zResultout,zoutextrapoints);
    zResultout = zResultout(uid);

    % store profiles in result (and make correct patches)
    resultout.xSea = xDUROS(xDUROS > DUROSresult.VTVinfo.Xp);
    resultout.zSea = zDUROS(xDUROS > DUROSresult.VTVinfo.Xp);
    resultout.xLand = xDUROS(xDUROS < resultout.VTVinfo.Xr);
    resultout.zLand = zDUROS(xDUROS < resultout.VTVinfo.Xr);
    ActiveidDUROS = xDUROS <= DUROSresult.VTVinfo.Xp & xDUROS >= resultout.VTVinfo.Xr;
    ActiveidResult = xResultout <= DUROSresult.VTVinfo.Xp & xResultout >= resultout.VTVinfo.Xr;
    resultout.xActive = unique(cat(1,...
        resultout.VTVinfo.Xp,...
        resultout.VTVinfo.Xr,...
        DUROSresult.VTVinfo.Xp,...
        DUROSresult.VTVinfo.Xr,...
        xDUROS(ActiveidDUROS),...
        xResultout(ActiveidResult)));
    resultout.zActive = interp1(xDUROS,zDUROS,resultout.xActive);
    resultout.z2Active = interp1(xResultout,zResultout,resultout.xActive);
else
    resultout.xLand = DUROSresult.xLand;
    resultout.zLand = DUROSresult.zLand;
    xInitialActiveSeaID = xInitial > DUROSresult.VTVinfo.Xp & xInitial < resultout.VTVinfo.Xr;
    xInitialActiveLandID = xInitial < DUROSresult.VTVinfo.Xp & xInitial > DUROSresult.VTVinfo.Xr;
    [resultout.xActive uid] = unique(cat(1,...
        DUROSresult.VTVinfo.Xr,...
        DUROSresult.VTVinfo.Xp,...
        resultout.VTVinfo.Xr,...
        resultout.VTVinfo.Xp,...
        xInitial(xInitialActiveLandID),...
        xInitial(xInitialActiveSeaID)));
    resultout.zActive = cat(1,...
        DUROSresult.VTVinfo.Zr,...
        DUROSresult.VTVinfo.Zp,...
        resultout.VTVinfo.Zp,...
        resultout.VTVinfo.Zp,...
        interp1(DUROSresult.xActive,DUROSresult.z2Active,xInitial(xInitialActiveLandID)),...
        ones(sum(xInitialActiveSeaID),1)*resultout.VTVinfo.Zp);
    resultout.zActive = resultout.zActive(uid);
    zInitialinterp = interp1(xInitial,zInitial,resultout.xActive);
    idaboveinitial = resultout.zActive>zInitialinterp;
    resultout.zActive(idaboveinitial) = zInitial(ismember(xInitial,resultout.xActive(idaboveinitial)));
    zDUROSXp = resultout.VTVinfo.Zr;
    if resultout.VTVinfo.Xr > DUROSresult.VTVinfo.Xp
        zDUROSXp = interp1(xInitial,zInitial,DUROSresult.VTVinfo.Xp);
    end
    resultout.z2Active = cat(1,...
        DUROSresult.VTVinfo.Zr,...
        zDUROSXp,...
        resultout.VTVinfo.Zr,...
        resultout.VTVinfo.Zp,...
        zInitial(xInitialActiveLandID),...
        zInitial(xInitialActiveSeaID));
    resultout.z2Active = resultout.z2Active(uid);
    ActiveID = DUROSresult.xActive>resultout.VTVinfo.Xp;
    [resultout.xSea uid] = unique(cat(1,...
        DUROSresult.xSea,...
        DUROSresult.xActive(ActiveID)));
    resultout.zSea = cat(1,...
        DUROSresult.zSea,...
        DUROSresult.z2Active(ActiveID));
    resultout.zSea = resultout.zSea(uid);
end

% Calculate correct volumes etc
if numel(resultout.xActive)==1
    % No additional erosion
    TVolume = 0;
    resultout.Volumes.Volume = 0;
    resultout.Volumes.volumes = 0;
    resultout.Volumes.Accretion = 0;
    resultout.Volumes.Erosion = 0;
else
    [TVolume resulttemp] = getVolume(...
        'x',resultout.xActive,...          = column array with x points (increasing index and positive x in seaward direction)
        'z',resultout.zActive,...            = column array with z points
        'LowerBoundary',WL_t,...  = lower horizontal plane of volume area (not specified please enter [] as argument)
        'x2',  resultout.xActive,...     = column array with x2 points (increasing index and positive x in seaward direction)
        'z2',  resultout.z2Active);
    resultout.Volumes = resulttemp.Volumes;
end

% write VTV info
resultout.VTVinfo.TVolume = TVolume;

%% Check the result on boundaries and write messages if necessary
if ~resultout.info.resultinboundaries
    % perform check and write message
    msg = writemessage('get');
    msgcodes = [msg{:,1}];
    msgcodes(1:find(msgcodes==300))=[];
    if resultout.info.x0 == x0min || any(msgcodes == 24)
        AdditionalRetreat = resultout.VTVinfo.Xr - DUROSresult.VTVinfo.Xr;
        switch x0minBoundary{1}
            case {'maxRetreat', 'dunevalley'}
                if strcmp(x0minBoundary{end},'dunevalley')
                    writemessage(45, ['Erosional length restricted within dunevalley. An additional erosion volume of ' num2str(resultout.VTVinfo.TVolume, '%.2f') ' m^3/m^1 (TargetVolume = ' num2str(TargetVolume) ' m^3/m^1) leads to an additional retreat of ' num2str(AdditionalRetreat, '%.2f') ' m.']);
                else
                    writemessage(42, ['Additional retreat limit of ' num2str(maxRetreat) ' m reached. '...
                        'An Additional volume of ' num2str(resultout.VTVinfo.TVolume, '%.2f') ' m^3/m^1 (TargetVolume=' num2str(TargetVolume, '%.2f') ' m^3/m^1) leads to an additional retreat of ' num2str(AdditionalRetreat, '%.2f') ' m.']);
                end
                resultout.info.resultinboundaries = true;
            case 'endofprofile'
                writemessage(46, ['Erosional length restricted by lack of information on the landside. An additional erosion volume of ' num2str(resultout.VTVinfo.TVolume, '%.2f') ' m^3/m^1 (TargetVolume =' num2str(TargetVolume, '%.2f') 'm^3/m^1) could be achieved with an additional retreat of ' num2str(AdditionalRetreat, '%.2f') ' m.']);
                % erosional length restricted by profile info.
            case 'XpDUROS'
                % positive TargetVolume. If this (Volume = 0) is the best
                % solution, something went wrong. This should not occur.
        end
    else %(resultout.info.x0 == x0max) || any(msgcodes == 23)
        switch x0maxBoundary{1}
            case 'XpDUROS'
                % Should not occur. This is only the case when TargetVolume
                % = 0; We have already returned from this function if that
                % is the case
            case 'WLcrossing'
                % This can happen if the target volume is positive and
                % larger than A. In that case the result should be kept and
                % a warning must be given.
                writemessage(47,['TargetVolume (' num2str(TargetVolume, '%.2f') ') is positive and exceeds the A Volume (' num2str(AVolume, '%.2f') ').']);
        end
    end
end

resultout.info.time = toc;
