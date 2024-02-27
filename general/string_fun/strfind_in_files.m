function [D,count] = strfind_in_files(D,expression,varargin)
%STRFIND_IN_FILES  advanced string find in files
%
%   The results of the query are added to the file name structure D
%
%   Syntax:
%   varargout = strfind_in_files(D,expression,varargin)
%
%   Input: For <keyword,value> pairs call strfind_in_files() without arguments.
%   D = file name structure as returnded by dir2
%   expression = what to look for. The default method simple looks for the
%   literal string in the file. If method is advanced, the expression is 
%   parsed with regexp, allowing for wildcards and other more advanced
%   queries.
%
%   Output:
%   D = modified file name structure with added field strfind
%
%   Example
%   % Find all calls to setproperty in the openearthtools
%    D = dir2(oetroot,'file_incl','\.m$','no_dirs',true);
%    [D,count] = strfind_in_files(D,'setproperty[^\)]*\)','method','regex_match');
%    sum(count)
%    D(count>0).strfind
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 10 Oct 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: strfind_in_files.m 7512 2012-10-16 16:37:54Z tda.x $
% $Date: 2012-10-17 00:37:54 +0800 (Wed, 17 Oct 2012) $
% $Author: tda.x $
% $Revision: 7512 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strfind_in_files.m $
% $Keywords: $

%%
OPT.method         = 'regex_match';
OPT.case_sensitive = false;
OPT.quiet          = false;
% return defaults (aka introspection)
if nargin==0;
    varargout = OPT;
    return;
end
OPT = setproperty(OPT,varargin{:});
% overwrite defaults with user arguments
%% preparations
% error checking
requiredfields =  {
    'name'
    'date'
    'bytes'
    'isdir'
    'datenum'
    'pathname'
    };

if ~all(ismember(requiredfields,fieldnames(D)))
    error('input must be a struct returned by dir2')
end

% parse method and case sensitivity
switch OPT.method
    case 'simple'
        if OPT.case_sensitive
            func = @strfind;
        else
            func = @strfindi;
        end
    case 'regex'
        if OPT.case_sensitive
            func = @regexp;
        else
            func = @regexpi;
        end
    case 'regex_match'
        if OPT.case_sensitive
            func = @(str, expr) regexp (str, expr,'match');
        else
            func = @(str, expr) regexpi(str, expr,'match');
        end
    otherwise
        error('Unknown method')
end

% add strfind field
isfile = ~[D.isdir]';
[D.strfind] = deal([]);

% setup waitbar
if ~OPT.quiet
    multiWaitbar('Processing files','reset','color',[0,.5,.5])
    totalBytes = sum([D(isfile).bytes]);
    readBytes  = 0;
    timer = tic;
end

%% start function
% loop through files
for ii = find(isfile)'
    % read file
    fid = fopen([D(ii).pathname D(ii).name],'r');
    contents = fread(fid,'*char')';
    fclose(fid);
    
    % search file
    D(ii).strfind = func(contents,expression);
    
    % waitbar
    readBytes = readBytes + D(ii).bytes;
    if ~OPT.quiet
        if toc(timer) > 0.1 || ii == find(isfile,1,'last')
            multiWaitbar('Processing files',readBytes/totalBytes);
            timer = tic;
        end
    end
end
count = cellfun(@length, {D.strfind})';