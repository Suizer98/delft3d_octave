function plotMCConvergence(result, varargin)
%PLOTMCCONVERGENCE  Plot convergence diagram based on MC result structure
%
%   Plot convergence diagram based on MC result structure.
%
%   Syntax:
%   plotMCConvergence(result, varargin)
%
%   Input:
%   result    = result structure from MC routine
%   varargin  = confidence:     confidence used in computation of accuracy
%
%   Output:
%   none
%
%   Example
%   plotMCConvergence(result)
%
%   See also MC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Ferdinand Diermanse
%
%       dorothea.kaste@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       Netherlands
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
% Created: 21 May 2012
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: plotMCConvergence.m 7355 2012-09-28 12:54:04Z dierman $
% $Date: 2012-09-28 20:54:04 +0800 (Fri, 28 Sep 2012) $
% $Author: dierman $
% $Revision: 7355 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/MonteCarlo/plotMCConvergence.m $
% $Keywords: $

%% read options

OPT = struct(...
    'confidence',       .95    ...
);

OPT = setproperty(OPT, varargin{:});

%% check input

if ~isstruct(result)
    error('No structure given');
end

if ~isfield(result,'Output')
    error('No output field found');
end

if ~isstruct(result.Output)
    error('No output structure found');
end

if ~isfield(result.Output,'idFail') || ~isfield(result.Output,'Calc') || ~isfield(result.Output,'P_corr')
    error('No data found');
end

%% compute accuracy
Estresult = MCEstimator(result.Output.idFail, result.Output.P_corr, OPT.confidence);
Pz = Estresult.P_z;
Pf = Estresult.P_f;
Acy_absV = Estresult.Acy_absV;
Acy_abs = Estresult.Acy_abs;
Acy_rel = Estresult.Acy_rel;


%% plot convergence
n = result.Output.Calc;
cumNsamps = (1:n)';

figure; hold on;

plot(cumNsamps,Pz,'-g');
plot([1 n],Pf*[1 1],'-r');
plot(cumNsamps,Pz+Acy_absV,'-b');
plot(cumNsamps,max(0,Pz-Acy_absV),'-b');

xlabel('Number of samples [-]');
ylabel('Probability [-]');
set(gca, 'xscale','log');
set(gca, 'yscale','log');


legend({ ...
    'Convergence of probability of failure' ...
    'Estimated probability of failure' ...
    sprintf('%1.0f%% confidence interval', OPT.confidence*100)},'Location','SouthEast');

grid on;
set(gca,'XScale','log');
set(gca,'YScale','log');

title(sprintf('P_f = %2.1e ; Accuracy = %2.1e (%2.1f%%) ; N = %d ', ...
        Pf, Acy_abs, 100*Acy_rel, n ));
        