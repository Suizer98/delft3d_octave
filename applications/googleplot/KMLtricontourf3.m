function varargout = KMLtricontourf3(tri,lat,lon,z,varargin)
%KMLTRICONTOURF3  Wrapper for KMLtricontourf, to make it 3D
%
%     KMLtricontourf3(tri,lat,lon,z,<keyword,value>)
%
%See also: GooglePlot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 05 Mar 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: KMLtricontourf3.m 3074 2010-09-22 10:53:25Z boer_g $
% $Date: 2010-09-22 18:53:25 +0800 (Wed, 22 Sep 2010) $
% $Author: boer_g $
% $Revision: 3074 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLtricontourf3.m $
% $Keywords: $

%% process varargin

OPT               = KMLcontourf();
OPT.is3D          = true;
OPT.extrude       = true;
OPT.staggered     = true;
if nargin==0
    varargout = {OPT};
  return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

KMLcontourf(lat,lon,z,tri,OPT);