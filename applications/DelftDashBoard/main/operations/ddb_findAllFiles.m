function files = ddb_findAllFiles(dr, filterspec)
%DDB_FINDALLFILES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   files = ddb_findAllFiles(dr, filterspec)
%
%   Input:
%   dr         =
%   filterspec =
%
%   Output:
%   files      =
%
%   Example
%   ddb_findAllFiles
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_findAllFiles.m 5539 2011-11-29 13:24:17Z boer_we $
% $Date: 2011-11-29 21:24:17 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5539 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/operations/ddb_findAllFiles.m $
% $Keywords: $

%% Find all files inside directory and sub directories with file extension

files=[];

if strcmpi(dr(end),filesep)
    dr=dr(1:end-1);
end

% All file in this folder
flist=dir([dr filesep filterspec]);
for i=1:length(flist)
    files{i}=[dr filesep flist(i).name];
end

% And the rest of the folders
flist=dir(dr);
for i=1:length(flist)
    filesInFolder=[];
    if isdir([dr filesep flist(i).name])
        switch flist(i).name
            case{'.','..','.svn'}
            otherwise
                filesInFolder=ddb_findAllFiles([dr filesep flist(i).name],filterspec);
        end
    end
    n=length(files);
    nf=length(filesInFolder);
    for j=1:nf
        n=n+1;
        files{n}=filesInFolder{j};
    end
end

