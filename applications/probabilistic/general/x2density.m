function p = x2density(stochast, x)
% x2density: pdf of vector x 
%
%   Syntax:
%   p = x2density(stochast, x)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares 
%       F.L.M. Diermanse
%
%       Fedrinand.diermanse@Deltares.nl	
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

% Created: 27 Dec 2012
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: x2density.m 7863 2012-12-27 15:49:44Z dierman $
% $Date: 2012-12-27 23:49:44 +0800 (Thu, 27 Dec 2012) $
% $Author: dierman $
% $Revision: 7863 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/x2density.m $

%% allocate x, being same size as P
p = NaN(size(x));
% pre-allocate the X-structure
%X = struct();

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
    if ~isfield(stochast(i),'DistrPdf')
        fname = func2str(stochast(i).Distr);
        if isempty(strfind(fname,'n'))
           error('distribution function has no "inv" in the name') 
        end
        eval(['pdfname = @ ' strrep(fname, 'inv', 'pdf')]);
    else
        pdfname = stochast(i).DistrPdf;
    end    
    p(:,i) = feval(pdfname, x(:,i), Params{:});
    
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