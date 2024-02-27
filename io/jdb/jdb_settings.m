function varargout = jdb_settings(varargin)
%JDB_SETTINGS  Load toolbox for JDBC connection to a PostgreSQL or Oracle database 
%
% JDB_SETTINGS() adds correct JDBC to dynamic java path. You need to 
% do this every Matlab session when you want to use PostgreSQL or Oracle.
%
%   jdb_settings('dbtype','postgresql');
%   jdb_settings('dbtype','oracle');
%
% Alternatively you can let load it automatically into the static
% java path by adding it to in the following file that is read
% every new Matlab session: % <matlabroot>/toolbox/local/classpath.txt
% The static jave path has better performance than the dynamci path.
%
%See also postgresql, http://jdbc.postgresql.org/download.html, netcdf_settings

%% Copyright notice: see below

OPT.check  = 0;
OPT.quiet  = 0;
OPT.dbtype = 'oracle';

OPT = setproperty(OPT,varargin);

%Get all java classpath's
alljavaclasspath = path2os(javaclasspath('-all')); % can also be in static path in <matlabroot>/toolbox/local/classpath.txt

switch lower(OPT.dbtype)
    case 'postgresql'
        
        if any(strfindi(version('-java'),'Java 1.6')) || ...
                any(strfindi(version('-java'),'Java 1.7'))
            java2add = which('postgresql-9.3-1102.jdbc41.jar');
        elseif  any(strfindi(version('-java'),'Java 1.8'))
            java2add = which('postgresql-42.2.14.jar');
        else
            java2add = which('postgresql-9.3-1102.jdbc3.jar');            
        end
        
        [~,jdbfile,jdbext] = fileparts(java2add);
        indices            = strfindi(alljavaclasspath,path2os(java2add));
%         indices     = strfindi(alljavaclasspath,path2os([fileparts(mfilename('fullpath')),filesep,java2add]));
        
        if isempty(cell2mat(indices))           
            if OPT.check
                disp(['checked status PostgreSQL: JDBC NOT present: ',jdbfile, jdbext]);
                OK = -1;
            else
%                 javaaddpath (path2os([fileparts(mfilename('fullpath')),filesep,java2add]))
                % Add jar file to classpath (ensure it is present in your current dir)
                cwd = pwd;
                try
                    cd (fileparts(java2add))
                    javaclasspath([jdbfile,jdbext]);
                    if ~(OPT.quiet)
                        disp(['PostgreSQL: JDBC driver added: ',java2add]);
                    end
                    OK = 1;
                catch ME
                    disp(ME.message)
                    OK = -1;
                end
                cd(cwd)  
            end                        
        else            
            if OPT.check
                if ~(OPT.quiet)
                    disp(['checked status PostgreSQL: JDBC present: ',jdbfile]);
                end
                OK = 1;
            else
                if ~(OPT.quiet)
                    disp(['PostgreSQL: JDBC driver not added, already there: ',jdbfile]);
                end
                OK = 1;
            end           
        end
        
    case 'oracle'
        java2add          = which('ojdbc14.jar');
        [~,jdbfile,jdbext]= fileparts(java2add);
        indices           = strfindi(alljavaclasspath,path2os(java2add)) ;%[jdbpath,filesep,jdbfile]));
        
        if isempty(cell2mat(indices))
            if OPT.check
                disp(['checked status ORACLE: JDBC NOT present: ',jdbfile, jdbext]);
                OK = -1;
            else
                % Add jar file to classpath (ensure it is present in your current dir)
                cwd = pwd;
                try
                    cd (fileparts(which('ojdbc14.jar')))
                    javaclasspath('ojdbc14.jar');
                    OK = 1;
                catch ME
                    disp(ME.message)
                    OK = -1;
                end
                cd(cwd)
            end
        else            
            if OPT.check
                if ~(OPT.quiet)
                    disp(['checked status ORACLE: JDBC present: ',jdbfile]);
                end
                OK = 1;
            else
                if ~(OPT.quiet)
                    disp(['ORACLE: JDBC driver not added, already there: ',jdbfile]);
                end
                OK = 1;
            end
        end
        
    case 'access'
        for jarfile = {'hsqldb.jar' 'jackcess-2.1.3.jar' 'commons-lang-2.6.jar' 'commons-logging-1.1.1.jar' 'ucanaccess-3.0.4.jar'}
            %CLASSPATH="%UCANACCESS_HOME%\lib\hsqldb.jar;%UCANACCESS_HOME%\lib\jackcess-2.1.3.jar;%UCANACCESS_HOME%\lib\commons-lang-2.6.jar;%UCANACCESS_HOME%\lib\commons-logging-1.1.1.jar;%UCANACCESS_HOME%\ucanaccess-3.0.4.jar"
            java2add          = which(jarfile{:});
            [~,jdbfile,jdbext]= fileparts(java2add);

            indices           = strfindi(alljavaclasspath,path2os(java2add)) ;%[jdbpath,filesep,jdbfile]));

            if isempty(cell2mat(indices))
                if OPT.check
                    disp(['checked status ACCESS: JDBC NOT present: ',jdbfile, jdbext]);
                    OK = -1;
                else
                    javaaddpath (path2os(java2add))
                    if ~(OPT.quiet)
                        disp(['ACCESS: JDBC driver added: ',java2add]);
                    end

                end
            else            
                if OPT.check
                    if ~(OPT.quiet)
                        disp(['checked status ACCESS: JDBC present: ',jdbfile]);
                    end
                    OK = 1;
                else
                    if ~(OPT.quiet)
                        disp(['ACCESS: JDBC driver not added, already there: ',jdbfile]);
                    end
                    OK = 1;
                end
            end
        end
        
    otherwise
        disp(['Requested database: ' OPT.db ' not present.']);
        OK = -1;
end

if nargout==1
    varargout = {OK};
end

function K = strfindi(txt,txts)
% strfindi  - case insensitive strfind
% handles issue that alljavaclasspath() uses capital C: whereas which() returns c:\

K = strfind(lower(txt),lower(txts));


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
%       ronald.vanderhout@vanoord.com
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
% $Id: jdb_settings.m 16426 2020-06-18 08:49:23Z wcn.vessies.x $
% $Date: 2020-06-18 16:49:23 +0800 (Thu, 18 Jun 2020) $
% $Author: wcn.vessies.x $
% $Revision: 16426 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/jdb/jdb_settings.m $
