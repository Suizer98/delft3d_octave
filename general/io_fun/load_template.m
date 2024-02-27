function varargout  = load_template(fname,varargin)
%LOAD_TEMPLATE   template for making a function that reads/loads a file
%
% [DATA,<iostat>] = load_template(filename)
% where <iostat> is optional.
%
% Opens and closes file for ASCII reading.
% The actual reading has still to be implemented, 
% dependent on your specific file.
%
% LOAD_TEMPLATE cathes the following errors:
% - error finding: iostat=-1
% - error opening: iostat=-2
% - error reading: iostat=-3
%
% and returns the following fields:
% -  filename: 'foo.txt'
% -  filedate: '23-May-2006 10:56:48'
% - filebytes: 2652688
% -  iomethod: ''
% -   read_at: '28-Jul-2006 13:20:55'
% -  iostatus: 1
%
%See also : oetnewfun

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

% $Id: load_template.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/load_template.m $
% $Keywords$

%% defaults
   DAT.filename     = fname;
   iostat           = 1;
   OPT.debug        = 0;

%% keywords
   OPT = setproperty(OPT, varargin{1:end});

%% check for file existence (1)

   tmp = dir(fname);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fname])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      DAT.filedate  = tmp.date;
      DAT.filebytes = tmp.bytes;
   
      filenameshort = filename(fname);
      
%% check for file opening (2)

      fid       = fopen  (fname,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fname])
         else
            iostat = -2;
         end
      
      elseif fid > 2
      
%% check for file reading (3)

         try

         % Implement actual reading of the ASCII file here
         % use low level (fgetl, fscanf, fread etc) or high-level functions here (textscan).
         % Read both data and metadata!
         
         DAT.meta = [];
         DAT.data = [];
          
         catch
          
            if nargout==1
               error(['Error reading file: ',fname])
            else
               iostat = -3;
            end      
         
         end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
   DAT.read.with     = '$Id: load_template.m 2616 2010-05-26 09:06:00Z geer $'; % SVN keyword, will insert name of this function
   DAT.read.at       = datestr(now);
   DAT.read.iostatus = iostat;

%% Function output

   if nargout    ==0 | nargout==1
      varargout  = {DAT};
   elseif nargout==2
      varargout  = {DAT,iostat};
   end
   
%% EOF
