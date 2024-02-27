function bzip(fname,varargin)
%BZIP  bzip2 compression/decompression
%
%   bzip(fname,<flags>);
%
% compression/decompression of fname that is <a href="http://www.bzip.org">bzip</a> 
% compressed (extension bz2) by calling bzip2-105-x86-win32.exe
%
% where flags by default is '-d' (force decompression without 
% keeping origional zipped file). The bzip2 flags are:
%
%   -h --help           print this message
%   -d --decompress     force decompression
%   -z --compress       force compression
%   -k --keep           keep (don't delete) input files
%   -f --force          overwrite existing output files
%   -t --test           test compressed file integrity
%   -c --stdout         output to standard out
%   -q --quiet          suppress noncritical error messages
%   -v --verbose        be verbose (a 2nd -v gives more)
%   -L --license        display software version & license
%   -V --version        display software version & license
%   -s --small          use less memory (at most 2500k)
%   -1 .. -9            set block size to 100k .. 900k
%   --fast              alias for -1
%   --best              alias for -9
%
%  If invoked as `bzip2', default action is to compress.
%             as `bunzip2',  default action is to decompress.
%             as `bzcat', default action is to decompress to stdout.
%
%  If no file names are given, bzip2 compresses or decompresses
%  from standard input to standard output.  You can combine
%  short flags, so `-v -4' means the same as -v4 or -4v, &c.%
%
% Example:
%
%   bzip('20050201-AVHRR16_L-EUR-L2P-mcsst_..._cnavo-v01.nc.bz2','-d -k')
%
%See also: ZIP, compress, uncompress

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: bzip.m 5221 2011-09-12 09:35:12Z boer_g $
% $Date: 2009-06$
% $Author: boer_g $
% $Revision: 5221 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/bzip.m $
% $Keywords: $

   flags = '-d';
   
   if nargin > 1
      flags = varargin{1};
   end
   
   basedir      = filepathstr(mfilename('fullpath'));
   
   if ispc
   cmd          = [basedir,filesep,'bzip2-105-x86-win32.exe ',fname,' ',flags];
   else
      error('other OS than windows not implemented')
   end
   
   system(cmd);
   
%% EOF   