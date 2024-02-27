function evalstr = workspace2evalstr
%WORKSPACE2EVALSTR routine to create an evalstring of the workspace variables
%
% routine to create an evalstring including all the variables of the current 
% workspace (can also be the workspace of a function)
%
% Syntax:
% evalstr = workspace2evalstr
%
% Input:
%
% Output:
% evalstr = string containing variable definitions
%
% See also: var2evalstr

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% Created: 03 Apr 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: workspace2evalstr.m 328 2009-04-03 09:41:40Z heijer $
% $Date: 2009-04-03 17:41:40 +0800 (Fri, 03 Apr 2009) $
% $Author: heijer $
% $Revision: 328 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/workspace2evalstr.m $
% $Keywords: $

%% 
% make sure that the UserData is empty
set(0, 'UserData', []);

% save the workspace of the caller to a tempfile
evalin('caller', 'save([tempdir num2str(round(now)) ''.mat''])');

% load the tempfile from the current workspace
load([tempdir num2str(round(now)) '.mat']);

variables = who;

evalstr = '';
for i = 1:length(variables)
    evalstr = [evalstr...
        sprintf('%s', var2evalstr(eval(variables{i}), 'basevarname', variables{i}))]; %#ok<AGROW>
end