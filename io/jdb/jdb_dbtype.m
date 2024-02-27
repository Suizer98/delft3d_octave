function dbtype = jdb_dbtype(conn)
%jdb_dbtype returns dbtype from connection string
%
%  dbtype = jdb_dbtype(conn) where conn = jdb_connectdb()
%
% and dbtype is 'oracle','postgresql','access','unknown'
%
%See also: jdb_connectdb

C = textscan(class(conn), '%s', 'delimiter','.');
C = C{:};
if ismember('oracle',C)
    dbtype = 'oracle';
elseif ismember('postgresql',C)
    dbtype = 'postgresql';  
elseif ismember('ucanaccess',C)
    dbtype = 'access';  
else
    dbtype = 'unknown';
end