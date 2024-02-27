function [dzdu A_abs B Beta Alfa] = prob_FORM_analyse_process(result)
%PROB_FORM_ANALYSE_PROCESS  One line description goes here.
%
%   reanalyse FORM result structure to A (dz/du), A_abs, B, Alfa and Beta. 
%
%   Syntax:
%   [dzdu A_abs B Beta Alfa] = prob_FORM_analyse_process(varargin)
%
%   Input:
%   result  = FORM result structure
%
%   Output:
%   varargout =
%
%   Example
%   prob_FORM_analyse_process
%
%   See also FORM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
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
% Created: 04 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: prob_FORM_analyse_process.m 5304 2011-10-04 14:57:40Z heijer $
% $Date: 2011-10-04 22:57:40 +0800 (Tue, 04 Oct 2011) $
% $Author: heijer $
% $Revision: 5304 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/prob_FORM_analyse_process.m $
% $Keywords: $

%%
stochast = result.Input;

active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));

DerivativeSides = result.settings.DerivativeSides;
if DerivativeSides == 2
    TODO('Application with 2-sided derivatives is not tested.')
end
z = result.Output.z;
u = result.Output.u;

% pre-allocate variables
dzdu = zeros(size(z,1), length(active));
nIter = result.Output.Iter-result.Output.Converged;
[B Beta A_abs] = deal(NaN(nIter,1));
Alfa = zeros(nIter,length(active));

for Iter = 1:nIter
    id_upp = Iter * DerivativeSides + sum(active) * Iter;
    id_low = Iter * DerivativeSides + sum(active) * (Iter - 1) + (0:sum(active)-1);
    
    dz = z(id_upp) - z(id_low);
    
    du = u(id_upp, active) - sum(u(id_low, active) .* eye(sum(active)));
    
    dzdu(Iter,active) = dz ./ du';
    
    A = dzdu(Iter,:);
    A_abs(Iter) = sqrt(A*A');
    
    B(Iter) = z(id_upp) - A * u(id_upp,:)';
    Beta(Iter) = B(Iter) / A_abs(Iter);
    Alfa(Iter,:) = A / A_abs(Iter);
end