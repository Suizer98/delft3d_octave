function [X,Y,Z] = arcgridread(filename)

fid = fopen(filename,'r');

% The file header contains the following meta-data tags:
hdr = struct( ...
    'ncols','', ...
    'nrows','', ...
    'xllcorner','', ...
    'yllcorner','',...
    'cellsize','', ...
    'nodata_value','');

% Read the header line-by-line.
tags = fieldnames(hdr);
for k = 1:numel(tags)
    line = fgetl(fid);
    [tag, value] = strtok(line);
    tag = lower(tag);
    hdr.(tag) = str2double(value);
end

% Read the matrix of data values, putting the k-th row in the data
% file into the k-th column of matrix Z.  Close file -- nothing left to
% read after this.
Z = fscanf(fid,'%g',[hdr.ncols,hdr.nrows]);

% Replace each no-data value with NaN.
Z(Z == hdr.nodata_value) = NaN;

% Orient the data so that rows are parallel to the x-axis and columns
% are parallel to the y-axis (for compatibility with MATLAB functions
% like SURF and MESH).
Z = Z';

% Construct the referencing matrix.
R(1,2) = -hdr.cellsize;
R(2,1) = hdr.cellsize;
R(3,1) = hdr.xllcorner + hdr.cellsize/2 - R(2,1);
R(3,2) = hdr.yllcorner + (hdr.nrows - 1/2) * hdr.cellsize  - R(1,2);

%% Make X and Y
[input_n_y input_n_x]           = size(Z);
input_delta_x                   = R(2,1);
input_delta_y                   = R(1,2);
input_lon_w                     = R(3,1);
input_lon_e                     = R(3,1)+input_delta_x*(input_n_x-1);
input_lat_n                     = R(3,2);
input_lat_s                     = R(3,2)+input_delta_y*(input_n_y-1);
[X, Y]                          = meshgrid(input_lon_w:input_delta_x:input_lon_e,input_lat_n:input_delta_y:input_lat_s);

%% Finished
fclose('all');