function [dirs dircont files] = dirlisting(maindir, exc)
% DIRLISTING returns subdirectory names
%
% This function gives the names of all subdirs given a certain 
% directory name. 
%
% syntax: 
%           [dirs dircont files] = dirlisting(maindir,exc)
%
% input:
%   maindir         -   dirname of main directory (char).
%   exc             -   exceptions (given as char or as a cell of character
%                       arrays). All subdirectory names that contain one of
%                       the exceptions specified will not be included in
%                       the output.
%
% output:
%   dirs            -   cell array of strings with all names of the
%                       subdirs.
%   dircont         -   structure the same length as dirs with for each dir
%                       a field name (that includes the same name as in
%                       dirs) and content (which is a listing of the files
%                       and their properties in that dir. this is the 
%                       output structure of the command "dir").
%   files           -   All filenames that are listed in the subdirs
%
% See also DIR, FINDALLFILES

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer / Pieter van Geer
%
%       Kees.denHeijer@deltares.nl / Pieter.vanGeer@deltares.nl
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
%   --------------------------------------------------------------------% --------------------------------------------------------------------------

%% check input
if nargin == 0
    maindir = uigetdir;
end


%% create cell with dirnames
dirs = strread(genpath(maindir), '%s', 'delimiter', pathsep);

%% check exceptions
if nargin > 1
    if ischar(exc)
        exc = {exc};
    end
    for iexc = 1: length(exc)
        % find dirs containing exc in their name
        id = ~cellfun(@isempty, strfind(dirs, exc{iexc}));
        % remove dirs containing exc in their name
        dirs(id) = [];
    end
end

%% file contents for each dir; cell dircont corresponds to dirs
if nargout > 1
    dircont = struct(...
        'name', '',...
        'content', '');
    if nargout > 2
        files = cell(0);
    end

    for i = 1:length(dirs)
        cnt = dir(dirs{i});
        dircont(i).name = dirs{i};
        dircont(i).content = cnt(~[cnt.isdir]);
        if nargout > 2
            for j = 1:length(dircont(i).content)
                files{end+1} = fullfile(dirs{i}, dircont(i).content(j).name); %#ok<AGROW>
            end
        end
    end
end