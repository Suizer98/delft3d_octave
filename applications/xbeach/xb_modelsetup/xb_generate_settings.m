function xb = xb_generate_settings(varargin)
%XB_GENERATE_SETTINGS  Generates a XBeach structure with model settings
%
%   Generates a XBeach structure with model settings. A minimal set of
%   default settings is used, unless otherwise provided. Settings can be
%   provided by a varargin list of name/value pairs.
%
%   Syntax:
%   xb = xb_generate_settings(varargin)
%
%   Input:
%   varargin  = Name/value pairs of model settings (e.g. 'nx',100,'ny',200)
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_settings()
%   xb = xb_generate_settings('nx', 100, 'ny', 200)
%
%   See also xb_generate_model

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_generate_settings.m 7015 2012-07-24 14:26:52Z hoonhout $
% $Date: 2012-07-24 22:26:52 +0800 (Tue, 24 Jul 2012) $
% $Author: hoonhout $
% $Revision: 7015 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_generate_settings.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'thetamin', -90, ...
    'thetamax', 90, ...
    'dtheta', 10, ...
    'tstop', 2000 ...
);

names = varargin(1:2:end);
values = varargin(2:2:end);

for i = 1:length(values)
	OPT.(names{i}) = values{i};
end

names = fieldnames(OPT);
values = struct2cell(OPT);

%% generate settings

xb_verbose(0,'---');
xb_verbose(0,'Generating settings');
xb_verbose(1,names,values);

xb = xs_empty();

f = fieldnames(OPT);
for i = 1:length(f)
    xb = xs_set(xb, f{i}, OPT.(f{i}));
end

xb = xs_meta(xb, mfilename, 'input');