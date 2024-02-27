function evalstr = var2evalstr(varargin)
%VAR2EVALSTR 	routine to create an evaluation string resulting in variable
%
%   Routine to create a string which after evaluation results in the
%   original variable. Can be useful for creating a stand alone testfile
%   with extensive arrays as fixed input.
%
%   syntax:
%   evalstr = var2evalstr(varargin)
%
%   input:
%       variable        =   arbitrary variable
%       property value pairs =
%           'precision' - precision as defined in fprintf
%           'delimiter' - delimiter at the end of each variable definition
%           'basevarname' - customised variable name
%
%   example:
%
%
%   See also DOUBLE2EVALSTR SINGLE2EVALSTR CHAR2EVALSTR LOGICAL2EVALSTR

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
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 03 Apr 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: var2evalstr.m 7282 2012-09-25 15:00:07Z tda.x $
% $Date: 2012-09-25 23:00:07 +0800 (Tue, 25 Sep 2012) $
% $Author: tda.x $
% $Revision: 7282 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/var2evalstr.m $
% $Keywords: $

%%
if any(strcmpi(varargin,'precision'))
    precid = find(strcmpi(varargin,'precision'));
    prec = varargin{precid+1};
    varargin(precid:precid+1)=[];
else
    prec = '%g';
end

if any(strcmpi(varargin, 'delimiter'))
    delimiterid = find(strcmpi(varargin, 'delimiter'));
    delimiter = varargin{delimiterid+1};
    varargin(delimiterid:delimiterid+1)=[];
else
    delimiter = ';\n';
end

NameIsDummy = false;
if length(varargin) == 3 && any(strcmpi(varargin, 'basevarname'))
    basevarnameid = find(strcmpi(varargin, 'basevarname'));
    basevarname = varargin{basevarnameid+1};
    varargin(basevarnameid:basevarnameid+1)=[];
elseif length(varargin) == 1 && ~isempty(inputname(1))
    basevarname = inputname(1);
else
    basevarname = 'variable';
    NameIsDummy = true;
end

evalstr = '';
for i = 1:length(varargin)
    if length(size(varargin{i})) > 2
        warning('var2evalstr is not suitable for variables with 3 or more dimensions');
        continue
    end
    if NameIsDummy && ~isempty(inputname(i))
        basevarname = inputname(i);
    elseif NameIsDummy
        basevarname = [basevarname num2str(i)]; %#ok<AGROW>
    end
    variable = varargin{i};
    if isstruct(variable)
        [rows columns] = size(variable);
    else
        [rows columns] = deal(1);
    end
    for row = 1:rows
        for column = 1:columns
            idstr = '';
            if isstruct(variable)
                if rows == 1 && columns == 1
                    if iscell(variable)
                        idstr = '{1}';
                    end
                elseif rows == 1 && columns > 1
                    if iscell(variable)
                        idstr = ['{' num2str(column) '}'];
                    else
                        idstr = ['(' num2str(column) ')'];
                    end
                elseif rows > 1
                    if iscell(variable)
                        idstr = ['{' num2str(row) ',' num2str(column) '}'];
                    else
                        idstr = ['(' num2str(row) ',' num2str(column) ')'];
                    end
                end
            end
            switch class(variable)
                case 'double'
                    evalstr = [evalstr double2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'precision', prec, 'delimiter', delimiter)]; %#ok<AGROW>
                case 'single'
                    evalstr = [evalstr single2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'precision', prec, 'delimiter', delimiter)]; %#ok<AGROW>
                case {'int64' 'int32' 'int16' 'int8' 'uint64' 'uint32' 'uint16' 'uint8'}
                    evalstr = [evalstr int2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'precision', prec, 'delimiter', delimiter)]; %#ok<AGROW>
                case 'char'
                    evalstr = [evalstr char2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'delimiter', delimiter)]; %#ok<AGROW>
                case 'logical'
                    evalstr = [evalstr logical2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'delimiter', delimiter)]; %#ok<AGROW>
                case 'function_handle'
                    tempvar = [char(eval(['variable' idstr]))]; % change function handle to string being '@' followed by the function name
                    tempvarstr = char2evalstr(tempvar, 'basevarname', [basevarname idstr], 'delimiter', delimiter); 
                    tempvarstr = strrep(tempvarstr, '''', '');
                    evalstr = [evalstr tempvarstr]; %#ok<AGROW>
                case 'struct'
                    FieldNames = fieldnames(eval(['variable' idstr]));
                    for jj = 1:length(FieldNames)
                        evalstr = [evalstr var2evalstr(eval(['variable' idstr '.' FieldNames{jj}]), 'basevarname', [basevarname idstr '.' FieldNames{jj}], 'precision', prec, 'delimiter', delimiter)]; %#ok<AGROW>
                    end
                case 'cell'
                    evalstr = [evalstr cell2evalstr(eval(['variable' idstr]), 'basevarname', [basevarname idstr], 'precision', prec, 'delimiter', delimiter)]; %#ok<AGROW>
                otherwise
                    error('field type not implemented: %s',class(variable))
            end
        end
    end
end
if isempty(basevarname)
    evalstr = strrep(evalstr, ' = ', '');
end