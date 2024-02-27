function [IsCalledBy Line Column] = getIsCalledBy(fun, directory, varargin)
% GETISCALLEDBY  routine to list m-files which call 'fun'
%
%   Routine searches in all sub-directories of 'directory' and lists al
%   functions which call the function 'fun'. The items function list appear
%   as hyperlinks, directing to the location in the function where 'fun' is
%   called.
%   WARNING: this only works when the filename 'fun' exists! So, in case of
%   changing a function name, first scan for the dependencies, then change
%   all calls as well as the function name and file name itself!
%
%   syntax:
%   [IsCalledBy Line Column] = getIsCalledBy(fun, directory)
%
%   input:
%       fun                 = function handle or string containing the name 
%                               of a function
%       directory           = string containing the directory in which
%                               (including sub dirs) must be searched
%
%   example:
%
%
%   See also depfun, getCalls

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
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

% $Id: getIsCalledBy.m 2131 2010-01-08 10:17:07Z heijer $
% $Date: 2010-01-08 18:17:07 +0800 (Fri, 08 Jan 2010) $
% $Author: heijer $
% $Revision: 2131 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/getIsCalledBy.m $
% $Keywords: $

%% input variables
if ~isempty(varargin)
    quiet = any(strcmpi('quiet', varargin));
else
    quiet = false;
end

%%
[fhandle fl fun] = checkfhandle(fun);
if ~fl
    return
end

%% Current dir
currentdir = cd;

%% Set default parameters if not given as input
getdefaults('directory', cd, 1);

%% Initiate output variables variables
IsCalledBy = {};
[Line Column] = deal([]);

%% List directories
%
%    Actually all dirs in the matlab search path should be checked. This
%    will take a while. At this moment only the current dir (including
%    subdirs) is checked.
%       ===> path
%

subdirectories = strread(genpath(directory), '%s',...
    'delimiter', pathsep); % derive all sub dirs of 'directory'
id = cellfun(@isempty, strfind(subdirectories, 'svn')); % select only the sub dirs that do not contain 'svn'
subdirectories = subdirectories(id); % keep only relevant sub dirs

%% Search for calls to the specified function
warning('off', 'MATLAB:mir_warning_unrecognized_pragma');

id = 1;
for i = 1:length(subdirectories)
%     disp(['dir nr.: ' num2str(i) ' of ' num2str(length(subdirectories))]);
    files = dir([subdirectories{i} filesep '*.m']); % get m-files
    for j = 1 : length(files)
        cd(subdirectories{i});
        list = depfun(files(j).name,'-quiet','-toponly'); % each m-file calls: list
        filename = which(files(j).name);
        spaceinname = ~isempty(strfind(filename, ' '));
        if spaceinname
            fprintf(2, 'ommitted due to spaces in path and/or file name: %s\n', filename);
        else
            try
                str = mlintmex('-calls', filename);
                [code, templine, temploc, funcname] = strread(str,'%s %f %f %s');
                for k = 1:length(list)
                    [dummy tempfuncname] = fileparts(list{k});
                    if strcmpi(tempfuncname,fun) % function 'fun' occurs in list
                        ID = find(strcmpi(funcname, tempfuncname));
                        for m = 1:length(ID)
                            IsCalledBy{id} = files(j).name; %#ok<AGROW> % that particular file calls 'fun'
                            Line(id) = templine(ID(m));
                            Column(id) = temploc(ID(m));
                            id = id + 1;
                        end
                    end
                end
            catch %#ok<CTCH>
                fprintf(2, 'ommitted due to unknown error: %s\n', filename)
            end
        end
    end
end
warning('on', 'MATLAB:mir_warning_unrecognized_pragma');

%% display results

if ~quiet
    if ~isempty(IsCalledBy) % any results
        fprintf('\nfunction %s is called by:\n',fun)
        for i = 1 : length(IsCalledBy)
            filelocation = [fileparts(which(IsCalledBy{i})), filesep];
            linestr=['<a href="error:' filelocation IsCalledBy{i} ',' num2str(Line(i)) ',' num2str(Column(i)) '">' IsCalledBy{i} '</a> at line ' num2str(Line(i)) ', column ' num2str(Column(i))];
            fprintf('  %s\n',linestr)
        end
    else % no results
        fprintf('\n function %s is not called by any other function in the sub directories of %s\n',fun,directory)
    end
    fprintf('\n')
end

%% cd back to current dir
cd(currentdir);