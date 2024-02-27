function [x,y,z] = read_adcirc_fort14(fort14_file)
%  This function reads an ADCIRC fort.14 finite element mesh (FEM) file and
%  returns the nodal coordinates, including depths.  Note that depths are
%  positive downward, and elevations above sea level are negative.
%  Presently, the element list and boundary information are not read.
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
%  Revision History:
%  20 Dec 2011  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  04 Jan 2012  Replaced the FOR loop with a single fscanf() call; updated
%               the help content.
%
%*******************************************************************************

%  Open the file & read, discard the 1st header record.
fid = fopen(fort14_file);
fgetl(fid);	 % 1st header line is descriptive text.

%  Read the number of elements, nodes, respectively.
data = fscanf(fid,'%d %d\n',2);
ne=data(1);  % Number of elements
nn=data(2);  % Number of nodes

%  Read the nodal coordinate information.
data = fscanf(fid, '%d %f %f %f\n', [4,nn]);
%  Close file.
fclose(fid);

%  Parse the coordinate values.
x = data(2,:);  %  Longitude, decimal degrees
y = data(3,:);  %  Latitude, dec. deg.
z = data(4,:);  %  Depth, m (positive downward)

return;
