function [type types counts] = xb_get_wavefiletype(filename)
%XB_GET_WAVEFILETYPE  Determines the type of wave definition file for XBeach input
%
%   Analyzes the contents of a wave definition file for XBeach input and
%   returns a string specifying the type of wave definition files.
%   Currently, the following types can be returned: unknown, filelist,
%   jonswap, jonswap_mtx, vardens, bcflist
%
%   Syntax:
%   type = xb_get_wavefiletype(filename)
%
%   Input:
%   filename  = filename of wave definition file to be analyzed
%
%   Output:
%   type      = string specifying the wave definition filetype
%   types     = wave definition filetypes available
%   counts    = matching scores of each filetype
%
%   Example
%   type = xb_get_wavefiletype(filename)
%
%   See also xb_read_params, xb_read_waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 23 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_wavefiletype.m 9421 2013-10-16 12:32:20Z bieman $
% $Date: 2013-10-16 20:32:20 +0800 (Wed, 16 Oct 2013) $
% $Author: bieman $
% $Revision: 9421 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_get_wavefiletype.m $
% $Keywords: $

%% set file types

types = {'unknown' 'filelist' 'jonswap' 'jonswap_mtx' 'vardens' 'bcflist' 'ezs'};
counts = zeros(1,length(types));

%% determine filetype

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

vardens_dim = [Inf Inf];

lcount = 1;
    
% read lines of file
fid = fopen(filename, 'r');
while ~feof(fid) && lcount < 100
    fline = fgetl(fid);
    if isempty(fline); continue; end;

    cnt = counts;

    % test for filelist
    try
        if strcmpi(fline, 'FILELIST') && lcount == 1
            counts = increase_count(types, counts, 'filelist');
        else
            [a b c] = strread(fline, '%f %f %s\n');
            if ~isempty(a) && ~isempty(b) && ~isempty(c) && lcount > 1
                counts = increase_count(types, counts, 'filelist');
            end
        end
    end

    % test for bcflist
    try
        [a b c d e f] = strread(fline, '%f %f %f %f %f %s\n');
        if ~isempty(a) && ~isempty(b) && ~isempty(c) && ...
                ~isempty(d) && ~isempty(e) && ~isempty(f) 
            counts = increase_count(types, counts, 'bcflist');
        end
    end

    % test for single jonswap
    try
        [key value] = strtok(fline, '=');
        if ~isempty(value) && ismember(strtrim(key), {'Hm0' 'fp' 'mainang' 'gammajsp' 's' 'fnyq'})
            counts = increase_count(types, counts, 'jonswap');
        end
    end

    % test for jonswap matrix
    try
        data = strread(fline, '%f', 'delimiter', ' ');
        if length(data) == 7
            counts = increase_count(types, counts, 'jonswap_mtx');
        end
    end

    % test for vardens
    try
        data = strread(fline, '%f', 'delimiter', ' ');
        switch length(data)
            case 1
                if lcount == 1
                    vardens_dim(1) = data(1);
                    counts = increase_count(types, counts, 'vardens');
                elseif lcount <= vardens_dim(1)+1
                    counts = increase_count(types, counts, 'vardens');
                elseif lcount == vardens_dim(1)+2
                    vardens_dim(2) = data(1);
                    counts = increase_count(types, counts, 'vardens');
                elseif lcount <= sum(vardens_dim)+2
                    counts = increase_count(types, counts, 'vardens');
                end
            case vardens_dim(1)
                if lcount > sum(vardens_dim)+2
                    counts = increase_count(types, counts, 'jonswap_mtx');
                end
        end
    end
    
    % test for ezs file
    try
        if ~isempty(regexp(fline, '^BL\d+$', 'once')) || ~isempty(regexp(fline, '^\*', 'once'))
            counts = increase_count(types, counts, 'ezs');
        end
        
        [a b c d e] = strread(fline, '%f %f %f %f %f\n');
        if ~isempty(a) && ~isempty(b) && ~isempty(c) && ...
                ~isempty(d) && ~isempty(e)
            counts = increase_count(types, counts, 'ezs');
        end
    end

    % if no match found, increase unknown
    if sum(cnt) == sum(counts)
        counts = increase_count(types, counts, 'unknown');
    end

    lcount = lcount + 1;
end
fclose(fid);

% determine filetype with largest match score
[m i] = max(counts);
type = types{i};

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function counts = increase_count(types, counts, type)
idx = strcmpi(type, types);
if counts(idx) >= sum(counts(~idx))
    counts(idx) = counts(idx)+1;
end