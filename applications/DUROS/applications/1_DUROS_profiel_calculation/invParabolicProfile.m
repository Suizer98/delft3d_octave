function dx = invParabolicProfile(WL_t,Hsig_t,Tp_t,w,z)
%INVPARABOLICPROFILE  Calculates the exact x-position of a contour line for in the parabolic profile.
%
%   Based on the (inverse) formulation of a parabolic profile this function 
%   calculates the exact x-position (relative to x0) of a contour line.
%
%   Syntax:
%   dx = invParabolicProfile(WL_t,Hsig_t,Tp_t,w,z)
%
% Input:
%               WL_t      = Water level [m] ('Rekenpeil')
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%               z         = vector (n x 1) with z coordinates
%
% Output:       
%       dx   = vector the same size as z with values of the relative 
%               x-position of the contours specified in z
%
%   See also invParabolicProfileMain getParabolicProfile getIerationBounderies getRcParabolicProfile
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: invParabolicProfile.m 1815 2009-10-22 07:18:00Z geer $
% $Date: 2009-10-22 15:18:00 +0800 (Thu, 22 Oct 2009) $
% $Author: geer $
% $Revision: 1815 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/1_DUROS_profiel_calculation/invParabolicProfile.m $
% $Keywords: $

%% Switch method
Plus = DuneErosionSettings('get','Plus');
if strcmp(Plus,'') && Tp_t~=12
    Tp_t = 12;
end

%% Retrieve settings
[c_hs c_tp c_1 cp_hs cp_tp cp_w c_w] = DuneErosionSettings('get','c_hs','c_tp','c_1','cp_hs','cp_tp','cp_w','c_w');

%% Calculate x position
dx = (((-(z-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(18))/c_1).^2-18) / (((c_hs/Hsig_t).^cp_hs)*((c_tp/Tp_t).^cp_tp)*((w/c_w).^cp_w));