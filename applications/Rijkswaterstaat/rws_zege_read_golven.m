function DAT = rws_zege_read_golven(varargin)
%RWS_ZEGE_READ_GOLVEN  Reads ZEGE .dat files and makes a struct
%
%   Header-less .dat file converted to .mat with correct structure.
%   A few tricks needed to make raw .dat files ready. 
%   1. Remove 1st and 3rd header line leaving only the name of the station
%   2. Add two blank lines at the end - will try to fix this later
%   See www.hmcz.nl for more details and also further metainformation
%
%   Syntax:
%   DAT = rws_zege_read_golven(varargin)
%
%   Input: For <keyword,value> pairs call rws_zege_read_golven() without arguments.
%   varargin = .dat file from www.hmcz.nl
%
%   Output:
%   DAT      =
%
%   Example
%   rws_zege_read_golven
%
%   See also rws_zege_golven2nc 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       cronin
%
%       <katherine.cronin@deltares.nl>
%
%       <Deltares, Rotterdamseweg, 185, Delft>
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
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Apr 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: rws_zege_read_golven.m 8472 2013-04-18 15:53:01Z cronin $
% $Date: 2013-04-18 23:53:01 +0800 (Thu, 18 Apr 2013) $
% $Author: cronin $
% $Revision: 8472 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_zege_read_golven.m $

%% file description
%% adapted from rws_zege_read to read wave downloads

OPT.headerlines = 1;
OPT.nodatavalue = '*';
OPT.colnames    = {'Date',... %1. 
                   'Time',... %2.
                  'H3'  ,... %3.
                   'H10',...   %4.
		           'H50' ,...  %5.
		           'GGH' ,...  %6.
		           'HMAX',...  %7.
                  'SPGH',...  %8.
                  'TM02',...  %9.
                  'TMAX',...  %10.
                  'GGT',...  %11.
                  'SPGT',...  %12.
                  'T3',...   %13.
                  'TH3',...  %14.
                  'AG',...   %15.
                  'AV',...   %16.
                  'HCM',...  %17.
                  'HS7',...  %18.
                  'Hm0',...  %19.
                  'TE1',...  %20.
                  'TE2',...  %21.
                  'E10',...  %22.
                  'FP',...  %23.
                  'THMAX',... %24.
                  'Nwt_zP',... %25.
                  'Tm_10',... %26.
                  'TE0',...  %27.
                  'Dummy1',... %28.
                  'Dummy2'};  %29.
OPT.colfactor   = [1,... %1.
                   1,... %2.
                   1,... %3.
                   1,... %4.
                   1,... %5.
                   1,... %6.
                   1,... %7.
                   1,... %8.
                   10,... %9. Period of 0.1s converted to 1s
                   10,... %10. Period of 0.1s converted to 1s
                   10,... %11. Period of 0.1s converted to 1s
                   10,... %12. Period of 0.1s converted to 1s
                   10,... %13. Period of 0.1s converted to 1s
                   10,... %14. Period of 0.1s converted to 1s
                    1,... %15.
                    1,... %16.
                    1,... %17.
                    1,... %18.
                    1,... %19.
                    1,... %20.
                    1,... %21.
                    1,... %22.
                    1,... %23.
                    1,... %24. Period of 0.1s converted to 1s
                    1,... %25.
                    1,... %26. Period of 0.1s converted to 1s
                    1,... %27.
                    1,... %28.
                    1]; %29.  
		 
OPT.collegend   = {'Date',... %1.
		   'Time',...     %2.
		   'Average height of the 1/3 highest waves/Gemiddelde hoogte van het 1/3 deel hoogste golven (cm)',...   %3. 
		   'Average height of the 1/10 highest waves/Gemiddelde hoogte van het 1/10 deel hoogste golven (cm)',... %4.
		   'Average height of the 1/50 highest waves/Gemiddelde hoogte van het 1/50 deel hoogste golven (cm)',... %5.
           'Average wave height/Gemiddelde golfhoogte in cm',... %6.
           'Maximum wave height/Maximale golfhoogte (cm)',...    %7.
           'Spreiding van de golfhoogte (cm) - definition unclear',... %8.
           'Period calculated from the spectrum 0.03-1 Hz in 0.1s/Periodeparameter berekend uit het spectrum 0.03-1 Hz',... %9.
           'Maximum wave period in s/Maximale golfperiode',... % 10. units adjusted from 0.1s
           'Averaged wave period in s/Gemiddelde golfperiode'... % 11. units adjusted from 0.1s
           'Spreiding van de golfperiode in s',... % 12. units adjusted from 0.1s
           'Average of the highest 1/3 wave periods in s/Gemiddelde van het hoogste 1/3 deel van de golfperioden',... % 13. units adjusted from 0.1s
           'Average period from which the H3 waves are determined (s)/Gemiddelde periode van de golven waaruit de H3 bepaald is in',... %14. units adjusted from 0.1s
           'Number of waves/Aantal golven',... %15.
           'Degrees of freedom/Aantal vrijheidsgraden',... %16.
           'Crest height in cm/Kamhoogte',... %17.
           'Sign. golfhoogte uit 10 mHz spectrum van 0.03-0.1425 Hz in cm',... %18.
           'Sign. golfhoogte uit 10 mHz spectrum van 0.03-1.0000 Hz in cm',... %19.
           'Energy from 0.2-1 Hz in cm2/Energie van 0.2-1 Hz',... %20.
           'Energy from 0.1-02 Hz in cm2/Energie van 0.1-0.2 Hz',... %21.
           'Energy from 0.0-0.1 Hz in cm2/Energie van 0.0-0.1 Hz',... %22.
           'Peak Frequency in 0.001 Hz/Piekfrequentie',... %23.
           'Period of the highest waves in s/Periode van de hoogste golf in',... %24. units adjusted from 0.1s
           'Quotient som golfperiodes en verwerkingsperiod (*1000)',... %25.
           'Min-eerste moment periode (M-1/M0) in s',... %26. units adjusted from 0.1s
           'Energy from 0.5-1.0 Hz in cm2/Energie van 0.5-1.0 Hz',... %27.
           'Dummy',... %28.
           'Dummy'};  %29.

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
            for icol= 1:length(OPT.colnames)
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
            
            if mod(nrow,100)==0
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
               
               for icol=3:length(OPT.colnames)
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
   
   DAT.read.method = ['$Id: rws_zege_read_golven.m 8472 2013-04-18 15:53:01Z cronin $']; 
   DAT.read.at     = datestr(now);
   DAT.read.status = iostat;
   
   %% Function output

   if nargout    < 2
      varargout= {DAT};
   elseif nargout==2
      varargout= {DAT, iostat};
   end

   %% EOF