function varargout = KMLpatch(lat,lon,varargin)
%KMLPATCH Just like patch
%
%    KMLpatch(lat,lon,<c>,<keyword,value>)
% 
% only works for a single patch (filled polygon)
% see the keyword/value pair defaults for additional options. 
% For the <keyword,value> pairs call.
%
%    OPT = KMLpatch()
%
% See also: googlePlot, KMLpatch3, KMLtrisurf, KML_poly, patch

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id: KMLpatch.m 3388 2010-11-24 09:10:37Z boer_g $
% $Date: 2010-11-24 17:10:37 +0800 (Wed, 24 Nov 2010) $
% $Author: boer_g $
% $Revision: 3388 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLpatch.m $
% $Keywords: $

%% process varargin
z   = 'clampToGround';

OPT = KMLpatch3();

OPT.extrude            = false;
OPT.tessellate         = true;

if nargin==0
   varargout = {OPT};
   return
end
    
if odd(nargin)
   c = varargin{1};
  [OPT, Set, Default] = setproperty(OPT, varargin{2:end});
   KMLpatch3(lat,lon,z,c,OPT); % TO DO does not work yet.
else
  [OPT, Set, Default] = setproperty(OPT, varargin{:});
   KMLpatch3(lat,lon,z,OPT);
end


varargout = {};
