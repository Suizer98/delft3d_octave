function varargout = knmi_potwind(varargin)
%KNMI_POTWIND   Reads ASCII wind file from KNMI website
%
%    W = knmi_potwind(filename) 
%
% reads a wind file (can be zipped) from
%     Old data: <http://www.knmi.nl/samenw/hydra>
%     New data: <http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/>
% into a struct W with the following fields:
%
%    DD      = wind direction in degrees north
%    QQD     = quality code dd
%    UP      = potential wind speed in m/s
%    QUP     = quality code up
%    DATENUM = matlab datenumber
%
% [W,iostat] = knmi_potwind(filename) 
%
% returns error status in iostat
%
% OK/cancel/file not found/
%
% W = knmi_potwind(filename,<keyword,value>) 
%
% where the following optional <keyword,value> pairs are implemented:
% (see: http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
% * calms    : value of direction when wind speed is approx. 0          (default NaN);
% * variables: value of direction when wind direction is higly variable (default NaN);
%
% * pol2cart:  adds also u and v wind components to speed UP and direction DD
%
% See also: wind_plot, CART2POL, POL2CART, DEGN2DEGUC, DEGUC2DEGN, HMCZ_WIND_READ
%           KNMI_ETMGEG, KNMI_POTWIND_MULTI

% uses time2datenum (OET)
%      deg2rad      (matlab and OET)

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
%   -------------------------------------------------------------------

      %
      % >   N-360  >
      %    /     \
      % W-270     E-90
      %    \     /
      % <   S-180  <
      %      

% 1 'POTENTIAL WIND STATION  xxx    xxxxxxxxxxxxxxxxxx',                    
% 2 'MOST RECENT COORDINATES  X :     xxxxxx; Y :     xxxxxx',              
% 3 'MEASURED AT xxxxxx METER HEIGHT',                                      
% 4
% 5 'POTENTIAL WIND MEANS: CORRECTED TO THE WIND SPEED AT 10 M HEIGHT OVER',
% 6 'OPEN xxxxx WITH ROUGHNESS LENGTH  xxxx METER',                         
% 7 '',
% 8 'CONSULT THE REPORTS AT THE SITE: http://www.knmi.nl/samenw/hydra',
% 9 'FOR BACKGROUND INFORMATION',
%10 'THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED:',
%11 'ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE',
%12 'KONINKLIJK NEDERLANDS METEOROLOGISCH INSTITUUT',
%13 '',
%14 'VERSION JANUARY 2003',
%15 '',
%16 'TIME IN GMT',
%17 'DD  = WIND DIRECTION IN DEGREES NORTH',
%18 'QQD = QUALITY CODE DD',
%19 'UP  = POTENTIAL WIND SPEED IN M/S',
%20 'QUP = QUALITY CODE UP'
%21 ''
%22 '  DATE,TIME, DD,QDD, UP,QUP'};  % edited UP comment to 1 m/s

%% 0 - command line file name or 
%      Launch file open GUI

%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'potwind*.*' ,'KNMI wind time-series file (potwind*.*)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'KNMI wind time-series file (potwind*.*)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         W.file.name    = [];
         iostat         = 0;
      else
         W.file.name    = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(W.file.name)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

%% No file name specified if odd number of arguments
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      W.file.name  = varargin{1};
      iostat       = 1;
   end
   
%% Keywords

      H.calms     = nan;
      H.variables = Inf;
      H.pol2cart  = 0;

      H = setproperty(H,varargin{2:end});
   
%% I - Check if file exists (actually redundant after file GUI)

   tmp = dir(W.file.name);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',W.file.name])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
%% Unzip optionnally (and delete aftwewards)

      deletezip = '';
      if strcmpi(W.file.name(end-3:end),'.zip')
         disp([mfilename,': unzipping to temp dir'])
         fname       = fullfile(tempdir,filename(W.file.name(1:end-4)));
         unzip(W.file.name,tempdir);
         deletezip   = fname;
      else
         fname = W.file.name;
      end

      W.file.date     = tmp.date;
      W.file.bytes    = tmp.bytes;

%% Read header

         fid             = fopen(fname);
         W.comments{1}   = fgetl(fid);
         if isempty(strfind(W.comments{1},'POTENTIAL WIND'))
            error(['incorrect file type: 1st line does not start with ''POTENTIAL WIND'' but with ''',W.comments{1},''''])
         end

         for iline = 2:22
            W.comments{iline} = fgetl(fid);
         end
         fclose(fid);
         
%% Extract meta-info from header
      
         % POTENTIAL WIND STATION  242    Vlieland          
         % MOST RECENT COORDINATES  X :     123800; Y :     583850
         
         % POTENTIAL WIND STATION  235    De Kooy           
         % MOST RECENT COORDINATES  X :     114254; Y :     549042

         % Regular expression to allow for stationnumbers with =~3 digits
%          W.stationnumber = strtrim (W.comments{1}(24:28));
%          W.stationname   = strtrim (W.comments{1}(29:end));
         W.stationnumber = W.comments{1}(regexp(W.comments{1},'\<[0-9]'):regexp(W.comments{1},'[0-9]\o{40}'));
         W.stationname   = W.comments{1}((regexp(W.comments{1},'[0-9]\o{40}')+2):end);
         
         semicolon       = strfind (W.comments{2},':');
         delimiter       = strfind (W.comments{2},';');
         W.xpar          = str2num (W.comments{2}(semicolon(1)+1:delimiter-1));%str2num(strtrim(line2(30:40)));
         W.ypar          = str2num (W.comments{2}(semicolon(2)+1:end        ));%str2num(strtrim(line2(48:end)));
        [W.lon,W.lat]    = convertCoordinates(W.xpar,W.ypar,'CS1.code',28992,'CS2.code',4326); % RD to [lat,lon] WGS84
         
         char1           = strfind (W.comments{ 3},'MEASURED AT')+11;
         char2           = strfind (W.comments{ 3},'METER');
         W.height        =         (W.comments{3}(char1+1:char2-2)); % char!: contains comment "Begroeing in 1999 in NW en N (310-010) te hoog geworden" for station 235.
         
         W.over          =          W.comments{ 6}(7:11);
         char1           = strfind (W.comments{ 6},'LENGTH')+6;
         char2           = strfind (W.comments{ 6},'METER');
         W.roughness     = str2num (W.comments{ 6}(char1+1:char2-2));
         
         W.version       = strtrim (W.comments{14}(10:end));
         
         W.timezone      = strtrim (W.comments{16}(9:end));
      
%% Read legend

         W.DD_longname      = 'WIND DIRECTION IN DEGREES NORTH';
         W.QQD_longname     = 'QUALITY CODE DD';
         W.UP_longname      = 'POTENTIAL WIND SPEED IN M/S'; % edited UP comment from 0.1 m/s to 1 m/s
         W.QUP_longname     = 'QUALITY CODE UP';
         W.datenum_longname = 'days since 00:00 Jan 0 0000';
         if H.pol2cart
            W.UX_longname   = 'POTENTIAL WIND SPEED IN M/S WIND IN X-DIRECTION';
            W.UY_longname   = 'POTENTIAL WIND SPEED IN M/S WIND IN Y-DIRECTION';
         end
         
%% Read data

         [itdate,hour,W.DD,W.QQD,W.UP,W.QUP] = textread(fname,'%n%n%n%n%n%n',...
           'delimiter'  ,',',...
           'emptyvalue' ,NaN,...
           'headerlines',22);
         
         W.UP            = W.UP/10; % to [m/s]
         W.datenum       = time2datenum(itdate) + hour./24; % make matlab days
         
%% Add u,v

         if H.pol2cart
           [W.UX,...
            W.UY] = pol2cart(deg2rad(degN2deguc(W.DD)),...
                                                W.UP);
         end
         
         
         W.UP_units      = 'm/s';
         W.QQD_units     = 'm/s';
         W.DD_units      = '[-1,0,2,3,6,7,100,990]';
         W.QUP_units     = '[-1,0,2,3,6,7,100,990]';      
         W.datenum_units = 'day';

         if H.pol2cart
            W.UX_units = 'm/s';
            W.UY_units = 'm/s';
         end         

%% Apply masks
      
         W.UP(W.UP<0)=nan; % -0.1 occurs in station 277 year 1971
      
         W.DD(W.QQD>0)=nan;
         W.DD(W.DD==0)=nan;
         
         % http://wwW.knmi.nl/samenw/hydra/meta_data/quality.htm
         % Quality codes  	
         % 
         % 
         % -1		 no data	
         % 0		 valid data	
         % 2		 data taken from WIKLI-archives	
         % 3		 wind direction in degrees computed from points of the compass	
         % 6		 added data	
         % 7		 missing data	
         % 100		 suspected data         
         
         W.DD(W.DD==0  ) = H.calms    ; % stil, calm winds, windspeed ~ 0, see below
         W.DD(W.DD==990) = H.variables; % veranderlijk, standard deviation direction > 30 deg, see below
         
         % http://wwW.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
         % Wind direction codes  	
         %
         % Wind direction is reported in units of 10 degrees, starting from 10 to 360. The wind direction is always an average over the last 10-min preceding the full hour. There are two special codes: 0 and 990.
         % Code 0 applies to calms. You may find records, however, with non-zero wind speed and direction 0 for the following reason. The wind speed at our web site is computed from the hourly averaged wind speed (FH). The wind direction, however, is averaged only over the last ten minutes preceding the full hour. If the wind speed in that period (FF) is zero, then the wind direction will be zero as well. The hourly averaged wind, however, is not necessarily zero.
         % Code 990 applies to variable wind direction. This means that the standard deviation is larger than 30 degrees.         
         
   end % if length(tmp)==0
   
   W.read.with     = '$Id: knmi_potwind.m 12504 2016-02-12 16:48:07Z cclaessens.x $'; % SVN keyword, will insert name of this function
   W.read.at       = datestr(now);
   W.read.iostatus = iostat;
   
%% Delete zipped file

   if ~isempty(deletezip)
      delete(deletezip)
   end
   
%% Function output

   if nargout    < 2
      varargout= {W};
   elseif nargout==2
      varargout= {W, iostat};
   end

%% EOF