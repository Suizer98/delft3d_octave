function varargout = dgst_get_model(varargin)
%DGST_GET_MODEL  Retreive the model type of D-Geo Stability
%
%   This function can provide the model name, the model code or both, based
%   on the type of input. If the model name is provided as input, the
%   corresponding code is returned, and vice versa. If an Xstructure is
%   provided as input, a structure with the fields "name" and "code" is
%   returned
%
%   Syntax:
%   varargout = dgst_get_model(varargin)
%
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_get_model(1)
%   dgst_get_model('Bishop')
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
% Created: 13 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: dgst_get_model.m 9220 2013-09-13 15:00:33Z heijer $
% $Date: 2013-09-13 23:00:33 +0800 (Fri, 13 Sep 2013) $
% $Author: heijer $
% $Revision: 9220 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DGeoStability/io/dgst_get_model.m $
% $Keywords: $

%% code
% cell array with available models
models = {...
    'Bishop'... 1
    'Fellenius'... 2
    'Spencer'... 3
    'Uplift_Van'... 4
    'Uplift_Spencer'... 5
    'Bishop_probabilistic_random_field'... 6
    'Horizontal_balance'... 7
    };

M = varargin{1};
switch class(M)
    case 'struct'
        % try to retreive both the model.model and the model output
        [mm, m] = xs_get(M, 'model.model', 'model');
        if ~isempty(mm)
            % if structure M contains the input at the highest level, mm
            % should be the model code
            mdl = mm;
        elseif ~isempty(m)
            % if structure M contains the model input only, m should be the
            % model code
            mdl = m;
        else
            warning('model not found in input.')
            varargout = {};
            return
        end
        % return structure with both name and code of model
        varargout = {struct('name', dgst_get_model(mdl), 'code', mdl)};
    case 'char'
        % assume the input to be a model name, return the corresponding
        % code
        varargout = {find(strcmpi(M, models))};
    case 'double'
        % assume the input to be a model code, return the corresponding
        % name
        varargout = models(M);
end