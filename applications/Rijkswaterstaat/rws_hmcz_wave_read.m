function DAT = rws_hmcz_wave_read(varargin)
%RWS_HMCZ_WIND_READ   Reads ASCII wind file from www.hmcz.nl
%
%      D = rws_hmcz_wave_read('fname')
%
%   eeads ASCII wind data file from www.hmcz.nl of type 
%   GHr2 (see 2nd line) that looks like:
%
%   ----------------------------------------------------------
%   20050101 0000 20050131 2330 30
%   OS4   GHr2
%               1            2            3            4            5            6            7            8 
%   01-jan-2007 00:00          132          224          190          125          179           18          132            8 
%   ...
%   31-jan-2007 23:50           55          268           65           52           61            4           57            3 
%   ----------------------------------------------------------
%
%   HMCZ_WAVE_READ returns a struct D containing the data from the 
%   file 'fname' which includes the following fields:
%
%     1 H3 Gemiddelde hoogte van het 1/3 deel hoogste golven in [cm]
%     2 H10 Gemiddelde hoogte van het 1/10 deel hoogste golven in [cm]
%     3 H50 Gemiddelde hoogte van het 1/50 deel hoogste golven in [cm]
%     4 GGH Gemiddelde golfhoogte in [cm]
%     5 HMAX Maximale golfhoogte in [cm]
%     6 SPGH Spreiding van de golfhoogte in [cm]
%     7 TM02 Periodeparameter berekend uit het spectum 0.03-1.0 Hz in [0.1 s]
%     8 TMAX Maximale golfperiode in [0.1 s]
%     9 GGT Gemiddelde golfperiode in [0.1 s]
%     10 SPGT Spreiding van de golfperiode in [0.1 s]
%     11 T3 Gemiddelde van het hoogste 1/3 deel van de golfperioden in [0.1 s]
%     12 TH3 Gemiddelde periode van de golven waaruit de H3 bepaald is in [0.1 s]
%     13 AG Aantal golven
%     14 AV Aantal vrijheidsgraden
%     15 HCM Kamhoogte in [cm]
%     16 HS7 Sign. golfhoogte uit 10 mHz spectrum van 0.03-0.1425 Hz in [cm]
%     17 Hm0 Sign. golfhoogte uit 10 mHz spectrum van 0.03-1.000 Hz in [cm ]
%     18 TE1 Energie van 0.2 - 1.0 Hz in [cm2]
%     19 TE2 Energie van 0.1 - 0.2 Hz in [cm2]
%     20 E10 Energie van 0.0 - 0.1 Hz in [cm2]
%     21 FP Piekfrequentie in [0.001 Hz]
%     22 THMAX Periode van de hoogste golf in [0.1 s]
%     23 Nwt_zP Quotient som golfperiodes en verwerkingsperiode (*1000)
%     24 Tm-10 Min-eerste moment periode (M-1/M0) in [0.1 s]
%     25 TE0 Energie van 0.5 - 1.0 Hz in [cm2]
%     26 Dummy
%     27 Dummy
%     28 Czz10(0) Energiedichtheid 0.000-0.005 Hz in [10 cm2 * s]
%     29 Czz10(1) Energiedichtheid 0.005-0.015 Hz in [10 cm2 * s]
%     30 Czz10(2) Energiedichtheid 0.015-0.025 Hz in [10 cm2 * s]
%     .
%     .
%     127 Czz10(99) Energiedichtheid 0.985-0.995 Hz in [10 cm2 * s]
%     128 Czz10(100) Energiedichtheid 0.995-1.000 Hz in [10 cm2 * s]
%    
%   To keep the struct from becoming too big, rws_hmcz_wave_read only reads
%   the first 25 fields.
% 
% 
%
%   * The different blocks in the file are loaded as separate blocks.
%   * Lines with a * are treated as NaNs.
%
%
% See also: rws_hmcz_wind_read('fname')

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
        {'*.src' ,'HMCZ wave file (*.data)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'HMCZ wave file (*.data)');
      
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
            DAT.data(nblock).H3     = repmat(nan,[1 nt]);
            
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
               if tok01(4:6)=='mrt'
                   tok01(4:6)='mar';
               end
               if tok01(4:6)=='mei'
                   tok01(4:6)='may';
               end
               if tok01(4:6)=='okt'
                   tok01(4:6)='oct';
               end
               [tok02,record] = strtok(record);
               hr             = str2num(tok02(1:2));
               mn             = str2num(tok02(4:5));
               datenumnow     = datenum(tok01     ) + (hr + mn./60)./24;
               
               DAT.data(nblock).datenum (nrow) = datenumnow;
               [tok03,record] = strtok(record);
               
               %% I found cases where only one column is *, and the others are not, so we have to check each number separately
               
               if strcmp(deblank2(tok03),'*')
               DAT.data(nblock).H3    (nrow) = nan;
               else
               DAT.data(nblock).H3    (nrow) = str2num(tok03); 
               end
               
               [tok04,record] = strtok(record);
               if strcmp(deblank2(tok04),'*')
               DAT.data(nblock).H10    (nrow) = nan;
               else
               DAT.data(nblock).H10    (nrow) = str2num(tok04)    ; 
               end

               [tok05,record] = strtok(record);
               if strcmp(deblank2(tok05),'*')
               DAT.data(nblock).H50(nrow) = nan;
               else
               DAT.data(nblock).H50(nrow) = str2num(tok05); 
               end

               [tok06,record] = strtok(record);
               if strcmp(deblank2(tok06),'*')
               DAT.data(nblock).GGH    (nrow) = nan;
               else
               DAT.data(nblock).GGH    (nrow) = str2num(tok06); 
               end

               [tok07,record] = strtok(record);
               if strcmp(deblank2(tok07),'*')
               DAT.data(nblock).HMAX(nrow) = nan;
               else
               DAT.data(nblock).HMAX(nrow) = str2num(tok07); 
               end

               [tok08,record] = strtok(record);
               if strcmp(deblank2(tok08),'*')
               DAT.data(nblock).SPGH (nrow) = nan;
               else
               DAT.data(nblock).SPGH (nrow) = str2num(tok08); 
               end

               [tok09,record] = strtok(record);
               if strcmp(deblank2(tok09),'*')
               DAT.data(nblock).TM02(nrow) = nan;
               else
               DAT.data(nblock).TM02(nrow) = str2num(tok09); 
               end

               [tok10,record] = strtok(record);
               if strcmp(deblank2(tok10),'*')
               DAT.data(nblock).TMAX (nrow) = nan;
               else
               DAT.data(nblock).TMAX (nrow) = str2num(tok10); 
               end
               
               [tok11,record] = strtok(record);
               if strcmp(deblank2(tok11),'*')
               DAT.data(nblock).GGT (nrow) = nan;
               else
               DAT.data(nblock).GGT (nrow) = str2num(tok11); 
               end
               
               [tok12,record] = strtok(record);
               if strcmp(deblank2(tok12),'*')
               DAT.data(nblock).SPGT (nrow) = nan;
               else
               DAT.data(nblock).SPGT (nrow) = str2num(tok12); 
               end
               
               [tok13,record] = strtok(record);
               if strcmp(deblank2(tok13),'*')
               DAT.data(nblock).T3 (nrow) = nan;
               else
               DAT.data(nblock).T3 (nrow) = str2num(tok13); 
               end
               
               [tok14,record] = strtok(record);
               if strcmp(deblank2(tok14),'*')
               DAT.data(nblock).TH3 (nrow) = nan;
               else
               DAT.data(nblock).TH3 (nrow) = str2num(tok14); 
               end
               
               [tok15,record] = strtok(record);
               if strcmp(deblank2(tok15),'*')
               DAT.data(nblock).AG (nrow) = nan;
               else
               DAT.data(nblock).AG (nrow) = str2num(tok15); 
               end
               
               [tok16,record] = strtok(record);
               if strcmp(deblank2(tok16),'*')
               DAT.data(nblock).AV (nrow) = nan;
               else
               DAT.data(nblock).AV (nrow) = str2num(tok16); 
               end
               
               [tok17,record] = strtok(record);
               if strcmp(deblank2(tok17),'*')
               DAT.data(nblock).HCM (nrow) = nan;
               else
               DAT.data(nblock).HCM (nrow) = str2num(tok17); 
               end
               
               [tok18,record] = strtok(record);
               if strcmp(deblank2(tok18),'*')
               DAT.data(nblock).HS7 (nrow) = nan;
               else
               DAT.data(nblock).HS7 (nrow) = str2num(tok18); 
               end
               
               [tok19,record] = strtok(record);
               if strcmp(deblank2(tok19),'*')
               DAT.data(nblock).Hm0 (nrow) = nan;
               else
               DAT.data(nblock).Hm0 (nrow) = str2num(tok19); 
               end
               
               [tok20,record] = strtok(record);
               if strcmp(deblank2(tok20),'*')
               DAT.data(nblock).TE1 (nrow) = nan;
               else
               DAT.data(nblock).TE1 (nrow) = str2num(tok20); 
               end
               
               
               [tok21,record] = strtok(record);
               if strcmp(deblank2(tok21),'*')
               DAT.data(nblock).TE2 (nrow) = nan;
               else
               DAT.data(nblock).TE2 (nrow) = str2num(tok21); 
               end
               
               [tok22,record] = strtok(record);
               if strcmp(deblank2(tok22),'*')
               DAT.data(nblock).E10 (nrow) = nan;
               else
               DAT.data(nblock).E10 (nrow) = str2num(tok22); 
               end
               
               [tok23,record] = strtok(record);
               if strcmp(deblank2(tok23),'*')
               DAT.data(nblock).FP (nrow) = nan;
               else
               DAT.data(nblock).FP (nrow) = str2num(tok23); 
               end
               
               [tok24,record] = strtok(record);
               if strcmp(deblank2(tok24),'*')
               DAT.data(nblock).THMAX (nrow) = nan;
               else
               DAT.data(nblock).THMAX (nrow) = str2num(tok24); 
               end
               
               [tok25,record] = strtok(record);
               if strcmp(deblank2(tok25),'*')
               DAT.data(nblock).Nwt_zP (nrow) = nan;
               else
               DAT.data(nblock).Nwt_zP (nrow) = str2num(tok25); 
               end
               
               [tok26,record] = strtok(record);
               if strcmp(deblank2(tok26),'*')
               DAT.data(nblock).Tm10 (nrow) = nan;
               else
               DAT.data(nblock).Tm10 (nrow) = str2num(tok26); 
               end
               
               [tok27,record] = strtok(record);
               if strcmp(deblank2(tok27),'*')
               DAT.data(nblock).TE0 (nrow) = nan;
               else
               DAT.data(nblock).TE0 (nrow) = str2num(tok27); 
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
                     nt = round((datenum1 - datenum0)*24*60/dtmn +1);
                    
                     header{2} = fgetl(fid);
                     header{3} = fgetl(fid);
                     
                     disp(['Reading data        : ',datestr(datenum0,0)])
                     disp(['up to and including : ',datestr(datenum1,0),'   = block ',num2str(nblock)])
                     
                     DAT.data(nblock).datenum  = repmat(nan,[1 nt]);
                     DAT.data(nblock).H3     = repmat(nan,[1 nt]);
                     
                     nrow                      = 0;
                  
                  end

               end
               
            end % EOF
            
            %% Merge multiple blocks into one block
            
            %% Add description
            
         
 DAT.legend.H3 = 'Gemiddelde hoogte van het 1/3 deel hoogste golven in [cm]';
 DAT.legend.H10 = 'Gemiddelde hoogte van het 1/10 deel hoogste golven in [cm]';
 DAT.legend.H50 = 'Gemiddelde hoogte van het 1/50 deel hoogste golven in [cm]';
 DAT.legend.GGH = 'Gemiddelde golfhoogte in [cm]';
 DAT.legend.HMAX = 'Maximale golfhoogte in [cm]';
 DAT.legend.SPGH = 'Spreiding van de golfhoogte in [cm]';
 DAT.legend.TM02 = 'Periodeparameter berekend uit het spectum 0.03-1.0 Hz in [0.1 s]';
 DAT.legend.TMAX = 'Maximale golfperiode in [0.1 s]';
 DAT.legend.GGT = 'Gemiddelde golfperiode in [0.1 s]';
 DAT.legend.SPGT = 'Spreiding van de golfperiode in [0.1 s]';
 DAT.legend.T3 = 'Gemiddelde van het hoogste 1/3 deel van de golfperioden in [0.1 s]';
 DAT.legend.TH3 = 'Gemiddelde periode van de golven waaruit de H3 bepaald is in [0.1 s]';
 DAT.legend.AG = 'Aantal golven';
 DAT.legend.AV = 'Aantal vrijheidsgraden';
 DAT.legend.HCM = 'Kamhoogte in [cm]';
 DAT.legend.HS7 = 'Sign. golfhoogte uit 10 mHz spectrum van 0.03-0.1425 Hz in [cm]';
 DAT.legend.Hm0 = 'Sign. golfhoogte uit 10 mHz spectrum van 0.03-1.000 Hz in [cm ]';
 DAT.legend.TE1 = 'Energie van 0.2 - 1.0 Hz in [cm2]';
 DAT.legend.TE2 = 'Energie van 0.1 - 0.2 Hz in [cm2]';
 DAT.legend.E10 = 'Energie van 0.0 - 0.1 Hz in [cm2]';
 DAT.legend.FP = 'Piekfrequentie in [0.001 Hz]';
 DAT.legend.THMAX = 'Periode van de hoogste golf in [0.1 s]';
 DAT.legend.Nwt_zP = 'Quotient som golfperiodes en verwerkingsperiode (*1000)';
 DAT.legend.Tm10 = 'Min-eerste moment periode (M-1/M0) in [0.1 s]';
 DAT.legend.TE0 = 'Energie van 0.5 - 1.0 Hz in [cm2]';
            
            

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
   
   DAT.iomethod = ['© hmcz_wave_read.m  ',mfile_version]; 
   DAT.read_at  = datestr(now);
   DAT.iostatus = iostat;
   
   %% Function output

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end

   %% EOF