function varargout = adcirc2dflowfm(varargin);
%adcirc2dflowfm -  convert ADCIRC grid to D-Flow FM mesh
%
% Creates a D-Flow FM mesh (*_net.nc file) from an ADCIRC grid (*.14 file)
%
%    <output> = dflowfm.adcirc2dflowfm(<1>,<2>);
%
%    <1>      = Filename/Location for the ADCIRC mesh file (*.14, optional)
%    <2>      = Filename/Location for the D-Flow FM grid file (*_net.nc, optional)
%    <output> = Output structure identical to dflowfm.readNet (optional)
%
%   Note that ALL input variables are optional, when simply calling
%   dflowfm.adcirc2dflowfm the user is asked to supply the ADCIRC *.14
%   file & supply a filename for the D-Flow FM grid file (*_net.nc)
%
% Input variable specification:
%
%  <Filename/Location for the ADCIRC grid file>
%    A string containing the filename of the ADCIRC grid (with or without
%    folder location, with or without *.14 extension) as function input.
%    The ADCIRC grid may only contain triangles (current ADCIRC limitation).
%
%  <Filename/Location for the D-Flow FM grid file>
%    A string containing the filename of the D-Flow FM grid file (with or 
%    without folder location, with or without *_net.nc extension), used for
%    function output. Note that existing *_net.nc files will be
%    overwritten. If 'default' is specified as a filename, the file will be
%    saved in the current directory as 'output_net.nc'
%
% Output variable specification:
%
%  <Output>
%    Output structure identical to dflowfm.readNet(<2>)
%
%
%  Example 1:
%    FM_structure_from_ADCIRC_grid = dflowfm.adcirc2dflowfm; *
%              * (User will be asked for all files)
%
%  Example 2:
%    dflowfm.adcirc2dflowfm('D:/dflowfm/ADCIRC_grid.14'); *
%              * (User will be asked for a *.net_nc output filename)
%
%  Example 3:
%    dflowfm.adcirc2dflowfm('D:/dflowfm/ADCIRC_grid.14','D:/dflowfm/output_net.nc');
%
%  Example 4:
%    FM_structure_from_ADCIRC_grid_1 = dflowfm.adcirc2dflowfm('D:/dflowfm/ADCIRC_grid.14','default');
%    FM_structure_from_ADCIRC_grid_2 = dflowfm.readNet([pwd filesep 'output_net.nc']);
%    % Both structures are identical (in x, y, z, Links etc.)
%    
%  Please note than any boundary conditions or other additional data in the
%  *.14 file is ignored during this conversion.
%
% See also: dflowfm, dflowfm.writeNet, dflowfm.mike2dflowfm

%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Please contact me if errors occur.
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

if size(varargin,2)==0
    uiwait(msgbox('No ADCIRC grid was choosen, please select one now...','ADCIRC grid missing','modal'))
    [mesh_name, mesh_path] = uigetfile('*.14', 'Select an ADCIRC grid (*.14)');
    if size(mesh_name==0,2)==1
        if mesh_name==0
            error('Aborted by user, since no *.14 file was selected');
        end
    end
    
    varargin{1} = [mesh_path mesh_name];
end

mesh_file_in = varargin{1};

if isempty(strfind(mesh_file_in,filesep))
    mesh_file_in = [pwd filesep mesh_file_in];
end

if isdir(mesh_file_in(1:max(strfind(mesh_file_in,filesep))))
    if strcmp(mesh_file_in(end-2:end),'.14')==0
        mesh_file_in = [strrep(mesh_file_in,'.','') '.14'];
    end
else
    error('Location (folder) for *.14 file is non-existant');
end

if size(varargin,2)==1
    uiwait(msgbox('No FM grid name was choosen, specify one now...','FM grid missing','modal'));
    varargin{2} = cell2mat(inputdlg('Specify an output name for the FM grid (*_net.nc) ','No output name specified',1,{'output_net.nc'}));
    if isempty(varargin{2})
        error('Aborted by user, since no output file was specified');
    end
end
    
fm_file_out = varargin{2};

if strcmp(fm_file_out,'default')==1
    fm_file_out = [pwd filesep 'output_net.nc'];
end

if isempty(strfind(fm_file_out,filesep))
    fm_file_out = [pwd filesep fm_file_out];
end

if isdir(fm_file_out(1:max(strfind(fm_file_out,filesep))))
    if strcmp(fm_file_out(end-6:end),'_net.nc')==0
        fm_file_out = [strrep(fm_file_out,'.','') '_net.nc'];
    end
else
    error('Location (folder) for grid saving is non-existant');
end


fid    = fopen(mesh_file_in,'rt');
if fid == -1
  error(['Could not find ADCIRC grid file ' mesh_file_in]);
end

header0     = fgetl(fid);
header1     = fgetl(fid);
header_nums = sscanf(header1,'%f');

% Extract the number of nodes (last number)
nnodes = header_nums(2,1);
nelmts = header_nums(1,1);

disp(['Reading original ADCIRC grid file...'])

% Read all node data
Nodes  = fscanf(fid,'%f %f %f %f %f\n',[4,nnodes]);
Nodes  = Nodes';

% Read all element data
Elmts  = fscanf(fid,'%f %f %f %f %f',[5,nelmts]);
Elmts  = Elmts';

% Remove index number and triangle size (always 1-incrementing and 3, not needed)
Nodes  = Nodes(:,2:end);
Elmts  = Elmts(:,3:end);

fclose(fid);

disp(['Storing individual elements...'])
Links = zeros(size(Elmts,1)*3,2);
tel=0;
perc = 0;
for ii=1:size(Elmts,1)
    if round(100*(ii/size(Elmts,1))) ~= perc
        disp([num2str(round(100*(ii/size(Elmts,1)))) '%']);
        perc = round(100*(ii/size(Elmts,1)));
    end
    tel=tel+1;
    Links(tel,[1:2])=[Elmts(ii,1); Elmts(ii,2)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts(ii,2); Elmts(ii,3)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts(ii,3); Elmts(ii,1)];
end

disp(['Converting to D-Flow FM links...'])
Links_sorted = sortrows([str2num(char(strrep(cellstr(num2str(sort(Links,2))),' ',''))) ([1:size(Links,1)]')],1);

tel=0;
for jj=2:size(Links_sorted,1)
    if Links_sorted(jj-1,1) == Links_sorted(jj,1)
        tel=tel+1;
        inds_del_temp(tel,1) = jj;
    end
end

inds_del = Links_sorted(inds_del_temp,2);
Links(inds_del,:) = [];

disp(['Saving to D-Flow FM grid file...'])

grd.file.name = fm_file_out;
grd.cor.x = [Nodes(:,1)'];
grd.cor.y = [Nodes(:,2)'];
grd.cor.z = [Nodes(:,3)'];
grd.cor.n = size(Nodes,1);
grd.cor.Link = int32([Links']);
grd.cor.LinkType = int32(repmat(2,1,size(Links,1)));
grd.cor.nLink = size(Links,1);
grd.cor.flag_values = [0 1 2];
grd.cor.flag_meanings = {'closed_link_between_2D_nodes';'link_between_1D_nodes';'link_between_2D_nodes';};

dflowfm.writeNet(fm_file_out,grd.cor.x,grd.cor.y,grd.cor.Link,grd.cor.z);

if nargout>0
    varargout{1}=grd;
    if nargout>1
        warning('Function only supports one output variable');
    end
end



