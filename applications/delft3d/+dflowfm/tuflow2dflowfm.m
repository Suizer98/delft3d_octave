function G = tuflow2dflowfm(varargin)
%TUFLOW2DFLOWFM  Creates a Delft3D (D-Flow) FM mesh (*_net.nc file) from a TUFLOW grid (*.2dm file)
%
%   This function directly converts a TUFLOW (*.2dm) grid into a grid suitable for
%   Delft3D Flexible Mesh. Please note that:
%   - material roughness specified in the 2dm-file is not accounted for in this version
%   - The user may need to perform some manual adjustments to the grid in order to fulfill 
%     the grid orthogonality requirement of Delft3D-FM (see manual for details).
%
%   Input:  
%   tuflowGrdFile  = A string containing the filename of the TUFLOW mesh (optional). The TUFLOW mesh may contain both triangles and
%                    quadrangles. 
%   plotGrid       = Boolean to generate and save (*png) a
%                    plot of the grid (optional, default = false) 
%   
%   Output: 
%   G              = Output structure identical to dflowfm.readNet (optional)
%
%   Example 1:
%               G = tuflow2dflowfm; 
%               * user will be asked for input file, grid information will
%               be stored in structure 'G'
%   
%   Example 2:
%               tuflow2dflowfm('tuflowGrdFile','example_grid.2dm','plotGrid',1)
%               * Output grid file (example_grid_net.nc), will be saved in
%               local directory. Plots of grid and bathymetry will be
%               generated.
%   
%
%   See also: dflowfm, dflowfm.writeNet, dflowfm.mike2dflowfm, dflowfm.adcirc2dflowfm

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       Arnold van Rooijen
%
%       arnold.vanrooijen@deltares.nl
%
%
%   This library is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%
%   This library is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%
%   You should have received a copy of the GNU General Public License along
%   with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a
% href="http://www.OpenEarth.eu">OpenEarthTools</a>. OpenEarthTools is an
% online collaboration to share and manage data and programming tools in an
% open source, version controlled environment. Sign up to recieve regular
% updates of this function, and to contribute your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Sep 2018 Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: $ $Date: $ $Author: $ $Revision: $ $HeadURL: $ $Keywords: $

%% Read input
OPT.tuflowGrdFile ='';
OPT.plotGrid      = false;
OPT = setproperty(OPT, varargin);

if strcmp(OPT.tuflowGrdFile,'')
    uiwait(msgbox('No TUFLOW grid was specified, please select one now...','TUFLOW grid missing','modal'))
    [mesh_name, mesh_path] = uigetfile('*.2dm', 'Select a TUFLOW grid (*.2dm)');
    if size(mesh_name==0,2)==1
        if mesh_name==0
            error('Aborted by user, since no *.2dm file was selected');
        end
    end
    
    OPT.tuflowGrdFile = [mesh_path mesh_name];
end

% Output grid file name identical to input grid
OPT.dflowfmGrdFile = [OPT.tuflowGrdFile(1:end-4) '_net.nc'];

%% READ TUFLOW GRID AND GENERATE D-FLOW FM GRID

% % % 1) Get basic grid information/define number of elements and nodes % %
% %
fid       = fopen(OPT.tuflowGrdFile);
allText   = textscan(fid,'%s'); %selects the element data, headerlines allows program to skip 1st row
fclose(fid);
str       = allText{:};

NE4       = nnz(strcmp(str,'E4Q')); % number of quadrilateral elements
NE3       = nnz(strcmp(str,'E3T')); % number of triangular elements
NEt       = NE4 + NE3;              % total number of elements
ND        = nnz(strcmp(str,'ND'));  % number of nodes
headerNum = NEt+1;                  % start index of node input data
headerTot = NEt*7;                  % elements have up to 6/7 input parametesr: type(E4Q) , 3 or 4 node IDs, material
nodeNum   = ND*5;                   % node numbers have 5 input parameters: type(ND), Node ID, X, Y, Z

% Test if MESHNAME is part of the header (if yes than we have 3 header
% lines, otherwise just one)
headerTest = strcmp(allText{1,1}(2),'MESHNAME');
if headerTest == 1;
    headerCount = 3;
    headerNum = headerNum+2;
else
    headerCount = 1;
end

% % % 2) Get ELEMENT data (skip headers) % % %
fid    = fopen(OPT.tuflowGrdFile);
elText = textscan(fid,'%s',headerTot,'headerlines',headerCount);
EData  = elText{1,1};
fclose(fid);

indexE4Q  = strmatch('E4Q',EData);    % index of quadrilateral elements
indexE3T  = strmatch('E3T',EData);    % index of triangular elements

for i = 1:length(indexE4Q); % iterates over all of the QUADRILATERAL elements
    [a, b, c, d, e, f]   = EData{indexE4Q(i):(indexE4Q(i)+5)};
    Elmts4(i,1) = str2double(c);% start with c (a is element type, b is elem id)
    Elmts4(i,2) = str2double(d);
    Elmts4(i,3) = str2double(e);
    Elmts4(i,4) = str2double(f);
end

for i = 1:length(indexE3T); % iterates over all of the QUADRILATERAL elements
    [a, b, c, d, e]   = EData{indexE3T(i):(indexE3T(i)+4)};
    Elmts3(i,1) = str2double(c);% start with c (a is element type, b is elem id)
    Elmts3(i,2) = str2double(d);
    Elmts3(i,3) = str2double(e);
end

% % % 3) Get NODE data (skip headers+element data using 'headerNum') % % %
% %
fid    = fopen(OPT.tuflowGrdFile); 
ndText = textscan(fid,'%s',nodeNum,'headerlines',headerNum);
Nstr   = ndText{1,1};
fclose(fid);

% Extract only the node xyz values
for i = 1:3
    Nxyz_str(:,i) = Nstr(i+2:5:end,1); 
end
Nxyz_str = Nxyz_str';

% We can convert cell str2num, but saving/loading sample file (.xyz) is
% much faster
if 1
    fid = fopen([OPT.tuflowGrdFile(1:end-4) '.xyz'],'w','n');
    fprintf(fid,'%s   %s   %s\n',Nxyz_str{:,:});
    fclose(fid);
    Nxyz = importdata([OPT.tuflowGrdFile(1:end-4) '.xyz']); % import data as numeric
else
    Nxyz = cellfun(@str2num,Nxyz_str);
end

% % % 4 Create Net Links
tel=0;
Links = zeros(size(Elmts3,1)+size(Elmts4,1),2);
for ii=1:size(Elmts3,1)
    tel=tel+1;
    Links(tel,[1:2])=[Elmts3(ii,1); Elmts3(ii,2)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts3(ii,2); Elmts3(ii,3)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts3(ii,3); Elmts3(ii,1)];
end
for ii=1:size(Elmts4,1)
    tel=tel+1;
    Links(tel,[1:2])=[Elmts4(ii,1); Elmts4(ii,2)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts4(ii,2); Elmts4(ii,3)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts4(ii,3); Elmts4(ii,4)];
    tel=tel+1;
    Links(tel,[1:2])=[Elmts4(ii,4); Elmts4(ii,1)];
end

% % % 5) PLOT BATHYMETRY SAMPLES & GRID
if OPT.plotGrid
    disp('Plotting bathymetry...')
    % Plot Bathymetry samples
    figure;
    scatter(Nxyz(:,1),Nxyz(:,2),3,Nxyz(:,3));
    axis equal
    xlabel('X')
    ylabel('Y')
    cb = colorbar;
    title(cb,'bed level [m]')
    caxis([-50 0])
    title('bathymetry samples (.xyz)')
    print('-dpng',[OPT.tuflowGrdFile(1:end-4) '_BATHY'])
    
    % Plot Grid (this may take some time!)
    disp('Plotting grid...')
    xx = [];
    yy = [];
    for i = 1:size(Links,1)
        xx = [xx, Nxyz(Links(i,:),1)' NaN];
        yy = [yy, Nxyz(Links(i,:),2)' NaN];
    end
    figure
    plot(xx,yy,'k');
    axis equal
    xlabel('X')
    ylabel('Y')
    title('Grid')
    print('-dpng',[OPT.tuflowGrdFile(1:end-4) '_GRID'])
    disp('Done...')
end

% % % 6) Save grid as Delft3D FM NetCDF File Save Grid info in structure
G.file.name         = OPT.dflowfmGrdFile;
G.cor.x             = Nxyz(:,1)';
G.cor.y             = Nxyz(:,2)';
G.cor.z             = Nxyz(:,3)';
G.cor.n             = size(Nxyz,1);
G.cor.Link          = int32(Links');
G.cor.LinkType      = int32(repmat(2,1,size(Links,1)));
G.cor.nLink         = size(Links,1);
G.cor.flag_values   = [0 1 2];
G.cor.flag_meanings = {'closed_link_between_2D_nodes';'link_between_1D_nodes';'link_between_2D_nodes';};

% Use WriteNet tool from Open Earth Tools
dflowfm.writeNet(G.file.name,G.cor.x,G.cor.y,G.cor.Link,G.cor.z);

