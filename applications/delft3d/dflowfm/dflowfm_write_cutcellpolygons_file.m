function dflowfm_write_cutcellpolygons_file(DirPol,DirOutput,polNameStart)

% dflowfm_write_cutcellpolygons_file creates a cutcellpolygons.lst file,
% which can be used in Delft3D-FM to model the flow patterns around shorelines (e.g. islands)
% smoothly without adjusting the network. The cutcellpolygons.lst file
% contains the filenames of seperate polygons and needs to be added to the
% run directory (no addition is required in the .mdu file) 

% dflowfm_write_cutcellpolygons_file(DirPol,DirOutput,<polNameStart>)
% DirPol        = Required, location of the polygon file 
% DirOutput     = Required, directory where the cutcellpolygons.lst file and the seperate
%               polygon files need to be stored
% <polNameStart> = Optional, start of filname for the seperated polygons (if applicable)

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

if nargin < 3
    polNameStart = 'Polygon';
end

% open polygon
pol = landboundary('read',DirPol);

% check if .pol consists of several polygons
IDpolInterface = find(isnan(pol(:,1)));
if ~isempty(IDpolInterface)
	ID_pols = [0;find(isnan(pol(:,1)))];
end

% open cutcellpolygons.lst file
fid = fopen([DirOutput,filesep,'cutcellpolygons.lst'],'wt');

% write polygon files in DirOutput and put polygon filenames in cutcellpolygons.lst
if ~isempty(IDpolInterface)
    for pp = 1:length(ID_pols)-1
        pol_seperate = pol(ID_pols(pp)+1:ID_pols(pp+1)-1,:);
        tekal('write',[DirOutput,polNameStart,'_',num2str(pp,'%03i'),'.pli'],pol_seperate);
        fprintf(fid,'%s \n',[polNameStart,'_',num2str(pp,'%03i'),'.pli']);
    end
else
    [~,polName] = fileparts(DirPol);
    tekal('write',[DirOutput,polName,'.pli'],pol);    
    fprintf(fid,'%s \n',[polName,'.pli']);
end

fclose(fid);

