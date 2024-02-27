function S = oettestroot(varargin)
% OETTESTROOT  root directory of OpenEarthTools tests
%
% S = oettestroot returns a string that is the name of the directory
% where the OpenEarthTools tests are installed.
%
% see also: matlabroot oetroot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 25 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: oettestroot.m 4345 2011-03-25 10:24:23Z geer $
% $Date: 2011-03-25 18:24:23 +0800 (Fri, 25 Mar 2011) $
% $Author: geer $
% $Revision: 4345 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oettestroot.m $
% $Keywords: $

%%
S = fileparts(which('oettestsettings')); % fulle filename of current file

if isempty(S)
    error('OET:General','The openearth tests could not be found.');
end

S = [S filesep];

%% EOF