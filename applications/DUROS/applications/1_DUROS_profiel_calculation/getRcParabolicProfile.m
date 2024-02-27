function rcparab = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z)
%GETRCPARABOLICPROFILE calculates the derivative of the parabolic profile given input and height
%
% This routine returns the derivative of the parabolic profile given the input
% WL_t, Hsig_t, Tp_t, w and z
%
% Syntax:
% rcparab = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z);
%
% Input:
%               WL_t      = Water level [m] ('Rekenpeil')
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%               z         = vector (n x 1) with z coordinates
%
% Output:       
%		rcparab   = vector the same size as z with
%				values of the derivative of the parabolic
%				profile at the heights specified in z
%
%   See also getParabolicProfile getIterationBounderies
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, November 2008 (Version 1.0, November 2008)
% By:           <Pieter van Geer (email: Pieter.vanGeer@deltares.nl)>
% --------------------------------------------------------------------------

%% initiate variables
Plus = DuneErosionSettings('get','Plus');
dz = 0.05;
ztemp = [z-dz, z+dz];

%% Correct Tp_t
% This step should not be necessary whereas it is already done in the main function
% (getDuneEroision).
if strcmp(Plus,'') && Tp_t~=12
    Tp_t = 12;
end

%% Calculate x coordinates
% for all z values of z+dz and z-dz
[c_hs c_tp c_1 cp_hs cp_tp cp_w c_w] = DuneErosionSettings('get','c_hs','c_tp','c_1','cp_hs','cp_tp','cp_w','c_w');
% c_hs = 7.6;
% c_tp = 12;
% c_1 = 0.4714;
% cp_hs = 1.28;
% cp_tp = 0.45;
% cp_w = 0.56;
% c_w = 0.0268;
dxparab = (((-(ztemp-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(18))/c_1).^2-18) / (((c_hs/Hsig_t).^cp_hs)*((c_tp/Tp_t).^cp_tp)*((w/c_w).^cp_w));

%% Calculate value of derivative
rcparab = (2*dz)./diff(dxparab,1,2);