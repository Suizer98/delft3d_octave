function data = prob_FORM_designpoint(result, varargin)
%PROB_FORM_DESIGNPOINT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_FORM_designpoint(varargin)
%
%   Input: For <keyword,value> pairs call prob_FORM_designpoint() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_FORM_designpoint
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 03 Oct 2012
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id: prob_FORM_designpoint.m 7494 2012-10-15 15:33:17Z heijer $
% $Date: 2012-10-15 23:33:17 +0800 (Mon, 15 Oct 2012) $
% $Author: heijer $
% $Revision: 7494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/prob_FORM_designpoint.m $
% $Keywords: $

%%
OPT = struct(...
    'rowdelimiter', '\n',...
    'columndelimiter', '',...
    'sigfigs', 3,...
    'sortVar', 'alphas',...
    'sortFcn', @(v) sort(v.^2, 2, 'descend'));
% return defaults (aka introspection)
if nargin==0;
    varargout = OPT;
    return;
end
OPT = setproperty(OPT, varargin );
% overwrite defaults with user arguments
%% code
data.varnames = cellfun(@(x) x, {result.Input.Name}, 'uniformoutput', false);
data.varvalues = cellfun(@(x) result.Output.designpoint.(x), data.varnames);
data.alphas = result.Output.alpha;

[~, ix] = OPT.sortFcn(data.(OPT.sortVar));

varnames = data.varnames(ix);
varvalues = data.varvalues(ix);
alphas = data.alphas(ix);

headerstrings = {'Variable' 'Value' 'alpha^2 * 100 [%]'};

maxstrlength = max(cellfun(@length, [varnames headerstrings(1)]));
maxnumlength = max([cellfun(@(x) length(sprintf(['%.' num2str(OPT.sigfigs) 'g'], x)), num2cell(varvalues)), length(headerstrings{2})]) + 2;
maxperclength = max([4 length(headerstrings{3})]);

rowdelimiters = repmat({OPT.rowdelimiter}, 1, length(varnames));
columndelimiters = repmat({OPT.columndelimiter}, 1, length(varnames));

data = [varnames' num2cell(varvalues') num2cell(alphas'.^2 *100)]';
% data = [{'Variable' 'alpha^2 * 100 [%]'}; data]
header = sprintf(...
    ['%-' num2str(maxstrlength+1) 's' OPT.columndelimiter ' %-' num2str(maxnumlength) 's ' OPT.columndelimiter ' %-' num2str(maxperclength) 's'],...
    headerstrings{:});
formats = [...
    repmat({['%-' num2str(maxstrlength+1) 's']}, 1, length(varnames));...
    columndelimiters;...
    repmat({['%' num2str(maxnumlength+1) '.' num2str(OPT.sigfigs) 'g ']}, 1, length(varnames));...
    columndelimiters;...
    repmat({['%' num2str(maxperclength+1) '.1f ']}, 1, length(varnames));...
    rowdelimiters];
fprintf(['%s ' OPT.rowdelimiter sprintf('%s', formats{:})], header, data{:})
