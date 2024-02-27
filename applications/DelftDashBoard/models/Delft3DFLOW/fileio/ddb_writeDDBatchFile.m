function ddb_writeDDBatchFile(ddfile)
%DDB_WRITEDDBATCHFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_writeDDBatchFile(ddfile)
%
%   Input:
%   ddfile =
%
%
%
%
%   Example
%   ddb_writeDDBatchFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_writeDDBatchFile.m 10628 2014-04-30 16:31:40Z boer_we $
% $Date: 2014-05-01 00:31:40 +0800 (Thu, 01 May 2014) $
% $Author: boer_we $
% $Revision: 10628 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/fileio/ddb_writeDDBatchFile.m $
% $Keywords: $

%%
% fid = fopen('batch_flw_dd.bat','wt');
% 
% if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
%     
%     fprintf(fid,'%s\n','@ echo off');
%     fprintf(fid,'%s\n','set argfile=config_flow2d3d_dd.ini');
%     fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
%     fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
%     fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
%     fclose(fid);
%     
%     % Write config file
%     fini=fopen('config_flow2d3d_dd.ini','w');
%     fprintf(fini,'%s\n','[FileInformation]');
%     fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
%     fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
%     fprintf(fini,'%s\n','   FileVersion      = 00.01');
%     fprintf(fini,'%s\n','[Component]');
%     fprintf(fini,'%s\n','   Name                = flow2d3d');
%     fprintf(fini,'%s\n',['   DDBfile             = ' ddfile]);
%     fclose(fini);
%     
% else
%     
%     if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\trisim.exe'],'file')
%     elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\delftflow.exe'],'file')
%         fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
%         fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
%         fprintf(fid,'%s\n',['echo -c ' ddfile ' >%argfile%']);
%         fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
%     end
%     
% end

handles=getHandles;
fname = 'batch_flw_dd.bat';
switch handles.model.delft3dflow.version
        
        case{'5.00.xx'}

            % Batch file
            fid=fopen(fname,'w');            
            fprintf(fid,'%s\n','@ echo off');            
            fprintf(fid,'%s\n','set argfile=config_flow2d3d_dd.ini');
            fprintf(fid,'%s\n',['set flowexedir="' handles.model.delft3dflow.exedir '"']);
            fprintf(fid,'%s\n','set PATH=%waveexedir%;%flowexedir%;%PATH%');
            fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
            fclose(fid);
            
            % Write config file
            fini=fopen('config_flow2d3d_dd.ini','w');
            fprintf(fini,'%s\n','[FileInformation]');
            fprintf(fini,'%s\n',['   FileCreatedBy    = DelftDashboard']);
            fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
            fprintf(fini,'%s\n','   FileVersion      = 00.01');
            fprintf(fini,'%s\n','[Component]');
            fprintf(fini,'%s\n','   Name                = flow2d3d');
            fprintf(fini,'%s\n',['   DDBfile             = ' ddfile]);
            fclose(fini);
            
        case{'6.00.xx','N/A'}
            
            % Batch file
            fid=fopen(fname,'w');            
            fprintf(fid,'%s\n','@ echo off');            
            fprintf(fid,'%s\n','set argfile=config_d_hydro_dd.xml');            
            fprintf(fid,'%s\n',['set flowexedir="' handles.model.delft3dflow.exedir '"']);
            fprintf(fid,'%s\n','set PATH=%flowexedir%;%waveexedir%;%PATH%');
            fprintf(fid,'%s\n','%flowexedir%\d_hydro.exe %argfile%');
            fclose(fid);

            % Write xml config file
            fini=fopen('config_d_hydro_dd.xml','w');
            fprintf(fini,'%s\n','<?xml version=''1.0'' encoding=''iso-8859-1''?>');
            fprintf(fini,'%s\n','<deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">');
            fprintf(fini,'%s\n','<documentation>');
            fprintf(fini,'%s\n','File created by    : DelftDashboard');
            fprintf(fini,'%s\n',['File creation date : ' datestr(now)]);
            fprintf(fini,'%s\n','File version       : 1.00');
            fprintf(fini,'%s\n','</documentation>');
            fprintf(fini,'%s\n','<control>');
            fprintf(fini,'%s\n','<sequence>');
            fprintf(fini,'%s\n','<start>myNameFlow</start>');
            fprintf(fini,'%s\n','</sequence>');
            fprintf(fini,'%s\n','</control>');
            fprintf(fini,'%s\n','<flow2D3D name="myNameFlow">');
            fprintf(fini,'%s\n','<library>flow2d3d</library>');
            fprintf(fini,'%s\n',['<ddbFile>' ddfile '</ddbFile>']);
            fprintf(fini,'%s\n','</flow2D3D>');
            fprintf(fini,'%s\n','</deltaresHydro>');
            fclose(fini);
            
        otherwise
            % older version, not writing batch file
end

