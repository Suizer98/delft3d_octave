function varargout = displayFORMresult(result)
%DISPLAYFORMRESULT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = displayFORMresult(result)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   displayFORMresult
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: displayFORMresult.m 7372 2012-10-03 15:28:24Z heijer $
% $Date: 2012-10-03 23:28:24 +0800 (Wed, 03 Oct 2012) $
% $Author: heijer $
% $Revision: 7372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/displayFORMresult.m $

%% Display results

if ~isscalar(result)
    str = cell(length(result),1);
    for i = 1:length(result)
        str{find(cellfun(@isempty, str),1)} = displayFORMresult(result(i));
    end
else
    str = cell(9+length(result(1).Input),1);
    if ~result.Output.Converged
        str{find(cellfun(@isempty, str),1)} = sprintf('\n\n!!!! NO CONVERGENCE FOUND !!!!\n');
    else
        str{find(cellfun(@isempty, str),1)} = sprintf('\n');
    end

    str{find(cellfun(@isempty, str),1)} = sprintf('\nNumber of calculations (FORM): %i\n\n', result.Output.Calc(end));
    str{find(cellfun(@isempty, str),1)} = sprintf('Beta : %5.3E\n', result.Output.Beta(end));
    str{find(cellfun(@isempty, str),1)} = sprintf('P_f  : %5.3E\n\n', result.Output.P_f);

    maxlengthNumber = length(num2str(length({result.Input.Name})));
    maxlengthParameter = max(cellfun(@length, [{result.Input.Name} {'Parameter'}]));
    maxlengthAlfa = max(cellfun(@(x) length(num2str(x, '%5.3E')), [mat2cell(result.Output.alpha, 1, ones(size(result.Output.alpha))) {'alfa'}]));
    maxlengthX = max(cellfun(@(x) length(num2str(x, '%5.3E')), [mat2cell(result.Output.x(result.Output.Calc(end),:), 1, ones(size(result.Output.x(result.Output.Calc(end),:)))) {'X'}]));

    str{find(cellfun(@isempty, str),1)} = sprintf(['%s  %' num2str(maxlengthParameter) 's  %' num2str(maxlengthAlfa) 's  %' num2str(maxlengthX) 's\n'], blanks(maxlengthNumber), 'Parameter', 'alfa', 'X');
    for i = 1:length(result.Input)
        nrblanks = maxlengthParameter-length(result.Input(i).Name);
        str{find(cellfun(@isempty, str),1)} = sprintf(['%' num2str(maxlengthNumber) 'i  %' num2str(maxlengthParameter) 's  %' num2str(maxlengthAlfa) 's  %' num2str(maxlengthX) 's\n'], i, [result.Input(i).Name blanks(nrblanks)], num2str(result.Output.alpha(i), '%5.3E'), num2str(result.Output.x(result.Output.Calc(end),i), '%5.3E'));
    end

%     str{find(cellfun(@isempty, str),1)} = sprintf('\nz-value (Resistance = %g)\n', result.settings.Resistance);
    for i = [1 result.Output.Calc(end)]
        str{find(cellfun(@isempty, str),1)} = sprintf(['%' num2str(length(num2str(result.Output.Calc(end)))) 'i  %5.3E\n'], i, result.Output.z(i));
    end
    str{find(cellfun(@isempty, str),1)} = sprintf('\n\n');
end

%%
if nargout == 1
    varargout = {sprintf('%s', str{:})};
else
    fprintf('%s', str{:});
end