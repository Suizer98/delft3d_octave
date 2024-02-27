function varargout  = m3u_read(fname,varargin)
%M3U_READ   load *.m3u file
%
% [DATA,<iostat>] = m3u_read(filename,<keyword,value>)
% where <iostat> -1/-2/-3 indicates an error in 
% finding/opening/closing filename.
%
% The following <keyword,value> pairs have been implemented:
% * absolute: add absolute path of *.m3u file to song file
%             names if they are relative (default: true)
%             When true, m3u_read checks for existence of song.
%
% Example:
% 
%   D = m3u_read('D:\MP3\fresh mix 2.m3u','absolute',0);
%
%See also: mmfileinfo

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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

% $Id: m3u_read.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/mm/m3u_read.m $
% $Keywords$

% TO DO: handle url links

%% defaults
   DAT.filename     = fname;
   iostat           = 1;
   OPT.debug        = 0;

   OPT.absolute     = 1;

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

         %-% try

            %% read m3u file
            LINES = textscan(fid,'%s','delimiter','\n');
            fclose(fid);
            LINES = LINES{1};
            
            %% scroll data block
            if ~strcmpi(LINES{1}(1),'#')
              error('regular m3u format not implemented, only extended m3u format')
            else
              DAT.format   = 'Extended M3U';
              for ii=2:2:length(LINES)
                 line   = LINES{ii};
                 file   =      (ii)/2;
                 i1     = strfind(line,':');
                 i2     = strfind(line,',');
                 DAT.list(file).seconds = str2num(line(i1+1:i2-1));
                 DAT.list(file).title   =         line(i2+1:end );
                 DAT.list(file).name    = LINES{ii+1};
                 
                 %% Make all song file names absolute

                 check = 1;
                 if any(strcmp(DAT.list(file).name,':'))
                 else
                   if OPT.absolute
                     DAT.list(file).name = [filepathstr(DAT.filename),filesep,DAT.list(file).name];
                   else
                    check = 0;
                   end
                 end

                 %% Check whether song exists (exclude urls...)
                 if check
                   if length(dir(DAT.list(file).name))==0
                    disp(['Song does not exist: ',DAT.list(file).name])
                   end
                 end
                 
              end % song loop
            end % format
            
         %-% catch
         %-%  
         %-%    if nargout==1
         %-%       error(['Error reading file: ',fname])
         %-%    else
         %-%       iostat = -3;
         %-%    end      
         %-% 
         %-% end % try
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
   DAT.read.with     = '$Id: m3u_read.m 2616 2010-05-26 09:06:00Z geer $'; % SVN keyword, will insert name of this function
   DAT.read.at       = datestr(now);
   DAT.read.iostatus = iostat;

%% Function output

   if nargout    ==0 | nargout==1
      varargout  = {DAT};
   elseif nargout==2
      varargout  = {DAT,iostat};
   end
   
%% EOF
