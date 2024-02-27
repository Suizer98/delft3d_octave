function [result zparabmin] = getDUROSprofile(xInitial, zInitial, x0, Hsig_t, Tp_t, WL_t, w, SeawardBoundaryofInterest, ChannelCalc)
%GETDUROSPROFILE    routine to create the DUROS profile
%
% This routine returns the DUROS (-plus) profile using basically the
% x-grid of the initial profile (xInitial), but adds x-locations if (part of) the
% grid is too coarse
%
% Syntax:      [result zparabmin] = getDUROSprofile(xInitial, zInitial, x0,
% Hsig_t, Tp_t, WL_t, w, SeawardBoundaryofInterest)
%
% Input:
%               xInitial  = column array containing x-locations of initial profile [m]
%               zInitial  = column array containing z-locations of initial profile [m]
%               x0        = x-location of the origin of the parabolic
%                               profile
%               Hsig_t    = wave height [m]
%               WL_t      = Water level [m] w.r.t. NAP
%               w         = fall velocity of the sediment in water
%
% Output:       Eventual output is stored in a structure result
%
%   See also getFallVelocity
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY
% Version:      Version 1.0, December 2007 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% --------------------------------------------------------------------------

%% default values

getdefaults(...
    'w', [DuneErosionSettings('get', 'FallVelocity') {225e-6}], 1,...
    'ChannelCalc', false, 0);

if iscell(w)
    w = feval(w{:});
end

%% Create emtpy result structure

result=createEmptyDUROSResult;

%% Initialize variables

% minimum required number of evenly distributed grid points to describe the
% parabolic profile
Ngrid = 20;

% endpoint of the parabolic profile
xmax = ParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, x0, []);

% recommended grid size, used as maximum during the check
XgridSize = (xmax-x0)/(Ngrid-1);

% margin for the grid size check
threshold = 1e-10;

%% create parabolic Profile
if isempty(xInitial);

    % create x-grid of parabolic part of the profile
    x2 = x0 + (0:Ngrid-1)'*XgridSize;

else
    getdefaults('SeawardBoundaryofInterest', xInitial(end), 0);
    
    % make sure that x-values are unique and ascending
    x2 = sort(unique(xInitial));
    id = (x2>=x0 & x2<=xmax); % identifiers parabolic part erosion profile
    x2 = [x0; x2(id); xmax];

    % check for positions where x-grid is too coarse
    if max(diff(x2))>XgridSize+threshold
        % identifiers of locations where x-grid is too coarse:
        ids = find((diff(x2)>XgridSize+threshold)>0);

        for i = 1 : length(ids) % all those too coarse locations
            id = [ids(i) ids(i)+1];
            % number of extra grid points required
            nrXtra = floor(diff(x2(id))/XgridSize);

            % x-interval to distribute the new points evenly over the
            % available area
            intXtra = diff(x2(id))/(nrXtra+1);

            % add extra point(s)
            x2 = [x2; x2(id(1))+(1:nrXtra)'*intXtra]; %#ok<AGROW>
        end
        x2 = sort(x2);
    end
end
x2 = sort(unique(x2));

% formulation for parabolic profile
[xmax, z2] = ParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, x0, x2);

zparabmin = min(z2);

if ~isempty(zInitial)
    [xparabcr, yparabcr, xInitial,zInitial,x2,z2] = findCrossings(xInitial,zInitial,x2,z2,'keeporiginalgrid');
    %
    %% Create face
    %
    [zmin, zmax] = deal(min(zInitial), max(zInitial));
    
    % duneface erosion profile 1:1; z = f(x)
    face = [-1 x0+WL_t];
    % most landward-upper point of face
    [xface, zface] = deal([polyval(face,zmax); x2(1)], [zmax; z2(1)]);
    
    if (diff(xface)==0)
        xfaceintersect = xface(1);
        zfaceintersect = zface(1);
    else
        % find intersections of face with initial profile
        [xfaceintersect, zfaceintersect, xInitial, zInitial] = findCrossings(xInitial, zInitial, xface, zface, 'keeporiginalgrid');
    end
    %
    %% Create Toe
    %
    % Create toe if lowest point in initial profile lies below lowest point
    % of parabolic profile.
    LowestPointProfileUnderParabZmin = z2(end) > zmin;
    ParabZminNotAboveProfile = interp1(xInitial,zInitial,x2(end))>= z2(end);
    if LowestPointProfileUnderParabZmin && (~ParabZminNotAboveProfile || ChannelCalc)
        
        % toe slope erosion profile 1:12.5; z = f(x)
        toe  = [-1/12.5 x2(end)/12.5+z2(end)];
        invtoe = [1/toe(1) -toe(2)/toe(1)]; % x = f(z)
        [xtoe, ztoe] = deal([x2(end); polyval(invtoe,zmin)], [z2(end); zmin]);
        
        % find crossings toe with initial profile
        [xtoeintersect, ztoeintersect, xtemp, ztemp] = findCrossings(xInitial(xInitial<=SeawardBoundaryofInterest), zInitial(xInitial<=SeawardBoundaryofInterest), xtoe, ztoe, 'keeporiginalgrid');
        [xInitial, zInitial] = deal([xtemp; xInitial(xInitial>SeawardBoundaryofInterest)], [ztemp; zInitial(xInitial>SeawardBoundaryofInterest)]);
        CrossingsToeWithProfile = ~isempty(xtoeintersect);
        if ~CrossingsToeWithProfile

            % no intersections between initial profile and toe profile.
            [x2cr, z2cr, xInitial, zInitial, x2, z2] = findCrossings(xInitial, zInitial, x2, z2, 'keeporiginalgrid');
            NoCrossingsParabWithProfile = isempty(x2cr);
            if NoCrossingsParabWithProfile
                % no intersection between parabolic profile and initial
                % profile either, probably due to rounding in xmax 
                % parabolic profile. Profile needs to be shifted to compensate.
                
                [xtempvals, zminparab, xInitial, zInitial] = findCrossings(xInitial,zInitial,xInitial,repmat(z2(end),size(xInitial)), 'keeporiginalgrid');
                diffs = diff([repmat(x2(end),size(xtempvals)),xtempvals],1,2);
                x2(end) = xtempvals(diffs==min(diffs));
%                 [xtoeintersect, ztoeintersect] = deal([x2(end); polyval(invtoe,zmin)], [z2(end); zmin]);
            end
        else
            ztoeintersect = ztoeintersect(xtoeintersect==min(xtoeintersect));
            xtoeintersect = min(xtoeintersect);
        end
    else
        [xtoeintersect,ztoeintersect] = deal([]);
    end
    
    %% Construct full profile
    [x2, z2] = deal([xfaceintersect; x2; xtoeintersect],[zfaceintersect; z2; ztoeintersect]);
    [x2, uniid] = unique(x2,'rows');
    [x2, sortid] = sort(x2);
    z2=z2(uniid);
    z2=z2(sortid);
    
    % Add crossings between initial profile and active part.
    xcrs = [xparabcr; xfaceintersect; xtoeintersect];
    maxactprof= max(xcrs);
    minactprof= min(xcrs);
    
%     % Add crossings between initial profile and active part.
%     [xActiveBoundaries zActiveBoundaries, xInitial, zInitial, x2, z2] = findCrossings(xInitial,zInitial,x2,z2,'keeporiginalgrid');
        
    % isolate active part of profile
    zparabmin=min(z2);
    xInitinactive=xInitial( xInitial>=minactprof & xInitial<=maxactprof );
    x2inactive = x2(x2 >= minactprof & x2 <= maxactprof);

    %% interpolate results on new grid
    result.xActive = sort(unique([x2inactive; xInitinactive]));
    result.zActive = interp1(xInitial,zInitial,result.xActive);
    result.z2Active = interp1(x2,z2,result.xActive);
    
    %% add land and seaward parts to result structure
    [idLand, idSea] = deal(xInitial<min(result.xActive), xInitial>max(result.xActive));
    [result.xLand, result.zLand, result.xSea, result.zSea] = deal(xInitial(idLand), zInitial(idLand), xInitial(idSea), zInitial(idSea));

    if dbstate
        dbPlotDuneErosion;
    end
    
    result.info.x0 = x0;

    %
    %% Calculate volumes and CumVolume
    %
    
    volume = getCumVolume(result.xActive,result.zActive,result.z2Active);
    [Volume, result.Volumes.Volume] = deal(sum(volume));
    [result.Volumes.volumes, result.Volumes.Accretion, result.Volumes.Erosion] = deal(volume, sum(volume(volume>0)), -sum(volume(volume<0)));

    result.info.ToeProfile = ~(xmax > result.xActive(end));

else % to create a floating profile, only xActive and z2Active are useful, other result structure fields are not filled
    [result.xActive, result.z2Active] = deal(x2, z2);
end
