function varargout = dbf_get(varargin)
%DBF_GET  Extracts data from a DBF result
%
%   Extracts data based on column name from a DBF result obtained from the
%   dbf_read or dbf_read_struct function. This can be a structure with
%   fields headers and data or two cell arrays with data and corresponding
%   headers seprately.
%   The rest of the input are either column names to be returned or a index
%   vector of records to be returned. Each column is returned as separate
%   variable.
%   Filtering of column names uses the strfilter superpowers. Be aware that
%   the number of returned variables can be unexpected when using filters.
%
%   Syntax:
%   varargout = dbf_get(varargin)
%
%   Input:
%   varargin  = 1:      DBF structure obtained from dbf_read_struct or DBF
%                       cell array with data obtained from dbf_read
%               2:      DBF cell array with headers obtained from dbf_read,
%                       first column name (or filter) to be returned or
%                       indexing vector
%               3 - N:  Column name (or filter) to be returned or indexing
%                       vector
%
%   Output:
%   varargout = Data for requested columns (one variable per colomn)
%
%   Example
%   [data headers] = dbf_read('someDatabase.DBF');
%   col1 = dbf_get(data, headers, 'Colomn_1');
%   [col1 col2] = dbf_get(data, headers, 'Colomn_1', 'Column_2');
%   [col1 col2 col3] = dbf_get(data, headers, 'Colomn_*');
%   [col1 col2 col3] = dbf_get(data, headers, '/Colomn_\d+');
%
%   DBF = dbf_read_struct('someDatabase.DBF');
%   col1 = dbf_get(DBF, 'Colomn_1');
%   [col1 col2] = dbf_get(DBF, 'Colomn_1', 'Column_2');
%   [col1 col2] = dbf_get(DBF, [1 2 3], 'Colomn_1', 'Column_2');
%   [col1 col2 col3] = dbf_get(DBF, 'Colomn_*', 1:10:101);
%
%   See also dbf_read, dbf_read_struct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: dbf_get.m 7083 2012-07-31 13:08:30Z hoonhout $
% $Date: 2012-07-31 21:08:30 +0800 (Tue, 31 Jul 2012) $
% $Author: hoonhout $
% $Revision: 7083 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/dbf/dbf_get.m $
% $Keywords: $

%% read input

varargout = {};

if ~isempty(varargin)
    
    if isstruct(varargin{1})
        
        if isfield(varargin{1}, 'data') && isfield(varargin{1}, 'headers')
        
            data    = varargin{1}.data;
            headers = varargin{1}.headers;
            vars    = varargin(2:end);
            
        else
            error('Unknown input structure');
        end
        
    elseif length(varargin) > 1
        
        data    = varargin{1};
        headers = varargin{2};
        vars    = varargin(3:end);
        
    else
        error('Not enough input parameters');
    end
    
    % look for indexing vectors
    idx     = ~cellfun(@ischar, vars);
    sel     = vars(idx);
    vars    = vars(~idx);
    
    % select all fields in case none are given
    if isempty(vars)
        vars = headers;
    end
    
    for i = 1:length(vars)
        
        idx = find(strfilter(headers, vars{i}));
    
        for j = 1:length(idx)

            varargout = [varargout {data(:,idx(j))}];

        end
    end
    
    if ~isempty(sel)
        for i = 1:length(varargout)
            varargout{i} = varargout{i}(sel{1});
        end
    end
    
end