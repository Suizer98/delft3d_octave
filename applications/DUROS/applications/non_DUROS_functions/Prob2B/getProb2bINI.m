function [str, Globals, command] = getProb2bINI(INIfname, flag)
%GETPROB2BINI   routine to read settings from Prob2B INI-file

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C. (Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
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

%%
if exist('flag', 'var')
    ReadAll = strcmp(flag, 'all');
else
    ReadAll = false;
end

%%
command = cell(0);
Globals = 'global command';

% read file
fid = fopen(INIfname);
string = fread(fid, '*char')';
fclose(fid);

str = strread(string, '%s', 'delimiter', char(13)); % put lines in cell array
str = cellfun(@(x) strtrim(x), str, 'UniformOutput', false); % trim string

if ~ReadAll
    % remove comment lines
    str(cellfun(@(x) strcmp(x(1), '%'), str)) = [];
end

for i = 1:length(str)
    if ~isempty(str{i}) && ~strcmp(str{i}(1), '%')
        locIS = min(findstr(str{i}, '='));
        if isempty(findstr(str{i}(1:locIS), '{'))
            % one or more variables to be added to the Globals
            id = true(size(str{i}));
            id(locIS:end) = false;
            id(findstr(str{i}, '[')) = false;
            id(findstr(str{i}, ']')) = false;
            id(findstr(str{i}, ',')) = false;
            Globals = [Globals ' ' strtrim(str{i}(id))]; %#ok<NODEF,NASGU,AGROW>
        end
    end
end
