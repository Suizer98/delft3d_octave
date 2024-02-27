function [x00min, x0min, x0max, x0except, xInitial, zInitial, SeawardBoundaryofInterest, chpoints_new] = getIterationBoundaries(xInitial, zInitial, xparab, zparab, Hsig_t, Tp_t, WL_t, w)
%GETITERATIONBOURNDARIES   derive iteration boundaries given input variables
%
% This routine returns iteration boundaries to facilitate fitting
% equilibrium profile give input variables: xInitial, zInitial, WL_t,
% xparab, zparab
%
% Syntax:
% [x00min, x0min, x0max, x0except, xInitial, zInitial,
% SeawardBoundaryofInterest] = getIterationBoundaries(xInitial, zInitial, xparab, zparab, Hsig_t, Tp_t, WL_t, w)
%
% Input:
%               xInitial  = column array with x points (increasing index and
%                               positive x in seaward direction) [m]
%               zInitial  = column array with z points [m]
%               WL_t      = Water level [m] ('Rekenpeil')
%               xparab    = column array with x points of parabolic part
%                               equilibrium profile [m]
%               zparab    = column array with z points of parabolic part
%                               equilibrium profile [m]
%
% Output:       Eventual output is stored in variables x00min, x0min, x0max and x0except
%
%   See also
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, December 2007 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>
% --------------------------------------------------------------------------

%%
ChannelSlopes = DuneErosionSettings('ChannelSlopes');

%TODO: make inverse parabic function also suitable for DUROS, which means
%that Tp_t = 12 s should be taken into account
%{ temporary solution:
Method = DuneErosionSettings('get', 'Plus');
if strcmp(Method, '');
    Tp_t = 12;
end
%}

Basis = struct(...
    'general',[],...
    'x00min',[],...
    'x0min',[],...
    'x0max',[]);

%% most seaward (x0max)

% find crossings between profile and waterlevel

[xcross, zcross, xInitial, zInitial] = findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*WL_t, 'keeporiginalgrid');  % intersections of initial profile with WL_t
[xdum, zdum, xInitial, zInitial] = findCrossings(xInitial, zInitial, xInitial([1 end]), ones(2,1)*min(zparab), 'keeporiginalgrid');  % intersections of initial profile with WL_t

zInitial(ismember(xInitial, xdum)) = deal(min(zparab));

if isempty(xcross)
    % No crossings --> no boundaries can be defined!
    Basis.general(end+1) = 8;
    Reason2message(Basis);
    [x00min x0min x0max x0except SeawardBoundaryofInterest chpoints_new] = deal([]);
    return
end

% change exact values of crossings betwee initial profile and water
% level.
zInitial(ismember(xInitial, xcross)) = deal(WL_t);

% determine extends
x0max_wl = max(xcross); % most seaward intersection
x0sea = x0max_wl; % most seaward position of x0max
xparab = xparab - xparab(1); % reset x0 to zero

% Check lowest point of the profile in relation to the lowest parabolic
% point (to determine the need for a toe extension 1:12,5).
ParabZminUnderLowestPointProfile = min(zparab) < min(zInitial);

if ~ParabZminUnderLowestPointProfile
    % TODO: Why do we do this, it seems useless?
    toe  = [-1/12.5 (xparab(end)+x0max_wl)/12.5+zparab(end)];
    invtoe = [1/toe(1) -toe(2)/toe(1)]; % x = f(z)
    [xtoe, ztoe] = deal([xparab(end)+x0max_wl; polyval(invtoe,min(zInitial))], [zparab(end); min(zInitial)]);

    % find crossings toe with initial profile
    [xtoeintersect, ztoeintersect, xInitial, zInitial] = findCrossings(xInitial, zInitial, xtoe, ztoe, 'keeporiginalgrid');
end

% isolate part of initial profile seaward of x0max
% TODO: This could cause a problem when an important (high) bank appears
% just inside x0max. This could also shift the SWB.
[x, z] = deal(xInitial(xInitial>=x0max_wl), zInitial(xInitial>=x0max_wl));

% find all 'outer' corner points under SSL
rcInt = diff(z)./diff(x);
CornerIds = find([false; [diff(rcInt)<0; false]] & z>zparab(end)); % all 'outer' corners
ToeCornerIds = find([false; [diff(rcInt)<0; false]] & z<zparab(end)); % all 'outer' corners under the parabolic profile
rcparab = rcParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, z(CornerIds)); % derivative of the profile at the determined corners
% rcparab2 = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z(CornerIds)); % derivative of the profile at the determined corners
% TODO('Come up with new formulation');
% This does not check whether the 1:12,5 toe crosses the initial profile.
CornerIds = CornerIds(rcInt(CornerIds-1)> rcparab & rcInt(CornerIds)< rcparab); % Only select local maxima that "touch" (not cross) the parabolic profile.
ToeCornerIds = ToeCornerIds(rcInt(ToeCornerIds-1) < -1/12.5 & rcInt(ToeCornerIds)< 1/12.5);

% list all points that could act as most seaward point in solution.
Basisid = ones(1,length(CornerIds)+length(ToeCornerIds))*12;
points = [x(CornerIds) z(CornerIds); x(ToeCornerIds) z(ToeCornerIds); x(end) z(end)];

% temp seaward boundary = most seaward point of profile
SeawardBoundaryofInterest = x(end);

% calculate x0 values for seaward boundary points
dx = ones(size(points, 1),1) * x0max_wl; % pre-allocation
dx(points(:,2)>zparab(end)) = invParabolicProfileMain(WL_t,Hsig_t,Tp_t,w,points(points(:,2)>zparab(end),2));
dx(points(:,2)<=zparab(end)) = xparab(end) + 12.5*(zparab(end)-points(points(:,2)<=zparab(end),2));
x0max_new = points(:,1) - dx;

% rerieve x0max point of maximum x-coordinate of the profile
x0max_maxprofile = x0max_new(end); % Basisid = 6;
x0max_new(end) = [];

x0max_corn = x0max_new(x0max_new<=x0max_wl);
x0max = min([x0max_wl max([x0max_corn; x0max_maxprofile])]);

% if parabolic profile is under the initial profile use x0max_maxprofile as
% a definite boundary!!!
parabToeUnderMaxSeaInitProfile = min(zparab) < zInitial(xInitial == max(xInitial));
if parabToeUnderMaxSeaInitProfile
    x0max = min([x0max x0max_maxprofile]);
end
if x0max == x0max_wl
    Basis.x0max(end+1) = 4; % Crossing between max(zparab) and initial profile
elseif x0max == x0max_maxprofile
    Basis.x0max(end+1) = 6; 
    NrCrossingsInitialParab = length(findCrossings(xInitial, zInitial, xparab+x0max, zparab, 'keeporiginalgrid')); % Number of crossings between Initial and Parab (at most seaward position)
    if NrCrossingsInitialParab==0
        Basis.general(end+1) = 7; % Should be different code. This is not a problem of lack of data on landward side
        [x00min, x0min, x0max, x0except, chpoints_new]= deal([]);
        SeawardBoundaryofInterest = xInitial(end);
        Reason2message(Basis)
        return
    end
else
    Basis.x0max(end+1) = Basisid(find(x0max_new == max(x0max_new),1,'last'));
end

if dbstate
    dbPlotDuneErosion('x0max');
end

%% most landward (x00min)
k = find(zInitial>WL_t,1,'first'); % find identifier of most landward point above WL_t
if k>1 % means that most landward part of initial profile is below WL_t
    x00min = interp1(zInitial(k-1:k),xInitial(k-1:k),WL_t);  % x of intersection with WL_t
    Basis.x00min(end+1) = 9;
else % means that most landward point of initial profile is at or above WL_t
    if isempty(k)
        % If this does not give us a crossing, the water line lies above
        % the profile. That should be taken care of in DUROSCheckConditions
        k = find(zInitial==WL_t,1,'first');
    end
    x00min = xInitial(k)+zInitial(k)-WL_t; % x of intersection of WL_t and 1:1 slope through most landward point of the initial profile
    Basis.x00min(end+1) = 10;
end

if dbstate
    dbPlotDuneErosion('x00min');
end

%% exception boundaries; parts of the profile which are below WL_t and between x00min and x0max
x0except = [];
if zInitial(xInitial==min(xInitial))< WL_t
    % landward tail of the profile, being below water level, is dealt with
    % as exception
   x0except = [min(xInitial) min(xcross)] ;
end

xcross = xcross(xcross>x00min & xcross<max(xcross)); % possible intersections of WL_t with part initial profile seaward of x00min and landward of x0max
xcrossid = false(size(xInitial,1),1);
for icr = 1:length(xcross)
    xcrossid(xInitial==xcross(icr))=true;
end
xcrossid = find(xcrossid);
xcrossup = zInitial(xcrossid+1)>WL_t;
downs = xcross(diff([1; xcrossup])==-1);
ups = xcross(diff([1; xcrossup])==1);
x0except = flipud([x0except; [downs(1:length(ups)), ups]]);
if isempty(x0except)
    % to avoid problems with a variable of size 0x1
    x0except=[];
end

if dbstate
    dbPlotDuneErosion('x0except');
end

%% landward boundary for DUROS profile (x0min)
[x z] = deal([x0sea; xInitial(xInitial>x0sea)], [WL_t; zInitial(xInitial>x0sea)]); % isolate part of initial profile seaward of x0max
[xdum ydum x z] = findCrossings(x, z, [min(x) max(x)], [min(zparab) min(zparab)], 'keeporiginalgrid'); % crossings between profile and lowest level of parabolic part
x0min = [];
if ~isempty(xdum) % profile reaches below level parabolic part
    x0min = max([min(xInitial) min(xdum)-max(xparab)]); % first 'guess': end of parabolic part just crosses the initial profile
    % TODO: This leads to problems when one of the valleys reached below
    % zParabMin
    z(x>min(xdum)) = []; % leave out the part profile of the crossing
    x(x>min(xdum)) = []; % leave out the part profile of the crossing
    if x0min == min(xInitial)
        Basis.x0min(end+1) = 3;
    else
        Basis.x0min(end+1) = 1;
    end
end

x0min_old = x0min; % first guess of x0min
% determine corner points
rcInt = diff(z)./diff(x);
CornerIds = find([false; rcInt < 0 & [diff(rcInt)>0; false]]); % 'inner' corners
if dbstate
    scatter(x(CornerIds), z(CornerIds));
end

% derive the horizontal distance between origin of parabolic profile and
% each of the points (z-level of the cornerpoints) using the inverse of the parabolic formula
dxprb = invParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, z(CornerIds));
% derive the exact x-locations of those points
dx2 = x(CornerIds)-dxprb;
% x0min is at least the most landward profile point, and usually the
% mininum of the first-guess-x0min and the x0min's based on the
% cornerpoints
x0min = max([min(xInitial) min([dx2; x0min])]);

if x0min ~= x0min_old
    Basis.x0min(end+1) = 2;
end

MostLandwZAboveWL = zInitial(xInitial==min(xInitial))>WL_t;

if x0min < x00min && MostLandwZAboveWL
    x0min = x00min;
    Basis.x0min(end+1) = 11;
end % x0min must be equal or larger than x00min

IterationBoundariesConsistent = x0max > x0min;
if ~IterationBoundariesConsistent
    % to distinguish between non-consistent boundaries and a profile which
    % is too mild compared to the parabolic profile it has to be
    % checked whether in the most seaward posibility volume can be enclosed
    % (i.e. at least one crossing below the water level present)
    
    % this check must particularly focuss on the cornerpoints
    xp3 = unique([0; dxprb; max(xparab)]); %min(xparab):min(abs(dxprb))/2:max(xparab);
    % get corresponding y of parabolic profile
    [dum zp3] = ParabolicProfileMain(WL_t,Hsig_t, Tp_t, w, 0, xp3);
    
    % check for crossings between initial and parabolic profile
    [xcr zcr] = findCrossings(xInitial,zInitial,xp3+x0max,WL_t-zp3, 'keeporiginalgrid');
    % ignore the crossing at the water level
    xcr(zcr==WL_t) = []; 
    % --> zcr is rounded to 8 digits. This could cause problems when the
    %     WL_t is specified with more than 8 digits. To prevent problems,
    %     WL_t has been rounded to 8 decimal digits in DUROSCheckConditions
    if isempty(xcr) || all(dx2>x0max_wl)
        writemessage(-8, 'Initial profile is not steep enough to yield a solution under these conditions.');
    else
        if Basis.x0max == 6
            writemessage(25,'No result possible, not enough profile information at seaward side available');
        else
            writemessage(-99, 'Iteration boundaries are non-consistent');
        end
    end
    [x00min, x0min, x0max, x0except, chpoints_new]= deal([]);
    SeawardBoundaryofInterest = xInitial(end);
    return
end

if dbstate
    dbPlotDuneErosion('x0min');
end

%% Determine channel slopes

chpoints_new = [];
if ChannelSlopes
    % determine possible problems with channel slopes
    %     channelpoints = getSteepPoints(xInitial, zInitial, -1/12.5, zparab(end), x0max, 'first', 'exclude ripples'); % first 1/12.5 point, seaward of x0max and below the lowest point of the parabolic profile
    channelpoints = getSteepPoints(xInitial, zInitial, -1/12.5, zparab(end), x0max, '', 'exclude ripples');
    if ~isempty(channelpoints)
        writemessage(44,'Steep points could influence the accuracy of the solution.');
        % calculate x0 points.
        chpoints_new = ones(size(channelpoints,1),3);
        chpoints_new(:,2:3) = channelpoints;
        for i = 1:size(channelpoints,1)
            ztemp = channelpoints(i,2);
            if ztemp>zparab(end)
                % dx = invParabolicProfileMain(WL_t,ztemp,Hsig_t,Tp_t,w);
                dx = (((-(ztemp-WL_t).*(7.6/Hsig_t)+0.4714*sqrt(18))/0.4714).^2-18) / (((7.6/Hsig_t).^1.28)*((12/Tp_t).^0.45)*((w/0.0268).^0.56));
                TODO('Adjust to new formulation');
            else
                dx = xparab(end) + x0max + 12.5*(zparab(end)-channelpoints(i,2))-channelpoints(i,1);
            end
            chpoints_new(i,1) = x0max - dx;
        end
        if any(chpoints_new(:,1)>x0max & chpoints_new(:,1)<x0sea)
            x0max = max(chpoints_new(chpoints_new(:,1)<x0sea,1));
            Basis.x0max(end+1) = 5;
        end
    end
end
Reason2message(Basis)

%%
function Reason2message(Basis)
Messages = {
    11,	'Landward boundary based on crossing of lowest point of parabolic profile with initial profile';... % 1
    12,	'Landward boundary based on point of contact of parabolic profile with initial profile';...         % 2
    13,	'Landward boundary based on the lack of data at landward side';...                                  % 3
    14,	'Seaward boundary based on crossing of highest point of parabolic profile with initial profile';... % 4
    15,	'Seaward boundary based on 1:12.5 slope, i.e. non-erodible channel slope';...                       % 5
    16,	'Seaward boundary based on the lack of data at seaward side';...                                    % 6
    17,	'No result possible, not enough profile information at landward side available';...                 % 7
    18,	'No result possible, total profile is below water level';...                                        % 8
    19,	'Landward boundary x00min based on most landward cross section with the water level';...            % 9
    20,	'Landward boundary x00min based on 1:1 slope from most landward profile point';...                  %10
    21,	'Landward boundary based on limited data at landward side (x0min=x00min)';...                       %11
    22,	'Seaward boundary based on point of contact of parabolic profile with initial profile'...          %12
    };

for Field = fieldnames(Basis)'
    if ~isempty(Basis.(Field{1}))
        writemessage(Messages{Basis.(Field{1})(end),:});
    end
end
