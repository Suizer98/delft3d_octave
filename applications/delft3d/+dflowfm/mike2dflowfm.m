function varargout = mike2dflowfm(varargin);
%mike2dflowfm -  convert Mike mesh to D-Flow FM mesh
%
% Creates a D-Flow FM mesh (*_net.nc file) from a MIKE mesh (*.mesh file)
%
%    <output> = dflowfm.mike2dflowfm(<1>,<2>);
%
%    <1>      = Filename/Location for the MIKE mesh file (*.mesh, optional)
%    <2>      = Filename/Location for the D-Flow FM grid file (*_net.nc, optional)
%    <output> = Output structure identical to dflowfm.readNet (optional)
%
%   Note that ALL input variables are optional, when simply calling
%   dflowfm.mike2dflowfm the user is asked to supply the MIKE *.mesh
%   file & supply a filename for the D-Flow FM grid file (*_net.nc)
%
% Input variable specification:
%
%  <Filename/Location for the MIKE mesh file>
%    A string containing the filename of the MIKE mesh (with or without
%    folder location, with or without *.mesh extension) as function input.
%    The MIKE mesh may contain both triangles and quadrangles.
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
%    FM_structure_from_MIKE_mesh = dflowfm.mike2dflowfm; *
%              * (User will be asked for all files)
%
%  Example 2:
%    dflowfm.mike2dflowfm('D:/dflowfm/MIKE_mesh.mesh'); *
%              * (User will be asked for a *.net_nc output filename)
%
%  Example 3:
%    dflowfm.mike2dflowfm('D:/dflowfm/MIKE_mesh.mesh','D:/dflowfm/output_net.nc');
%
%  Example 4:
%    FM_structure_from_MIKE_mesh_1 = dflowfm.mike2dflowfm('D:/dflowfm/MIKE_mesh.mesh','default');
%    FM_structure_from_MIKE_mesh_2 = dflowfm.readNet([pwd filesep 'output_net.nc']);
%    % Both structures are identical (in x, y, z, Links etc.)
%    
%
% See also: dflowfm, dflowfm.writeNet, dflowfm.adcirc2dflowfm

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
    uiwait(msgbox('No MIKE grid was choosen, please select one now...','MIKE grid missing','modal'))
    [mesh_name, mesh_path] = uigetfile('*.mesh', 'Select a MIKE grid (*.mesh)');
    if size(mesh_name==0,2)==1
        if mesh_name==0
            error('Aborted by user, since no *.mesh file was selected');
        end
    end
    
    varargin{1} = [mesh_path mesh_name];
end

mesh_file_in = varargin{1};

if isempty(strfind(mesh_file_in,filesep))
    mesh_file_in = [pwd filesep mesh_file_in];
end

if isdir(mesh_file_in(1:max(strfind(mesh_file_in,filesep))))
    if strcmp(mesh_file_in(end-4:end),'.mesh')==0
        mesh_file_in = [strrep(mesh_file_in,'.','') '.mesh'];
    end
else
    error('Location (folder) for *.mesh file is non-existant');
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
  error(['Could not find mesh file ' mesh_file_in]);
end

header1     = fgetl(fid);
header_nums = sscanf(header1,'%f');

% Extract the number of nodes (last number if many)
nnodes = header_nums(end,1);

% Get projection name
proj  = header1(1,(strfind(header1,num2str(nnodes))+size(num2str(nnodes),2)+1):end); % I assume 1 space between nnodes & projection name here...
										     % Note that projection is not stored in the dflowfm.readNet structure (yet), so not stored/exported here

% Read all node data
Nodes    = fscanf(fid,'%f %f %f %f %f\n',[5,nnodes]);
Nodes    = Nodes';

% Read element header line
header2  = fgetl(fid);
tmp      = sscanf(header2,'%d',3);
nelmts   = tmp(1);                 % number of elements
npelmt   = tmp(2);                 % Nodes per element
elmttype = tmp(3);                 % Element type (21 for triangles, 25 for mixed)

% Read all element data
if (npelmt == 3)
  Elmts  = fscanf(fid,'%f %f %f %f',[4,nelmts]);
elseif (npelmt == 4)
  Elmts  = fscanf(fid,'%f %f %f %f %f',[5,nelmts]);
else
  error('This mesh format is not supported, or there is an error in the mesh file or this script, contact the developer')
end
Elmts  = Elmts';

% Remove index number (always 1-incrementing, not needed)
Nodes  = Nodes(:,2:end);
Elmts  = Elmts(:,2:end);

fclose(fid);

tel=0;
for ii=1:size(Elmts,1)
    if size(Elmts(ii,:),2)==3;
        tel=tel+1;
        Links(tel,[1:2])=[Elmts(ii,1); Elmts(ii,2)];
        tel=tel+1;
        Links(tel,[1:2])=[Elmts(ii,2); Elmts(ii,3)];
        tel=tel+1;
        Links(tel,[1:2])=[Elmts(ii,3); Elmts(ii,1)];
    elseif size(Elmts(ii,:),2)==4;
        tel=tel+1;
        Links(tel,[1:2])=[Elmts(ii,1); Elmts(ii,2)];
        tel=tel+1;
        Links(tel,[1:2])=[Elmts(ii,2); Elmts(ii,3)];
        if Elmts(ii,4)==0
            tel=tel+1;
            Links(tel,[1:2])=[Elmts(ii,3); Elmts(ii,1)];
        else
            tel=tel+1;
            Links(tel,[1:2])=[Elmts(ii,3); Elmts(ii,4)];
            tel=tel+1;
            Links(tel,[1:2])=[Elmts(ii,4); Elmts(ii,1)];
        end
    else
        error('Gridcell other than triangle or quadrangle found, not supported');
    end
end

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



