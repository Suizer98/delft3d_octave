function [xmax, z, Tp_t] = ParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, x0, x)
%PARABOLICPROFILEMAIN  Diverts to the correct function that calculates the shape of the parabolic profile.
%
%   Based on DuneErosionSettings this function diverts the calculation of
%   the parabolic profile to the correct (or at least specified) function.
%
% Syntax:       [xmax, y, Tp_t] = ParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, x0, x)
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
% Output:       Eventual output is stored in a variables xmax, z and Tp_t
%
%   See also getParabolicProfile DuneErosionSettings
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
% Created: 08 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: ParabolicProfileMain.m 1815 2009-10-22 07:18:00Z geer $
% $Date: 2009-10-22 15:18:00 +0800 (Thu, 22 Oct 2009) $
% $Author: geer $
% $Revision: 1815 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/1_DUROS_profiel_calculation/ParabolicProfileMain.m $
% $Keywords: $

%% Retrieve settings

fcnHandle = DuneErosionSettings('ParabolicProfileFcn');
profileArgs = DuneErosionSettings('ParabolicProfileFcnInput');

profileArgs(strcmp(profileArgs,'#PARHS_T')) = {Hsig_t};
profileArgs(strcmp(profileArgs,'#PARWL_T')) = {WL_t};
profileArgs(strcmp(profileArgs,'#PARTP_T')) = {Tp_t};
profileArgs(strcmp(profileArgs,'#PARW')) = {w};
profileArgs(strcmp(profileArgs,'#PARX0')) = {x0};
profileArgs(strcmp(profileArgs,'#PARX')) = {x};
profileArgs(strcmp(profileArgs,'#PARD')) = {DuneErosionSettings('get','d')};

%% Calculate parabolic profile
[xmax, z, Tp_t] = feval(fcnHandle,profileArgs{:});


