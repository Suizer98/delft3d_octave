function findreplace(file, otext, ntext, varargin)
%FINDREPLACE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   findreplace(file, otext, ntext, varargin)
%
%   Input:
%   file     =
%   otext    =
%   ntext    =
%   varargin =
%
%
%
%
%   Example
%   findreplace
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% FINDREPLACE finds and replaces strings in a text file
%
% SYNTAX:
%
% findreplace(file,oldtext,newtext)

% Obtaining the file full path
[fpath,fname,fext] = fileparts(file);
if isempty(fpath)
    out_path = pwd;
elseif fpath(1)=='.'
    out_path = [pwd filesep fpath];
else
    out_path = fpath;
end

% Reading the file contents
k=1;
fid = fopen([out_path filesep fname fext],'r');
while 1
    line{k} = fgetl(fid);
    if ~ischar(line{k})
        break;
    end
    k=k+1;
end
fclose(fid);

%Number of lines
nlines = length(line)-1;
for i=1:nlines
    if iscell(otext)
        for j=1:length(otext)
            line{i}=strrep(line{i},otext{j},ntext{j});
        end
    else
        line{i}=strrep(line{i},otext,ntext);
    end
end

line = line(1:end-1);

fid2 = fopen([out_path filesep fname fext],'w');

for i=1:nlines
    %    fprintf(fid2,[line{i} '\n']);
    fprintf(fid2,'%s\n',line{i});
end
fclose(fid2);

