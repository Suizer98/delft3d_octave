function [x z] = jarkus_combine_profiles(x1, z1, x2, z2, varargin)
%JARKUS_COMBINE_PROFILES  combine two jarkus profiles
%
%   Connect the landward part of profile 1 (x1, z1) with the seaward part o
%   profile 2 (x2, z2). The connection is made at a predefined contour. For
%   both profiles the most landward ('first') or most seaward ('last')
%   crossing with the connection contour can be selected.
%
%   Syntax:
%   varargout = jarkus_combine_profiles(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_combine_profiles
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Mar 2012
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_combine_profiles.m 6709 2012-06-29 08:46:06Z heijer $
% $Date: 2012-06-29 16:46:06 +0800 (Fri, 29 Jun 2012) $
% $Author: heijer $
% $Revision: 6709 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_combine_profiles.m $
% $Keywords: $

%%
OPT = struct(...
    'contour', -4,...
    'crossing1', 'first',...
    'crossing2', 'first');

OPT = setproperty(OPT, varargin);

%%
mask1 = true(size(x1));
mask1(find(z1 < OPT.contour, 1, OPT.crossing1):end) = false;

mask2 = true(size(x2));
mask2(1:find(z2 < OPT.contour, 1, OPT.crossing1)-1) = false;

%%
dx1_tr = diff(x1([diff(~mask1(:)); false] | [false; diff(~mask1(:))]));
dx2_tr = diff(x2([diff(~mask2(:)); false] | [false; diff(~mask2(:))]));

dx_tr = mean([dx1_tr dx2_tr]);

x1_end = x1(diff(~mask1)==1);
x2_start = x2(diff(~[true ~mask2])==1);

x = [x1(mask1) x2(mask2)-x2_start+x1_end+dx_tr];
z = [z1(mask1) z2(mask2)];