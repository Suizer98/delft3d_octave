function Result = boundaryprofile(xInitial,zInitial,waterLevel,significantWaveHeight,peakPeriod,x0Point,varargin)
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
% Copyright (c) Deltares 2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, November 2009 (Version 1.0, November 2009)
% By:           <Pieter van Geer (email: Pieter.VanGeer@deltares.nl)>                                                            
% --------------------------------------------------------------------------

% $Id: boundaryprofile.m 4334 2011-03-25 08:40:23Z geer $ 
% $Date: 2011-03-25 16:40:23 +0800 (Fri, 25 Mar 2011) $
% $Author: geer $
% $Revision: 4334 $

%%
Result = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod, x0Point);
boundaryProfileAboveInitialProfile = sum(interp1(xInitial, zInitial, Result.xActive) < Result.z2Active) > 0;
if boundaryProfileAboveInitialProfile
    targetVolume  = -Result.Volumes.Volume; % Attention, TargetVolume represents an additional amount of erosion, which is a negative number (!)
    Result = boundaryprofilevolumetric(xInitial, zInitial, waterLevel, x0Point,...
        'TargetVolume', targetVolume);
    Result.info.ID = 'Volumetric Boundary Profile';
end