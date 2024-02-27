function [varargout] = readnoaapc(varargin);
%KNMI_NOAAPC_READ  Function for reading NOAAPC files into data struct.
%
%   IMAGE = READNOAAPC('filename')
%   reads the satellite data file 'filename' according to 
%   the KNMI-format 'NOAAPC' in a structure. The structure IMAGE
%   contains all data (either binary or geophysical), latitide/
%   longitude co-ordinate fields and metadata from the NOAAPC file.
%   For NOAAPC details contact KNMI <Hans.Roozekrans@knmi.nl>.
%
%   IMAGE = READNOAAPC gives an interactive display for selection
%   of a NOAAPC file.
%
%   [IMAGE, iostat] = READNOAAPC('filename') also returns
%   a status integer indicating if something went wrong. 
%   iostat =1 when sucessfull, 0 when cancelled (only for input GUI),
%   -1 when an error occurred. READNOAAPC stops with error when
%   iostat is not requested among the output arguments
%   and an error does occur.
%
%   Two types of data can be read from the NOAAPC file:
%   1: integer (unit8) data as they are present in the NOAAPC file
%   2: geophysical data (temperature) obtained by
%      (a) Applying gain and offset
%      (b) Transformation to doubles
%      (c) Flipping of the array upside-down
%
%  The KNMI set contains data from the POES satellites 10 to 18: 
%      http://www.met.fsu.edu/explores/Guide/Noaa_Html/noaa15.html
%      http://www.oso.noaa.gov/poesstatus/
%      http://www.osdpd.noaa.gov/PSB/PPP/CALIB/home.html
%      Roozekrans & Prangsma (1992), page 10
%
%      Pre-launch code
%             Operational code
%                  Luanch data
%                                Start operational period
%                                             End operational period
%                                                            Decomissioned
%                                                                         Orbit
%      TIROS N  N  [            - Oct 19 1978 - Jan 30 1980 -            ] night/afternoon
%      NOAA  A  6  [            - Jun 27 1979 - Nov 16 1987 -            ] morning/afternoon
%      NOAA  B     [Failed launch                                        ]
%      NOAA  C  7  [            - Aug 19 1981 - Jun 07 1986 -            ] night/afternoon
%      NOAA  E  8  [            - Jun 20 1983 - Oct 31 1986 -            ] morning/afternoon
%      NOAA  F  9  [            - Feb 25 1985 - Nov 07 1988 -            ] night/afternoon
%  *   NOAA  G 10  [Sep 17 1986 - Nov 17 1986 -             - Sep 17 1991] morning/afternoon
%  *   NOAA  H 11  [Sep 24 1988 - Nov 08 1988 -             - Jun 16 2004] night/afternoon
%  *   NOAA  D 12  [May 14 1991 - Sep 01 1991 -             - Aug 10 2007] morning/afternoon
%  *   NOAA  I 13  [Aug 09 1993 - failure **                             ] 
%  *   NOAA  J 14  [Dec 30 1994 -                           - May 23 2007] 
%  *   NOAA  K 15  [May 13 1998 -             - operational              ] AM Secondary  
%  *   NOAA  L 16  [Sep 20 2000 -             - operational              ] PM Secondary  
%  *   NOAA  M 17  [Jun 24 2002 -             - operational              ] AM Backup     
%  *   NOAA  M 18  [May 20 2005 -             - operational              ] PM Primary    
% P.S. METOP-A/02  [Oct 19 2006 -             - operational              ] AM Primary    
%
% * these satellites are in the KNMI-NOAAPC series
%
% ** was placed in a near circular, polar orbit. The spacecraft and its systems 
% operated successfully for 12 days until a circuit failure resulted in a power 
% loss aboard the craft. At this time the spacecraft is still in its polar orbit; 
% however, no data is being received.
%
%   The options regarding the data type to be read are given below:
%
%   Note 1: The NOAAPC file format is not millennium proof.
%   Note 2: KNMI discontinued its NOAA service end 2005. 
%
%   There are a number of default 1x1 km2 mapping regions.
%   Two are the most common with bounding boxes:
%
%    Entire North Sea
%            lon     -3      12.718    9.4174   -2.2056      -3     deg E
%            lat     60      59.321   49.483    49.958       60     deg N 
%            with 1101x849 pixels
%
%    Southern Entire North Sea, note that the 0.01 is not an exclusive indicator, the rest of lon is
%            lon     -0.01    8.1739   7.2137   -0.0088119   -0.01  deg E
%            lat     55.3    54.966   50.669    50.957       55.3   deg N
%            with 481x513 which are exactly pixel indices 
%            111:590 and 160:671 from the mapping above
%
%   IMAGE = READNOAAPC('filename','optionname', optionval,...) or
%   IMAGE = READNOAAPC('optionname', optionval,...)
%   supported options are:
%
% * 'data'     when set to 1, the geophysical data array will be read
%              into doubles, with the origin in the lower left corner, so
%              it can readily be used for functions 'pcolor', 'surf', etc.
%              (default 1)
% * 'count'    when set to 1, the unsigned integer (uint8) data array
%              will be read into uint8 array, with the origin in the 
%              upper left corner (!), so it can readily be used usable
%              for function 'image'.
%              (default 0)
% * 'index'    when set to 1, the x and y indices of all pixels are
%              returned (as generated by meshgrid). (default 0)
% * 'cloudmask'when this option is set to a value
%              all cloud values are given this value. 
%              Useful values can be 0, 1, -999, NaN, Inf, -Inf
%              Cloudmask is set to NaN by default in the geophysical 
%              array, while set to 0 in the count array 
%              (like in KNMI NOAAPC file).
% * 'landmask' when this option is set to a value
%              all cloud values are given this value.
%              Useful values can be 0, 1, -999, nan, Inf, -Inf
%              Landmask is set to -Inf by default in the geophysical 
%              array, while set to 1 in the count array
%              (like in KNMI NOAAPC file).
% * 'xshift'   uniform geocorrection in [m]
% * 'yshift'   uniform geocorrection in [m]
%
% * 'center'   return coordinates of center points (defualt no)
% * 'corner'   return coordinates of corner points (defualt yes)
%
%See web: <a href="www.knmi.nl">www.knmi.nl</a>, <a href="http://www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html">www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html</a>
%See also: IMAGE, PCOLOR, SURF, 

% READNOAAPC requires the following functions:
% |
% +- ODD
% |
% +- YEARDAY
% |
% +- XY_POLARULC2LONLAT

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2007 Delft University of Technology
%
%       Gerben J. de Boer
%       g.j.deboer@tudelft.nl	
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_noaapc_read.m 8304 2013-03-08 17:03:36Z boer_g $
% $Date: 2013-03-09 01:03:36 +0800 (Sat, 09 Mar 2013) $
% $Author: boer_g $
% $Revision: 8304 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_noaapc_read.m $
% $Keywords: $

%% File name input
   
   OPT.iostat            = 0;
   OPT.debugswitch       = 0;
   OPT.keepxypolar       = 0;
   OPT.centercoordinates = 0;
   OPT.cornercoordinates = 1;
   OPT.dummyheaderlines  = 1;
   
%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

   if mod(nargin,2)     == 0 
     [filename, pathname, filterindex] = uigetfile( ...
        {'*.sst;*.ref', 'sst & reflection (*.sst;*.ref)'; ...
         '*.sst'      , 'sea surface temperature ch. 6  (*.sst)'; ...
         '*.ref'      , 'sea surface reflection  ch. 7  (*.ref)'; ...
         '*.*'        , 'All Files                      (*.*)'}, ...
         'NOAAPC file');
          % '*.ref', 'sea surface reflection ch. 7 (*.ref)'; ...
          % '*.ndvi','norm. diff. vegetation index ch. 7 (*.ndvi)'; ...
          % '*.lst' ,'land surface temp ch. 8 (*.lst)'; ...
          % '*.tsm' ,'total suspended matter ch. 9 (*.tsm)'; ...
          % '*.chl' ,'Chrorofyll ch. 12 (*.chl)'; ...
      
      if ~ischar(filename) % uigetfile cancelled
         IMAGE.filename = [];
         OPT.iostat         = 0;
      else
         IMAGE.filename = [pathname, filename];
         OPT.iostat         = 1;
      end

%% No file name specified if odd number of arguments

   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      IMAGE.filename = varargin{1};
      OPT.iostat         = 1;
   end
   
%% Open file
      
   if OPT.iostat==1 %  0 when uigetfile was cancelled
                % -1 when uigetfile failed
      
      [IMAGE.path IMAGE.name IMAGE.ext] = fileparts(IMAGE.filename);
      
      fid = fopen(IMAGE.filename,'r');
      if fid==-1            
         OPT.iostat=-1;
      end

      IMAGE.satellite        = 'NOAA';
      IMAGE.instrument       = 'AVHRR';
      IMAGE.url              =['http://www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html';
                               'http://www.knmi.nl/onderzk/applied/sd/en/sd_NOAA_AVHRR_KNMI.html';
                               'http://www.oso.noaa.gov/poes/                                   ';
                               'http://www.osi-saf.org/                                         '];
      IMAGE.literature       = 'Roozekrans, J.N. and Prangsma, G.J, march 1992. Observatie van het aard-atmosfeersysteem door de NOAA-satellieten (ontvangst, productie, toepassing en gebruik van de NOAA-data). BCSR report,92-02. ISBN 90 5411 034 1 (Dutch)';
      
   end
   
   if OPT.iostat %  0 when uigetfile was cancelled
                 % -1 when uigetfile/fopen failed
   try
      
      %% Cloud and land mask values input
         
         %% Default values
         
         IMAGE.cloudmask           = nan;
         IMAGE.landmask            = -Inf;
         IMAGE.readcount           = 0; % unit8
         IMAGE.readdata            = 1; % double and flipped
         IMAGE.readindex           = 0; % ix and iy
         IMAGE.lon0                = -0.01;
         IMAGE.lat0                = 55.30;
         IMAGE.scale_in_m          = 11395500;
         IMAGE.resolution_km_p_pix = 1;
         IMAGE.xshift              = 0;
         IMAGE.yshift              = 0;
         
         if mod(nargin,2)==1 % odd
            i=2;
         else
            i=1;
         end
         %% the remaining number of arguments is always even now
         while i<=nargin,
             switch lower ( varargin{i  })
             % all keywords lower case
             case 'cloudmask';i=i+1;IMAGE.cloudmask       = varargin{i};
             case 'landmask' ;i=i+1;IMAGE.landmask        = varargin{i};
             case 'data'     ;i=i+1;IMAGE.readdata        = varargin{i};
             case 'count'    ;i=i+1;IMAGE.readcount       = varargin{i};
             case 'index'    ;i=i+1;IMAGE.readindex       = varargin{i};
             case 'xshift'   ;i=i+1;IMAGE.xshift          = varargin{i};
             case 'yshift'   ;i=i+1;IMAGE.yshift          = varargin{i};
             case 'center'   ;i=i+1;OPT.centercoordinates = varargin{i};
             case 'corner'   ;i=i+1;OPT.cornercoordinates = varargin{i};
             otherwise
               error(sprintf('Invalid string argument (caps?) to readnoaapc %s.',...
               varargin{i}));
             end
             i=i+1;
         end;

      %% READ HEADER 
      %  -----------------------------
      %  27 interger*2 bytes (swapped)
      %  54 interger*1 bytes
      %  -----------------------------
         
         %% 2 swapped integer*1 in one column(1:54)
         [header8,count]  = fread(fid, 54,'uint8');             
         
         %% 2 swapped integer*1 in 2 x column(1:27)
         header16         = reshape(header8,[2 27]);            
         
         %% 1         integer*2 in one column(1:27)
         header           = header16(1,:).*256 + header16(2,:); 
         
         IMAGE.year                   = header(1)+1900;

         %% Millennium bug:
         %% - no images from before TIROS-N (launched in October 1978)
         %% - so this workaround will work until 2077
         if IMAGE.year < 1978
         IMAGE.year                   =  IMAGE.year + 100;
         end
         
         IMAGE.month                  =  header(2);
         IMAGE.day                    =  header(3);
         IMAGE.hour                   =  header(4); 
         IMAGE.minute                 =  header(5);
         IMAGE.second                 =  0;
         IMAGE.datenum                =  datenum(IMAGE.year  ,...    
                                                 IMAGE.month ,...   
                                                 IMAGE.day   ,...     
                                                 IMAGE.hour  ,...    
                                                 IMAGE.minute,...  
                                                 0);
         try
         IMAGE.yearday                =  yearday(IMAGE.datenum);                                    
         end
         IMAGE.satnum                 =  header(6);  
         IMAGE.orbnum                 =  header(7);
         IMAGE.type                   =  header(8);
         IMAGE.ny                     =  header(9);
         IMAGE.nx                     =  header(10);
         if mod(IMAGE.nx,2)==1 % odd
         IMAGE.nx_in_file             =  IMAGE.nx+1;
         else
         IMAGE.nx_in_file             =  IMAGE.nx;
         end
         IMAGE.westpix                =  header(11);
         IMAGE.lat0                   = (header(12))/100;   % 5530
         IMAGE.lon0                   = (header(13))/100-5; % 499  - 5 = - 0.01
         IMAGE.resolution_km_p_pix    =  header(14)./100;
         IMAGE.resolution_bits_p_pix  =  header(15);
         IMAGE.gain                   =  header(16)./1000;
         IMAGE.offset                 =  header(17)./1000;
         IMAGE.composite_year         =  header(18);
         IMAGE.composite_month        =  header(19);
         IMAGE.composite_day          =  header(20);
         IMAGE.composite_hour         =  header(21);
         IMAGE.percent_clouded_pixels =  header(22);
         IMAGE.count_min_value        =  header(23);
         IMAGE.count_max_value        =  header(24);
         IMAGE.data_min_value = IMAGE.count_min_value*IMAGE.gain - IMAGE.offset;
         IMAGE.data_max_value = IMAGE.count_max_value*IMAGE.gain - IMAGE.offset;
         IMAGE.norbits                =  header(25);
         IMAGE.mask                   =  header(26);
        %IMAGE.projection             =  header(27);% not right, should be 1 or 0 !
        
%% compliance with adaguc.knmi.nl

%TODO         IMAGE.proj4 = ['+proj=stere +lat_ts=52 +lat_0=',num2str(IMAGE.lat0),...
%TODO                                              ' +lon_0=',num2str(IMAGE.lon0),...
%TODO                       ' +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +no_defs']; % elipsoid ??
%TODO
%TODO               +proj=stere +lon_0=0.0 +lat_0=90.0 +lat_ts=60.0 +a=6378.169 +b=6356.58383

%+a=6371.00 +b=6371.00 +units=m
%
%+proj=stere +lat_ts=52 +lat_0=60 +lon_0=-3 +k=1.0 +x_0=0 +y_0=0 +ellps=WGS84 +no_defs

        % Hans Roozekrans told me that the projection keyword
        % was introduced only later when the started to provide UTM
        % besides polar stereographic. (That's perhaps why it's the last
        % variable in the header). So 'projection' it is NOT valid for all 
        % images, for the first images it contains a completely random number. 
        % To avoid errors we completely ignore projection always.
        
        % if IMAGE.projection == 1536
        %    IMAGE.projection_type        = 'polar stereographic southern North Sea';
        % elseif IMAGE.projection == 0
        %    IMAGE.projection_type        = 'polar stereographic whole North Sea';
        % elseif IMAGE.projection == 22619
        %    IMAGE.projection_type        = '?? southern North Sea Bight';
        %    %iostat                       = -1;
        %    IMAGE.error                  = 'Unknown projection';
        % elseif IMAGE.projection == 35784
        %    IMAGE.projection_type        = '?? southern North Sea Bight';
        %    %iostat                       = -1;
        %    IMAGE.error                  = 'Unknown projection';
        % elseif IMAGE.projection == 24515
        %    IMAGE.projection_type        = '?? southern North Sea Bight';
        %    %iostat                       = -1;
        %    IMAGE.error                  = 'Unknown projection';
        % end
             
   catch
      OPT.iostat = 0;
   end % try

   end % if iostat
   
   if OPT.iostat==1 %1 when header failed
       
   %-%try
         
      %% Skip rest of header

         if OPT.dummyheaderlines
         if mod(IMAGE.nx,2)==1
         IMAGE.dummy                 = fread(fid,IMAGE.nx-54 +1,'uint8');
         else
         IMAGE.dummy                 = fread(fid,IMAGE.nx-54   ,'uint8');
         end
         end
         
         if IMAGE.type==6
             
            IMAGE.product     = 'SST';
            IMAGE.producttex  = 'SST';
            IMAGE.units       = 'deg C';
            IMAGE.unitstex    = '\circ C';
            IMAGE.productannotation = 'Sea Surface Temperature';
            
         elseif IMAGE.type==7

            IMAGE.product     = 'REF';
            IMAGE.producttex  = 'REF';
            IMAGE.units       = '';
            IMAGE.unitstex    = '';
            IMAGE.productannotation = 'Sea Surface Reflection (with atmosphere correction)';
            
         else

             warning('Parameter not known.')
             
         end
            
      %% READ DATA
      %  -----------------------------
      %  - called 'count' by KNMI
      %  - 1 byte per pixel
      %  - when odd number of pixels, one pixel is added
      %    so every row always has an even number of pixels in the noaapc file
      %  -----------------------------
         
         % IMAGE.count = flipud(fread(fid,[IMAGE.nx IMAGE.ny],'uint8')');
         [IMAGE.count,...
          IMAGE.number_of_bytes] = fread(fid,[IMAGE.nx_in_file IMAGE.ny],'*uint8');
         
         if IMAGE.number_of_bytes < IMAGE.nx_in_file*IMAGE.ny;
             OPT.iostat = -1;
         elseif (IMAGE.number_of_bytes == IMAGE.nx_in_file*IMAGE.ny) & ...
                 odd(IMAGE.nx)
             IMAGE.count = IMAGE.count(1:end-1,:);
         end
         
         IMAGE.count = IMAGE.count';
         
      %% FOR GEOPHYSICAL FIELD (if required)
      %  a. Apply gain and offset
      %  b. Count to physical value
      %  c. Swap so (1,1) is at lower left corner (done above)

         if IMAGE.readdata == 1
         
            IMAGE.data  = IMAGE.gain.*(double(IMAGE.count)) - IMAGE.offset;
            
         %% clouds
            
            IMAGE.data(IMAGE.count==0) = IMAGE.cloudmask;
            
         %% land
            
            IMAGE.data(IMAGE.count==1) = IMAGE.landmask;
            
         else
         
            IMAGE.data  = [];
         
         end
         
         if IMAGE.readcount == 0
         
            IMAGE.count = [];
            
         end
         
         IMAGE.data = flipud(IMAGE.data);
         
         IMAGE      = rmfield(IMAGE,'readdata');
         IMAGE      = rmfield(IMAGE,'readcount');
         
         % CHECK: DOES KNMI ZERO OR 1 BASED for PIXELS ?

         dx   =        0;
         dy   =        0;
         xulc =        0 + dx;
         yulc =        0 + dy;

      %% Coordinates bounding box
      %
      %      1        512     ix pixel row index [#]
      %    --+---------+-->
      %     500      511500   x  pixel center x-coordinate = (ix-0.5)*resolution [m]
      %    
      %   #-----+-~-+-----+   |
      %   |1    |   |    2|   |
      %   |  o  |   |  o  |   +1
      %   |     |   |     |   |
      %   +-----+-~-+-----+   |
      %   |     |   |     |   |
      %   ~     ~   ~     ~   |
      %   |     |   |     |   |
      %   +-----+-~-+-----+   |
      %   |     |   |     |   |
      %   |  o  |   |  o  |   +480
      %   |4    |   |    3|   |
      %   +-----+-~-+-----+   v
      %
      %
      %   LEGEND: #    the origin lies at (0,0)
      %           o    pixel center coordinate
      %           +    pixel corner coordinate
      %           |    pixel border
      %           -    pixel border
      %           ~    cut-out
         
         IMAGE.xbox = [ 1-.5-.5  IMAGE.nx  IMAGE.nx    1-.5-.5  1-.5-.5].*IMAGE.resolution_km_p_pix.*1000 + dx;
         IMAGE.ybox = [ 1-.5-.5   1-.5-.5  IMAGE.ny   IMAGE.ny  1-.5-.5].*IMAGE.resolution_km_p_pix.*1000 + dy;
         
        [IMAGE.lonbox,...
         IMAGE.latbox] = xy_polarulc2lonlat(IMAGE.xbox ,...
                                            IMAGE.ybox ,...
                                            [IMAGE.lon0 ...
                                             IMAGE.lat0],...
                                            [xulc + IMAGE.xshift ...
                                             yulc - IMAGE.yshift],...
                                             IMAGE.scale_in_m);

      %% Coordinates of pixels

         if OPT.centercoordinates
         
            [IMAGE.ixcen,...
             IMAGE.iycen] = meshgrid(1:1:IMAGE.nx,...
                                         IMAGE.ny:-1:1); % did KNMI use zero based in c ?? I guess not.
                                         
             IMAGE.xcen = (IMAGE.ixcen - 0.5).*IMAGE.resolution_km_p_pix.*1000 + dx;
             IMAGE.ycen = (IMAGE.iycen - 0.5).*IMAGE.resolution_km_p_pix.*1000 + dy;
                                        
            [IMAGE.lonbox,...
             IMAGE.latbox] = xy_polarulc2lonlat(IMAGE.xbox ,...
                                                IMAGE.ybox ,...
                                                [IMAGE.lon0 ...
                                                 IMAGE.lat0],...
                                                [xulc + IMAGE.xshift ...
                                                 yulc - IMAGE.yshift],...
                                                 IMAGE.scale_in_m);
            [IMAGE.loncen,...
             IMAGE.latcen] = xy_polarulc2lonlat(IMAGE.xcen                    ,...
                                                IMAGE.ycen                    ,...
                                               [IMAGE.lon0 IMAGE.lat0]        ,...
                                               [xulc + IMAGE.xshift ...
                                                yulc - IMAGE.yshift],...
                                                IMAGE.scale_in_m);   
            if ~OPT.keepxypolar
               IMAGE = rmfield(IMAGE,'xcen');
               IMAGE = rmfield(IMAGE,'ycen');
            end
            
            if ~IMAGE.readindex
               IMAGE = rmfield(IMAGE,'ixcen');
               IMAGE = rmfield(IMAGE,'iycen');
            end
            
         
            
         end

         if OPT.cornercoordinates
         
            [IMAGE.ixcor,...
             IMAGE.iycor] = meshgrid(0:1:IMAGE.nx,...
                                         IMAGE.ny:-1:0); % did KNMI use zero based in c ?? I guess not.
                                         
             IMAGE.xcor = (IMAGE.ixcor - 0.0).*IMAGE.resolution_km_p_pix.*1000 + dx;
             IMAGE.ycor = (IMAGE.iycor - 0.0).*IMAGE.resolution_km_p_pix.*1000 + dy;
                                        
            [IMAGE.loncor,...
             IMAGE.latcor] = xy_polarulc2lonlat(IMAGE.xcor                    ,...
                                                IMAGE.ycor                    ,...
                                               [IMAGE.lon0 IMAGE.lat0]        ,...
                                               [xulc + IMAGE.xshift ...
                                                yulc - IMAGE.yshift],...
                                                IMAGE.scale_in_m);
	    
	    
            if ~OPT.keepxypolar
               IMAGE = rmfield(IMAGE,'xcor');
               IMAGE = rmfield(IMAGE,'ycor');
            end
            
            if ~IMAGE.readindex
               IMAGE = rmfield(IMAGE,'ixcor');
               IMAGE = rmfield(IMAGE,'iycor');
            end
                     
         
         end
         
      %% Close file
         
         fid = fclose(fid);
         
         if fid==-1
            if nargout==1
               error(['Error in closing file: ',IMAGE.filename]);
            end
         end
            
   %-%catch
   %-%
   %-%  iostat = -1;
   %-%  
   %-%  %% Make sure that in case of error the 
   %-%  %% returned IMAGE struct only contains
   %-%  %% filename in release mode (not debug mode)
   %-%  %% -----------------------------
   %-%  if ~OPT.debugswitch
   %-%     fname = IMAGE.filename;
   %-%     clear IMAGE;
   %-%     IMAGE.filename = fname;
   %-%     clear fname;
   %-%  end
   %-%
   %-%end % try

   end % if iostat
   
   
%% Function output

   IMAGE.iostat    = OPT.iostat;
   if nargout      ==0 | nargout==1
      varargout= {IMAGE};
      %  Call matlab error: any script stops.
      %  DO ERROR HANDLING AT HIGHER LEVEL PREFERABLY
      %  AND ASK FOR IOSTAT.
      if OPT.iostat==-1
         %error(['Error in opening file: ',IMAGE.filename]);
         %IMAGE    = IMAGE.iostat;
         varargout= {IMAGE};
      end
   elseif nargout==2
      %  When user asks for an ouput status identifier,
      %  the error is handled at a higher level: so here we only
      %  display that an error has occured, while not calling
      %  matlab error(...).
      varargout= {IMAGE, OPT.iostat};
      if OPT.iostat==-1
         disp (['Error in opening file: ',IMAGE.filename]);
        %IMAGE    = IMAGE.iostat;
         varargout= {IMAGE, OPT.iostat};
      end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
function [lon, lat]= xy_polar2lonlat(xpol,ypol,varargin)
%xy_polar2lonlat  Converts x,y pairs in polar sterographic co-ordinates into lat/lon pairs
%
% xy_polar2lonlat converts x,y pairs in polar 
% sterographic co-ordinates into lon/lat pairs.
%
%  [longitude, latitude] = xy_polarulc2lonlat(x, y, picture_scale)
%
% Be aware of the fact that in the default polar stereographic projection
% the 0-meridian points upwards from the equator to the north pole
% WHEN YOU DEFINE the (0,0) coordinate at the upper left pixel
% of the image, this is no problem (KNMI does this).
%
% However, if you define the lower left corner as the origin
% you need to flip the result from the mapping in the 
% y-direction of the image.
%
%              |                y
%    \        (0)       /       ^
%     (-45)    |    (45)        |
%        \     |    /           |
%          \   |  /             |
%            \ |/               |
%  (-90)-----Npole-------(90)   +----> x
%            / |\           
%          /   |  \         
%        /     |    \       
%    (-135)    |    (135)  
%    /       (180)      \    
%              |            
%See also: XY_POLARULC2LONLAT, KNMI_NOAAPC_READ

   ps_scale       = [11395500];

   if nargin >2
      ps_scale   = varargin{1};
   end
   
   %% Does not use degrees except for input and output
   %-----------------------------------------------
   
   r    = sqrt(xpol.^2 + ypol.^2);

   lon  =             atan(xpol./ypol);
   lat  = pi./2 - 2.*(atan(r./ps_scale));

   lon  = rad2deg(lon);
   lat  = rad2deg(lat);
   
%% EOF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lon_pix, lat_pix]= xy_polarulc2lonlat(x_pix,  y_pix,varargin)
%XY_POLARULC2LONLAT  Converts x,y pairs in polar sterographic co-ordinates into lat/lon pairs
%
% XY_POLARULC2LONLAT converts x,y pairs in polar 
% sterographic co-ordinates into lon/lat pairs.
%
%   [longitude, latitude] = xy_polarulc2lonlat(x,   y)
%
% With optional parameters:
%
% [longitude, latitude] = xy_polarulc2lonlat(x,   y,...
%                                           [lon0 lat0 ],...
%                                           [x0   y0   ],...
%                                           picture_scale)
%
%   Where [lon0 lat0] and [x0 y0] are the corresponding
%   co-ordinates of the origin of the projection.
%
% Be aware of the fact that in the default polar stereographic projection
% the 0-meridian points upwards from the equator to the north pole
% WHEN YOU DEFINE the (0,0) coordinate at the upper left pixel
% of the image, this is no problem (KNMI does this).
%
% However, if you define the lower left corner as the origin
% you need to flip the result from the mapping in the 
% y-direction of the image.
%
%              |                y
%    \        (0)       /       ^
%     (-45)    |    (45)        |
%        \     |    /           |
%          \   |  /             |
%            \ |/               |
%  (-90)-----Npole-------(90)   +----> x
%            / |\           
%          /   |  \         
%        /     |    \       
%    (-135)    |    (135)  
%    /       (180)      \    
%              |            
%
%See also: XY_POLAR2LONLAT, KNMI_NOAAPC_READ

%% Input

   latlon0        = [-0.01 55.30];
   xy0            = [ 0     0   ];
   ps_scale       = [11395500];

   if     nargin >2
      latlon0    = varargin{1};
   end
   if nargin     >3
      xy0        = varargin{2};
   end
   if nargin     >4
      ps_scale   = varargin{3};
   end
   
%% Does not use degrees except for input and output
   
   x0       = xy0(1);
   y0       = xy0(2);

   lon0     = deg2rad(latlon0(1));
   lat0     = deg2rad(latlon0(2));

   var0     = (pi/2 - lat0)/2;

   x_ulc    =  (ps_scale * (sin(var0)./cos(var0)) * sin(lon0)); 
   y_ulc    =  (ps_scale * (sin(var0)./cos(var0)) * cos(lon0)); 
   
   var_x    = x_pix + x_ulc + x0;
   var_y    = y_pix + y_ulc + y0;
   
   %var_x([1 end],[1 end])
   %var_y([1 end],[1 end])

   var_pix  = sqrt(var_x.^2 + var_y.^2);

   lon_pix  =             atan(var_x./var_y);
   lat_pix  = pi./2 - 2.*(atan(var_pix./ps_scale));

   lon_pix  = rad2deg(lon_pix);
   lat_pix  = rad2deg(lat_pix);
   
%% EOF