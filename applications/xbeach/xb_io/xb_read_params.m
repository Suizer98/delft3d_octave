function xb = xb_read_params(filename, varargin)
%XB_READ_PARAMS  read XBeach params.txt file
%
%   Routine to read the xbeach settings from the params.txt file. The
%   settings are stored in a XBeach structure.
%
%   Syntax:
%   xb = xb_read_params(filename)
%
%   Input:
%   filename   = params.txt file name
%   varargin   = none
%
%   Output:
%   xb         = XBeach structure array
%
%   Example
%   xb_read_params
%
%   See also xb_read_input, xb_read_waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_read_params.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_params.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read params file

if isdir(filename)
    filename = fullfile(filename, 'params.txt');
end

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

fid = fopen(filename);
txt = fread(fid, '*char')';
fclose(fid);

%% read params

% obtain all keywords and values using regular expressions
[exprNames endIndex] = regexp([txt char(10)], ...
    '\s*(?<name>.*?)\s*=\s*(?<value>.*?)\s*\n', 'names', 'end', 'dotexceptnewline');

names = {exprNames.name};
values = {exprNames.value};

% distinguish between output variable definitions, doubles, strings and
% filenames
for i = 1:length(values)
    if any(~cellfun('isempty', regexp(names{i}, {'^n.*var$' '^npoints$' '^nrugauge$'})))
        % output variable definition
        list = txt(endIndex(i)+1:end);
        
        switch names{i}
            case 'npoints'
                names{i} = 'npoints';
                
                % support old notation of pointvars
                if ~ismember('pointvar', names) && any(list=='#')
                    re = regexp(list, '(\w+)#', 'tokens');
                    names = [names{:} {'pointvars'}];
                    values{length(names)} = unique(cat(1,re{:}));
                    list = regexprep(list,'\s+(\d+)\s+(\w+#)+','');
                end
            case 'nrugauge'
                names{i} = 'nrugauge';
            otherwise
                names{i} = [names{i}(2:end) 's'];
        end
        
        values{i} = strread(list, '%s', str2double(values{i}), 'delimiter', '\n');
    elseif ~isnan(str2double(values{i}))
        % numeric value
        values{i} = str2double(values{i});
    else
        % string value
        values{i} = strtrim(values{i});
    end
end

% remove doubles
[names idx] = unique(names, 'last');
values = values(idx);

% convert parameter cells to xbeach setting structure
xb = xs_empty();

for i = 1:length(names)
    if ~ismember(names{i}(1), {'%' '#' '$'})
        xb = xs_set(xb, names{i}, values{i});
    end
end

% set meta data
xb = xs_meta(xb, mfilename, 'params', filename);