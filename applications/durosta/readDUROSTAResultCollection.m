function [x y y_smooth titles] = readDUROSTAResultCollection(path, varargin)
%readDUROSTAResultCollection: reads entire directory with DUROSTA result files and returns specific values ready for plotting
%
%   This function first reads the raw entries from DUROSTA result files
%   from a certain directory and returns a matrix with one row for each
%   file and one column for each requested variable. A variable from the
%   DUROSTA results struct can be defined as variable to use as x-axis. The
%   x-values are also returned in a similar matrix as the y-values. Also a
%   smooth version of the y-matrix is returned which is created using
%   moving averaging. Furthermore a cell with variable names corresponding
%   to the columns in the matrices is returned.
%
%   WARNING:    THIS FUNCTION USES THE CLOSED SOURCE qpread FUNCTION
%               AVAILABLE IN THE MCTOOLS REPOSITORY !!!
%
%   Syntax:
%   [x y y_smooth titles] = readDUROSTAResultCollection(path, varargin)
%
%   Input:
%   name        = path to input files
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%                   'xVar'              = full name of variable in result
%                                           struct to be used as variable
%                                           for the x-axis (default:
%                                           'D.Input.WaveAngle')
%                   'fields'            = cell array with names from the
%                                           raw entries from the result
%                                           struct to be returned. An empty
%                                           value means all entries
%                                           (default: [])
%                   'smoothFactor'      = factor to be provided to the
%                                           smooth function to smooth the
%                                           y-values (default: 10)
%                   'crossShoreAverage' = flag that determines whether the
%                                           requested field values are
%                                           cross-shore averaged or
%                                           integrated or that each value
%                                           of each cross-shore cell is
%                                           returned (default: true)
%
%   Output:
%   x           = matrix where columns provide x-values for the different
%                   variables
%   y           = matrix where columns provide y-values for the different
%                   variables
%   y_smooth    = matrix similar to y, but with smoothed values created
%                   using moving averages (only returned for cross-shore
%                   averaged values)
%   titles      = cell array with names of the variables corresponding to
%                   each column in the returned matrices
%
%   Example
%   [x y y_smooth titles] = readDUROSTAResultCollection(path)
%
%   See also QPREAD DUROSTA_Run readDUROSTAResult

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

% Created: 26 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: readDUROSTAResultCollection.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/durosta/readDUROSTAResultCollection.m $

%% settings

OPT = struct( ...
    'xVar', 'D.Input.WaveAngle', ...
    'fields', [], ...
    'smoothFactor', 10, ...
    'crossShoreAverage', true ...
);

OPT = setproperty(OPT, varargin{:});

%% read results

% define result variables
x = [];
y = [];
y_smooth = [];
titles = {};

% loop through DUROSTA results in directory
l = 1;
files = dir(fullfile(path, '*.daf'));
for i = 1:length(files)
    file = files(i).name;
    
    % read input and result files for current result
    D = readDUROSTAResult(fullfile(path, file));
    
    % check whether raw data is available in result struct
    if isfield(D.Output, 'RAW')
        
        % read grid from result struct
        grid = D.Output.RAW.grid;
        
        % lopp through variables in current result struct
        k = 1;
        fields = fieldnames(D.Output.RAW);
        for j = 1:length(fields)
            
            % check whether current variable is requested for output,
            % otherwise continue with next variable
            field = char(fields(j));
            if ~isempty(OPT.fields) && ~sum(ismember(field, OPT.fields)); continue; end;
            
            % retrieve values for current variable
            param = D.Output.RAW.(field);
            if ~isempty(param) && ~strcmpi(field, 'grid') && ~strcmpi(field, 'times')
                
                x(l, k) = eval(OPT.xVar);
                
                if OPT.crossShoreAverage
                    % integrate or average weighed values in cross shore
                    % direction and add to result variables
                    if strcmpi(field, 'Scross') || strcmpi(field, 'Slong') || strcmpi(field, 'Dep')
                        y(l, k) = sum(param(end, 1:end-1) .* diff(grid));
                    else
                        y(l, k) = mean(param(end, 1:end-1) .* diff(grid) ./ mean(diff(grid)));
                    end
                else
                    y(l, k, :) = param(end, :);
                end
                
                % add variable name to results
                titles{k} = field;
                
                k = k + 1;
            end
        end
        
        l = l + 1;
    end
end

% sort data points and add smoothed version
[x i] = sort(x, 1);
for j = 1:size(y, 2)
    if OPT.crossShoreAverage
        y(:, j) = y(i(:, j), j);
        y_smooth(:, j) = smooth(y(:, j), OPT.smoothFactor);
    else
        y(:, j, :) = y(i(:, j), j, :);
    end
end