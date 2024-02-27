function str = fprinteol(varargin)
%FPRINTEOL   Write end-of-line symbol(s) of specific OS to file.
%
% Writes the system depenedent ASCII end of line 
% character to an open text file (fid) or string (str).
%
% str = FPRINTEOL(    OperationSystem)
%       FPRINTEOL(fid,OperationSystem)
%
% where fid is a file indentifier as returned by FOPEN,
% where OperationSystem is a string with value
% * 'u<nix>' & 'l<inux>'             char(    10) =  \n (hex: 0A) (default)
% * 'd<os>' & 'w<indows>' & 'p<c>'   char([13 10])=\r\n (hex: 0D, 0A)
% * 'm<ac>'                          char(    13) =\r   (hex: 0D) 
%
%See also: FOPEN, FPRINTF, FCLOSE

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: fprinteol.m 8891 2013-07-06 09:21:47Z boer_g $
% $Date: 2013-07-06 17:21:47 +0800 (Sat, 06 Jul 2013) $
% $Author: boer_g $
% $Revision: 8891 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/fprinteol.m $
% $Keywords$

   OS = 'l';

if nargout==1
   if nargin==1
      OS = varargin{1};
   end
    fid = [];
       if strcmpi(OS(1),'u');str = sprintf(  '\n');
   elseif strcmpi(OS(1),'l');str = sprintf(  '\n');
   elseif strcmpi(OS(1),'w');str = sprintf('\r\n');
   elseif strcmpi(OS(1),'d');str = sprintf('\r\n');
   elseif strcmpi(OS(1),'p');str = sprintf('\r\n');
   elseif strcmpi(OS(1),'m');str = sprintf('\r'  );
   end 
else
    fid = varargin{1};
   if nargin==2
      OS = varargin{2};
   end
       if strcmpi(OS(1),'u');fprintf(fid,  '\n');
   elseif strcmpi(OS(1),'l');fprintf(fid,  '\n');
   elseif strcmpi(OS(1),'w');fprintf(fid,'\r\n');
   elseif strcmpi(OS(1),'d');fprintf(fid,'\r\n');
   elseif strcmpi(OS(1),'p');fprintf(fid,'\r\n');
   elseif strcmpi(OS(1),'m');fprintf(fid,'\r'  );
   end 
end

%% EOF