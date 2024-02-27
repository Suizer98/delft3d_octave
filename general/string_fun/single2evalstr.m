function evalstr = single2evalstr(varargin)
%SINGLE2EVALSTR  routine to create an evaluation string resulting in variable
%
%   Routine to create a string which after evaluation result in the
%   original variable. Can be useful for creating a stand alone testfile
%   with extensive arrays as fixed input.
%
%   Syntax:
%   evalstr = single2evalstr(varargin)
%
%   Input:
%   varargin = one or more string variables
%   'PropertyName' - PropertyValue pairs:
%           'basevarname' - predefined name of variable
%           'equalsign'   - delimiter between variablename and value
%           'delimiter'   - delimiter at the end of each variable definition
%           'rowdelimiter'   - delimiter at the end of each row
%           'columndelimiter'   - delimiter between columns
%           'precision' - precision as defined in fprintf; precision can
%           also be defined as cell array with multiple precisions, in that
%           case the shortest string with maximum precision will be used
%       variable        =   single array
%
%   Output:
%   evalstr  =
%
%   Example
%   single2evalstr
%
%   NB: TO DO: NaN does not becomes nan('single')
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

% $Id: single2evalstr.m 6841 2012-07-10 10:23:54Z boer_g $
% $Date: 2012-07-10 18:23:54 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6841 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/single2evalstr.m $
% $Keywords:

%% default options
OPT = struct(...
    'basevarname', '',...
    'equalsign', ' = ',...
    'precision', '%g',...
    'rowdelimiter', '\n\t',...
    'columndelimiter', ' ',...
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
variable_ids = ~keyword_ids & ~value_ids & cellfun(@isnumeric, varargin);

%% set options
OPT = setproperty(OPT, varargin{keyword_ids | value_ids});

%% isolate variables and double the quotes
variables = varargin(variable_ids);

%% create cell arrays of the respective elements
basevarnames  = repmat({OPT.basevarname}, size(variables));
equalsigns    = repmat({OPT.equalsign}, size(variables));
bracketsopen  = repmat({''}, size(variables));
variablestr   = repmat({''}, size(variables));
bracketsclose = repmat({''}, size(variables));
quotes        = repmat({''}, size(variables));
delimiters    = repmat({OPT.delimiter}, size(variables));

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
end

%%
for j = 1:length(variables)
    variable = variables{j};
    if numel(variable) == 0
        % make sure that an empty variable has a size of 0x0
        variable = [];
    end
    if strcmp(class(variable), 'single')
        [m n] = size(variable);

        %% create string
        if isscalar(variable) % single value
            variablestr{j} = num2str(variable);
        elseif isvector(variable) &&... % vector
                (length(variable) > 2 || length(variable) == 2 && diff(variable) == 1) &&... 
                min(diff(variable))==max(diff(variable)) &&...  % equidistant 
                ~any(isnan(variable)) %#ok<ISMT> % no NaNs
            interval = diff(variable(1:2));
            if interval ~= 0
                if interval == 1
                    intervalstr = ':';
                else
                    intervalstr = [':' num2string(interval, OPT.precision) ':'];
                end
                variablestr{j} = [num2string(variable(1), OPT.precision) intervalstr num2string(variable(end), OPT.precision)];
                if n == 1
                	% column vector
                    [bracketsopen{j} bracketsclose{j} quotes{j}] = deal('(', ')', '''');
                end
            else
                if variable(1,1) == 0
                    basis = 'zeros';
                    multiplication = '';
                else
                    basis = 'ones';
                    if variable(1,1) == 1
                        multiplication = '';
                    else
                        multiplication = sprintf(' * %s', num2string(variable(1,1), OPT.precision));
                    end
                end
                variablestr{j} = sprintf('%s(%i,%i)%s', basis, m, n, multiplication);
            end
        elseif isvector(variable) % either row or column vector
            for i = 1:length(variable)
                variablestr{j} = [variablestr{j} num2string(variable(i), OPT.precision)]; %#ok<AGROW>
                if i < length(variable)
                    variablestr{j} = [variablestr{j} sprintf(OPT.columndelimiter)];
                end
            end
            [bracketsopen{j} bracketsclose{j}] = deal('[', ']');
            if n == 1
                % column vector
                quotes{j} = '''';
            end
        else % matrix (possibly empty)
            [bracketsopen{j} bracketsclose{j}] = deal('[', ']');
            for i = 1:m %rows
                for k = 1:n %columns
                    variablestr{j} = [variablestr{j} num2string(variable(i, k), OPT.precision)];
                    if k < n
                        % not last column
                        variablestr{j} = [variablestr{j} sprintf(OPT.columndelimiter)]; %#ok<AGROW>
                    elseif i < m
                        % not last row
                        variablestr{j} = [variablestr{j} sprintf(OPT.rowdelimiter)]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end

%% create cell in which each column combined contains the evalstr of a variable
txtcell = [basevarnames; equalsigns; bracketsopen; variablestr; bracketsclose; quotes; delimiters];

%% combine all strings to one
evalstr = [txtcell{:}];

%%
function str = num2string(variable, prec)
if ischar(prec)
    % apply num2str with specified precision
    str = num2str(variable, prec);
elseif iscell(prec)
    if length(prec)>1
        % derive appropriate precision
        for iprec = 1:length(prec)
            % create string for any precision and transform back to double
            cellstr{iprec} = num2str(variable, prec{iprec}); %#ok<AGROW>
            variable2(iprec) = eval(cellstr{iprec}); %#ok<AGROW>
        end
        % derive differences with origional value
        err = abs(abs(variable) - abs(variable2));
        id1 = err == min(err); % identify minimum difference(s)
        strlength = cellfun(@length, cellstr(id1)); % length of most precise string(s)
        prec = prec(id1); % keep only precisions corresponding to most precise string(s)
        id = find(strlength == min(strlength), 1, 'first'); % identify shortest string with maximum precision
    else
        id = 1;
    end
    % apply num2str with specified precision
    str = num2str(variable, prec{id});
end