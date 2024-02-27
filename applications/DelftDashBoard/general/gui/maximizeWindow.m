function maximizeWindow(name)
%MAXIMIZEWINDOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   maximizeWindow(name)
%
%   Input:
%   name =
%
%
%
%
%   Example
%   maximizeWindow
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: maximizeWindow.m 5532 2011-11-28 17:56:41Z boer_we $
% $Date: 2011-11-29 01:56:41 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5532 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/maximizeWindow.m $
% $Keywords: $

%%

h = actxserver('WScript.Shell');
%Put the title of your window as seen in the title bar
h.AppActivate(name);
h.SendKeys('% '); %this is shortcut key ALT + {SPACE}
h.SendKeys('{DOWN 4}');
h.SendKeys('~'); %This is enter

