function ddb_Delft3DWAVE_writeBatchFile(mdwfile)
%DDB_DELFT3DWAVE_WRITEBATCHFILE  Writes Delft3D-WAVE stand-alone batch file

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% $Id: ddb_Delft3DWAVE_writeBatchFile.m 18234 2022-07-08 12:08:17Z leijnse $
% $Date: 2022-07-08 20:08:17 +0800 (Fri, 08 Jul 2022) $
% $Author: leijnse $
% $Revision: 18234 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DWAVE/fileio/ddb_Delft3DWAVE_writeBatchFile.m $
% $Keywords: $

%%
handles=getHandles;

fid=fopen('batch_wave.bat','wt');

% if ~isempty(getenv('D3D_HOME'))
%     exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\'];
% else
%     exedir='c:\delft3d\w32\wave\bin\';
% end

if ~isfield(handles.model.delft3dwave,'arch')
    handles.model.delft3dwave.arch = 'win32';
end




fprintf(fid, '%s\n',['set mdwfile=' mdwfile]);
fprintf(fid, '%s\n',['set ARCH=',handles.model.delft3dwave.arch]);
fprintf(fid, '%s\n',['set D3D_HOME=' handles.model.delft3dwave.exedir]);
fprintf(fid, '%s\n',['set waveexedir=%D3D_HOME%\%ARCH%\dwaves\bin']);
fprintf(fid, '%s\n',['set swanexedir=%D3D_HOME%\%ARCH%\swan\bin']);
fprintf(fid, '%s\n',['set swanbatdir=%D3D_HOME%\%ARCH%\swan\scripts']);

if isfield(handles.model.delft3dwave,'dlldir')
    fprintf(fid, '%s\n',['set dlldir=' handles.model.delft3dwave.dlldir]);
    fprintf(fid, '%s\n',['title Wave simulation']);
    
    fprintf(fid, '%s\n',['set PATH=%waveexedir%;%swanbatdir%;%swanexedir%;%dlldir%;%PATH%']);        
else
    fprintf(fid, '%s\n',['title Wave simulation']);
    fprintf(fid, '%s\n',['set PATH=%waveexedir%;%swanbatdir%;%swanexedir%;%PATH%']);
end
fprintf(fid, '%s\n',['"%waveexedir%\wave.exe" %mdwfile% 0']);
fprintf(fid, '%s\n',['title %CD%']);

fclose(fid);
