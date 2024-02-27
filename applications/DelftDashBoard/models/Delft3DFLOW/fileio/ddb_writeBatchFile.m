function ddb_writeBatchFile(runid,varargin)
%DDB_WRITEBATCHFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_writeBatchFile(runid)
%
%   Input:
%   runid =
%
%
%
%
%   Example
%   ddb_writeBatchFile
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

handles=getHandles;

%%
if ispc,
    
    mdwfile=[];
    fname='batch_flow.bat';
    
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'mdwfile'}
                    mdwfile=varargin{ii+1};
                    fname='batch_flow_wave.bat';
            end
        end
    end
    
    switch handles.model.delft3dflow.version
        
        case{'5.00.xx'}
            
            % Batch file
            fid=fopen(fname,'w');
            fprintf(fid,'%s\n','@ echo off');
            fprintf(fid,'%s\n','set argfile=config_flow2d3d.xml');
            fprintf(fid,'%s\n',['set flowexedir="' handles.model.delft3dflow.exedir '"']);
            if ~isempty(mdwfile)
                fprintf(fid,'%s\n',['set waveexedir="' handles.model.delft3dwave.exedir '"']);
            end
            fprintf(fid,'%s\n','set PATH=%waveexedir%;%flowexedir%;%PATH%');
            if ~isempty(mdwfile)
                fprintf(fid,'%s\n','start %flowexedir%\deltares_hydro.exe %argfile%');
                fprintf(fid,'%s\n',['%waveexedir%\wave.exe ' mdwfile ' 1']);
            else
                fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
            end
            fclose(fid);
            
            % Write xml config file
            fini=fopen('config_flow2d3d.xml','w');
            fprintf(fini,'%s\n','<?xml version="1.0" encoding="iso-8859-1"?>');
            fprintf(fini,'%s\n','<DeltaresHydro start="flow2d3d">');
            fprintf(fini,'%s\n',['<flow2d3d MDFile = ''' runid '.mdf''></flow2d3d>']);
            fprintf(fini,'%s\n','</DeltaresHydro>');
            fclose(fini);
            
        case{'6.00.xx','N/A'}

            % Some work arounds. Use win32 folder as the real exe folder.
            flowexedir=handles.model.delft3dflow.exedir;
            waveexedir=handles.model.delft3dwave.exedir;
            if isfield(handles.model.delft3dwave,'swandir')
                swandir=handles.model.delft3dwave.swandir;
            else
                % Assume swan sits two directories higher
                if strcmpi(waveexedir(end),filesep)
                    waveexedir=waveexedir(1:end-1);
                end
                [pathstr,name,ext]=fileparts(waveexedir);
                [pathstr,name,ext]=fileparts(pathstr);
                swandir=[pathstr filesep 'swan'];
            end

            % Batch file
            fid=fopen(fname,'w');
            fprintf(fid,'%s\n','@ echo off');
            fprintf(fid,'%s\n','set argfile=config_d_hydro.xml');
            fprintf(fid,'%s\n',['set flowexedir=' flowexedir]);
            if ~isempty(mdwfile)
                fprintf(fid, '%s\n',['set mdwfile=' mdwfile]);
                fprintf(fid, '%s\n',['set ARCH=win64']);
                fprintf(fid, '%s\n',['set D3D_HOME=' handles.model.delft3dwave.exedir]);
                fprintf(fid, '%s\n',['set waveexedir=%D3D_HOME%\%ARCH%\wave\bin']);
                fprintf(fid, '%s\n',['set swanexedir=%D3D_HOME%\%ARCH%\swan\bin']);
                fprintf(fid, '%s\n',['set swanbatdir=%D3D_HOME%\%ARCH%\swan\scripts']);
                
                % Flow
                fprintf(fid, '%s\n',['rem Start FLOW']);
                fprintf(fid, '%s\n',['set PATH=%flowexedir%;%PATH%']);
                fprintf(fid, '%s\n',['start "Hydrodynamic simulation" "%flowexedir%\d_hydro.exe" %argfile%']);
                
                % Wave
                fprintf(fid, '%s\n',['title Wave simulation']);
                fprintf(fid, '%s\n',['set PATH=%waveexedir%;%swanbatdir%;%swanexedir%;%PATH%']);
                fprintf(fid, '%s\n',['"%waveexedir%\wave.exe" %mdwfile% 0']);
                fprintf(fid, '%s\n',['title %CD%']);
                
                % End
                fprintf(fid, '%s\n',[':end']);
            else
                fprintf(fid,'%s\n','set PATH=%flowexedir%;%PATH%');
                fprintf(fid,'%s\n','"%flowexedir%\d_hydro.exe" %argfile%');
            end
            fclose(fid);
            
            % Write xml config file
            fini=fopen('config_d_hydro.xml','w');
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
            fprintf(fini,'%s\n',['<mdfFile>' runid '.mdf</mdfFile>']);
            fprintf(fini,'%s\n','</flow2D3D>');
            fprintf(fini,'%s\n','</deltaresHydro>');
            fclose(fini);
            
        otherwise
            % older version, not writing batch file
    end
    
    %     fclose(fid);
    %
    %     if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin\d_hydro.exe'],'file')
    %
    % %         % Check whether Delft3D FLOW version has been set
    % %         handles=getHandles;
    % %         if handles.model.delft3dflow.VersionSelect == 0
    % %             clearInstructions;
    % %             ddb_zoomOff;
    % %             h=handles;
    % %             xmldir=handles.model.delft3dflow.xmlDir;
    % %             xmlfile='Delft3DFLOW.flowversion.xml';
    % %             [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
    % %
    % %             if ok
    % %                 handles=h;
    % %                 handles.model.delft3dflow.VersionSelect=1;
    % %                 setHandles(handles);
    % %             else
    % %                 ddb_giveWarning('','Could not generate batch file, because no flow version was selected')
    % %                 return
    % %             end
    % %         end
    %
    %         handles=getHandles;
    %
    %         % New open-source version
    %         fprintf(fid,'%s\n','@ echo off');
    %         if strcmp(handles.model.delft3dflow.version,'5.00.xx')
    %             fprintf(fid,'%s\n','set argfile=config_flow2d3d.xml');
    %             fprintf(fid,'%s\n',['set exedir="' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\"']);
    %         else
    %             fprintf(fid,'%s\n','set argfile=config_d_hydro.xml');
    %             fprintf(fid,'%s\n',['set exedir="' getenv('D3D_HOME') '\' getenv('ARCH') '\flow2d3d\bin\"']);
    %         end
    %         fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    %
    %         if ~isempty(mdwfile)
    %             fprintf(fid,'%s\n','start %exedir%\d_hydro.exe %argfile%');
    %             fprintf(fid,'%s\n',['"' getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe" ' mdwfile ' 1']);
    %         else
    %             fprintf(fid,'%s\n','%exedir%\d_hydro.exe %argfile%');
    %         end
    %
    %         if strcmp(handles.model.delft3dflow.version,'5.00.xx')
    %             % Xml only necessary for debugging in version 5.00.xx
    %
    %             % Write xml config file
    %             fini=fopen('config_flow2d3d.xml','w');
    %             fprintf(fini,'%s\n','<?xml version="1.0" encoding="iso-8859-1"?>');
    %             fprintf(fini,'%s\n','<DeltaresHydro start="flow2d3d">');
    %             fprintf(fini,'%s\n',['<flow2d3d MDFile = ''' runid '.mdf''></flow2d3d>']);
    %             fprintf(fini,'%s\n','</DeltaresHydro>');
    %             fclose(fini);
    %
    %             % Write old config file
    %             fini=fopen('config_flow2d3d.ini','w');
    %             fprintf(fini,'%s\n','[FileInformation]');
    %             fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    %             fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    %             fprintf(fini,'%s\n','   FileVersion      = 00.01');
    %             fprintf(fini,'%s\n','[Component]');
    %             fprintf(fini,'%s\n','   Name                = flow2d3d');
    %             fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    %             fclose(fini);
    %         else
    %             fini=fopen('config_d_hydro.xml','w');
    %             fprintf(fini,'%s\n','<?xml version=''1.0'' encoding=''iso-8859-1''?>');
    %             fprintf(fini,'%s\n','<deltaresHydro xmlns="http://schemas.deltares.nl/deltaresHydro" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.deltares.nl/deltaresHydro http://content.oss.deltares.nl/schemas/d_hydro-1.00.xsd">');
    %             fprintf(fini,'%s\n','<documentation>');
    %             fprintf(fini,'%s\n','File created by    : DelftDashboard');
    %             fprintf(fini,'%s\n',['File creation date : ' datestr(now)]);
    %             fprintf(fini,'%s\n','File version       : 1.00');
    %             fprintf(fini,'%s\n','</documentation>');
    %             fprintf(fini,'%s\n','<control>');
    %             fprintf(fini,'%s\n','<sequence>');
    %             fprintf(fini,'%s\n','<start>myNameFlow</start>');
    %             fprintf(fini,'%s\n','</sequence>');
    %             fprintf(fini,'%s\n','</control>');
    %             fprintf(fini,'%s\n','<flow2D3D name="myNameFlow">');
    %             fprintf(fini,'%s\n','<library>flow2d3d</library>');
    %             fprintf(fini,'%s\n',['<mdfFile>' runid '.mdf</mdfFile>']);
    %             fprintf(fini,'%s\n','</flow2D3D>');
    %             fprintf(fini,'%s\n','</deltaresHydro>');
    %             fclose(fini);
    %         end
    %
    %
    %     elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
    %
    %         % New open-source version
    %         fprintf(fid,'%s\n','@ echo off');
    %         fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
    %         fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    %         fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    %
    %         if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
    %
    %             % New open-source version
    %             fprintf(fid,'%s\n','@ echo off');
    %             fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
    %             fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    %             fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    %
    %             if ~isempty(mdwfile)
    %                 fprintf(fid,'%s\n','start %exedir%\deltares_hydro.exe %argfile%');
    %                 fprintf(fid,'%s\n',[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe ' mdwfile ' 1']);
    %             else
    %                 fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
    %             end
    %
    %             % Write config file
    %             fini=fopen('config_flow2d3d.ini','w');
    %             fprintf(fini,'%s\n','[FileInformation]');
    %             fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    %             fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    %             fprintf(fini,'%s\n','   FileVersion      = 00.01');
    %             fprintf(fini,'%s\n','[Component]');
    %             fprintf(fini,'%s\n','   Name                = flow2d3d');
    %             fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    %             fclose(fini);
    %
    %         else
    %             if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\trisim.exe'],'file')
    %                 fprintf(fid,'%s\n',['echo ' runid ' > runid ']);
    %                 fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\tdatom.exe');
    %                 fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\trisim.exe');
    %             elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\delftflow.exe'],'file')
    %                 fprintf(fid,'%s\n',['set runid=' runid]);
    %                 fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    %                 fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
    %                 fprintf(fid,'%s\n','echo -r %runid% >%argfile%');
    %                 fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
    %                 if ~isempty(mdwfile)
    %                     fprintf(fid,'%s\n','start %exedir%\delftflow.exe %argfile% dummy delft3d');
    %                     fprintf(fid,'%s\n',[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe ' mdwfile ' 1']);
    %                 else
    %                     fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
    %                 end
    %             else
    %
    %                 % Assume new open source version sits in c:\delft3d\w32\flow\bin\
    %                 fprintf(fid,'%s\n','@ echo off');
    %                 fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
    %                 fprintf(fid,'%s\n',['set exedir=c:\delft3d\w32\flow\bin\']);
    %                 fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    %                 if ~isempty(mdwfile)
    %                     fprintf(fid,'%s\n','start %exedir%\deltares_hydro.exe %argfile%');
    %                     fprintf(fid,'%s\n',['c:\delft3d\w32\flow\bin\wave\bin\wave.exe ' mdwfile ' 1']);
    %                 else
    %                     fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
    %                 end
    %
    %                 % Write config file
    %                 fini=fopen('config_flow2d3d.ini','w');
    %                 fprintf(fini,'%s\n','[FileInformation]');
    %                 fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    %                 fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    %                 fprintf(fini,'%s\n','   FileVersion      = 00.01');
    %                 fprintf(fini,'%s\n','[Component]');
    %                 fprintf(fini,'%s\n','   Name                = flow2d3d');
    %                 fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    %                 fclose(fini);
    %
    %             end
    %         end
    %     end
    %     fclose(fid);
    
    %% Now for the linux counterpart
elseif isunix
    mdwfile=[];
    fname='batch_flow.sh';
    for ii=1:length(varargin)
        if ischar(varargin{ii})
            switch lower(varargin{ii})
                case{'mdwfile'}
                    mdwfile=varargin{ii+1};
                    fname='batch_flow_wave.sh';
            end
        end
    end
    
    %     if ~exist(getenv('D3D_HOME'),'dir')
    %         fprintf('Could not find root Delft3D executables directory\n');
    %         fprintf('Execution paths and library assumed available\n');
    %         fprintf('Set D3D_HOME variable to approriate value in batch file\n');
    %     else
    %         if ~isempty(strfind(getenv('ARCH'),'lnx'))
    %             fprintf('Could not find ope\n');
    %         end
    %     end
    % Batch file
    fid=fopen(fname,'w');
    fprintf(fid,'%s\n','#!/bin/bash');
    fprintf(fid,'%s\n','argfile=config_d_hydro.xml');
    fprintf(fid,'%s\n',['flowexedir="' handles.model.delft3dflow.exedir '"']);
    if ~isempty(mdwfile)
        fprintf(fid,'%s\n',['waveexedir="' handles.model.delft3dwave.exedir '"']);
    end
    fprintf(fid,'%s\n','export PATH=$flowexedir:$waveexedir;$PATH');
    if ~isempty(mdwfile)
        fprintf(fid,'%s\n','$flowexedir/d_hydro.exe argfile &');
        fprintf(fid,'%s\n',['$waveexedir/wave.exe ' mdwfile ' 1']);
    else
        fprintf(fid,'%s\n','$flowexedir/d_hydro.exe argfile');
    end
    fclose(fid);
    
    % Write xml config file
    fini=fopen('config_d_hydro.xml','w');
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
    fprintf(fini,'%s\n',['<mdfFile>' runid '.mdf</mdfFile>']);
    fprintf(fini,'%s\n','</flow2D3D>');
    fprintf(fini,'%s\n','</deltaresHydro>');
    fclose(fini);
    
end
