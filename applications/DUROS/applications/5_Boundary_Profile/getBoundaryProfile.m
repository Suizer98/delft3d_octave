function result = getBoundaryProfile(WL_t, Tp_t, Hsig_t, x0)
%GETBOUNDARYPROFILE     routine to create boundary profile
%
% This routine returns the boundary profile landward of the x-location x0
%
% Syntax:       result = getBoundaryProfile(WL_t, Hsig_t, Tp_t, x0)
%
% Input: 
%               WL_t      = Water level [m] w.r.t. NAP
%               Tp_t      = Peak wave period [m]
%               Hsig_t    = Significant wave height [m]
%               x0        = x-location most seaward point of boundary
%                               profile
%
% Output:       Eventual output is stored in a structure result 
%
%   See also fitBoundaryProfile
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

%%
result = createEmptyDUROSResult;

ProfileHeight = max([2.5 .12*Tp_t*sqrt(Hsig_t)]); % profile should be at least 2.5 m high

result.xActive = x0 - [3*ProfileHeight+3 ProfileHeight+3 ProfileHeight 0]';
result.z2Active = WL_t + [0 ProfileHeight ProfileHeight 0]';
result.zActive = ones(4,1)*WL_t;

[result.xLand, result.zLand, result.xSea, result.zSea] = deal([]);
result.Volumes.Volume = 3/2 * ProfileHeight^2 + 3*ProfileHeight;
result.info.ID = 'Boundary Profile';