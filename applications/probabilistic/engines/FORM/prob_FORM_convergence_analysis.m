function [epsZ maxdZ epsBeta NrIter] = prob_FORM_convergence_analysis(result, varargin)
%PROB_FORM_CONVERGENCE_ANALYSIS  find optimal convergence in FORM run
%
%   Routine to analyse the results of a FORM run and check whether during
%   the run convergence has occured (with corresponding settings).
%
%   Syntax:
%   [epsZ maxdZ epsBeta NrIter] = prob_FORM_convergence_analysis(varargin)
%
%   Input:
%   result  = FORM result structure
%
%   Output:
%   varargout =
%
%   Example
%   prob_FORM_convergence_analysis
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
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
% Created: 22 Aug 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: prob_FORM_convergence_analysis.m 5098 2011-08-22 13:05:48Z heijer $
% $Date: 2011-08-22 21:05:48 +0800 (Mon, 22 Aug 2011) $
% $Author: heijer $
% $Revision: 5098 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/prob_FORM_convergence_analysis.m $
% $Keywords: $

%%
converged = result.Output.Converged;
Z1 = result.Output.criteriumZ1 * result.settings.epsZ;
Z2 = result.Output.criteriumZ2 * result.settings.maxdZ;
Beta = result.Output.criteriumBeta * result.settings.epsBeta;

Iterend = result.Output.Iter;
if converged
    % don't take the last FORM step into account
    Iterend = Iterend - 1;
end

crit = NaN(Iterend, 3); % pre-allocate crit matrix
for Iter = 2:Iterend
    crit(Iter,:) = [min(Z1(Iter-1:Iter)) min(Z2(Iter-1:Iter)) min(Beta(Iter-1:Iter))];
end

% sort the convergence matrix
[critsort,IX] = sortrows(crit);

% extract the first row of the sorted matrix
epsZ = critsort(1,1);
maxdZ = critsort(1,2);
epsBeta = critsort(1,3);
NrIter = IX(1);

% fprintf('Best available convergence is found at %i iterations\n', IX(1));
% fprintf('Corresponding criteria are:\n');
% fprintf('epsZ = %g\nmaxdZ = %g\nepsBeta = %g\n\n', critsort(1,:))