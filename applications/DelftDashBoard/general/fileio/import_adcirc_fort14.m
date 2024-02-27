function [x,y,z,n1,n2,n3] = import_adcirc_fort14(fort14_file,wb_h,pct_wb)
%  This function reads an ADCIRC fort.14 finite element mesh (FEM) file and
%  returns the nodal coordinates, including depths.
%
%  Syntax: [x,y,z] = read_adcirc_fort14(fort14_file)
%  where:  fort14_file is the name of the fort.14 FEM file,
%          x is the returned row vector of longitudes,
%          y is the returned row vector of latitudes, and
%          z is the returned row vector of depths
%
%  Calls:  [none]
%
%  Called by: 
%
%  Based on read_adcirc_fort14:
%  20 Dec 2011  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%
% written by David Sitton, QNA/NRL Code 7320
% Revision history: 
% Initial coding Dec. 2011
% Added status panel updates 20 Jan, 2011
%*******************************************************************************

if nargin < 3
    pct_wb = [0,1];
end
if nargin < 2
    wb_h = waitbar(0,'Reading Data from adcirc File');
end

%  Open the file & read, discard the 1st header record.
fid=fopen(fort14_file);
fgetl(fid);	 % 1st header line is descriptive text.

%  Read the number of elements, nodes, respectively.
data=fscanf(fid,'%d %d\n',2);
ne=data(1);  % Number of elements
nn=data(2);  % Number of nodes

waitbar(pct_wb(1),wb_h,'Reading the vertices of the data');

% this, as it turns out, is much faster than the loop below
loc_verts = textscan(fid,'%*d%f%f%f',nn); %roughly 7 seconds instead of several minutes
x=loc_verts{1};
y=loc_verts{2};
z=loc_verts{3};

waitbar(mean(pct_wb),wb_h,'Getting the triangulation of the data');


% get the indices of the triangles:
node_idxes = textscan(fid,'%*d%*d%d%d%d',ne); 
n1=node_idxes{1};
n2=node_idxes{2};
n3=node_idxes{3};

% %  Loop over nodes....
% for i = 1:nn
%     %  Read the nodal coordinate information.
%     data = fscanf(fid, '%d %f %f %f\n', 4);
%     x(i) = data(2);  %  Longitude, decimal degrees
%     y(i) = data(3);  %  Latitude, dec. deg.
%     z(i) = data(4);  %  Depth, m (positive downward)
% end

% get triangles:



%  Close file, return.
fclose(fid);

waitbar(pct_wb(2),wb_h,'Finished Reading ADCIRC data');


return;
