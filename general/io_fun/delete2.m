function delete2(D)
%DELETE2  Deletes all files and folders in a structure returned by dir2
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = delete2(varargin)
%
%   Input:
%   D = struct returned by dir2 function
%
%   Output:
%   varargout =
%
%   Example
%   delete2
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 26 Apr 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: delete2.m 4662 2011-06-14 13:31:28Z thijs@damsma.net $
% $Date: 2011-06-14 21:31:28 +0800 (Tue, 14 Jun 2011) $
% $Author: thijs@damsma.net $
% $Revision: 4662 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/delete2.m $
% $Keywords: $

%% code
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

state.warning = warning;
warning off;

warn  = lastwarn;
dirs  = find( [D.isdir]);
files = find(~[D.isdir]);
for ii = files
    try
        delete([D(ii).pathname D(ii).name]);
    catch 
        disp(['could not remove file: ' D(ii).pathname D(ii).name]);
    end
    if ~isequal(warn,lastwarn)
        disp(['could not remove file: ' D(ii).pathname D(ii).name]);
        warn = lastwarn;
    end
end

[~,order] = sort(cellfun(@length,{D(dirs).pathname}),'descend');
dirs      = dirs(order);

for ii = dirs
    try
        rmdir([D(ii).pathname D(ii).name]);
    catch 
        disp(['could not remove directory: ' D(ii).pathname D(ii).name]);
    end
end

warning(state.warning)
