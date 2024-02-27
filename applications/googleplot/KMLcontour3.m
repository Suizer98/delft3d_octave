function varargout = KMLcontour3(lat,lon,z,varargin)
% KMLCONTOUR3   Just like contour3
%
%    KMLcontour3(lat,lon,c,  <keyword,value>)
%
% plots 3D contours with color c at level c.
%
%    KMLcontour3(lat,lon,z,c,<keyword,value>)
%
% plots 3D contours with color c at level z. z values are
% interpolated from the z matrix at the location of the
% c contours, this process (griddata) is SLOW. Set keyword 
% 'zstride' to use only a subset from the z matrix to interpolate to.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontour3()
%
% The most important keywords are 'fileName' and 'levels';
%
%    OPT = KMLcontour3(lat,lon,z,<c>,'fileName','mycontour3.kml','levels',20)
%
% The kml code hat is written to file 'fileName' can optionally be returned.
%
%    kmlcode = KMLcontour3(lat,lon,z,<c>,<keyword,value>)
%
% Example: time animated 3d contour kml file:
%         [lat,lon] = meshgrid(54:.1:57,2:.1:5);
%         z = peaks(31);
%         z = abs(z);
%         t = now;
% 
%         OPT = KMLcontour3;
%         OPT.zScaleFun   = @(z) (z+1)*2000;
% 
%         OPT.fileName    = 'timestep1.kml';
%         OPT.timeIn      = t+0;
%         OPT.timeOut     = t+2;
%         KMLcontour3(lat   ,lon,   z+2, OPT);
% 
%         OPT.fileName    = 'timestep2.kml';
%         OPT.timeIn      = t+2;
%         OPT.timeOut     = t+3;
%         KMLcontour3(lat   ,lon,   z+1, OPT);
% 
%         OPT.fileName    = 'timestep3.kml';
%         OPT.timeIn      = t+3;
%         OPT.timeOut     = t+4;
%         KMLcontour3(lat   ,lon,   z+.5, OPT);
% 
%         OPT.fileName    = 'timestep4.kml';
%         OPT.timeIn      = t+4;
%         OPT.timeOut     = t+5;
%         KMLcontour3(lat   ,lon,   z+.2, OPT);
% 
%         KMLmerge_files('fileName','Animated 3d contour.kml',...
%             'sourceFiles',{'timestep1.kml','timestep2.kml','timestep3.kml','timestep4.kml'},...
%             'deleteSourceFiles',true);
% 
% See also: googlePlot, contour, contour3

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

% $Id: KMLcontour3.m 4900 2011-07-25 14:24:42Z boer_g $
% $Date: 2011-07-25 22:24:42 +0800 (Mon, 25 Jul 2011) $
% $Author: boer_g $
% $Revision: 4900 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcontour3.m $
% $Keywords: $

%% process varargin

OPT               = KMLcontour();
OPT.is3D          = true;
OPT.zScaleFun     = @(z) (z+20)*10;
OPT.zstride       = 1; % stride for interpolating z data to contours

if nargin==0
   varargout = {OPT};
end

c = [];
nextarg = 1;
if nargin==0
  return
elseif ~odd(nargin) & ~isstruct(varargin{1});
  c = varargin{1};
  varargin(1) = [];
end

[OPT, Set, Default] = setproperty(OPT, varargin{:});

if isempty(c)
   [kmlcode,pngNames] = KMLcontour(lat,lon,z,  OPT); % c==z
else
   [kmlcode,pngNames] = KMLcontour(lat,lon,z,c,OPT);
end

if nargout > 0
   varargout = {kmlcode, pngNames};
else
   varargout = {OPT, Set, Default};
end

%% EOF