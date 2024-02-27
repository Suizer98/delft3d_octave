function lyrfracvoldiff = delft3d_lyrfracvoldiff(Nfs, istart, istop, varargin)
%DELFT3D_LYRFRACVOLDIFF determines the total volume difference of sediment 
% fractions between two time steps
%
%   Syntax:
%   lyrfracvoldiff = delft3d_lyrfracvoldiff(Nfs, istart, istop)
%
%   Input:
%   Nfs  = NEFIS structure obtained by vs_use([filenamestring]);
%   istart = start time step (integer)
%   istop = stop time step (integer)
%
%   Output:
%   lyrfracvoldiff = total volume difference of fractions between time steps
%
%   Example:
%   trim01 = vs_use('h:\NLMN1DT0012\A2056_GH\kwelder\modellen\wadw-zeeg-kwel2\tri-files\trim-ww25.dat');
%   T = vs_time(trim01);
%   istart = 1;
%   istop = T.nt_storage;
%   lyrfracvoldiff = delft3d_lyrfracvoldiff(trim01, istart, istop);
%
%   See also vs_use vs_time

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: delft3d_lyrfracvoldiff.m 2810 2010-07-09 13:07:57Z b.t.grasmeijer@arcadis.nl $
% $Date: 2010-07-09 21:07:57 +0800 (Fri, 09 Jul 2010) $
% $Author: b.t.grasmeijer@arcadis.nl $
% $Revision: 2810 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d_lyrfracvoldiff.m $
% $Keywords: $

%%

%% read data
lyrfrac_istart = squeeze(vs_let(Nfs,'map-sed-series',{[istart]},'LYRFRAC'));
thlyr_istart = squeeze(vs_let(Nfs,'map-sed-series',{[istart]},'THLYR'));
lyrfrac_istop = squeeze(vs_let(Nfs,'map-sed-series',{[istop]},'LYRFRAC'));
thlyr_istop = squeeze(vs_let(Nfs,'map-sed-series',{[istop]},'THLYR'));

%% determine volumes
lyrfracsize = size(lyrfrac_istart);
fracvol_istart = NaN(lyrfracsize);
fracvol_istop = NaN(lyrfracsize);
for i = 1:lyrfracsize(4)                                      % loop over fractions
    for j = 1:lyrfracsize(3)                                  % loop over layers
        fracvol_istart(:,:,j,i) = lyrfrac_istart(:,:,j,i).*thlyr_istart(:,:,j);
        fracvol_istop(:,:,j,i) = lyrfrac_istop(:,:,j,i).*thlyr_istop(:,:,j);        
    end
end

%% sum over all bed layers
fracvolsum_istart = squeeze(sum(fracvol_istart,3));                         % sum over all bed layers (3rd dimension of lyrfrac)
fracvolsum_istop = squeeze(sum(fracvol_istop,3));                           % sum over all bed layers

%% what's the difference
lyrfracvoldiff = fracvolsum_istop-fracvolsum_istart;                        % difference between first and last time step



