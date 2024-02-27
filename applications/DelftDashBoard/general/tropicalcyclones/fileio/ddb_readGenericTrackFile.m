function tc = ddb_readGenericTrackFile(fname)
%DDB_READGENERICTRACKFILE  Read a generic .trk file and return the contents
%
%   This MATLAB function reads a generic, ASCII text, tropical cyclone
%   track file in the .trk format compatible with the Deltares WES.EXE
%   program.  See ddb_computeCyclone.m for an example of how to write such
%   a file.
%
%   Syntax:
%   tc = ddb_readGenericTrackFile(fname)
%
%   Input:
%   fname  = Full path name of specified .trk file
%
%   Output:
%   tc = MATLAB data structure with the TC parameters
%
%   Example
%   tc = ddb_readGenericTrackFile(fname)
%
%   See also ddb_readBestTrackUnisys.m, ddb_computeCyclone.m
%
%  Revision History:
%  16 Dec 2011  Initial coding.  R.S. Linzell, QNA/NRL Code 7322
%  18 Jan 2012  Added support for obtaining the storm name from the 1st
%               record of the input .trk file; corrected the def. of
%               tc.nrTrackPoints.  (RSL)
%  20 Jan 2012  Added def. of 'MISS9'; added pre-allocation of the 2-D
%               arrays using the value of 'MISS9' to conform to the format
%               expected by subfunc. importTrack,
%               ddb_TropicalCycloneToolbox_setParameters.m  (RSL)
%
%*******************************************************************************

%  Initialize the output data structure.
tc.name = fname;

%  Define the missing value codes.
MISS = 1.0e30;
MISS9 = -999;

%  Define the quadrant option (uniform or perquadrant); presently, the TC
%  message file parsers average the R34/R50/... wind radii.
tc.quadrantOption='uniform';
iq = 1;  % Number of quadrants used in the data
nq = 4;  % Number of possible quadrants

%  Open the file.
fid = fopen(fname, 'r');

%  Define the number of header lines.
nhdr = 9;

%  Loop over the number of header lines to read, discard each.
for i = 1:nhdr
    %  Handle the 1st record separately, as it may have a storm name.
    if (i == 1)
        %  Obtain the storm name if available.
        txt = fgetl(fid);
        [s1,e1] = regexp(txt, 'File for ', 'start','end');
        [s2,e2] = regexp(txt,' from the','start','end');
        tc.name = txt(e1+1:s2-1);
    else
        fgetl(fid);
    end
end

%  Read the TC speed, direction
line = textscan(fid,'%f %f');

%  Parse the values.
tc.initDir = line{1};    % Storm initial direction (decimal degrees)
tc.initSpeed = line{2};  % Storm initial translation speed (knots)

%  Read, discard another header line.
fgetl(fid);

%  Define the data format.  This should work for any presently supported
%  track file type.
fmt = '%d %d %d %d %f %f %d %f %f %f %f %f %f %f %f %f';

%  The rest of the file contains data records.  There is no explicit number
%  of lines; read the rest of the file in a single call.
line = textscan(fid, fmt);

%  Close the input file.
fclose(fid);

%  Define the number of track points.
tc.nrTrackPoints = size(line{1},1);

%  Pre-allocate the 2-D arrays with the 2nd missing value code.
tc.vmax = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.rmax = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.r100 = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.r65 = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.r50 = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.r35 = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.a = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.b = zeros(tc.nrTrackPoints,nq) + MISS9;
tc.p = zeros(tc.nrTrackPoints,nq) + MISS9;

%  Loop over track points to store the remaining parameters.
for j = 1:tc.nrTrackPoints
    tc.time(j) = datenum(double(line{1}(j)),double(line{2}(j)),double(line{3}(j)),double(line{4}(j)),0.0,0.0);  % Date/Time (YYYY,MM,DD,HH)
    tc.lon(j) = line{6}(j);          % Longitude (decimal deg.)
    tc.lat(j) = line{5}(j);          % Latitude (dec. deg.)
    tc.vmax(j,iq) = line{8}(j);   % Max. sustained winds (knots)
    tc.rmax(j,iq) = line{9}(j);    % Radius of Max. Winds (nmi)
    tc.r100(j,iq) = line{10}(j);   % R100 radius (nmi)
    tc.r65(j,iq) = line{11}(j);    % R65 radius (nmi)
    tc.r50(j,iq) = line{12}(j);    % R50 radius (nmi)
    tc.r35(j,iq) = line{13}(j);    % R35 radius (nmi)
    tc.a(j) = line{14}(j);         % Holland 'A' parameter
    tc.b(j) = line{15}(j);         % Holland 'B' parameter
    tc.p(j,iq) = line{16}(j);  % Pressure drop (Pa)
    
    tc.method = line{7}(j);  % Method for WES.EXE; this also determines the order of the variables.
    %  Parse the remaining data based on the method. 
    %  NOTE: THIS IS DISABLED AS OF 16 DEC 2011 SINCE THE PARAMETERS ARE IN
    %  THE SAME ORDER REGARDLESS OF METHOD TYPE.
    %if (method == 1)
        % e,e,e,e,e,inp.trackB(j,iq),inp.trackA(j,iq),e
    %elseif (method == 2)
        % 
    %elseif (method == 3)
        % 
    %elseif (method == 4)
        % 
    %elseif (method == 5)
        % 
    %elseif (method == 6)
        % 
    %end
    
end

return;
