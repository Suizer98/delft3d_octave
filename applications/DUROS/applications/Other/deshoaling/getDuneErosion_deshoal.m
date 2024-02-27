function [result, messages, waveconversioninfo] = getDuneErosion_deshoal(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, d)
%GETDUNEEROSION_DESHOAL Calculates dune erosion according to the DUROS+ method with "deshoaling"
%
%   This is the main routine for calculations of dune erosion with the
%   DUROS+ method. The first step is to recalculate the significant wave 
%   height to one at 20 [m] depth. This is done with linear wave theory.
%   Based on hydraulic input parameters a parabolic erosion
%   profile is determined. This profile is extended with a part above the
%   water line (1:1) and beneath the toe (1:12,5). The erosion profile is
%   fitted in the initial profile in such a way that the amount of
%   accretion equals the amount of erosion. Influences of coastal bends and
%   or channels near the dune are incorporated as well as dune breaches.
%   After calculation of the erosion profile the function determines: the 
%   amount of erosion above the maximum storm search level; any additional
%   erosion (due to uncertainties in the calculation method) and; fits a
%   boundary profile in the remaining erosion profile.
%
%   Syntax:
%   [result, messages, waveconversioninfo] = getDuneErosion_deshoal(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t, d)
%
%   Input:
%   xInitial /zInitial -    doubles (n*1) with x-points and the 
%                           corresponding height of the dune initial profile.
%   D50                -    Grain size.
%   WL_t               -    Maximum storm search level
%   Hsig_t             -    Significant wave height during the storm
%   Tp_t               -    Peak wave period during the storm
%   d                  -    Bottom height at the location of the given wave 
%			    height [m].
%
%   Output:
%   result             -    a struc that contains the results for each
%                           calculation step. The result struct has fields:
%                               info:    information about the calculation
%                                           step
%                               Volumes: Cumulative volumes, erosion volume
%                                           and accretion volume
%                               xActive: x-coordinates of the area that was
%                                           changes during the calculation 
%                                           step
%                               zActive: z-coordinates of the points that
%                                           was changes prior to the change
%                               z2Active:z-coordinates of the changed
%                                           points
%                               xLand:   x-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zLand:   z-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               xSea:    x-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zSea:    z-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%   messages            -   error, and warning messages that occured during
%                           the calculation
%   waveconversioninfo  -   struc with information about the conversion of
%                           the wave height.
%                               
%   Example
%
%   See also getDuneErosion deshoal iterateWaveLength

%   --------------------------------------------------------------------
%   Copyright (C) $date(yyyy) $Company
%       $author
%
%       $email	
%
%       $address
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: getDuneErosion_deshoal.m 1661 2009-02-12 14:20:39Z geer $
% $Date: 2009-02-12 22:20:39 +0800 (Thu, 12 Feb 2009) $
% $Author: geer $
% $Revision: 1661 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/Other/deshoaling/getDuneErosion_deshoal.m $
% $Keywords: dune dunes erosion DUROS DUROS+ VTV beach

%% Deshoal the Hs
Hs = deshoal(Hsig_t, Tp_t, d+WL_t, 20+WL_t);

%% Calculate dune erosion

[result messages] = getDuneErosion(xInitial, zInitial, D50, WL_t, Hs, Tp_t);

%% TODO: wave conversion info (k, n, etc).
waveconversioninfo = [Hs, Hsig_t];
