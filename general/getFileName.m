function fname = getFileName(directory, extension, exception, fileid)
%GETFILENAME  routine select to file
%
%   Routine lists available files in a predefined directory and asks the
%   user to choose out of the list. By predefining a extension, only the
%   files with that particular extension will be listed. The exception
%   gives the possibility to exclude one or more files from being listed
%
%   Syntax:
%   fname = getFileName(directory, extension, exception, fileid)
%
%   Input:
%   directory = string containing the directory
%   extension = string containing the extension (e.g. 'txt')
%   exception = string or cell array containing one or more
%               filesnames (including extension) to be excluded
%   fileid    = (optional) integer expressing the file choice
%               (e.g. 1 for the latest file)
%
%   Output:
%   fname     =
%
%   Example
%   getFileName
%
%   See also 

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

% Created: 20 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: getFileName.m 243 2009-02-20 13:42:53Z heijer $
% $Date: 2009-02-20 21:42:53 +0800 (Fri, 20 Feb 2009) $
% $Author: heijer $
% $Revision: 243 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/getFileName.m $
% $Keywords:

%% get defaults
variables  = getInputVariables(mfilename);
default_values = {cd, '*', [], []};
display_ind = zeros(size(variables));

getdefaults(variables, default_values, display_ind);

%%
if ischar(exception)
    exception = {exception};
end

% get files, exclude sub directories
files = dir(fullfile(directory, ['*.' extension]));
files = files(~[files.isdir]);

filescell = struct2cell(files);
for i = 1:length(exception)
    files = files(~strcmp(exception{i}, filescell(1,:)));
    filescell = filescell(:, ~strcmp(exception{i}, filescell(1,:)));
end
[dummy IX] = sort(cell2mat(filescell(5,:)));
files = flipud(files(IX));

if ~isempty(files)
    if isempty(fileid) || fileid<1 || fileid>length(files)
        for i = 1:length(files)
            fprintf('%3g   %s\n', i, files(i).name)
        end
    end

    fprintf('\n')

    while isempty(fileid) || fileid<1 || fileid>length(files)
        fileid = input('Enter the file number: ');
        if isempty(fileid) || fileid<1 || fileid>length(files)
            fprintf('Choose one of the available file numbers (1 through %g)\n', length(files))
        end
    end
    fname = fullfile(directory, files(fileid).name);
else
    if ~strcmp(extension, '*')
        fprintf('There are no files with extension "%s" available in directory %s\n', extension, directory)
    else
        fprintf('There are no files available in directory %s\n', directory)
    end
    fname = [];
end