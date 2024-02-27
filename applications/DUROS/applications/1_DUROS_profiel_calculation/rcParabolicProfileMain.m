function rcparab = rcParabolicProfileMain(WL_t, Hsig_t, Tp_t, w, z)
%RCPARABOLICPROFILEMAIN  Diverts to the correct function that calculates the rc of the parabolic profile.
%
%   Based on DuneErosionSettings this function diverts the calculation of
%   rc of the parabolic profile to the correct (or at least specified) 
%   function.
%
% Syntax:
% rcparab = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z);
%
% Input:
%               WL_t      = Water level [m] ('Rekenpeil')
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%		z	  = vector (n x 1) with z coordinates
%
% Output:       
%		rcparab   = vector the same size as z with
%				values of the derivative of the parabolic
%				profile at the heights specified in z
%
%   See also getRcParabolicProfile getIterationBounderies ParabolicProfileMain
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

% $Id: rcParabolicProfileMain.m 1815 2009-10-22 07:18:00Z geer $
% $Date: 2009-10-22 15:18:00 +0800 (Thu, 22 Oct 2009) $
% $Author: geer $
% $Revision: 1815 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/1_DUROS_profiel_calculation/rcParabolicProfileMain.m $
% $Keywords: $

%% Retrieve settings

fcnHandle = DuneErosionSettings('rcParabolicProfileFcn');
rcprofileArgs = DuneErosionSettings('rcParabolicProfileFcnInput');

rcprofileArgs(strcmp(rcprofileArgs,'#PARHS_T')) = {Hsig_t};
rcprofileArgs(strcmp(rcprofileArgs,'#PARTP_T')) = {Tp_t};
rcprofileArgs(strcmp(rcprofileArgs,'#PARW')) = {w};
rcprofileArgs(strcmp(rcprofileArgs,'#PARZ')) = {z};
rcprofileArgs(strcmp(rcprofileArgs,'#PARWL_T')) = {WL_t};
rcprofileArgs(strcmp(rcprofileArgs,'#PARD')) = {DuneErosionSettings('get','d')};

%% Calculate rc of parabolic profile
rcparab = feval(fcnHandle,rcprofileArgs{:});



