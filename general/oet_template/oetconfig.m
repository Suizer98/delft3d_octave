function oetconfig()
%OETCONFIG  Open OET user specifuc config file
%
%   This function opens the OpenEarthTools user condig file for editing.
%   The config file is used whenever the user creates a function or class
%   using oetnewfun or oetnewclass
%
%   Syntax:
%   oetconfig()
%
%   See also oetnewfun oetnewclass

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl
%
%       Rotterdamseweg185
%       2629 HD Delft
%       P.O. Box 177 
%       2600 MH Delft 
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
% Created: 26 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: oetconfig.m 9588 2013-11-06 10:21:02Z boer_g $
% $Date: 2013-11-06 18:21:02 +0800 (Wed, 06 Nov 2013) $
% $Author: boer_g $
% $Revision: 9588 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/oetconfig.m $
% $Keywords: $

%% Edit config file
edit(fullfile(getenv('APPDATA'), 'OET', 'config'))