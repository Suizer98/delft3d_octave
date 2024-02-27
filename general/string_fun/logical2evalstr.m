function evalstr = logical2evalstr(varargin)
%LOGICAL2EVALSTR 	routine to create an evaluation string resulting in variable
%
%   Routine to create a string which after evaluation result in the
%   original variable. Can be useful for creating a stand alone testfile
%   with extensive arrays as fixed input.
%
%   syntax:
%   evalstr = logical2evalstr(varargin)
%
%   input:
%       variable        =   string
%       property value pairs =
%           'delimiter' - delimiter at the end of each variable definition
%           'basevarname' - customised variable name
%
%   example:
%
%
%   See also VAR2EVALSTR

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

% $Id: logical2evalstr.m 6842 2012-07-10 10:27:47Z boer_g $
% $Date: 2012-07-10 18:27:47 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6842 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/logical2evalstr.m $
% $Keywords: $

%%
if any(strcmpi(varargin, 'delimiter'))
    delimiterid = find(strcmpi(varargin, 'delimiter'));
    delimiter = varargin{delimiterid+1};
    varargin(delimiterid:delimiterid+1) = [];
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
    basevarname = '';
    NameIsDummy = true;
end

%%
evalstr = '';
for j = 1 : length(varargin)
    variable = varargin{j};
    if islogical(variable)
        if NameIsDummy && ~isempty(inputname(j))
            basevarname = inputname(j);
        elseif NameIsDummy
            basevarname = [basevarname num2str(j)]; %#ok<AGROW>
        end

        %% create string
        [rows columns] = size(variable);
        if rows == 1 && columns == 1
            if variable
                evalstr = [evalstr sprintf('%s = true%s', basevarname, delimiter)]; %#ok<AGROW>
            else
                evalstr = [evalstr sprintf('%s = false%s', basevarname, delimiter)]; %#ok<AGROW>
            end
        else
            tempvar = double2evalstr(ones(size(variable)).*variable, 'delimiter', ' ');
            bgn = 1;
            if ~isempty(strfind(tempvar,'='))
                bgn = max(strfind(tempvar,'='))+1;
            end
            tempvar = ['logical(' strtrim(tempvar(bgn:end-1)) ')'];

            evalstr = [evalstr sprintf('%s = %s%s', basevarname, tempvar, delimiter)]; %#ok<AGROW>
        end
        evalstr = sprintf(evalstr);

        if j < length(varargin) && isempty(findstr(delimiter, '\n'))
            evalstr = [evalstr, ' ']; %#ok<AGROW>
        end
    end
end
% evalstr = strtrim(evalstr);