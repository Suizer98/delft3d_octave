function subfunc = get_subfunc(func)
%GET_SUBFUNC  Reads function declarations from in m-file
%
%   Reads function declarations from in m-file based on a function name
%
%   Syntax:
%   subfunc = get_subfunc(func)
%
%   Input:
%   func        = name of function to read
%
%   Output:
%   subfunc     = struct with function declarations
%
%   Example
%   subfunc = get_subfunc(func)
%
%   See also which

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 06 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: get_subfunc.m 3862 2011-01-13 10:13:55Z hoonhout $
% $Date: 2011-01-13 18:13:55 +0800 (Thu, 13 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3862 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/get_subfunc.m $
% $Keywords: $

%% read mfile

subfunc = struct('name', {}, 'varin', {}, 'varout', {});

fname = which(func);

if exist(fname, 'file')
    i = 1;
    fid = fopen(fname);
    while ~feof(fid)
        fline = fgetl(fid);
        re = regexp(fline, '^\s*function\s+(?<func>.+?)\s*$', 'names');
        if ~isempty(re)
            re = regexp(re.func, '\s*=\s*', 'split');
            
            if length(re) > 1
                varout = regexp(regexprep(re{1}, '\[|\]', ''), '[\s,]+', 'split');
                func = re{2};
            else
                varout = {};
                func = re{1};
            end
            
            re = regexp(func, '^\s*(?<name>[^\s]+)\s*\(\s*(?<varin>.*)\s*\)\s*$', 'names');
            
            if isempty(re)
                varin = {};
                name = strtrim(func);
            else
                varin = regexp(re.varin, '[\s,]+', 'split');
                name = re.name;
            end
            
            subfunc(i) = struct( ...
                'name', name, ...
                'varin', {setdiff(varin, {''})}, ...
                'varout', {setdiff(varout, {''})} ...
            );
        
            i = i + 1;
        end
    end
    fclose(fid);
else
    error(['File does not exist [' fname ']']);
end
