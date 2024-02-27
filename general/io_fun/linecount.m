function [n, m] = linecount(file)
%LINECOUNT Return the line count for a file.
%
%   N = LINECOUNT(FILE) returns the number of lines in the specified file.
%   Only lines ending with an end-of-line character is counted.
%
%   [N, M] = LINECOUNT(FILE) returns a second value M which is the number of
%   lines in the specified file, including the last line even if it does not
%   end with an end-of-line character.  M is always either N or N+1.

%   Retrieved from on April 06 2010 by Thijs Damsma from:
%   http://home.online.no/~pjacklam/matlab/software/util/fileutil/linecount.m     

%   Author:      Peter J. Acklam
%   Time-stamp:  2004-06-05 21:03:19 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % check number of input arguments
   error(nargchk(1, 1, nargin));

   % see if the file exists
   if ~exist(file, 'file')
      error([file, ': No such file.']);
   end

   % initialize line counters
   n = 0;
   m = 0;

   % quick exit for empty files
   info = dir(file);
   if info.bytes == 0
      return
   end

   % open file for reading
   [fid, msg] = fopen(file, 'rb');
   if fid < 0
      error([file ': Can''t open the file for reading.']);
   end

   % initialize line number counter
   n = 0;

   while ~feof(fid)

      % read a chunk of data
      [data, count] = fread(fid, 262144, '*uchar');

      % increment the line counter
      n = n + sum(data == 10);

   end

   % see if the last line ends with a newline
   m = n;
   if data(end) ~= 10;
      m = m + 1;
   end

   % close file
   status = fclose(fid);
   if status < 0
      error([file ': Can''t close the file.']);
   end
