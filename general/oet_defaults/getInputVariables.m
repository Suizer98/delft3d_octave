function [inputVariables str] = getInputVariables(fun)
%GETINPUTVARIABLES  routine derives the input variable names of the caller function
%
%   Routine determines the input variable names of function 'fun', as well
%   as the complete call of the function. If 'fun'
%   not specified, the 'caller' function will be scanned.
%
%   Syntax:
%   [inputVariables str] = getInputVariables(fun)
%
%   Input:
%   fun            = string containing the name of a function
%
%   Output:
%   inputVariables = cell array containing the input variable names
%   str            = string containing syntax
%
%   Example
%   getInputVariables
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

% $Id: getInputVariables.m 6244 2012-05-25 09:05:26Z heijer $
% $Date: 2012-05-25 17:05:26 +0800 (Fri, 25 May 2012) $
% $Author: heijer $
% $Revision: 6244 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/getInputVariables.m $
% $Keywords:

%% check input
if ~exist('fun','var') % get filename of caller function if 'fun' not specified
    ST = dbstack;
    if length(ST)>1
        fun = ST(2).file; % derives the file name of the caller function
    else % it should be possible to add the functionality that the variables of the workspace will be assigned to 'inputVariables'
        return
        % this will produce an error whereas none of the output vars have 
        % been determined yet......
    end
end

%% turn fun into a function handle
[fun fl] = checkfhandle(fun);

%% read relevant part of caller function

str = getFunctionCall(fun);

if ~fl && isempty(str)
   error('GETVARIABLES:NotExistingFile',['File ', fun, ' does not exist']);
end

if isempty(str)
    inputVariables = 'varargin';
    return
end

%% read input variables from string
inputVariables = cellfun(@strtrim, regexp(str, '(?<=(\(|,))[^,=\[\]]*(?=(\)|,))', 'match'),...
    'UniformOutput', false);