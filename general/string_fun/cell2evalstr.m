function evalstr = cell2evalstr(varargin)
%CELL2EVALSTR 	routine to create an evaluation string resulting in variable
%
%   Routine to create a string which after evaluation result in the
%   original variable. Can be useful for creating a stand alone testfile
%   with extensive arrays as fixed input.
%
%   syntax:
%   evalstr = cell2evalstr(varargin)
%
%   input:
%       variable        =   double array
%       property value pairs =
%           'precision' - precision as defined in fprintf; precision can
%           also be defined as cell array with multiple precisions, in that
%           case the shortest string with maximum precision will be used
%           'delimiter' - delimiter at the end of each variable definition
%           'basevarname' - customised variable name
%
%   example:
%
%
%   See also var2evalstr double2evalstr char2evalstr logical2evalstr

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

% $Id: cell2evalstr.m 9415 2013-10-15 13:48:44Z tda.x $
% $Date: 2013-10-15 21:48:44 +0800 (Tue, 15 Oct 2013) $
% $Author: tda.x $
% $Revision: 9415 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/cell2evalstr.m $
% $Keywords: $

%%
if any(strcmpi(varargin,'precision'))
    precid = find(strcmpi(varargin,'precision'));
    prec = varargin{precid+1};
    varargin(precid:precid+1)=[];
else
    prec = '%g';
end

if any(strcmpi(varargin,'delimiter'))
    delimiterid = find(strcmpi(varargin,'delimiter'));
    delimiter = varargin{delimiterid+1};
    varargin(delimiterid:delimiterid+1)=[];
else
    delimiter = ';\n';
end

intdelimiter = '\n\t';

NameIsDummy = false;
if length(varargin) == 3 && any(strcmpi(varargin, 'basevarname'))
    basevarnameid = find(strcmpi(varargin, 'basevarname'));
    basevarname = varargin{basevarnameid+1};
    varargin(basevarnameid:basevarnameid+1)=[];
elseif length(varargin) == 1 && ~isempty(inputname(1))
    basevarname = inputname(1);
else
    basevarname = '';
    NameIsDummy = true;
end

%%
evalstr = '';
for j = 1 : length(varargin)
    variable = varargin{j};
    if NameIsDummy && ~isempty(inputname(j))
        basevarname = inputname(j);
    elseif NameIsDummy
        basevarname = [basevarname num2str(j)]; %#ok<AGROW>
    end
    if iscell(variable)
        [m,n] = size(variable);
        
        %% create string
        strcontents = cell(size(variable));
        evalstr = [evalstr basevarname ' = {']; % start
        for row = 1:m
            for column = 1:n
                % fill in each element
                if isstruct(variable{row,column})
                    strcontents{row,column} = var2evalstr(variable{row,column}, 'basevarname', ' ', 'delimiter', ';', 'precision', prec);
                else
                    strcontents{row,column} = var2evalstr(variable{row,column}, 'basevarname', '', 'delimiter', '', 'precision', prec);
                end
                evalstr = [evalstr '%s '];
                if column == n && row ~= m
                    % add intdelimiter at end of each row, except for the last row
                    evalstr(end:end+length(intdelimiter)-1) = intdelimiter;
                end
            end
        end
        if numel(variable) == 0
            id = length(evalstr)+1;
        else
            id = length(evalstr);
        end
        evalstr(id) = '}'; % close
        evalstr = [evalstr delimiter]; % include delimiter
        if j < length(varargin) && isempty(findstr(delimiter, '\n'))
            evalstr = [evalstr, ' ']; %#ok<AGROW>
        end
    end
    evalstr = sprintf(evalstr,strcontents{:});
end