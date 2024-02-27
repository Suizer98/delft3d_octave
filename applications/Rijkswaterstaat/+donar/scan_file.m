function Blocks = scan_file(diafile,varargin)
%scan_file scans an entire donar file: all blocks
%
% Blocks = scan_file(diafile) scans all blocks
% of an entire donar file, by alternatingly calling
% donar.read_header() and donar.scan_block(). Blocks
% contains the ftell positions of al headers and blokcs
% to allow direct access of those headers and blocks.
% * ftell  - [ftell_header ftell_block]
% * nlines - number of ascii lines
% * nval   - number of data tuples :-separated (x,y,t,value)
%
%See also: open = scan_file + merge_headers, scan_file = read_header + scan_block

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
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
% $Id: scan_file.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/scan_file.m $
% $Keywords: $

OPT.disp = 100;
OPT = setproperty(OPT,varargin);

fid = fopen(diafile,'r');
[hdr,boh] = donar.read_header(fid);
i   = 0; % block counter
if OPT.disp > 0
disp([mfilename,' scanning ',diafile]) % in case one of first OPT.disp blocks is BIG
end
while ~isnumeric(hdr)
   i = i + 1;
   Blocks(i).block_index = i;
   Blocks(i).hdr         = hdr;
   Blocks(i).ftell(1)    = boh;
  [Blocks(i).nline,...
   Blocks(i).nval, ...
   Blocks(i).ftell(2)] = donar.scan_block (fid,'rewind',0);
  [hdr,boh]            = donar.read_header(fid);
  if mod(i,OPT.disp)==0
  disp([mfilename,' scanned block ',num2str(i)])
  end
end
fclose(fid);
if OPT.disp > 0
  disp([mfilename,' # of blocks = ',num2str(i)])
  disp([mfilename,' # of values = ',num2str(sum([Blocks.nval]))]) 
end