function dms = degrees2dms(angleInDegrees)
%DEGREES2DMS Convert degrees to degrees-minutes-seconds
%  
%   DMS = degrees2dms(angleInDegrees) converts angles from values in
%   degrees which may include a fractional part (sometimes called
%   "decimal degrees") to degree-minutes-seconds representation.
%
%   The input should be a real-valued column vector.  Given N-by-1
%   input, DMS will be N-by-3, with one row per input angle.
%  
%   The first column of DMS contains the "degrees" element and is
%   integer-valued.  The second column contains the "minutes" element
%   and is integer-valued.  The third column contains the "seconds"
%   element, and may have a non-zero fractional part.
%  
%   In any given row of DMS, the sign of the first non-zero element indicates
%   the sign of the overall angle.  A positive number indicates north
%   latitude or east longitude; a negative number indicates south
%   latitude or west longitude.  Any remaining elements in that row will
%   have non-negative values.
%  
%   Example
%   -------
%   angleInDegrees = [ 30.8457722555556; ...
%                     -82.0444189583333; ...
%                      -0.504756513888889;...
%                       0.004116666666667];
%  
%   dms = degrees2dms(angleInDegrees)
%  
%   % Convert angles to a string, with each angle on its own line.
%   nonnegative = all((dms >= 0),2);
%   hemisphere = repmat('N', size(nonnegative));
%   hemisphere(~nonnegative) = 'S';
%   absvalues = num2cell(abs(dms'));
%   values = [absvalues; num2cell(hemisphere')];
%   str = sprintf('%2.0fd%2.0fm%7.5fs%s\n', values{:})
%  
%   % Split the string into cells as delimited by the newline
%   % character, then return to the original values using STR2ANGLE.
%   newline = sprintf('\n');
%   a = strread(str,'%s',-1,'delimiter',newline);
%   for k = 1:numel(a)
%       str2angle(a{k})
%   end
%  
%   See also: dms2degrees, deg2rad, degrees2dms, rad2deg.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 2594 $  $Date: 2009-11-22 00:37:39 +0100 (Sun, 22 Nov 2009) $

% Ensure column-vector input.
inputSize = size(angleInDegrees);
angleInDegrees = angleInDegrees(:);
if ~isequal(size(angleInDegrees),inputSize)
    wid = sprintf('%s:%s:reshapingInput', 'map', mfilename);
    warning(wid,...
        'Reshaping input into %d-by-1 column vector.  Output will be %d-by-3.',...
        numel(angleInDegrees), numel(angleInDegrees));
end

% Construct a DMS array in which each nonzero
% element in a given row has the same sign.
minutes = 60*rem(angleInDegrees,1);
dms = [fix(angleInDegrees) fix(minutes) 60*rem(minutes,1)];

% Flip the sign in the seconds column (from negative to positive)
% if either degrees or minutes is negative.
negativeDorM = any(dms(:,1:2) < 0, 2);
dms(negativeDorM,3) = -dms(negativeDorM,3);

% Flip the sign in the minutes column (from negative to positive)
% if degrees is negative.
negativeD = (dms(:,1) < 0);
dms(negativeD,2) = -dms(negativeD,2);
