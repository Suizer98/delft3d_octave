function Result = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod, x0Point)
%GETBOUNDARYPROFILE     routine to create boundary profile geometry
%
% This routine returns the boundary profile landward of the x-location x0
%
% Syntax:       
%               result = boundaryProfileGeometry(WL, Hs, Tp, x0);
%               result = boundaryProfileGeometry(WL, Hs, Tp);
%
% Input: 
%               WL      = Water level [m] w.r.t. NAP
%               Tp      = Peak wave period [m]
%               Hs      = Significant wave height [m]
%               x0      = x-location most seaward point of boundary
%                               profile (default = 0).
%
% Output:       Eventual output is stored in a structure result 
%
%   See also boundaryProfile boundaryprofilevolumetric
% 
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, November 2009 (Version 1.0, November 2009)
% By:           <Pieter van Geer (email: Pieter.VanGeer@deltares.nl)>                                                            
% --------------------------------------------------------------------------

%% Create empty result
Result = createemptydurosresult;

%% Check x0
if nargin<4
    x0Point = 0;
end

%% Calculate boundary profile height
profileHeight = max([2.5 .12*peakPeriod*sqrt(significantWaveHeight)]); % profile should be at least 2.5 m high

%% Construct profile (according to TRDA)
Result.xActive = x0Point - [3*profileHeight+3 profileHeight+3 profileHeight 0]';
Result.z2Active = waterLevel + [0 profileHeight profileHeight 0]';
Result.zActive = ones(4,1)*waterLevel;

%% Fill result structure with necessary information
[Result.xLand, Result.zLand, Result.xSea, Result.zSea] = deal([]);
Result.Volumes.Volume = 3/2 * profileHeight^2 + 3*profileHeight;
Result.info.ID = 'Boundary Profile';