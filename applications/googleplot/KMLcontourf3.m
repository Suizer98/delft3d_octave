function varargout = KMLcontourf3(lat,lon,z,varargin)
%KMLcontourf3  Wrapper for KMLtricontourf, to make it 3D
%
%     KMLcontourf3(lat,lon,z,<keyword,value>)
%
% See also : GooglePlot

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

% $Id: KMLcontourf3.m 3207 2010-10-29 09:41:28Z boer_g $
% $Date: 2010-10-29 17:41:28 +0800 (Fri, 29 Oct 2010) $
% $Author: boer_g $
% $Revision: 3207 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/googleplot/KMLcontourf3.m $
% $Keywords: $

%%
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

KMLcontourf(lat,lon,z,OPT);