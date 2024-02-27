function varargout = filerefmultiplatform(filename)
%FILEREFMULTIPLATFORM  make fullfile calls multiplatform applicable
%
%   Checks in the file "filename" all calls to fullfile for being
%   multiplatform applicable. If platform dependent "filesep"'s occur in
%   the call, the input arguments are replaced in a way that those
%   "filesep"'s can be avoided.
%
%   Syntax:
%   varargout = filerefmultiplatform(filename)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   filerefmultiplatform
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: filerefmultiplatform.m 2995 2010-08-26 12:20:31Z heijer $
% $Date: 2010-08-26 20:20:31 +0800 (Thu, 26 Aug 2010) $
% $Author: heijer $
% $Revision: 2995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/filerefmultiplatform.m $
% $Keywords: $

%%
if exist(filename, 'dir')
    % in case of a directory, scan all subdirectories for m-files
    [dirs dircont files] = dirlisting(filename, '.svn');
    for ifile = 1:length(files)
        [path, fname, extension] = fileparts(files{ifile});
        if strcmp(extension, '.m')
            filerefmultiplatform(files{ifile})
        end
    end
    return
end

%%
% open the m-file and read text
fid = fopen(filename);
if fid < 0
    error(['cannot open file:"' filename '"'])
end
str = fread(fid, '*char')';
fclose(fid);

%% locate all fullfile calls
[startids endids match] = regexp(str, 'fullfile\s?\(',...
    'start', 'end', 'match');

%% find the corresponding closing bracket, and so the whole fullfile call
for imatch = 1:length(startids)
    position = endids(imatch);
    bracketopenlevel = 1;
    while bracketopenlevel > 0
        position = position + 1;
        if str(position) == '('
            bracketopenlevel = bracketopenlevel + 1;
        elseif str(position) == ')'
            bracketopenlevel = bracketopenlevel - 1;
        end
    end
    endids(imatch) = position;
    match{imatch} = str(startids(imatch):endids(imatch));
end

%% create the replacements
replacement = match;
for imatch = 1:length(startids)
    sid = regexp(match{imatch}, '\\|/');
    
    for repstr = unique(match{imatch}(sid))
        replacement{imatch} = strrep(replacement{imatch}, repstr, ''', ''');
    end
end

%% create the updated file contents
newstr = str;
for imatch = 1:length(startids)
    if ~strcmp(match{imatch}, replacement{imatch})
        fprintf('file:\n%s\n', filename);
        fprintf('original call:\n%s\n', match{imatch});
        fprintf('replaced by:\n%s\n', replacement{imatch});
        newstr = strrep(newstr, match{imatch}, replacement{imatch});
    end
end

%% open the m-file and write new text
fid = fopen(filename, 'w');
fprintf(fid, '%s', newstr);
fclose(fid);