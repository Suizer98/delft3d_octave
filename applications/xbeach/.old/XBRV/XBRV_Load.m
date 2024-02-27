function XBRV_Load(varargin)
%XBRV_LOAD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   XBRV_Load(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   XBRV_Load
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 27 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: XBRV_Load.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBRV/XBRV_Load.m $
% $Keywords: $

%%
h=guidata(varargin{1});

dirname = uigetdir;

if isnumeric(dirname)
    return
end

set(h.dirfield,'String',dirname);

TODO('User specification of variables that have to be read?');
XB = XB_Read_Results(dirname,CreateEmptyXBeachVar,'3d','zb','zs','H','nodisp');

set(h.fig,'UserData',XB);

XBRV_StartVideo(varargin{:},1)