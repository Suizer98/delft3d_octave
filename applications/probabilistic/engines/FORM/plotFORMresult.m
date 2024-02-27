function varargout = plotFORMresult(result, fhandle)
%PLOTFORMRESULT  plot iteration trajectory of FORM calculation
%
%   Plot routine to show for each of the stochastic variables as well as
%   for the Z and Beta values the development as function of the individual
%   realisations.
%
%   Syntax:
%   varargout = plotFORMresult(result, fhandle)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   plotFORMresult
%
%   See also FORM

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

% $Id: plotFORMresult.m 5321 2011-10-11 09:19:03Z heijer $
% $Date: 2011-10-11 17:19:03 +0800 (Tue, 11 Oct 2011) $
% $Author: heijer $
% $Revision: 5321 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/FORM/plotFORMresult.m $

%%
stochast = result.Input;   % all variables, including deterministic ones
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));
Nstoch = sum(active);   % number of random variables (deterministic ones excuded)

NrFigureColumns = ceil(sqrt(Nstoch+2));
NrFigureRows = NrFigureColumns - floor(mod(NrFigureColumns^2, Nstoch+2) / NrFigureColumns);

if exist('fhandle', 'var') && ishandle(fhandle) && strcmp(get(fhandle, 'Type'), 'figure')
    fig = fhandle;
else
    fig = figure;
end

% dimensions: number of calculations and number of iterations. Each
% iteration consists of Nstoch+1 calculations of the z-variable, i.e.
% a computation for the current state vector x and Nstoch perturbations,
% (1 for each random variable)
Nx = size(result.Output.x,1);
xnums = 1:Nx;
if result.Output.Converged
    Nx = Nx - 1;
end
Ndv = result.settings.DerivativeSides; % 1 or 2 sided derivatives
if mod(Nx, Ndv*Nstoch+1) ~=0
    error('length of resultvector x no multiple of number of random variables');
end
IterIndex = Ndv*Nstoch+1:Ndv*Nstoch+1:Nx;

activeInd = find(active);

ax = zeros(1,Nstoch+2); % pre-allocate ax
% make subplots for each active stochast
for ifig = 1:Nstoch+2
    % prepare subplot and add title and axis labels
    ax(ifig) = subplot(NrFigureRows, NrFigureColumns, ifig,...
        'Nextplot', 'add',...
        'XLim', [0 Nx]);
    xlabel('Calculations')
    if ifig == Nstoch + 1
        % plot Z
        title('Z')
        xi = result.Output.z;
    elseif ifig == Nstoch + 2
        % plot Beta
        title('\beta')
        xi = NaN(size(result.Output.z));
        xi(IterIndex) = result.Output.Betas;
    else
        % plot stochastic variables
        istoch = activeInd(ifig);
        title(result.Input(istoch).Name)
        xi = result.Output.x(:,istoch);
    end
    % apply title as ylabel as well
    ylabel(get(get(gca, 'title'), 'String'))
        
    % plot FORM iterations
    plot(xnums(IterIndex), xi(IterIndex),...
        'DisplayName', 'FORM iterations',...
        'LineWidth', 2);
    % plot individual calculations
    plot(xnums, xi, 'b:',...
        'DisplayName', 'all computations');
    if Nstoch + 2 == NrFigureColumns *  NrFigureRows
        % add legend
        leg = legend('toggle');
        set(leg,...
            'location', 'best');
    end
end

linkaxes(ax,'x');

if Nstoch + 2 < NrFigureColumns *  NrFigureRows
    ax(ifig+1) = subplot(NrFigureRows, NrFigureColumns, ifig+1);
    plot(1, NaN,...
        'DisplayName', 'FORM iterations',...
        'LineWidth', 2);
    hold on
    plot(1, NaN, 'b:',...
        'DisplayName', 'all computations');
    % add legend
    leg = legend('toggle');
    set(leg,...
        'location', 'best');
    set(ax(ifig+1), 'visible', 'off')
end

%%
if nargout == 1
    varargout = {fig};
end