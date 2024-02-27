function result = fitBoundaryProfile(xInitial, zInitial, x2, z2, WL_t, Tp_t, Hsig_t, x0min, x0max, x0except)
%FITBOUNDARYPROFILE    routine to fit the boundary profile into the profile 
% 
% This routine returns a volumepatch of the boundary profile, located just 
% landward of the dune erosion computation (x2, z2). Basically the
% prescribed boundary profile is used. If necessary, the volumetric
% boundary profile is fitted landward of the result profile of the dune
% erosion computation (x2, z2)
%
% Syntax:       result = fitBoundaryProfile(xInitial, zInitial,
%                   x2, z2, WL_t, Tp_t, Hsig_t, x0min, x0max, x0except)
%
% Input: 
%               xInitial  = column array containing x-locations of initial profile [m]
%               zInitial  = column array containing z-locations of initial profile [m]
%               x2        = column array with x2 points (increasing index and positive x in seaward direction)
%               z2        = column array with z2 points
%               WL_t      = Water level [m] w.r.t. NAP
%               Tp_t      = Peak wave period [s]
%               Hsig_t    = wave height [m]
%               x0min     = landward boundary of boundary profile
%               x0max     = seaward boundary of boundary profile
%               x0except  = possible exception area because of dune valleys
% Output:       Eventual output is stored in a variables result 
%
%   See also getBoundaryProfile
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2007 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

% $Id: fitBoundaryProfile.m 12800 2016-07-06 06:21:37Z nederhof $ 
% $Date: 2016-07-06 14:21:37 +0800 (Wed, 06 Jul 2016) $
% $Author: nederhof $
% $Revision: 12800 $

%%
result = getBoundaryProfile(WL_t, Tp_t, Hsig_t, x0max);
BoundaryProfileAboveProfile = sum(interp1(xInitial, zInitial, result.xActive) < result.z2Active) > 0;
% NoCrossingsWithProfile = ~isempty(findCrossings(xInitial, zInitial, result.xActive, result.z2Active));
if BoundaryProfileAboveProfile
    TargetVolume  = -result.Volumes.Volume*0.75; % Attention, TargetVolume represents an additional amount of erosion, which is a negative number (!)
    [x3, z3] = deal([0; max(xInitial)-min(xInitial)], [WL_t; WL_t]);
    result = getDuneErosion_volumetricboundaryprofile(x2, z2, x3, z3, WL_t, x0min, x0max, x0except, TargetVolume, []);
    result.info.ID = 'Volumetric Boundary Profile';
end