function strfrep(filename,origtext,newtext,varargin)
%STRFREP  Quickly replaces strings in files.
%
%   This function quickly replaces one or more strings in a file.
%
%   Syntax:
%   varargout = strfrep(filename,origtext,newtext)
%
%   Input:
%   filename  = filename of the ascii file in which a string has to be replaced
%   origtext  = a string or 1D cell array of strings with strings that need to be replaced
%   newtext   = variable of the same type and size as origtext with the new string or strings
%
% To replace beyond end-of-lines, fprint code as \n does not work, use 
% [char(13),char(10)] for windows, char(10) for linux, char(13) for mac
%
%   Example
%   strfrep(which('TODO'),'Display a TODO message','Display a TODO message');
%
%   See also strrep fread fopen fprinteol

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 18 Dec 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: strfrep.m 8872 2013-07-01 15:09:13Z boer_g $
% $Date: 2013-07-01 23:09:13 +0800 (Mon, 01 Jul 2013) $
% $Author: boer_g $
% $Revision: 8872 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/strfrep.m $
% $Keywords: $

%% Check input
if nargin < 3
    error('This function requires at least three input arguments');
end

%% Check file existance
fid1 = fopen(filename,'r');
if fid1==-1
    error([filename ' is not found.']);
end

%% transform char to cell (cell input is also possible)
if ischar(origtext)
    origtext = {origtext};
end
if ischar(newtext)
    newtext = {newtext};
end

%% read full text from file
fulltext = fread(fid1,'*char')';
fclose(fid1);

%% replace text
for irep = 1:length(origtext)
    if isnumeric(newtext{irep})
        if nargin > 3
            newtext{irep} = num2str(newtext{irep},varargin{1});
        else
            newtext{irep} = num2str(newtext{irep});
        end
    end
    fulltext = strrep(fulltext,origtext{irep},newtext{irep});
end

%% rewrite file
fid2 = fopen(filename,'w');
fprintf(fid2,'%s',fulltext);
fclose(fid2);