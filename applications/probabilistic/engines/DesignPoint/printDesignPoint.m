function result = printDesignPoint(result, varargin)
% printDesingPoint: Prints Design Point descriptions found in result variable from MC or FORM routine in neat tables
%
%   Prints tables to the command window with Design Point descriptions
%   found in the provided result structure. The result structure can be
%   from the MC or FORM routine. In case of a result structure from the
%   FORM routine it is necessary to translate the Design Point description
%   first using the getFORMDesignPoint routine. The tables provide
%   information about the Design Point in u and X space and the probability
%   of failure. If found, the tables provide also information about the
%   number of iterations and the time needed for the calculations. In case
%   of a FORM result the tables state whether the routine has converged or
%   not.
%
%   Syntax:
%   [result] = printDesignPoint(result, varargin)
%
%   Input:
%   result      = result structure from MC or FORM routine
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'types'   = possible fieldnames in result structure that
%                               contain a Design Point description
%                               (default: {'designPoint',
%                               'designPointOptimized'})
%
%   Output:
%   result      = original result structure
%
%   Example
%   printDesignPoint(result)
%
%   See also getFORMDesignPoint MC FORM approxMCDesignPoint

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
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

% Created: 13 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: printDesignPoint.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DesignPoint/printDesignPoint.m $

%% settings

OPT = struct( ...
    'types', {'designPoint', 'equivFORMResult'}, ...
    'precisionDP', 0, ...
    'methodDP', '', ...
    'thresholdDP', 0, ...
    'optimizeDP', '' ...
);

OPT = setproperty(OPT, varargin{:});

%% print tables

if ~isfield(result.Output, 'designPoint') && ~isfield(result.Output, 'designPointOptimized')
    result = approxMCDesignPoint(result, 'method', OPT.methodDP, 'threshold', OPT.thresholdDP, 'optimize', OPT.optimizeDP, 'precision', OPT.precisionDP);
end

for type = {OPT.types}
    type = char(type);
    
    if isfield(result.Output, type)
        fprintf(['\n--- ' type ' ---\n\n']);
        
        if isfield(result.Output.(type), 'converged')
            fprintf('Converged:               %10.0f\n', result.Output.(type).converged);
        end
        
        if isfield(result.Output.(type), 'iterations')
            fprintf('Iterations:              %10.0f\n', result.Output.(type).iterations);
        end
        
        if isfield(result.Output.(type), 'calculations')
            fprintf('Calculations:            %10.0f\n', result.Output.(type).calculations);
        end
        
        if isfield(result.Output.(type), 'time')
            fprintf('Time:                    %10.4f', result.Output.(type).time);
            
            if isfield(result.Output, 'time')
                fprintf(' (%7.4f)', result.Output.time + result.Output.(type).time);
            end
            
            fprintf('\n');
        end
        
        beta = sqrt(sum(result.Output.(type).u'.^2));
        
        fprintf('Probability of failure:  %10.8f\n', result.Output.(type).P);
        fprintf('Beta-value:              %10.8f\n\n', beta);

        % print headers
        fprintf('                         ');
        for var = {result.Input.Name}
            fprintf('%10s', char(var));
        end
        fprintf('\n');

        % print design point in u space
        fprintf('Design Point in U:       ');
        for u = result.Output.(type).u
            fprintf('%10.4f', u);
        end
        fprintf('\n');

        % print design point in x space
        fprintf('Design Point in X:       ');
        for x = result.Output.(type).x
            fprintf('%10.4f', x);
        end
        fprintf('\n');
        
        % print alpha-values
        fprintf('Alpha-squared values:    ');
        for a = (result.Output.(type).u ./ beta) .^2
            fprintf('%10.4f', a);
        end
        fprintf('\n\n');

        % print z value
        fprintf('Z value:                 %10.4f\n', result.Output.(type).z);
    end
end