function rcparab = getRcParabolicProfilePLUSPLUS(WL_t, Hsig_t, Tp_t, w, z)
%GETRCPARABOLICPROFILEPLUSPLUS calculates the derivative of the parabolic profile given input and height
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
Plus                                    = DuneErosionSettings('get','Plus');
[c_hs, c_tp, c_w]                       = DuneErosionSettings('get','c_hs','c_tp','c_w');
[cp_hs, cp_tp, cp_w]                    = DuneErosionSettings('get','cp_hs','cp_tp','cp_w');
[c_1, c_2, c_1plusplus, c_2plusplus]    = DuneErosionSettings('get','c_1','c_2','c_1plusplus','c_2plusplus');
[periodtype]                            = DuneErosionSettings('get','Period');
dz     = 0.05;
ztemp  = [z-dz, z+dz];

if strcmpi(periodtype,'TMM10')
    % If Tm-1,0 is used, the base period is divided by 1.105
    c_tp=c_tp/1.105;
end
%% ----------- DUROS ----------- 
if strcmp(Plus,'')
    Tp_t      = 12;
    c_tp      = 12;
    cp_tp     = 0;   %waveperiodcmpt = 1
    two       = c_1*sqrt(c_2);   % by using this expression, the profile will exactly cross (x0,0)
%% ----------- DUROS+ ----------- 
elseif strcmp(Plus,'-plus')
    two       = c_1*sqrt(c_2);   % by using this expression, the profile will exactly cross (x0,0)
%% ----------- D++ ----------- 
elseif strcmp(Plus,'-plusplus') | strcmp(Plus,'-plusplus0')
    c_1       = c_1plusplus;
    c_2       = c_2plusplus;
    two       = c_1*sqrt(c_2);   % by using this expression, the profile will exactly cross (x0,0)
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end

%% Calculate x coordinates
% for all z values of z+dz and z-dz
waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
fallvelocitycmpt = (w/c_w)^cp_w;
dxparab = (((-(ztemp-WL_t).*(c_hs/Hsig_t)+two)/c_1).^2-c_2) / (waveheightcmpt*waveperiodcmpt*fallvelocitycmpt);

%% Calculate value of derivative
rcparab = (2*dz)./diff(dxparab,1,2);