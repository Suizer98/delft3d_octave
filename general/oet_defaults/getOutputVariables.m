function [varsout str] = getOutputVariables(fun)
%GETOUTPUTVARIABLES  routine derives the output variable names of the caller function
%
%   Routine determines the output variable names of function "fun", as well
%   as the complete call of the function.
%
%   Syntax:
%   [varsout str] = getOutputVariables(fun)
%
%   Input:
%   fun     = string containing the name of a function
%
%   Output:
%   varsout = cell array containing the output variables of "fun"
%   str     = string containing syntax
%
%   Example
%   getOutputVariables
%
%   See also

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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 12 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: getOutputVariables.m 2493 2010-04-27 07:04:13Z heijer $
% $Date: 2010-04-27 15:04:13 +0800 (Tue, 27 Apr 2010) $
% $Author: heijer $
% $Revision: 2493 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/getOutputVariables.m $
% $Keywords:

%%
% maybe add same functionality as in getInputVariables???
if nargin==0
    error('not enough input parameters');
end

%% get function handle
[fun fl] = checkfhandle(fun);

if ~fl
    error('Specified function could not be found');
end

%% get fuinction call
str = getFunctionCall(fun);

if isempty(str)
    varsout = {'varargout'};
    return
end

%% isolate output variables
id = strfind(str, '=');
outstr = strtrim(str(1:id-1));
outstr = strrep(outstr, '[', '');
outstr = strrep(outstr, ']', '');
outstr = strrep(outstr, ',', ' ');
varsout = strread(outstr, '%s');