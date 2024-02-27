function varargout = odv_read(fullfilename,varargin)
%ODVREAD   read ascii file in ODV format into ODV struct
%
%   D = odvread(fname,<keyword,value>)
%
% loads ASCII file in Ocean Data Viewer (ODV) format into struct D.
% D.cast=1 for profile data (> ODVPLOT_CAST)
% D.cast=0 for point time series or trajectories (> ODVPLOT_OVERVIEW)
%
% ODV is one of the standard file formats of 
% <a href="http://www.SeaDataNet.org">www.SeaDataNet.org</a> of which <a href="http://www.nodc.nl">www.nodc.nl</a> is a member.
%
% ODV files contain the following information:
%
% +---------------------------------------------+----------------------------------------
% | ## Metavariables ########################## | ## Values ############################
% +---------------------------------------------+----------------------------------------
% | Cruise                                      | Cruise, expedition, or instrument name
% | Station                                     | Unique station identifier
% | Type                                        | B for bottle or 
% |                                             | C for CTD, 
% |                                             | XBT or stations with >250 samples
% | yyyy-mm-ddThh:mm:ss.sss                     | Date and time of station (instrument at depth)
% | Longitude [degrees_east]                    | Longitude of station (instrument at depth)
% | Latitude [degrees_north]                    | Latitude of station (instrument at depth)
% | Bot. Depth [m]                              | Bottom depth of station
% | Unlimited number of other metavariables     | Text or numeric; user defined text length 
% |                                             | or 1 to 8 byte integer or floating point numbers
% +---------------------------------------------+----------------------------------------
% | ## Collection Variables ################### | ## Comment ############################
% +---------------------------------------------+----------------------------------------
% | Depth or pressure in water column, ice core | 
% | core, sediment core, or soil; elevation or  | To be used as primary variable
% +---------------------------------------------+----------------------------------------
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a> (Ocean Data Viewer)
%See also: OceanDataView, python module "openearthtools.io.pyodv"

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% $Id: odvread.m 10615 2014-04-28 10:03:00Z boer_g $
% $Date: 2014-04-28 18:03:00 +0800 (Mon, 28 Apr 2014) $
% $Author: boer_g $
% $Revision: 10615 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/odvread.m $
% $Keywords:$

% TO DO: file #Processing 328/764: result_CTDCAST_75___36-260409# is slow, find out why

% 3.1.1 Metavariables
% ODV requires availability of some types of metadata for its basic operation. The geo-graphic location of a station, for instance, must be known to be able to plot the station in the station map. Date and time of observation, or the names of the station and cruise (or expedition) it belongs to are needed to fully identify the station and to be able to apply station selection filters that only allow stations of given name patterns are from specific time periods. Because of this fundamental importance, ODV defines a set of mandatory metavariables providing name, location and timing information of a given station (see Table 3-3). Other suggested metavariables are optional, and still others may be added by the user, as necessary. Metavariable values can be either text or numeric, and the respective byte lengths can be set by the user. The value type (text or numeric) of the mandatory meta-variables may not be changed, while the byte length may. As an example, the data type of the longitude and latitude metavariables may be set as 8 bytes double precision to accommodate better than cm-scale precision of station location. Metavariables with values in the ranges [0 to 255] or [-32,768 to 32,767] may be represented by 1 or 2 byte integers, respectively, to conserve storage space.

% Table 3-3: Mandatory and optional ODV metavariables.
% ---------------------------------------------------------------------------------------------------------
% Metavariable                                                                          % Recommended Label
% ---------------------------------------------------------------------------------------------------------
% Mandatory
%    Cruise label (text).                                                               %    Cruise
%    Station label (text).                                                              %    Station
%    Station type (text).                                                               %    Type
%    Date and time of observation (numeric year, month, day, hour, minute and seconds). %    yyyy-mm-ddThh:mm:ss.sss
%    Longitude (numeric).                                                               %    Longitude [degrees_east]
%    Latitude (numeric).                                                                %    Latitude [degrees_north]
% ---------------------------------------------------------------------------------------------------------
% Optional
%    SeaDataNet station identifier (text).                                              %    LOCAL_CDI_ID
%    SeaDataNet institution identifier (numeric).                                       %    EDMO_code
%    Bottom depth at station, or instrument depth (numeric).                            %    Bot. Depth [m]
%    ..
%    Additional user defined metavariables (text or numeric).
% ---------------------------------------------------------------------------------------------------------

% 15.6 Making Cruise Maps
% You can create full-page, high quality stations maps showing the currently selected sta-tions of the open data collection using View>Window Layout>Layout Templates>Full Screen Map. Station maps may also be produced if you only have access to the station metadata (e.g., station postions, dates, etc.), but the actual station data are unaccessible. Here is how to proceed:
% * In an empty directory on your disk create an ASCII file that contains the longi-tude, latitude coordinates of the stations or way-points of your track. This file should have a descriptive name (e.g., CruiseTrack_xxx.txt, where xxx represents the name of your cruise) and it should comply with the generic ODV spreadsheet format specifications.
% As first line of the file use the following header line (note that columns are TAB sepa-rated): Cruise Station Type yyyy-mm-ddThh:mm Longitude [degrees_east] Latitude [degrees_north] Bot. Depth [m] Dummy1 Dummy2 Immediately following the header line, add one data line for each station or cruise track node and provide the following information for the respective station or node:
%
% ---------------------------------------------------------------------------------------------------------
% Cruise                    % The name of the cruise
% Station                   % Station label or number
% Type                      %"B"
% yyyy-mm-ddThh:mm          % Station date and time
% Longitude [degrees_east]  % Decimal longitude of station
% Latitude [degrees_north]  % Decimal latitude of station
% Bot. Depth [m]            % Bottom depth at station location or "0"
% Dummy1                    % "0"
% Dummy2                    % "0"
% ---------------------------------------------------------------------------------------------------------

% 17.3 Generic ODV Spreadsheet Format
% The ODV generic spreadsheet format is the recommended format for exchange of data beween data producers and data users. The generic spreadsheet format allows auto-matic import of data into ODV collections, not requiring any user interaction. ODV also uses the generic spreadsheet format when exporting data from collections, and the ex-ported datasets may easily be re-imported into the same or a different collection, possi-bly after editing and modifying the data in the file. Exporting data from the open collec-tion into a generic spreadsheet file is done via the Export>ODV Spreadsheet option. ODV generic spreadsheet files use the ASCII encoding, and the preferred file extension is .txt. Station metadata and data are provided in separate columns, where metadata and data columns can be in arbitrary order. Every metadata and data column may have an optional quality flag column. A quality flag column may appear anywhere after the metadata or data column it belongs to. Quality flag values may be in any one of the sup-ported quality flag schemes (see Table 17-5). The total number of columns in the file is unlimited. All non-comment lines (see below) in the file must have the same number of columns. Individual columns are separated by TAB or semicolon ; . Typically, ODV spreadsheet files hold the data of many stations from many cruises. The number of lines in a file, as well as the length of individual lines is unlimited. There are three types of lines in ODV generic spreadsheet files: (1) comment lines, (2) the column labels line, and (3) data lines.

% 17.3.1 Comment Lines
% Comment lines start with two slashes // as first two characters of the line and may con-tain arbitrary text in free format. Comment lines may, in principle, appear anywhere in the file, most commonly, however, they are placed at the beginning of the file and con-tain descriptions of the data, information about the originator or definitions of the va-riables included in the file. Comment lines are optional. Comment lines may be used to carry structured information that may be exploitet by ODV or other software. Examples are the //SDN_parameter_mapping block employed by the SeaDataNet project, and containing references to variable definitions in official pa-rameter dictionaries, or the //<attribute_name> lines defined by ODV, containing values for given attribute names. The currently defined attribute names are summarized in Table 15-6. Structured comment lines may only appear before the column labels line or the first data line.

% 17.3.2 Column Labels
% There has to be exactly one line containing the labels of the columns. This column labels line must always be present, it must appear before any data line and it must be the first non-comment line in the file.
% ODV generic spreadsheet files must provide columns for all mandatory metavariables (see Table 3-3), and the following labels must be used exactly as given as column labels: Cruise, Station, Type, one of the supported date/time formats, Longitude [degrees_east], Latitude [degrees_north], Bot. Depth [m]. The recommended date/time format is ISO 8601, which combines date and time as yyyy-mm-ddThh:mm:ss.sss in a single column. The labels Lon (°E) and Lat (°N) for longitude and latitude are still supported for back-ward compatibility.

   OPT.delimiter     = char(9);% columns are TAB sepa-rated [ODV manual section 15.6]
   OPT.variablesonly = 1; % remove units from variables
   OPT.method        = 'textscan'; %'fgetl'; % 'textscan';
   OPT.resolve       = 1; % speed up by not resolving when loading multipel files, odv_merge wll resolve
   OPT.CDI_record_id = {nan};
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:});

   D = struct('odv_name'         ,'',...
              'standard_name'    ,'','units'      ,'',...
              'local_name'       ,'','local_units','',...
              'sdn_standard_name','','sdn_units'  ,'',...
              'sdn_long_name'    ,'',...% 'sdn_units_long_name'    ,'',...
              'sdn_description'  ,'',...% 'sdn_units_description'  ,'',...
              'data',''); % determine command line order

  [D.file.path D.file.name D.file.ext] = fileparts(fullfilename);
   D.file.fullfilename = fullfilename;

   iostat        = 1;
   
%% check for file existence (1)                

   tmp = dir(fullfilename);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fullfilename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      D.file.date  = tmp.date;
      D.file.bytes = tmp.bytes;
                  
   
%% check for file opening (2)

      filenameshort = filename(D.file.name);
      
      fid       = fopen  (fullfilename,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fullfilename])
         else
            iostat = -2;
         end
      
      elseif fid > 2
      
%% read file line by line

         %try

         %% I) Header lines (//)
         %     Extract SDN vocab codes
            
            iSDN  = 0;
            SDN   = false;
            rec   = fgetl(fid);
            iline = 0;
            while (strcmpi(rec(1:2),'//'))
               iline                  = iline + 1;
               D.lines.header{iline}  = rec;
               rec                    = fgetl(fid);
               
               if any(strfind(D.lines.header{iline},'SDN_parameter_mapping'))
                  SDN  = true;
                  iSDN = 9; % first 9 parameters are meta-info
                  
                  D.sdn_long_name{1} = '';D.sdn_standard_name{1} ='';D.sdn_units{1} = '';D.odv_name{1} = '<subject>SDN:LOCAL:Cruise</subject>';
                  D.sdn_long_name{2} = '';D.sdn_standard_name{2} ='';D.sdn_units{2} = '';D.odv_name{2} = '<subject>SDN:LOCAL:Station</subject>';
                  D.sdn_long_name{3} = '';D.sdn_standard_name{3} ='';D.sdn_units{3} = '';D.odv_name{3} = '<subject>SDN:LOCAL:Type</subject>';
                  D.sdn_long_name{4} = '';D.sdn_standard_name{4} ='';D.sdn_units{4} = '';D.odv_name{4} = '<subject>SDN:LOCAL:yyyy-mm-ddThh:mm:ss.sss</subject>';
                  D.sdn_long_name{5} = '';D.sdn_standard_name{5} ='';D.sdn_units{5} = '';D.odv_name{5} = '<subject>SDN:LOCAL:Longitude [degrees_east]</subject>';
                  D.sdn_long_name{6} = '';D.sdn_standard_name{6} ='';D.sdn_units{6} = '';D.odv_name{6} = '<subject>SDN:LOCAL:Latitude [degrees_north]</subject>';
                  D.sdn_long_name{7} = '';D.sdn_standard_name{7} ='';D.sdn_units{7} = '';D.odv_name{7} = '<subject>SDN:LOCAL:LOCAL_CDI_ID</subject>';
                  D.sdn_long_name{8} = '';D.sdn_standard_name{8} ='';D.sdn_units{8} = '';D.odv_name{8} = '<subject>SDN:LOCAL:EDMO_code</subject>';
                  D.sdn_long_name{9} = '';D.sdn_standard_name{9} ='';D.sdn_units{9} = '';D.odv_name{9} = '<subject>SDN:LOCAL:Bot. Depth [m]</subject>';
                  
                  D.standard_name{1} = 'cruise_id'; D.units{1} = '';
                  D.standard_name{2} = 'station_id';D.units{2} = '';
                  D.standard_name{3} = '';          D.units{3} = '';
                  D.standard_name{4} = 'time';      D.units{4} = '';
                  D.standard_name{5} = 'longitude'; D.units{5} = 'degrees_east';
                  D.standard_name{6} = 'latitude';  D.units{6} = 'degrees_north';
                  D.standard_name{7} = '';          D.units{7} = '';
                  D.standard_name{8} = '';          D.units{8} = '';
                  D.standard_name{9} = '';          D.units{9} = 'meter';

               end
               
               if SDN
                  if any(strfind(D.lines.header{iline},'<subject>SDN:LOCAL'))
                  
                     iSDN = iSDN + 2;
                     
                  %% get names accoridng to different vocabs (CF, SDN, local,...)

                     D.odv_name{iSDN-1} =  D.lines.header{iline}(3:end);
                     D.odv_name{iSDN  } =  D.lines.header{iline}(3:end); % QV columns
                     
                     if ~OPT.resolve
                    [dummy,D.sdn_standard_name{iSDN-1},dummy] =  sdn_parameter_mapping_parse(D.lines.header{iline});
                    [dummy,D.sdn_standard_name{iSDN  },dummy] =  sdn_parameter_mapping_parse(D.lines.header{iline}); % QV columns
                     D.sdn_long_name{iSDN-1} =  '';
                     D.sdn_long_name{iSDN  } =  '';
                     D.sdn_units    {iSDN-1} =  '';
                     D.sdn_units    {iSDN  } =  '';
                     else
                    [dummy,D.sdn_standard_name{iSDN-1},dummy,q,u] =  sdn_parameter_mapping_parse(D.lines.header{iline});
                    [dummy,D.sdn_standard_name{iSDN  },dummy,q,u] =  sdn_parameter_mapping_parse(D.lines.header{iline}); % QV columns
                     D.sdn_long_name{iSDN-1} =  q;
                     D.sdn_long_name{iSDN  } =  q;
                     D.sdn_units    {iSDN-1} =  u;
                     D.sdn_units    {iSDN  } =  u;
                     end

                   %[standard_name,units]=sdn2cf(D.sdn_standard_name{iSDN});
                     standard_name = 'sdn2cf(sdn_standard_name) # TO DO';
                     units         = 'sdn2cf(sdn_units) # TO DO';
                     D.standard_name{iSDN-1} =  standard_name;
                     D.standard_name{iSDN  } =  standard_name;
                     D.units        {iSDN-1} =  units;
                     D.units        {iSDN  } =  units;
                     
                  end
               end
               
            end
            
         %% II) Column labels (variables)

            D.lines.column_labels = rec;
            
            ivar = 0;
            [variable,rec]    = strtok(rec,OPT.delimiter);
            while ~isempty(variable)
               ivar               = ivar + 1;
               D.local_name{ivar} = variable;
               [variable,rec]     = strtok(rec,OPT.delimiter);
            end
            
            nvar = length( D.local_name);
            
         %% II) Units
            
            for ivar=1:length(D.local_name)
               brack1            = strfind(D.local_name{ivar},'[');
               brack2            = strfind(D.local_name{ivar},']');
               D.local_units{ivar}     = D.local_name{ivar}([brack1+1:brack2-1]);
               % remove units AFTER extracting units
               if OPT.variablesonly
                if ~isempty(brack1)
                 D.local_name{ivar} = strtrim(D.local_name{ivar}([1:brack1-1]));
                end
               end
            end

         %% Find column index of mandarory variables

            D.index.cruise                 = find(strcmpi(D.local_name,'cruise'));
            D.index.station                = find(strcmpi(D.local_name,'Station'));
            D.index.type                   = find(strcmpi(D.local_name,'type'));
            D.index.time                   = find(strcmpi(D.local_name,'yyyy-mm-ddThh:mm:ss.sss'));
            if OPT.variablesonly
            D.index.latitude               = find(strcmpi(D.local_name,'Latitude'));
            D.index.longitude              = find(strcmpi(D.local_name,'Longitude'));
            D.index.bot_depth              = find(strcmpi(D.local_name,'Bot. Depth')); % often there as implicit z
            else
            D.index.latitude               = find(strcmpi(D.local_name,'Latitude [degrees_north]'));
            D.index.longitude              = find(strcmpi(D.local_name,'Longitude [degrees_east]'));
            D.index.bot_depth              = find(strcmpi(D.local_name,'Bot. Depth [m]'));
            end
            D.index.LOCAL_CDI_ID           = find(strcmpi(D.local_name,'LOCAL_CDI_ID'));
            D.index.EDMO_code              = find(strcmpi(D.local_name,'EDMO_code'));
            
            D.institution = 'EDMO_code2long_name(EDMO_code) # TO DO';
            
         %% III) Data lines
                idat   = 0;
            if strcmpi(OPT.method,'fgetl')
               D.data = cell(1,nvar);
               % TO DO: scan first for # data lines, to preallocate  D.data??
               while 1
                   rec = fgetl(fid);
                   if ~ischar(rec), break, end
                   idat = idat + 1;
                   sep = [0 strfind(rec,char(9)) (length(rec)+1)]; % tab-delimited (char(9)) with empty values possible between tabs
               end
            elseif strcmpi(OPT.method,'textscan')
               fmt    = repmat('%s',[1 nvar]);
               D.data = textscan(fid,fmt,'Delimiter',char(9));
               idat   = length(D.data{1});
            end
            
         %% some (like TNO) leave out rest of column when identical to first column elements
         
            for ivar=1:nvar
               for idat=1:length(D.data{ivar})
                  if isempty(D.data{ivar}{idat})
                     D.data{ivar}{idat} = D.data{ivar}{1}; % TNO leaves out rest of column when identical to first column elements
                  end
               end
            end
            
            
            for idat=[5 6    8 9:length(D.data)]; % skip first columns [1:4 7], they are chars anyway [Cruise	Station	Type	yyyy-mm-ddThh:mm:ss.sss ...LOCAL_CDI_ID]
               
               % make a double array, and make sure intermediate missing empty values are nan
               % str2num makes '' empty, so cell2mat beccomes too short, whereas
               % str2double makes '' a nan, so cell2mat has the correct shape.
               array = cell2mat(cellfun(@str2double,(D.data{idat}),'UniformOutput',0));

               % test whether raw data was 100% numeric or 100% empty: 
               % both will be considered numeric, mixed columsn are considered char
               if all(cellfun(@isempty,D.data{idat}))
                  D.data{idat} = nan(length(D.data{idat}),1); % mind orientation same as array
               elseif ~all(isnan(array))
                  D.data{idat} = array;
               end
               
            end
            
            % Turn rawdata into 1D cell
            
            if idat == 0

               disp(['Found empty file: ',D.file.name])

               D.data                     = {[]};
               D.metadata.cruise                 = {['']}; % {} gives error with char
               D.metadata.station                = {['']}; % {} gives error with char
               D.metadata.type                   = {['']}; % {} gives error with char
               D.metadata.datenum                =  nan;   % datestr gives error on NaN,Inf, while 0 not handy
               D.metadata.latitude               =  nan;
               D.metadata.longitude              =  nan;
               D.metadata.bot_depth              =  nan;

            else

               D.metadata.cruise                 =              D.data{D.index.cruise   };
               D.metadata.station                =              D.data{D.index.station  };
               D.metadata.type                   =              D.data{D.index.type     };
               D.metadata.datenum                = datenum(char(D.data{D.index.time     }),'yyyy-mm-ddTHH:MM:SS');
               D.metadata.latitude               =              D.data{D.index.latitude };
               D.metadata.longitude              =              D.data{D.index.longitude};
               D.metadata.bot_depth              =              D.data{D.index.bot_depth};
               D.LOCAL_CDI_ID                    =              D.data{D.index.LOCAL_CDI_ID }{1};  % unique string for ODV file
               D.EDMO_code                       =              D.data{D.index.EDMO_code    }(1);  % unique number for ODV file

            end

         %catch
         % 
         %   if nargout==1
         %      error(['Error reading file: ',D.file.name])
         %   else
         %      iostat = -3;
         %   end      
         %
         %end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
%% Get extraction info: 1 value per cast (and check for uniqueness: i.e. are there time-consuming, sidewards-drifting casts?)

   [D.cruise      ]   = unique(D.metadata.cruise      );if length(D.cruise      ) > 1;error('no unique value: cruise      ');end
   [D.type        ]   = unique(D.metadata.type        );if length(D.type        ) > 1;error('no unique value: type        ');end
    D.file.name       = char(D.file.name   );		      
    D.cruise          = char(D.cruise      );		      
    D.type            = char(D.type        );		      

   [station  ,ind1] = unique(D.metadata.station     );if length(station  ) == 1;D.metadata.station   = station  ;end 
   [ddatenum ,ind2] = unique(D.metadata.datenum     );if length(ddatenum ) == 1;D.metadata.datenum   = ddatenum ;end
   [latitude ,ind3] = unique(D.metadata.latitude    );if length(latitude ) == 1;D.metadata.latitude  = latitude ;end
   [longitude,ind4] = unique(D.metadata.longitude   );if length(longitude) == 1;D.metadata.longitude = longitude;end
   [bot_depth,ind5] = unique(D.metadata.bot_depth   );if length(bot_depth) == 1;D.metadata.bot_depth = bot_depth;end

   if length(ind1)==1 & ...
      length(ind2)==1 & ...
      length(ind3)==1 & ...
      length(ind4)==1 & ...
      length(ind5)==1 & ...
    ~(length(D.data{1})==1)
      D.cast    = 1;
      else
      D.cast    = 0;
   end
   
   if length(D.metadata.station)==1
      D.station = char(D.metadata.station);
   end
   
   D.CDI_record_id = {OPT.CDI_record_id};

%% Output

   %D.read.with   = '$Id: odvread.m 10615 2014-04-28 10:03:00Z boer_g $';
   %D.read.at     = datestr(now);
   %D.read.status = iostat;

   if nargout==1
      varargout  = {D};
   elseif nargout==2
      varargout  = {D,iostat};
   end

% EOF
