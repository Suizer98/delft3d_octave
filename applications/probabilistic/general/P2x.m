function x = P2x(stochast, P, varargin)
%P2X  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = P2x(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   P2x
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

% $Id: P2x.m 8250 2013-03-01 11:10:00Z dierman $
% $Date: 2013-03-01 19:10:00 +0800 (Fri, 01 Mar 2013) $
% $Author: dierman $
% $Revision: 8250 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/P2x.m $


%% settings
OPT = struct(...
    'CorrMatrix',[] ...      % matrix with correlation coefficients (for Gaussian correlation)
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

%% apply (Gaussian) correlation on u-variables
C=OPT.CorrMatrix;
if ~isempty(C)    
  
    %work around for values with P==1, happens with "discrete variables"
    eps = 1E-12;
    indP1 = P==1;
    P(indP1)=1-eps;

    % apply correlation
    u = norm_inv(P, 0, 1);
    [u, correlated] = ApplyCorrelation(u,C);
    P(:,correlated) = norm_cdf(u(:,correlated), 0, 1);

    % finish the workaround
    P(indP1&P==1-eps)=1;
    
end



%% allocate x, being same size as P
x = zeros(size(P));
% pre-allocate the X-structure
X = struct();

for i = 1:length(stochast)
    Params = stochast(i).Params;
    while ~all(cellfun(@isnumeric, Params))
        if any(cellfun(@iscell, Params))
            id = find(cellfun(@iscell, Params));
            for j = id
                if isa(Params{j}{1}, 'function_handle')
                    % evaluate function
                    Params{j} = evaluate(Params{j}, stochast, X);
                end
            end
        elseif any(cellfun(@ischar, Params))
            id = find(cellfun(@ischar, Params));
            for j = id
                for k = find(strcmp({stochast.Name}, Params{j}))
                    Params{j} = X.(stochast(k).Name);
                end
            end
        end
    end
    
    % evaluate distribution function, using the P-values and Params as
    % input (structure X with stochast names as fieldnames is useful to
    % pass results of one variable through, as input for others
    if ~isempty(stochast(i).Distr)
        X.(stochast(i).Name) = feval(stochast(i).Distr, P(:,i), Params{:});
    else
        X.(stochast(i).Name) = repmat(Params{1}, size(P(:,i)));
    end
    
    % fill column of x
    x(:,i) = X.(stochast(i).Name)(:,end);
end

%% sub function
function Params = evaluate(crudeParams, stochast, X)

if any(cellfun(@iscell, crudeParams))
    id = find(cellfun(@iscell, crudeParams));
    for j = id
        if isa(crudeParams{id}{1}, 'function_handle')
            crudeParams{j} = evaluate(crudeParams{j}, stochast);
        end
    end
else
    for j = 1:length(crudeParams)
        for k = find(strcmp({stochast.Name}, crudeParams{j}))
            crudeParams{j} = X.(stochast(k).Name);
        end
    end
    Params = feval(crudeParams{:});
end