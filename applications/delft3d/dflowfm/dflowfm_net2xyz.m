function dflowfm_net2xyz(DirNC)

% dflowfm_pol2xyn creates a sample file based on the bathymetry of a Delft3D-FM network

%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
%       Wilbert Verbruggen
%
%       <Wilbert.Verbruggen@deltares.nl>;
%
%       Deltares
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

%% reading
Net = dflowfm.readNet(DirNC);
[Basepath,FileName] = fileparts(DirNC);

%% write sample file
matrix = [Net.node.x' Net.node.y' Net.node.z'];

IDremove1 = find(Net.node.z==-999);
IDremove2 = find(isnan(Net.node.z));
IDremove = unique([IDremove1;IDremove2]);
matrix(IDremove,:) = [];

fid = fopen([Basepath,filesep,FileName '.xyz'],'w');
fprintf(fid,[repmat('%16.7e',1,size(matrix,2)) '\n'],matrix');
fclose(fid);

