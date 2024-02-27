function [xmax, z, Tp_t] = getParabolicProfilePLUSPLUS(WL_t, Hsig_t, Tp_t, w, x0, x)
%GETPARABOLICPROFILEPLUSPLUS    routine to create the parabolic DUROS/DUROS+/D++ profile 
% 
% This routine returns the most seaward x-coordinate of the parabolic DUROS
% (-plus) profile. If variable x with x-coordinates exists, than also the
% y-coordinates of the parabolic profile will be given
% 
% Syntax:       [xmax, y, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x)
% 
% Input: 
%               WL_t      = Maximum storm surge level [m]
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               d_t       = water depth [m] (derived from DUROS settings!)
%               w         = fall velocity of the sediment in water
%               x0        = x-location of the origin of the parabolic
%                               profile
%               x         = array with x-coordinates to create the
%                               parabolic profile on
% 
% Output:       Eventual output is stored in a variables xmax and z
% 
%   See also ParabolicProfileMain getFallVelocity
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

Plus                                    = DuneErosionSettings('get','Plus');
[c_hs, c_tp, c_w]                       = DuneErosionSettings('get','c_hs','c_tp','c_w');
[cp_hs, cp_tp, cp_w]                    = DuneErosionSettings('get','cp_hs','cp_tp','cp_w');
[c_1, c_2, c_1plusplus, c_2plusplus]    = DuneErosionSettings('get','c_1','c_2','c_1plusplus','c_2plusplus');
[xref,xrefplusplus]                     = DuneErosionSettings('get','xref','xrefplusplus');
[d_t]                                   = DuneErosionSettings('get','d');
[gammaplusplus,thetaplusplus]           = DuneErosionSettings('get','gammaplusplus','thetaplusplus');
[periodtype]                            = DuneErosionSettings('get','Period');
cfdepth = 1;

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
%% ----------- D++0 ----------- 
elseif strcmp(Plus,'-plusplus0') % -plusplus0 is only used for testing purposes!
    c_1       = c_1plusplus;
    c_2       = c_2plusplus;
    xref      = xrefplusplus;
    two       = c_1*sqrt(c_2);   % by using this expression, the profile will exactly cross (x0,0)
%% ----------- D++ ----------- 
elseif strcmp(Plus,'-plusplus')
    depth     = d_t + WL_t;
    c_1       = c_1plusplus;
    c_2       = c_2plusplus;
    xref      = xrefplusplus;
    two       = c_1*sqrt(c_2);   % by using this expression, the profile will exactly cross (x0,0)
    HS_d      = (Hsig_t/depth);
    delta     = max(min((HS_d-gammaplusplus)/thetaplusplus,1),0);
    cfdepth   = (1-delta) + delta*max((15/depth+0.11),1);    %overrule cfdepth with D++ values
    %fprintf('cfepth value = %4.3f, depth=%3.1f, Hs=%3.1f\n',cfdepth,depth,Hsig_t);
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''');
end

waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
fallvelocitycmpt = (w/c_w)^cp_w;

y                = (c_1*sqrt(waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
xmax             = x0 + xref * cfdepth * waveheightcmpt^-1 * fallvelocitycmpt^-1;

% round to 8 decimal digits to prevent rounding problems later on
y = roundoff(y, 8);

%% translate y to z
z = WL_t-y;