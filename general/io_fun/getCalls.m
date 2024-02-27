function IsCalls = getCalls(fun, directory, varargin)
% GETCALLS  routine to list functions which are called by 'fun'
%
%   Routine uses depfun to find all functions that are called. List is
%   filtered for functions that are subs of directory.
%   After Matlab2015a, throws the warning: DEPFUN will be removed in a future release. 
%   Use matlab.codetools.requiredFilesAndProducts instead. 
%
%   syntax:
%   IsCalls = getCalls(fun, directory)
%
%   input:
%       fun                 = function handle or string containing the name 
%                               of a function
%       directory           = string containing the directory in which
%                               (including sub dirs) must be searched
%
%   example:
%       IsCalls = getCalls('getDuneErosion_VTV2006', fileparts(which('getDuneErosion_VTV2006')))
%       IsCalls = getCalls('oetsettings', oetroot);
%
%
%   See also depfun, getIsCalledBy, oetrelease

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

% $Id: getCalls.m 12977 2016-11-07 16:19:28Z santinel $
% $Date: 2016-11-08 00:19:28 +0800 (Tue, 08 Nov 2016) $
% $Author: santinel $
% $Revision: 12977 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/getCalls.m $
% $Keywords: $

%%
getdefaults('directory', cd, 1);

IsCalls  = {};

%%
[fhandle fl fun] = checkfhandle(fun);
if ~fl
    return
end

if ~isempty(varargin)
    quiet = any(strcmpi('quiet', varargin));
else
    quiet = false;
end

% quick and dirty fix for duplicate functions: just take the first one
fullfunname = which(fun, '-all');
[FileDir FunName] = fileparts(fullfunname{1});
if ~isscalar(fullfunname)
    fprintf(1, 'Duplicate(s) of "%s" are ommitted\n', fun)
end

if ~isempty(FileDir)
    tempdir=cd;
    cd(FileDir);
end    

try
    %list = depfun(FunName, '-quiet', '-toponly');
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(FunName,'toponly');
    list = fList';
catch
    fprintf(2, 'Error in getCalls(%s); related calls are ommitted.\n', fun);
    list = {};
end
id = ~cellfun(@isempty,(strfind(lower(list), lower(directory))));

IsCalls = list(id);

%% display results

if ~quiet
    if ~isempty(IsCalls) % any results
        fprintf('\nfunction %s calls:\n',fun)
        for i = 1 : length(IsCalls)
            fileseplocations = strfind(IsCalls{i}, filesep); % find positions of file separators
            linestr=['<a href="error:' IsCalls{i} ',1,1">' IsCalls{i}(fileseplocations(end)+1:end) '</a>'];
            fprintf('  %s\n',linestr)
        end
    else % no results
        fprintf('\n function %s does not call any other function in the sub directories of %s\n',fun,directory)
    end
    fprintf('\n')
end

if ~isempty(FileDir)
    cd(tempdir);
end