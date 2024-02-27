function evalstr = char2evalstr(varargin)
%CHAR2EVALSTR 	routine to create an evaluation string resulting in variable
%
%   Routine to create a string which after evaluation result in the
%   original variable. Can be useful for creating a stand alone testfile
%   with extensive arrays as fixed input.
%
%   Syntax:
%   evalstr = char2evalstr(varargin)
%
%   Input:
%   varargin = one or more string variables
%   'PropertyName' - PropertyValue pairs:
%           'basevarname' - predefined name of variable
%           'equalsign'   - delimiter between variablename and value
%           'delimiter'   - delimiter at the end of each variable definition
%
%   Output:
%   evalstr  = string
%
%   Example
%   char2evalstr
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

% Created: 02 Mar 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: char2evalstr.m 6842 2012-07-10 10:27:47Z boer_g $
% $Date: 2012-07-10 18:27:47 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6842 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/char2evalstr.m $
% $Keywords:

%% default options
OPT = struct(...
    'basevarname', '',...
    'equalsign', ' = ',...
    'delimiter', ';\n' ...
    );

%% isolate ids of keywords and corresponding values
keyword_ids = false(size(varargin));
for keyword = fieldnames(OPT)'
    keyword_ids = sum([keyword_ids; strcmp(keyword{1}, varargin)]);
end
keyword_ids = keyword_ids == 1;
value_ids = [false keyword_ids(1:length(keyword_ids)-1)];

%% isolate ids of variables of concern (non-character variables are ignored)
variable_ids = ~keyword_ids & ~value_ids & cellfun(@ischar, varargin);

%% set options
OPT = setproperty(OPT, varargin{keyword_ids | value_ids});

%% isolate variables and double the quotes
variables = strrep(varargin(variable_ids), '''', '''''');

%% create cell arrays of the respective elements
basevarnames = repmat({OPT.basevarname}, size(variables));
equalsigns = repmat({OPT.equalsign}, size(variables));
quotes = repmat({''''}, size(variables));
delimiters = repmat({OPT.delimiter}, size(variables));

%% check whether basevarnames are available from invoking function
ids = find(variable_ids);
for id = 1:length(ids)
    if ~isempty(OPT.basevarname)
        % keep basevarname
    elseif ~isempty(inputname(ids(id)))
        % retrieve basevarname
        basevarnames{id} = inputname(ids(id));
    else
        % in case of no basevarname
        equalsigns{id} = '';
    end
    % run sprintf apply e.g. \n, \t, etc.
    equalsigns{id} = sprintf(equalsigns{id});
    delimiters{id} = sprintf(delimiters{id});
    % solve multiple line char arrays
    if size(variables{id},1) > 1
        variables{id} = sprintf('char(%s)', var2evalstr(cellstr(variables{id}), 'basevarname', '', 'delimiter', ''));
        quotes{id} = '';
    end
end

%% create cell in which each column combined contains the evalstr of a variable
txtcell = [basevarnames; equalsigns; quotes; variables; quotes; delimiters];

%% combine all strings to one
evalstr = [txtcell{:}];