function [xmax, z, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x)
%GETPARABOLICPROFILE    routine to create the parabolic DUROS (-plus) profile 
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

Plus = DuneErosionSettings('get','Plus');

%%
[c_hs c_tp c_1 cp_hs cp_tp cp_w c_w] = DuneErosionSettings('get','c_hs','c_tp','c_1','cp_hs','cp_tp','cp_w','c_w');

[xmax, y] = deal([]);
two = c_1*sqrt(18); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
xmax = x0 + 250*(Hsig_t/c_hs)^cp_hs*(c_w/w)^cp_w;
if strcmp(Plus,'')
    if exist('x','var') && ~isempty(x)
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(w/c_w)^cp_w*(x-x0)+18)-two) / (c_hs/Hsig_t);
    end
elseif strcmp(Plus,'-plus')
    if exist('x','var') && ~isempty(x)
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(c_tp/Tp_t)^cp_tp*(w/c_w)^cp_w*(x-x0)+18)-two) / (c_hs/Hsig_t);
    end
else
    error('Warning: variable "Plus" should be either '''' or ''-plus''')
end

% round to 8 decimal digits to prevent rounding problems later on
y = roundoff(y, 8);

%% translate y to z
z = WL_t-y;