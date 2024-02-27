function DAT = rws_hmcz_wind_read(varargin)
%RWS_HMCZ_WIND_READ   Reads ASCII wind file from www.hmcz.nl
%
%      D = rws_hmcz_wind_read('fname')
%
%   eeads ASCII wind data file from www.hmcz.nl of type 
%   WNr2 (see 2nd line) that looks like:
%
%   ----------------------------------------------------------
%   20070101 0000 20070131 2350 10
%   STAV WNr2
%               1            2            3            4            5            6            7            8 
%   01-jan-2007 00:00          132          224          190          125          179           18          132            8 
%   ...
%   31-jan-2007 23:50           55          268           65           52           61            4           57            3 
%   ----------------------------------------------------------
%
%   HMCZ_WIND_READ returns a struct D containing the data from the 
%   file 'fname' which includes the following fields:
%
%   1 WS10     10-min. scalair gemiddelde windsnelheid in [m/s]
%   2 WR10     10-min. gemiddelde windrichting in [sex.grd. tov Nrd.]
%   3 WS10MXS3 Max. 3-sec. windstoot in de afgelopen 10 min. in [m/s]
%   4 WC10     10-min. scalair gemiddelde windsnelheid gecorrigeerd naar 10 m boven het zeeoppervlak in [m/s]
%   5 WC10MXS3 Max. 3-sec windstoot in de afgelopen 10 minuten gecorrigeerd naar 10 m boven het zeeoppervlak in [m/s]
%   6 WS10STD  Standaardafwijking van de windsnelheid in de afgelopen 10 min. in [m/s]
%   7 WS10MX10 Max. 10 min.  lopend gemiddelde windsnelheid in de afgelopen 10 min. in [m/s]
%   8 WR10STD  Standaardafwijking van de windrichting in de afgelopen 10 min. in [m/s]
%
%   * The different blocks in the file are loaded as separate blocks.
%   * Lines with a * are treated as NaNs.
%   * Note that the returned units are [m/s] whereas the file cointaisn [dm/s]
%
% See also: KNMI_POTWIND

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Gerben J. de Boer
%
%       g.j.deboer@deltares.nl (also: gerben.deboer@deltares.nl)
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

% $Id: rws_hmcz_wind_read.m 4791 2011-07-08 12:15:55Z cronin $
% $Date: 2011-07-08 20:15:55 +0800 (Fri, 08 Jul 2011) $
% $Author: cronin $
% $Revision: 4791 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_hmcz_wind_read.m $

mfile_version = '1.0, Oct. 2006, beta';

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
         DAT.filename   = [];
         iostat         = 0;
      else
         DAT.filename   = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(DAT.filename)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

   %% No file name specified if odd number of arguments
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      DAT.filename   = varargin{1};
      iostat         = 1;
   end
   
   %% I - Check if file exists (actually redundant after file GUI)

   tmp = dir(DAT.filename);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',DAT.filename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      DAT.filedate     = tmp.date;
      DAT.filebytes    = tmp.bytes;
   
      fid              = fopen   (DAT.filename,'r');
      
      %% II - Check if can be opened (locked etc.)

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',DAT.filename])
         else
            iostat = -2;
         end
      
      elseif fid > 2

         %% II - Check if can be read (format etc.)
         
         nblock = 1;
         
         %% Read 1st block header

            header{1}       = fgetl(fid);
            
           [datestr01,rest] = strtok(header{1});
           [timestr01,rest] = strtok(rest);
           
            datenum0        = time2datenum(datestr01,timestr01);
           [datestr02,rest] = strtok(rest);
           [timestr02,rest] = strtok(rest);
           [dtmn     ,rest] = str2num(strtok(rest));
            datenum1        = time2datenum(datestr02,timestr02);
            nt = round((datenum1 - datenum0)*24*60/dtmn +1);

            header{2}       = fgetl(fid);
            header{3}       = fgetl(fid);
            
            disp(['Reading data        : ',datestr(datenum0,0)]);
            disp(['up to and including : ',datestr(datenum1,0),'   = block ',num2str(nblock)]);
            
            DAT.data(nblock).datenum  = repmat(nan,[1 nt]);
            DAT.data(nblock).WR10     = repmat(nan,[1 nt]);
            DAT.data(nblock).WS10MXS3 = repmat(nan,[1 nt]);
            DAT.data(nblock).WC10     = repmat(nan,[1 nt]);
            DAT.data(nblock).WC10MXS3 = repmat(nan,[1 nt]);
            DAT.data(nblock).WS10STD  = repmat(nan,[1 nt]);
            DAT.data(nblock).WS10MX10 = repmat(nan,[1 nt]);
            DAT.data(nblock).WR10STD  = repmat(nan,[1 nt]);
            nrow                      = 0;
	   
            while 1
	   
               %% Read block data
               %  Read one line
               %  01-jan-2007 00:00          147          239          178          139          168            9          158            4 

               record = fgetl(fid);
               % disp(record)
               
               nrow = nrow + 1;
               
               %% Interpret one line
               
               [tok01,record] = strtok(record);
               [tok02,record] = strtok(record);
              
               tok01 = strrep(tok01,'mrt','mar'); % as datenum doesn't recognise otherwise
               tok01 = strrep(tok01,'mei','may');
               tok01 = strrep(tok01,'okt','oct');
               
               hr             = str2num(tok02(1:2));
               mn             = str2num(tok02(4:5));
               datenumnow     = datenum(tok01     ) + (hr + mn./60)./24;
               
                                               DAT.data(nblock).datenum (nrow) = datenumnow;
               [tok03,record] = strtok(record);
               
               %% I found cases where only one column is *, and the others are not, so we have to check each number separately
               
               if strcmp(deblank2(tok03),'*')
               DAT.data(nblock).WS10    (nrow) = nan;
               else
               DAT.data(nblock).WS10    (nrow) = str2num(tok03)./10; % [m/s]
               end
               
               [tok04,record] = strtok(record);
               if strcmp(deblank2(tok04),'*')
               DAT.data(nblock).WR10    (nrow) = nan;
               else
               DAT.data(nblock).WR10    (nrow) = str2num(tok04)    ; %[ deg]
               end

               [tok05,record] = strtok(record);
               if strcmp(deblank2(tok05),'*')
               DAT.data(nblock).WS10MXS3(nrow) = nan;
               else
               DAT.data(nblock).WS10MXS3(nrow) = str2num(tok05)./10; % [m/s]
               end

               [tok06,record] = strtok(record);
               if strcmp(deblank2(tok06),'*')
               DAT.data(nblock).WC10    (nrow) = nan;
               else
               DAT.data(nblock).WC10    (nrow) = str2num(tok06)./10; % [m/s]
               end

               [tok07,record] = strtok(record);
               if strcmp(deblank2(tok07),'*')
               DAT.data(nblock).WC10MXS3(nrow) = nan;
               else
               DAT.data(nblock).WC10MXS3(nrow) = str2num(tok07)./10; % [m/s]
               end

               [tok08,record] = strtok(record);
               if strcmp(deblank2(tok08),'*')
               DAT.data(nblock).WS10STD (nrow) = nan;
               else
               DAT.data(nblock).WS10STD (nrow) = str2num(tok08)./10; % [m/s]
               end

               [tok09,record] = strtok(record);
               if strcmp(deblank2(tok09),'*')
               DAT.data(nblock).WS10MX10(nrow) = nan;
               else
               DAT.data(nblock).WS10MX10(nrow) = str2num(tok09)./10; % [m/s]
               end

               [tok10,record] = strtok(record);
               if strcmp(deblank2(tok10),'*')
               DAT.data(nblock).WR10STD (nrow) = nan;
               else
               DAT.data(nblock).WR10STD (nrow) = str2num(tok10)./10; % [m/s]
               end
               
               %% Read header next block, if any
               if datenumnow == datenum1
               
                  disp('Finished reading block.')
              
                  record = fgetl(fid);
                  if ~ischar(record) % | nrow==2*24*6
                     disp('Finished reading file.')
                     break
                  else
                  
                     header{1}       = record;
                     nblock          = nblock + 1;
                  
                    [datestr01,rest] = strtok(header{1});
                    [timestr01,rest] = strtok(rest);
                    
                     datenum0 = time2datenum(datestr01,timestr01);
                    [datestr02,rest] = strtok(rest);
                    [timestr02,rest] = strtok(rest);
                     datenum1 = time2datenum(datestr02,timestr02);
                    
                     header{2} = fgetl(fid);
                     header{3} = fgetl(fid);
                     
                     disp(['Reading data        : ',datestr(datenum0,0)])
                     disp(['up to and including : ',datestr(datenum1,0),'   = block ',num2str(nblock)])
                     
                     DAT.data(nblock).datenum  = repmat(nan,[1 nt]);
                     DAT.data(nblock).WR10     = repmat(nan,[1 nt]);
                     DAT.data(nblock).WS10MXS3 = repmat(nan,[1 nt]);
                     DAT.data(nblock).WC10     = repmat(nan,[1 nt]);
                     DAT.data(nblock).WC10MXS3 = repmat(nan,[1 nt]);
                     DAT.data(nblock).WS10STD  = repmat(nan,[1 nt]);
                     DAT.data(nblock).WS10MX10 = repmat(nan,[1 nt]);
                     DAT.data(nblock).WR10STD  = repmat(nan,[1 nt]);
                     nrow                      = 0;
                  
                  end

               end
               
            end % EOF
            
            %% Merge multiple blocks into one block
            
            %% Add description
            
            DAT.legend.WS10     = '10-min. scalair gemiddelde windsnelheid in [m/s]';
            DAT.legend.WR10     = '10-min. gemiddelde windrichting in [sex.grd. tov Nrd.]';
            DAT.legend.WS10MXS3 = 'Max. 3-sec. windstoot in de afgelopen 10 min.]';
            DAT.legend.WC10     = '10-min. scalair gemiddelde windsnelheid gecorrigeerd naar 10 m boven het zeeoppervlak in [m/s]';
            DAT.legend.WC10MXS3 = 'Max. 3-sec windstoot in de afgelopen 10 minuten gecorrigeerd naar 10 m boven het zeeoppervlak in [m/s]';
            DAT.legend.WS10STD  = 'Standaardafwijking van de windsnelheid in de afgelopen 10 min. in [m/s]';
            DAT.legend.WS10MX10 = 'Max. 10 min.  lopend gemiddelde windsnelheid in de afgelopen 10 min. in [m/s]';
            DAT.legend.WR10STD  = 'Standaardafwijking van de windrichting in de afgelopen 10 min. in [m/s]';

%         try
%         catch
%         
%            if nargout==1
%               error(['Error reading file: ',DAT.filename])
%            else
%               iostat = -3;
%            end      
%         
%         end % try
      
         fclose(fid);

      end %  if fid <0

   end % if length(tmp)==0
   
   DAT.iomethod = ['© hmcz_wind_read.m  by G.J. de Boer (Deltares), g.j.deboer@DeltaRes.nl,',mfile_version]; 
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;
   
   %% Function output

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end

   %% EOF