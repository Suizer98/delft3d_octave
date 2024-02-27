function DAT = rws_zege_read(varargin)
%RWS_ZEGE_READ   Reads ASCII file from www.hmcz.nl
%
%      D = rws_zege_read('fname')
%
%   reads ASCII wind data file from www.hmcz.nl that looks like:
%
%   ----------------------------------------------------------
%   code
%   01-jan-2007 00:00          132          224          190          125          179           
%   ...
%   31-jan-2007 23:50           55          268           65           52           61            
%   ----------------------------------------------------------
%
%   HMCZ_WIND_READ returns a struct DAT containing the data from the 
%   file 'fname' which includes the following fields:
%
%   1 chlorosity   10 min. gemiddelde chlorositeit in [mg Cl/l]
%   2 conductivity 10 min. steekwaarde geleidendheid in [0.01 S/m]
%   3 temperature  10 min. steekwaarde watertemperatuur in [0.1 oC]
%   4 salinity     10 min. gemiddelde praktische saliniteit (resolutie 0.001)
%   5 density      10 min. gemiddelde soortelijk gewicht van zeewater in [kg/m3]
%
%   * Lines with a * are treated as NaNs.
%
% example:
%
%   D =rws_zege_read('st-sf-ha10-2004-2009.data ')
%   save           ('st-sf-ha10-2004-2009.mat','-STRUCT','D')
%   D        = load('st-sf-ha10-2004-2009.mat')
%
% See also: KNMI_POTWIND, RWS_HMCZ_WIND_READ

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@deltares.nl
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
%   --------------------------------------------------------------------

% $Id: rws_zege_read.m 8405 2013-04-04 14:56:22Z cronin $
% $Date: 2013-04-04 22:56:22 +0800 (Thu, 04 Apr 2013) $
% $Author: cronin $
% $Revision: 8405 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_zege_read.m $

%% file description

OPT.headerlines = 1;
OPT.nodatavalue = '*';
OPT.colnames    = {'chlorosity'  ,...
		   'conductivity',...
		   'temperature' ,...
		   'salinity'    ,...
		   'density'     };
OPT.colfactor   = [1   ,... % used for division
		   100 ,...
		   10  ,...
		   1000,...
		   1];
OPT.collegend   = {'10 min. gemiddelde chlorositeit in [mg Cl/l]',...
		   '10 min. steekwaarde geleidendheid in [S/m]',...     % note factor applied, units renamed
		   '10 min. steekwaarde watertemperatuur in [oC]',...   % note factor applied, units renamed
		   '10 min. gemiddelde praktische saliniteit (psu)',... % note factor applied, units renamed
		   '10 min. gemiddelde soortelijk gewicht van zeewater in [kg/m3]'};

%% cells are difficult to store as non-matlab files (HDF etc)
%  so we try to avoid them
no_cellstr    = 1;

   %% 0 - command line file name or 
   %      Launch file open GUI

   %% No file name specified if even number of arguments
   %  i.e. 2 or 4 input parameters
   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'*.src' ,'HMCZ wind file (*.data)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'HMCZ wind file (*.data)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         DAT.file.name   = [];
         iostat         = 0;
      else
         DAT.file.name   = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(DAT.file.name)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

   %% No file name specified if odd number of arguments
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      DAT.file.name   = varargin{1};
      iostat         = 1;
   end
   
   %% I - Check if file exists (actually redundant after file GUI)

   tmp = dir(DAT.file.name);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',DAT.file.name])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      DAT.file.date     = tmp.date;
      DAT.file.bytes    = tmp.bytes;
   
      fid              = fopen   (DAT.file.name,'r');
      
      %% II - Check if can be opened (locked etc.)

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',DAT.file.name])
         else
            iostat = -2;
         end
      
      elseif fid > 2

         %% II - Check if can be read (format etc.)
         
         nblock = 1;
         
         %% Count lines in stupid headerless file
         
            disp('Scanning file, please wait ...')
               nt     = 0;
            while 1
               tline = fgetl(fid);
               if ~ischar(tline), break, end
               nt = nt + 1;
            end
            nt = nt - 1; % pay attention to stupid extra line feed at end
            
            fseek(fid,0,-1); % rewind file
            
            disp(['   found ',num2str(nt),' lines.'])

         %% Pre-allocate

            DAT.data(nblock).datenum      = repmat(nan,[1 nt]);
            for icol=1:length(OPT.colnames)
            colname   = OPT.colnames{icol};
            collegend = OPT.colnames{icol};
            DAT.data(nblock).(colname)    = repmat(nan,[1 nt]);
            DAT.legend.chlorosity         = collegend;
            end

         %% Read 1st block header
         
            for ih=1:OPT.headerlines

            DAT.header{ih} = fgetl(fid);
            
            end

         %% Read 1st line

            disp('Reading file, please wait ...')
            nrow = 0;
	   
            while 1
            
            if mod(nrow,1000)==0
            disp(['   read ',num2str(nrow),' lines.'])
            end
	   
               %% Read block data
               %  Read one line
               %  01-jan-2007 00:00          147          239          178          139          168            

               record = fgetl(fid);
               if isempty(record)
               break
               else
               nrow   = nrow + 1;
               end

               %% Interpret one line
               
              [tok{1},record]  = strtok(record);
              
               tok{1} = strrep(tok{1},'mrt','mar');
               tok{1} = strrep(tok{1},'mei','may');
               tok{1} = strrep(tok{1},'okt','oct');
             
              [tok{2},record]  = strtok(record);
              datenum0        = datenum([tok{1} ' ' tok{2}],'dd-mmm-yyyy HH:MM');
               
               DAT.data(nblock).datenum (nrow) = datenum0;
               
               % I found cases where only one column is *, 
               % and the others are not, so we have to 
               % check each number separately
               
               for icol=1:length(OPT.colnames)
                  colname   = OPT.colnames{icol};
                  [tok{icol+2},record] = strtok(record);
                  if strcmp(deblank2(tok{icol+2}),OPT.nodatavalue)
                  DAT.data(nblock).(colname)(nrow) = nan;
                  else
                  DAT.data(nblock).(colname)(nrow) = str2num(tok{icol+2})./OPT.colfactor(icol);
                  end
               end
               
               tok = {};
               
            end % EOF
            
            % Chop too-much-preallocated due to stupid traling linefeeds
            
            DAT.data(nblock).datenum      = DAT.data(nblock).datenum(1:nrow);
            for icol=1:length(OPT.colnames)
            colname   = OPT.colnames{icol};
            DAT.data(nblock).(colname)    = DAT.data(nblock).(colname)(1:nrow);
            end
            
%         try
%         catch
%         
%            if nargout==1
%               error(['Error reading file: ',DAT.file.name])
%            else
%               iostat = -3;
%            end      
%         
%         end % try
      
         fclose(fid);

      end %  if fid <0

   end % if length(tmp)==0
   
   DAT.read.method = ['$Id: rws_zege_read.m 8405 2013-04-04 14:56:22Z cronin $']; 
   DAT.read.at     = datestr(now);
   DAT.read.status = iostat;
   
   %% Function output

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end

   %% EOF