function varargout = rws_waterbase_read(fnames,varargin)
%RWS_WATERBASE_READ   Read ASCII text file from www.waterbase.nl
%
%   DAT = rws_waterbase_read(fname,<keyword,value>)
%
% reads ONE txt file of ONE parameter at MULTIPLE locations to ONE structure DAT.
%       or
% reads MULTIPLE txt files of ONE parameter at ONE location to ONE structure DAT.
%
% Implemented optional <keyword,value> pairs are:
%  * 'locationcode':            obtain locationcode from waterbase filename 
%                               N.B. works only for ONE location per file AND
%                               with automatic filename from RWS_WATERBASE_GET_URL! (default 1)
%  * 'fieldname':               fieldname for parameter to be read (default 'waarde' as in DONAR file).
%  * 'fieldnamescale':          real value, field is DIVIDED by fieldnamescale (default 1).
%  * 'start_last_header_line':  "locatie;waarnemingssoort;datum;tijd"
%  * 'headerlines':             auto':(default) finds automatically 1st line starting with:
%                               start_last_header_line which is by default 
%                               "locatie;waarnemingssoort;datum;tijd"
%                               This option also reads the headerlines into DAT.
%                               number 7, or 5 or 4 for older files where the 
%                               EPSG names of the coordinates were not yet added.
%  * 'xscale','yscale':         real value. x and y fields can optionally be divided by 100 
%                               so they are  in SI units (meters etc.). (default all scales 1).
%  * 'method':                  'textread' (default) or 'fgetl'.
%          number               default: byte size at which to switch to fgetl method (default 40e6)
%         'textread':           method perfect for relatively small files (< tens of Mb's). 
%                               But NOTE that loading a large text file (O 100 Mb) with 
%                               textread requires an exceptional amount of memory (e.g ~ 1.3 Gb of 
%                               memory for a 150 MB file). With textread all meta-data vectors are read.
%         'fgetl':              fast that uses no more memory than needed. However, with 
%                               fgetl only 6 columns are read (datenum,waarde,x,y,epsg,z). With
%                               fgetl the other meta-data are ONLY read for the first location.
% LIMITATIONS: 
% * with method 'fgetl' not all meta-info is read
% * with method 'textread' RWS_WATERBASE_READ cannot handle lines with empty values as:
%
%      Maasmond;Debiet in m3/s in oppervlaktewater;;;;Geen data beschikbaar/No data available;;9;9;9;9;9;9;9;9;9;9;9,9,9
%
% LOCATIONS: On <a href="http://www.waterbase.nl/metis">waterbase.nl/metis</a> there is a table where the locations including coordinates 
%    can be found. The following <a href="http://www.epsg.org/guides/">epsg</a> codes are used:
%    
%    * 4230 ED50  (lon,lat) [degrees, minutes, seconds and tenths of seconds] (longitude (Ol.),latitude (Nb.))
%    * 4326 WGS84 (lon,lat) [degrees, minutes, seconds and tenths of seconds] (longitude (Ol.),latitude (Nb.))
%    * 7415 RD    (x  ,y  ) [cm] (East, North) 
%
%   See web : <a href="http://www.epsg.org/guides/">www.epsg.org</a>, <a href="http://www.waterbase.nl"    >www.waterbase.nl</a>
%   See also: rws_waterbase_get_url, LOAD, XLSREAD, rijkswaterstaat

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2010 Delft University of Technology
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

% $Id: rws_waterbase_read.m 8476 2013-04-19 08:43:26Z boer_g $
% $Date: 2013-04-19 16:43:26 +0800 (Fri, 19 Apr 2013) $
% $Author: boer_g $
% $Revision: 8476 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_read.m $

% 2006 Feb    : first version [Gerben J de Boer]
% 2009 apr 21 : fixed error that swapped [lon,lat] for EPSG codes 4230 and 4326 [Gerben J de Boer]
% 2009 may 03 : updated commetns to reflect matlab code-cells
% 2009 may 03 : used setproperty now (for which I ahd to delete scale keyword)
% 2010 jun 29 : made method automatic based on file size
% 2012 jun 19:  D(nloc).data.units = waarnemingssoort2units(D(nloc).data.waarnemingssoort) 
%               when rec(dlm( 6)+1:dlm( 7)-1) is empty

% TO DO perhaps regexp is faster in fgetl approach, ot textscan chunks
% TO DO read associated *.url and return that in struct, so it can be put in netcdf

% uses: time2datenum

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Sep 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: rws_waterbase_read.m 8476 2013-04-19 08:43:26Z boer_g $
% $Date: 2013-04-19 16:43:26 +0800 (Fri, 19 Apr 2013) $
% $Author: boer_g $
% $Revision: 8476 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_read.m $
% $Keywords: $

%% Defaults

   OPT.xscale                 = 1;
   OPT.yscale                 = 1;
   OPT.fieldnamescale         = 1;
   
   OPT.fieldname              = 'waarde';
   OPT.method                 = 40e6; %'textread';
   OPT.preallocate            = Inf; %11*366*24*6; % 11 years every 10 minute for method = 'fgetl'
   OPT.headerlines            = 'auto'; %changed from 4 to 5 after inclusion of EPSG names of coordinates and is 7 on 2007 june 27th
   OPT.start_last_header_line = 'locatie;waarnemingssoort;datum;tijd';
   OPT.display                = 'multiWaitbar'; %1; % empty is multiWaitbar, 1=command line
   OPT.displayskip            = 10000;
   OPT.ntmax                  = -1;
   OPT.locationcode           = 1;
   OPT.url                    = 1; % read associated *.url file (generated by rws_waterbase_get_url)

%% Key words

   OPT = setproperty(OPT,varargin{1:end});

%% Loop over file names
fnames = cellstr(fnames);

for ifile=1:length(fnames)

   fname = char(fnames{ifile});

   %% Original file info
 
   %% Automatic load method detection

      D = dir(fname);
      if isempty(D)
          error(['file not found:',fname]);
      end
      if isnumeric(OPT.method)
          if D.bytes < OPT.method
             OPT.method = 'textread';
          else
             OPT.method = 'fgetl';
          end
      else
        if    strcmpi(OPT.method,'fgetl')
          if D.bytes < 50e6
            warning('for small files method=textread is recommended to obtain all meta-info.');
          end
        elseif strcmpi(OPT.method,'textread')
          if D.bytes > 50e6
            warning('for large files method=fgetl is recommended to prevent excess memory use.');
          end
        end
      end
      
      if isempty(D)
         error([fname,' not found'])
      end
   
   %% Automatic header line detection
   
   if ischar(OPT.headerlines)
      if strcmpi(OPT.headerlines,'auto')
     fid           = fopen(fname,'r');
	 record        = fgetl(fid); % read one record
	 n_headerlines = 0;
	 finished      = 0;
	 if length(record) >=   length(OPT.start_last_header_line)
	    if strcmpi(record(1:length(OPT.start_last_header_line)),...
	                               OPT.start_last_header_line)
	       finished = 1;
	    end
	 end
	 while ~(finished)
	    n_headerlines           = n_headerlines + 1;
	    D.header{n_headerlines} = record;
	    record = fgetl(fid); % read one record
	    if length(record) >= length(OPT.start_last_header_line)
	    if strcmpi(record(1:length (OPT.start_last_header_line)),...
	                                OPT.start_last_header_line)
	       finished                = 1;
	       n_headerlines           = n_headerlines + 1;
	       D.header{n_headerlines} = record;
	    end
	    end
	 end
         fclose(fid);
      end

      OPT.headerlines = n_headerlines;

   end

   %% file format example
   %  locatie;waarnemingssoort;datum;tijd;bepalingsgrenscode;waarde;eenheid;hoedanigheid;anamet;ogi;vat;bemhgt;refvlk;x;y;orgaan;biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam)
   %  Noordwijk meetpost;Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater;1982-09-02;19:30;;-36;cm t.o.v. NAP;T.o.v. Normaal Amsterdams Peil;Rek. gem. waterhoogte over vorige 10 min. (MSW);Nationaal;Stappenbaak - type Marine 300;NVT;NVT;4174600;52162600;NVT;NVT,NVT,Niet van toepassing
   %  ----------------------------------------
   %  1    locatie                                                               Noordwijk meetpost
   %  2    waarnemingssoort							  Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater
   %  3    datum								  1982-09-02
   %  4    tijd								  19:30
   %  5    bepalingsgrenscode
   %  6    waarde								  -36
   %  7    eenheid								  cm t.o.v. NAP
   %  8    hoedanigheid							  T.o.v. Normaal Amsterdams Peil
   %  9    anamet								  Rek. gem. waterhoogte over vorige 10 min. (MSW)
   % 10    ogi									  Nationaal
   % 11    vat									  Stappenbaak - type Marine 300
   % 12    bemhgt								  NVT
   % 13    refvlk								  NVT
   % 14/   epsg								  7415
   % 15/14 x									  4174600
   % 16/15 y									  52162600
   % 17/16 orgaan								  NVT
   % 18/17 biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam) NVT,NVT,Niet van toepassing
   % new/old
   % ----------------------------------------
   
   %% read
   
   if strcmp(OPT.method,'textread')
   
       if     strcmpi(OPT.display,'multiWaitbar') % textread files are small: no waitbar needed
          %multiWaitbar([mfilename,'raw'    ],0,'label',[mfilename,': reading raw data.']     ,'color',[0.3 0.4 0.3])
          %multiWaitbar([mfilename,'2struct'],0,'label',[mfilename,': transforming raw data to struct.'],'color',[0.3 0.4 0.3])
       elseif OPT.display;
          disp([mfilename,' Reading raw data of: ',fname]);
       end

      if OPT.headerlines==4
      %% Old file type, no extra headerline, AND extra column with EPSG number
      %% File type after relaunch of waterbase dec 2009
      [location          ,...
       waarnemingssoort  ,...
       datestring        ,...
       timestring        ,...
       bepalingsgrenscode,...
       waardestring      ,... % can be N.A., so using %f format does not work
       eenheid           ,...
       hoedanigheid      ,...
       anamet            ,...
       ogi               ,...
       vat               ,...
       bemhgt            ,...
       refvlk            ,...
       epsg              ,...
       x                 ,...
       y                 ,...
       orgaan            ,...
       biotaxon] = textread(fname,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s',OPT.ntmax,...
                           'headerlines',OPT.headerlines,...
                           'delimiter'  ,';');
       else
      %% Extra headerline, AND extra column with EPSG number
      [location          ,...
       waarnemingssoort  ,...
       datestring        ,...
       timestring        ,...
       bepalingsgrenscode,...
       waardestring      ,... % can be N.A., so using %f format does not work
       eenheid           ,...
       hoedanigheid      ,...
       anamet            ,...
       ogi               ,...
       vat               ,...
       bemhgt            ,...
       refvlk            ,...
       epsg              ,...
       x                 ,...
       y                 ,...
       orgaan            ,...
       biotaxon] = textread(fname,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s',...
                           'headerlines',OPT.headerlines,...
                           'delimiter'  ,';');    
       end
       
       if isempty(char(datestring))
       datenumbers = nan;
       else
       datenumbers = time2datenum(datestring,timestring);
       if length(datenumbers) < length(datestring)
          datenumbers = repmat(nan,[length(datestring) 1]);
          
          % handle missing times
          for i=1:length(datestring)
          tmp = time2datenum(datestring{i},timestring{i});
          if ~isempty(tmp)
          datenumbers(i) = tmp;
          end
          end
          
       end

       end
       
       if     strcmpi(OPT.display,'multiWaitbar') % textread files are small: no waitbar needed
         %multiWaitbar([mfilename,'raw'    ],1,'label',[mfilename,': reading raw data.']     ,'color',[0.3 0.4 0.3])
       elseif OPT.display;
          disp(['rws_waterbase_read: read raw data: ',fname]);
       end
       
       % Method below (%n) cannot deal with Not Available data as in:
       % Maassluis;Temperatuur in oC in oppervlaktewater;1994-08-03;07:14;;25;graden Celsius;NVT;Onbekend;Nationaal;;-100;T.o.v. Waterspiegel;7415;77500;436100;NVT;NVT,NVT,Niet van toepassing
       % Maassluis;Temperatuur in oC in oppervlaktewater;1994-08-17;05:53;;N.A.;graden Celsius;NVT;Onbekend;Nationaal;;-100;T.o.v. Waterspiegel;7415;77500;436100;NVT;NVT,NVT,Niet van toepassing
       %    biotaxon] = textread(fname,'%s%s%s%s%s%n%s%s%s%s%s%s%s%s%s%s%s',...
       %                        'headerlines',OPT.headerlines,...
       %                        'delimiter'  ,';');
       
       %% Replace N.A. with NaNs
       
       % waardestring = char(waardestring);
       % 
       % %whos waarde
       % %108311x39
       % 
       % nodatavalues = {'N.A.',...                                  % OPP WATER TEMP (DONAR)
       %                 'Geen data beschikbaar/No data available'}; % Debiet
       %                 
       % for ii = 1:length(nodatavalues)
       %    mask   = strmatch(char(nodatavalues{ii}),waarde,'exact');
       %    for ii=1:length(mask)
       %       waarde(mask(ii),:)=pad('NaN',size(waarde,2));
       %    end
       % end
       % 
       % [waarde,OK]=str2num(waardestring);
       %    if OK==0
       %       error('conversion data to numeric values, probaly due to Geen data beschikbaar/No data available text in data.')
       %    end
   
       waardestring = cellstr(waardestring);
       waarde       = str2double(waardestring); % returns NaN where waardestring is not 
   
       %error('waarde also per station')
   
       %% Make into table
       %  TO DO: Sort per station into seperate struct fields
       
       D.locations = unique(location);
       
       for istat=1:length(D.locations)
       
          if     strcmpi(OPT.display,'multiWaitbar') % textread files are small: no waitbar needed
             %multiWaitbar([mfilename,'2struct'],istat/length(D.locations),'label',[mfilename,': transforming raw data to struct.'],'color',[0.3 0.4 0.3])
          elseif OPT.display;
             disp(['rws_waterbase_read: transforming to struct: ',num2str(istat),'/',num2str(length(D.locations))]);
          end
       
          mask = strmatch(D.locations{istat},location);
   
          D.data(istat).location           = char(location         (mask(1),:)); % unique by definition of using strmatch above
          D.data(istat).waarnemingssoort   = char(waarnemingssoort (mask(1),:)); % that's all what DONAR hands out.
         %D.data(istat).datum              = 
         %D.data(istat).tijd               = 
         %D.data(istat).bepalingsgrenscode = 
         %D.data(istat).waarde             = 
          D.data(istat).units              = char(eenheid       (mask(1),:)); % assumed
          if isempty(D.data(istat).units)
              D.data(istat).units = waarnemingssoort2units(D.data(istat).waarnemingssoort);
          end
          
          D.data(istat).hoedanigheid       = hoedanigheid       (mask,:); 
          D.data(istat).anamet             = anamet             (mask,:);
          D.data(istat).ogi                = ogi                (mask,:);
          D.data(istat).vat                = vat                (mask,:);
          bemhgt = strrep(lower(bemhgt),'nvt','nan');
          D.data(istat).z                  = str2num(char(bemhgt(mask,:)))./100; % I assume they are in cm
          D.data(istat).refvlk             =              refvlk(mask,:); % tested to be not unique
         
          D.data(istat).epsg               = str2num(char(epsg{mask,:})); % tested to be not unique
          D.data(istat).x                  = str2num(char(   x{mask,:})); % tested to be not unique
          D.data(istat).y                  = str2num(char(   y{mask,:})); % tested to be not unique
         %D.data(istat).orgaan             = 
         %D.data(istat).biotaxon           = 
         
          D.data(istat).(OPT.fieldname)    = waarde(mask);
          D.data(istat).datenum            = datenumbers(mask);

          %% Get uniform co-ordinates (lat,lon)
          
             D.data(istat).lon = repmat(nan,size(D.data(istat).x));
             D.data(istat).lat = repmat(nan,size(D.data(istat).x));
          
                               geomask.ed50   =                    D.data(istat).epsg==4230;
             D.data(istat).lat(geomask.ed50)  =                    D.data(istat).x(geomask.ed50);
             D.data(istat).lon(geomask.ed50)  =                    D.data(istat).y(geomask.ed50);

                               geomask.ll     =                    D.data(istat).epsg==4326;
             D.data(istat).lat(geomask.ll )   =                    D.data(istat).x(geomask.ll );
             D.data(istat).lon(geomask.ll )   =                    D.data(istat).y(geomask.ll );

                               geomask.par    =                    D.data(istat).epsg==7415;
            [D.data(istat).lon(geomask.par),...
             D.data(istat).lat(geomask.par)]  = convertCoordinates(D.data(istat).x(geomask.par),...
                                                                   D.data(istat).y(geomask.par),'persistent','CS1.code',7415,'CS2.code',4326);

                               geomask.unknow = ~(geomask.ed50 | geomask.par | geomask.ll);
          
       end
   
   elseif strcmp(OPT.method,'fgetl')
   
      if OPT.ntmax  == -1
         OPT.ntmax = Inf;
      end
   
      % warning('method fgetl does not work for multiple stations, neither for missing data data ''N.A.''')
   
      %% Fast scan file one time to count number of lines
      
      if isinf(OPT.preallocate) %%%-%%% & 0
         fid = fopen(fname,'r');
         nt  = 0;
         if     strcmpi(OPT.display,'multiWaitbar')
            multiWaitbar([mfilename,'station'],0,'label','count lines'     ,'color',[0.3 0.4 0.3])
            multiWaitbar([mfilename,'lines'  ],0,'label','loading raw data','color',[0.3 0.4 0.3])
         elseif OPT.display;
            disp('Fast scanning file to check number of lines');
         end

         while 1
            tline = fgetl(fid);
            nt    = nt+1;
            if ~ischar(tline), break, end
            if strcmpi(OPT.display,'multiWaitbar')
            elseif OPT.display==1
              if mod(nt,OPT.displayskip)==0
                disp([num2str(nt)])
              end
            end
         end
         fclose(fid);   
         
         if     strcmpi(OPT.display,'multiWaitbar')
            multiWaitbar([mfilename,'station'],1,'label',['count lines: ',num2str(nt)])
         elseif OPT.display;
            disp(['Slow scanning file to read data on # ',num2str(nt),' lines (incl.header).']);
         end
      else
         nt = OPT.preallocate;
      end
      
      %% Pre-allocate arrays
      % pre-allocate any extra vector too !!!

      D.readme               = ['Except the for five fields datenum,',OPT.fieldname,',x,y,epsg,z, the fields contain only the unique values !!!'];
      D.data.datenum         = repmat(nan,[1 nt]); % 1
      D.data.(OPT.fieldname) = repmat(nan,[1 nt]); % 2
      D.data.x               = repmat(nan,[1 nt]); % 3
      D.data.y               = repmat(nan,[1 nt]); % 4
      D.data.lon             = repmat(nan,[1 nt]); % 5
      D.data.lat             = repmat(nan,[1 nt]); % 6
      D.data.epsg            = repmat(nan,[1 nt]); % 7
      D.data.z               = repmat(nan,[1 nt]); % 7
      D.data.location        = ''; % needed in case file is empty

      it              = 0; % number of time per location
      nloc            = 1;
      first           = 1;
      currentlocation = '';
      
      %% Read data from file

      fid = fopen(fname,'r');
   
      for ii=1:OPT.headerlines
         D.header{ii} = fgetl(fid); % read one record
      end
   
      while 1
      
          rec = fgetl(fid); % read one record
          if ~ischar(rec) | isempty(rec) %%%-%%% | it==10
             break
          else
          
             % Waarnemingssoort: Debiet in m3/s in oppervlaktewater
             % Alle tijdsaanduidingen zijn in GMT+1 (MET)
             % Coordinaatweergave is x,y in EPSG 7415 (RD) en als lat/long in EPSG 4230 (ED50)
             % De afkorting NVT betekent: "Niet van toepassing"
             % locatie        ;waarnemingssoort                  ;datum     ;tijd ;bepalingsgrenscode;waarde;eenheid;hoedanigheid;anamet                                        ;ogi      ;vat;bemhgt;refvlk;EPSG;x/lat ;y/long;orgaan;biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam)
             % Hagestein boven;Debiet in m3/s in oppervlaktewater;1989-01-01;00:00;                  ;567   ;m3/s   ;NVT         ;Debiet uit afvoerkromme (Q/H- of Q/HH-relatie);Nationaal;NVT;NVT   ;NVT   ;7415;137740;444640;NVT   ;NVT,NVT,Niet van toepassing
             % Hagestein boven;Debiet in m3/s in oppervlaktewater;1989-01-02;00:00;                  ;530   ;m3/s   ;NVT         ;Debiet uit afvoerkromme (Q/H- of Q/HH-relatie);Nationaal;NVT;NVT   ;NVT   ;7415;137740;444640;NVT   ;NVT,NVT,Niet van toepassing       
             % ...
             
             it  = it + 1;
             
             if it > OPT.ntmax
                break
             else

                if strcmpi(OPT.display,'multiWaitbar') 
                   if (mod(it,OPT.displayskip)==0)
                      multiWaitbar([mfilename,'lines'],it/nt,'label','loading raw data')
                   end
                elseif OPT.display
                   if (mod(it,OPT.displayskip)==0)
                      disp(num2str(it,'%0.10d'));
                   end
                end             

             end
             
             dlm = strfind(rec,';');
             
             if it==1
             
                D(nloc).data.location               =         rec(1        :dlm( 1)-1);
                if isempty(D(nloc).data.location)
                   fprintf(2,'%s\n',['file empty: ',fname])
                   fclose(fid);
                   varargout = {D,-1};
                   return
                end
                D(nloc).data.waarnemingssoort       =         rec(dlm( 1)+1:dlm( 2)-1);
                                                                     % 2
                                                                     % 3
               %D(nloc).data.bepalingsgrenscode     =         rec(dlm( 4)+1:dlm( 5)-1);
                                                                     % 5
                D(nloc).data.units                  =         rec(dlm( 6)+1:dlm( 7)-1);

                if isempty(D.data.units)
                    D.data.units = waarnemingssoort2units(D.data.waarnemingssoort);
                end
                
                
                D(nloc).data.what                   =         rec(dlm( 7)+1:dlm( 8)-1);
                D(nloc).data.anamet                 =         rec(dlm( 8)+1:dlm( 9)-1);
                D(nloc).data.ogi                    =         rec(dlm( 9)+1:dlm(10)-1);
                D(nloc).data.vat                    =         rec(dlm(10)+1:dlm(11)-1);
                                                                     %11
                D(nloc).data.refvlk                 =         rec(dlm(12)+1:dlm(13)-1);
                                                                     %13
                                                                     %14
                                                                     %15
                D(nloc).data.orgaan                 =         rec(dlm(16)+1:dlm(17)-1);
                D(nloc).data.biotaxon               =         rec(dlm(17)+1:end      );
                
                D(nloc).data.README = 'For the following fields only the unique values have been processed, not all values: location, waarnemingssoort, bepalingsgrenscode, units, what, anamet, ogi, vat, refvlk, orgaan';
                fprintf(2,'WARNING: rws_waterbase_read: For the following fields only the unique values have been processed, not all values: location, waarnemingssoort, bepalingsgrenscode, units, what, anamet, ogi, vat, refvlk, orgaan.\n');
             
             else
             
                location                             =         rec(1        :dlm( 1)-1);
                
                if ~strcmpi(D(nloc).data.location,location)
                   error('More than one location in file, only one is allowed with method fgetl')
                end
                
                D(nloc).data.location               = rws_expand(D(nloc).data.location          ,rec(1        :dlm( 1)-1));
                D(nloc).data.waarnemingssoort       = rws_expand(D(nloc).data.waarnemingssoort  ,rec(dlm( 1)+1:dlm( 2)-1));
                                                                                                ,       % 2
                                                                                                ,       % 3
               %D(nloc).data.bepalingsgrenscode     = rws_expand(D(nloc).data.bepalingsgrenscode,rec(dlm( 4)+1:dlm( 5)-1));
                if ~isempty(rec(dlm( 6)+1:dlm( 7)-1))                                                                             ,       % 5
                    D(nloc).data.units                  = rws_expand(D(nloc).data.units             ,rec(dlm( 6)+1:dlm( 7)-1));
                else
                    D(nloc).data.units = waarnemingssoort2units(D(nloc).data.waarnemingssoort);
                end
                D(nloc).data.what                   = rws_expand(D(nloc).data.what              ,rec(dlm( 7)+1:dlm( 8)-1));
                D(nloc).data.anamet                 = rws_expand(D(nloc).data.anamet            ,rec(dlm( 8)+1:dlm( 9)-1));
                D(nloc).data.ogi                    = rws_expand(D(nloc).data.ogi               ,rec(dlm( 9)+1:dlm(10)-1));
                D(nloc).data.vat                    = rws_expand(D(nloc).data.vat               ,rec(dlm(10)+1:dlm(11)-1));
                                                                                                ,       %11
                D(nloc).data.refvlk                 = rws_expand(D(nloc).data.refvlk            ,rec(dlm(12)+1:dlm(13)-1));
                                                                                                ,       %13
                                                                                                ,       %14
                                                                                                ,       %15
                D(nloc).data.orgaan                 = rws_expand(D(nloc).data.orgaan            ,rec(dlm(16)+1:dlm(17)-1));
                D(nloc).data.biotaxon               = rws_expand(D(nloc).data.biotaxon          ,rec(dlm(17)+1:end      ));
                
             end         
   
             datestring          = rec(dlm( 2)+1:dlm( 3)-1);
             timestring          = rec(dlm( 3)+1:dlm( 4)-1);
             
             if ~isempty(datestring)
              
                yyyy                         = str2double(datestring( 1: 4));
                mm                           = str2double(datestring( 6: 7));
                dd                           = str2double(datestring( 9:10));
                HH                           = str2double(timestring( 1: 2));
                MI                           = str2double(timestring( 4: 5));
                
                D(nloc).data.datenum        (it) = datenum(yyyy,mm,dd,HH,MI,0);          % 1
                D(nloc).data.(OPT.fieldname)(it) = str2double(rec(dlm( 5)+1:dlm( 6)-1)); % 2
                D(nloc).data.epsg           (it) = str2num   (rec(dlm(13)+1:dlm(14)-1)); % 7
                D(nloc).data.x              (it) = str2num   (rec(dlm(14)+1:dlm(15)-1)); % 3
                D(nloc).data.y              (it) = str2num   (rec(dlm(15)+1:dlm(16)-1)); % 4
                             z                   =            rec(dlm(11)+1:dlm(12)-1);
                if ~strcmpi('nvt',z)
                D(nloc).data.z              (it) = str2num(z)./100; % 5
                end
   	        
             else

                D(nloc).data.datenum        (it) = nan;
                D(nloc).data.(OPT.fieldname)(it) = nan;
                D(nloc).data.epsg           (it) = nan;
                D(nloc).data.x              (it) = nan;
                D(nloc).data.y              (it) = nan;
                D(nloc).data.z              (it) = nan;
             
             end
             
             
          end
          
      end % while
             
      %% Get uniform co-ordinates (lat,lon)

         D(nloc).data.lon = repmat(nan,size(D(nloc).data.x)); % 5
         D(nloc).data.lat = repmat(nan,size(D(nloc).data.x)); % 6
      
                          geomask.ed50   =                    D(nloc).data.epsg==4230;
         D(nloc).data.lat(geomask.ed50)  =                    D(nloc).data.x(geomask.ed50);
         D(nloc).data.lon(geomask.ed50)  =                    D(nloc).data.y(geomask.ed50);

                          geomask.ll     =                    D(nloc).data.epsg==4326;
         D(nloc).data.lat(geomask.ll )   =                    D(nloc).data.x(geomask.ll );
         D(nloc).data.lon(geomask.ll )   =                    D(nloc).data.y(geomask.ll );

                          geomask.par    =                    D(nloc).data.epsg==7415;
        [D(nloc).data.lon(geomask.par),...
         D(nloc).data.lat(geomask.par)]  = convertCoordinates(D(nloc).data.x(geomask.par),...
                                                              D(nloc).data.y(geomask.par),'persistent','CS1.code',7415,'CS2.code',4326);

                          geomask.unknow = ~(geomask.ed50 | geomask.par | geomask.ll);
      
      %% Remove too much pre-allocated data.
      %  This need to be done even if OPT.preallocate is specified, because
      %  the fast scanning also counted the number of header lines.
      
      D.data.datenum         = D.data.datenum        (1:it); % 1
      D.data.(OPT.fieldname) = D.data.(OPT.fieldname)(1:it); % 2
      D.data.x               = D.data.x              (1:it); % 3
      D.data.y               = D.data.y              (1:it); % 4
      D.data.epsg            = D.data.epsg           (1:it); % 5
      D.data.lon             = D.data.lon            (1:it); % 6
      D.data.lat             = D.data.lat            (1:it); % 7
      D.data.z               = D.data.z              (1:it); % 8
      
      D.locations{1} = D(nloc).data.location;
   
      fclose(fid);
      
      multiWaitbar([mfilename,'station'],'Close')
      multiWaitbar([mfilename,'lines'  ],'Close')

   else
      error(['method unknown, only fgetl and textread allowed: ',OPT.method])
   end % OPT.method
   
%% apply scales to get rid of STUPID non-SI units of Rijkswaterstaat
   
   for idat = 1:length(D.data)
      D.data(idat).(OPT.fieldname) = D.data(idat).(OPT.fieldname)./OPT.fieldnamescale;
   end
   
   if isfield(D,'x')
   %  D.data.x = str2double(char(D.data.x))./OPT.xscale;
      D.data.x = D.data.x./OPT.xscale;
   end   
   
   if isfield(D,'y')
   %  D.data.y = str2double(char(D.data.y))./OPT.yscale;
      D.data.y = D.data.y./OPT.yscale;
   end   
   
%% In case of more files, copy to multiple-file structure

   if length(D.locations)==1
   
      % reduce redundant meta-info 

         if length(unique(D.data.x           ))==1;D.data.x               =      unique(D.data.x           ) ;end
         if length(unique(D.data.y           ))==1;D.data.y               =      unique(D.data.y           ) ;end
         if length(unique(D.data.epsg        ))==1;D.data.epsg            =      unique(D.data.epsg        ) ;end
         if length(unique(D.data.lon         ))==1;D.data.lon             =      unique(D.data.lon         ) ;end
         if length(unique(D.data.lat         ))==1;D.data.lat             =      unique(D.data.lat         ) ;end

      if strcmp(OPT.method,'textread')
         if length(unique(D.data.hoedanigheid))==1;D.data.hoedanigheid    = char(unique(D.data.hoedanigheid));end
         if length(unique(D.data.anamet      ))==1;D.data.anamet          = char(unique(D.data.anamet      ));end
         if length(unique(D.data.ogi         ))==1;D.data.ogi             = char(unique(D.data.ogi         ));end
         if length(unique(D.data.vat         ))==1;D.data.vat             = char(unique(D.data.vat         ));end
         if length(unique(D.data.z           ))==1;D.data.z               =      unique(D.data.z           ) ;end
         if length(unique(D.data.refvlk      ))==1;D.data.refvlk          = char(unique(D.data.refvlk      ));end
      end
      
      if all (isnan(D.data.z))
         D.data.z = nan;
      end
   
      %if ~(length(D.locations)==1)
      %   error('With MULTIPLE file names only ONE station per file is allowed.')
      %end
   
         %% Extract meta-information
         DS.name     {ifile} = D.name ;
         DS.date     {ifile} = D.date ;
         DS.bytes    (ifile) = D.bytes;
         DS.isdir    (ifile) = D.isdir;
         DS.datenum  {ifile} = D.data.datenum;
         DS.locations{ifile} = D.locations{1}; %D.data.location;
         
         %% Copy location code (as obtained from file name)
         if OPT.locationcode
         
            try % should work when filename is 
                % id22-IJMDMNTSPS-190001010000-201003062359.txt
                % id22-IJMDMNTSPS.txt
            ind = strfind (fname,'-'); if length(ind)==1;ind=[ind length(fname) - length(fileext(fname)) + 1];end
            locationcode     = lower(fname([ind(1)+1]:[ind(2)-1]));
            
            catch
            locationcode     = '';
            end
         
            if length(D.locations)==1
            D.data.location          = D.locations{1};
            D.data.locationcode      = locationcode;
            DS.locationcodes{ifile}  = locationcode;
            else
               error('With MULTIPLE file names only ONE station per file is allowed.')
            end
         end

         %% Copy data
         DS.data(ifile) = D.data;
         
         if     strcmpi(OPT.display,'multiWaitbar') & ~strcmp(OPT.method,'textread')% textread files are small: no waitbar needed
            multiWaitbar([mfilename,'lines'],ifile/num2str(length(fnames)),'label','loading raw data')
         elseif OPT.display;
            disp(['rws_waterbase_read: read file ',num2str(ifile),' of ',num2str(length(fnames))]);
         end
   
   end % D.locations==1
   
   if OPT.url % onyl works when downloaded with rws_waterbase_get_url
   
      fidurl = fopen(strrep(fname,'.txt','.url'),'r');
      if fidurl > 0
          rec    = fgetl(fidurl); % [InternetShortcut]
          rec    = fgetl(fidurl); % URL=%s
          fclose(fidurl);
          D.url  = rec(5:end);
      end
   
   end
   
end % for ifile=1:length(fnames)

%% Output

   if length(fnames) >1
      varargout = {DS};
   else      
      varargout = {D};
   end
   
%% EOF

function c = rws_expand(a,b)

if ~any(strcmpi(a,b));
   c = cellstrvcat(a,b);
else   
   c = a;
end

function units = waarnemingssoort2units(waarnemingssoort) 
% in live.waterbase.nl version 2 feb 2012 units column was suddenly gone, so we have to extract from name colum

switch waarnemingssoort
   case 'Zwevende stof in mg/l in oppervlaktewater'                           ,units='mg/l';
   case 'Debiet in m3/s in oppervlaktewater'                                  ,units='m3/s';
   case 'Waterhoogte in cm t.o.v. mean sea level in oppervlaktewater'         ,units='cm';
   case 'Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater',units='cm';
   case 'Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater',units='cm';
   case 'Gemiddelde richting uit golfrichtingsspectrum van 30-500 mhz in graad t.o.v. kaart noorden in oppervlaktewater',units ='degrees_north';
   case 'Gem. golfperiode uit spectrale momenten m0+m2 van 30-500 mhz in s in oppervlaktewater',units ='s';
   case 'Saliniteit in oppervlaktewater'                                     ,units='psu';
   case 'Temperatuur in oC in oppervlaktewater'                              ,units='degrees_C';
   case 'Chlorofyl-a in ug/l in oppervlaktewater'                            ,units='ug/l';
   case 'Percentage zuurstof in % in oppervlaktewater'                       ,units='%';
   case 'Kjeldahl stikstof in mg/l uitgedrukt in stikstof in oppervlaktewater',units='mg/l';
   case 'Stikstof in mg/l in oppervlaktewater'                               ,units='mg/l';
   case 'Stikstof in mg/l na filtratie in oppervlaktewater'                  ,units='mg/l';
   case 'Zuurstof in mg/l in oppervlaktewater'                               ,units='mg/l';
   case 'Totaal fosfaat in mg/l in oppervlaktewater'                         ,units='mg/l';
   case 'Totaal fosfaat in mg/l na filtratie in oppervlaktewater'            ,units='mg/l';
   case 'Orthofosfaat in mg/l uitgedrukt in fosfor / na filtratie in oppervlaktewater', units='mg/l';
   case 'Ammonium in mg/l uitgedrukt in stikstof / na filtratie in oppervlaktewater', units='mg/l';
   case 'Nitriet in mg/l uitgedrukt in stikstof / na filtratie in oppervlaktewater', units='mg/l';
   case 'Nitraat in mg/l uitgedrukt in stikstof / na filtratie in oppervlaktewater', units='mg/l';
   case 'Doorzicht in dm in oppervlaktewater'                                ,units='m';
   case 'Silicaat in mg/l uitgedrukt in silicium / na filtratie in oppervlaktewater', units='mg/l';
   case 'Zuurgraad in oppervlaktewater'                                      ,units='pH';
   case 'Opgelost organisch koolstof in mg/l na filtratie in oppervlaktewater',units='mg/l';
   case 'Som nitraat en nitriet in mg/l uitgedrukt in stikstof / na filtratie in oppervlaktewater',units='mg/l';
   case 'Extinctiecoefficient in /m in oppervlaktewater'                     ,units='/m';

   case 'Gem. golfperiode uit spectrale momenten m0+m2 van 30-500 mhz in s in oppervlaktewater', units='s';    
   otherwise, warning(['Units extraction not yet implemented for ',waarnemingssoort]);
   units = '';
end

