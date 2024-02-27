function varargout = dgst_get_defaultshearstrength(varargin)
%DGST_GET_DEFAULTSHEARSTRENGTH  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_get_defaultshearstrength(varargin)
%
%   Input: For <keyword,value> pairs call dgst_get_defaultshearstrength() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_get_defaultshearstrength
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
%
%       Deltares
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
% Created: 25 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% cell array with available default shear strength types
DSS = {...
    'C phi'... 1
    'Stress tables'... 2
    'Cu calculated'... 3
    'Cu measured'... 4
    'Cu gradient'... 5
    'Pseudo values'... 6
    };

M = varargin{1};
switch class(M)
    case 'struct'
        % try to retreive both the model.default_shear_strength and the default_shear_strength output
        [mm, m] = xs_get(M, 'model.default_shear_strength', 'default_shear_strength');
        if ~isempty(mm)
            % if structure M contains the input at the highest level, mm
            % should be the default shear strength code
            mdl = mm;
        elseif ~isempty(m)
            % if structure M contains the default shear strength input only, m should be the
            % model code
            mdl = m;
        else
            warning('default shear strength not found in input.')
            varargout = {};
            return
        end
        % return structure with both name and code of model
        varargout = {struct('name', dgst_get_defaultshearstrength(mdl), 'code', mdl)};
    case 'char'
        % assume the input to be a default shear strength name, return the corresponding
        % code
        varargout = {find(strcmpi(M, DSS))};
    case 'double'
        % assume the input to be a default shear strength code, return the corresponding
        % name
        varargout = DSS(M);
end