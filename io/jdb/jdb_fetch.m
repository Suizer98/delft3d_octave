function varargout = jdb_fetch(conn, sql, varargin)
% Executes a SQL query and imports database data into matlab
%
%   Executes a SQL query with the: 
%       (i)  licensed Mathworks database toolbox (with no checks etc.). 
%       (ii) the JDBC driver directly and fetches the result and checks 
%            the result for errors. 
%   Returns the resulting data in a cell array or matrix.
%
%   Syntax:
%   rs = jdb_fetch(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Fetched data from result set from SQL query
%
%   Remarks
%       The performance is improved by testing the jtype only on the first
%       row and increasing the fetch size.
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   jdb_fetch(conn, 'SELECT * FROM someTable');
%
%   See also jdb_exec, jdb_select_struct, jdb_insert_struct, jdb_update_struct, fetch

%% Copyright notice: see below

%% execute sql query
% inspect conn object to find out whether is was created with
% the licensed database toolbox or the JDCB driver directly.
OPT.database_toolbox = 0;
OPT.format = 'array';

try %#ok<TRYNC>
    if any(strfind(char(conn.Constructor),'mathworks'))
        OPT.database_toolbox = 1;
    end
end

OPT = setproperty(OPT, varargin);

if OPT.database_toolbox
    warning('Database toolbox is not fully implemented')
    data = fetch(conn, sql);
    header = {''};
    % does not parse time automatically to datenum
else

    % http://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html

    pstat = conn.prepareStatement(sql);
    rs = pstat.executeQuery();

    rsMetaData = rs.getMetaData();
    numberOfColumns = rsMetaData.getColumnCount();

    % a large fetch size greatly improves performance of large queries
    rs.setFetchSize(20000)      %Increased from 10000 -> better performance, 50000 gave errors

    row = 0;
    data = {};
    jtypes = cell(numberOfColumns,1);
    nrow = 0;
    while 1
        try
            if ~rs.next()
                break
            end
            row = row+1;
            for col = 1:numberOfColumns
                if row==1
                    jtypes{col} = char(rsMetaData.getColumnClassName(col));     % Only needed for first row (less calculations)
                end
    %                 jtype = char(rsMetaData.getColumnClassName(col));

                % not for editing:
                % If you are getting a JDB:DATA_FETCH_ERROR, then the
                % datatype you get is not implemented. There are many
                % datatypes, which are easy to implement as long as you
                % have test data. 
                % 
                % Please do not remove existing cases, just add more for
                % more cases
                switch jtypes{col} %jtype
                    case {'java.lang.String'}
                        data{row,col} = char(rs.getString(col));  %#ok<*AGROW>
                    case {'java.lang.Float','java.lang.Double','java.math.BigDecimal'}
                        data{row,col} = rs.getDouble(col);
                    case {'java.lang.Short','java.lang.Int','java.lang.Integer','java.lang.Long'}
                        data{row,col} = rs.getInt(col);
                    case {'java.sql.Timestamp','oracle.sql.TIMESTAMP'}
                        jt = rs.getTimestamp(col);
                        if isempty(jt)
                        data{row,col} = NaN;
                        else
                        mils_since_epoch = jt.getTime() - (jt.getTimezoneOffset * 60 * 1000);
                        epoch = datenum(1970,1,1);
                        data{row,col} = epoch + mils_since_epoch/1000/3600/24;
                        end
                    case {'java.lang.Boolean'}
                        data{row,col} = logical(rs.getBoolean(col));
                    case 'org.postgresql.util.PGInterval'
                        jt = rs.getTimestamp(col);
                        mils_since_epoch = jt.getTime() - (jt.getTimezoneOffset * 60 * 1000);
                        data{row,col} = mils_since_epoch * datenum(0,0,0,0,0,1/1000);
                    case {'java.lang.Object'} % e.g. hexadecimal PostGIS object
                        data{row,col} = rs.getString(col);
                    otherwise
                        warning('JDB:DATA_FETCH_ERROR:TYPE_NOT_IMPLEMENTED:datatype %s implemented',jtypes{col} )
                end
                nrow = nrow +1;
                if mod(nrow,100000)==0
                    disp(num2str(nrow))
                end
                
            end
        catch ME
            warning('JDB:DATA_FETCH_ERROR',ME.getReport())
            break
        end
    end

    header = arrayfun(...
        @(x) char(rsMetaData.getColumnName(x)),...
        (1:numberOfColumns),...
        'UniformOutput',false);

    pstat.close();
    rs.close();
end

%% convert to desired output format
switch OPT.format
    case 'array'
        varargout = {data,header};
    case 'struct'
        fieldnames = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(header));
        data_struct = struct();
        for ii = 1:length(fieldnames)
            if any(ischar([data{:,ii}]))
                data_struct.(fieldnames{ii}) = data(:,ii);
            else
                data_struct.(fieldnames{ii}) = [data{:,ii}]';
            end
        end
        varargout = {data_struct};
    otherwise
        error('Unknown format %s',OPT.format) 
end

%% debug options
prefs = getpref('postgresql');
if isstruct(prefs) && isfield(prefs, 'verbose') && prefs.verbose
    disp(sql);
end

if isstruct(prefs) && isfield(prefs, 'file') && ~isempty(prefs.file)
    fid = fopen(prefs.file, 'a');
    fprintf(fid, '%s\n', sql);
    fclose(fid);
end


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Bas Hoonhout
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       bas.hoonhout@deltares.nl
%       ronald.vanderhout@vanoord.com
%
%   JDBC: Copyright (C) 2012 Deltares for Building with Nature
%       Gerben J. de Boer
%       gerben.deboer@deltares.nl
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

% $Id: jdb_fetch.m 13042 2016-12-15 07:18:26Z gerben.deboer.x $
% $Date: 2016-12-15 15:18:26 +0800 (Thu, 15 Dec 2016) $
% $Author: gerben.deboer.x $
% $Revision: 13042 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_fetch.m $
% $Keywords: $
