function savestr(fname,str)
%SAVESTR   save 2D char array to ASCII file
%
%   SAVESTR(filename,string)
%
% saves 2D char or cellstr string to file filename.
% Note: does not prompt if filename already exists
% but overwrites it.
%
%See also: LOADSTR, FOPEN, FPRINTF, FCLOSE, SAVE (*,'-ASCII')

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
%   -------------------------------------------------------------------

% $Id: savestr.m 8359 2013-03-20 16:16:24Z boer_g $
% $Date: 2013-03-21 00:16:24 +0800 (Thu, 21 Mar 2013) $
% $Author: boer_g $
% $Revision: 8359 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/savestr.m $
% $Keywords$

if ischar(str)
   str = cellstr(str);
end

fid = fopen(fname,'w');

%% basic method
% for ii=1:length(str)
%    fprintf(fid,'%s\n',str{ii});
% end

%% memory cache method to prevent disk IO latency slowing us down (trick from GooglePlot toolbox)
output = repmat(char(1),1,1e5);kk=1;
for ii=1:length(str)
   newOutput = sprintf('%s\n',str{ii});
   output(kk:kk+length(newOutput)-1) = newOutput;
   kk = kk+length(newOutput);
   % write output to file if output is full, and reset
   if kk>1e5
       fprintf(fid,'%c',output(1:kk-1));
       kk        = 1;
       output    = repmat(char(1),1,1e5);
   end
end
fprintf(fid,'%c',output(1:kk-1));

fclose(fid);

%% EOF
