%tide_iho class for storing/importing/exporting IHO tidal components
%
% Static methods (GET):
%   obj = from_iho_xml(filename)           -
%   obj = from_t_tide_asc(filename)        - 
%   obj = from_t_tide_tidestruct(filename) - 
%   obj = from_utide_coef(filename)        - 
%
% Object methods (PUT):
%   xml = to_iho_xml(obj,filename)         - to IHO xml file
%   Cmp = to_t_tide_tidestruct(obj)        - struct for running t_predic()
%   Cmp = to_utide_coef(obj)               - struct for running ut_reconstr() WIP
%   ok  = to_nc(obj,filename)              - 
%
% WIP
%   obj = from_nc(filename)                - WIP 
%   ok  = to_t_tide_asc(obj,filename)      - WIP
%
% Example:
%  C = tide_iho(); % generate empty IHO class fields
%
%See also: t_tide, http://www.ukho.gov.uk/AdmiraltyPartners/FGHO/Pages/TidalHarmonics.aspx
%          http://www.iho.int/mtg_docs/com_wg/IHOTC/IHOTC8/UK_HC_Exchange_format.pdf
%          http://www.iho.int/mtg_docs/com_wg/IHOTC/IHOTC8/Product_Spec_for_Exchange_of_HCs.pdf
%          http://www.iho.int/mtg_docs/com_wg/IHOTC/TWLWG%201/TWLWG1_4-3-1.pdf
%          http://tidesandcurrents.noaa.gov/faq2.html

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 TU Delft ; Van Oord
%       Gerben J de Boer <g.j.deboer@tudelft.nl> ; <gerben.deboer@vanoord.com>
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

classdef tide_iho

    properties
        
    % http://www.ukho.gov.uk/AdmiraltyPartners/FGHO/Pages/TidalHarmonics.aspx <xs:element name="Port">
        platform_name    = ''; % removed name 'port' and replaced with Cf conventions 'platform_name'
        country          = ''; % IHO name
        latitude         = []; % dd mm.mmm in xml | decimal degrees in class
        longitude        = []; % dd mm.mmm in xml | decimal degrees in class
        timeZone         = '+00:00'; % maritime convention, e.g. +00:00
        units            = ''; % e.g. m
        observationStart = []; % yyyy-mm-dd HH:MM:SS in xml | datenum in class
        observationEnd   = []; % yyyy-mm-dd HH:MM:SS in xml | datenum in class
        comments         = ''; % e.g. method=t_tide

    % http://www.ukho.gov.uk/AdmiraltyPartners/FGHO/Pages/TidalHarmonics.aspx <xs:element name="Harmonic">
        component_name   = ''; % string
        speed            = []; % in degree/hour
        inferred         = []; % bool
        amplitude        = []; % in units
        phaseAngle       = []; % degree
        xdo              = repmat(' ',[7 0]); % 7-digit string, e.g. 2555555 or BZZZZZZ
     
    % extra, for storing error estimate information: t_tide, Data Assimilation, UTide
        amplitudeError   = []; % <not IHO standard>
        phaseAngleError  = []; % <not IHO standard> 
        SNR              = []; % <not IHO standard> 

    end % properties

    methods (Static = true)
        
        function obj = from_t_tide_asc(fname,varargin)
            %from_t_tide_asc load from t_tide ascii file
            
            obj = tide_iho;
            asc = t_tide_read(fname);

            obj.observationStart = asc.observationStart;
            obj.observationEnd   = asc.observationEnd;            

            obj.units            = asc.units.fmaj;
            obj.component_name   = asc.data.name;
            obj.speed            = asc.data.frequency*360; % [cyc/hr] to [deg/hr]
            obj.amplitude        = asc.data.fmaj;
            obj.phaseAngle       = asc.data.pha;

            obj.amplitudeError   = asc.data.emaj; % <not IHO standard>
            obj.phaseAngleError  = asc.data.epha; % <not IHO standard>
            obj.SNR              = asc.data.snr;  % <not IHO standard>

            obj.comments         = 'method=t_tide';

            obj = setproperty(obj,varargin);
            
        end % function
        
        function   obj = from_iho_xml(fname)
            %from_iho_xml load from IHO xml file            
          
            obj = tide_iho;
            xml = xml_read(fname);

            obj.platform_name    = xml.Port.name;
            obj.country          = xml.Port.country;
            obj.latitude         = xml.Port.position.latitude;
            obj.longitude        = xml.Port.position.longitude;
            obj.timeZone         = xml.Port.timeZone;
            obj.units            = xml.Port.units;
            obj.observationStart = xml.Port.observationStart;
            obj.observationEnd   = xml.Port.observationEnd;
            obj.comments         = xml.Port.comments;

            obj.component_name   = {xml.Port.Harmonic.name}';
            obj.speed            = [xml.Port.Harmonic.speed]'; % keep in [deg/hr]
            obj.amplitude        = [xml.Port.Harmonic.amplitude]';
            obj.phaseAngle       = [xml.Port.Harmonic.phaseAngle]';

            if isfield(xml.Port.Harmonic,'amplitudeError')
            obj.amplitudeError   = [xml.Port.Harmonic.amplitudeError]'; % <not IHO standard>
            end
            if isfield(xml.Port.Harmonic,'phaseAngleError')
            obj.phaseAngleError  = [xml.Port.Harmonic.phaseAngleError]'; % <not IHO standard>
            end
            if isfield(xml.Port.Harmonic,'SNR')
            obj.SNR              = [xml.Port.Harmonic.SNR]'; % <not IHO standard>
            end

            %% parse
            obj.observationStart = time2datenum(obj.observationStart);
            obj.observationEnd   = time2datenum(obj.observationEnd);

            [dd,mm]=strtok(strtrim(obj.latitude));dd=str2num(dd);
            sgn=1;if mm(end)=='S';sgn = -1;end  
            mm = str2num(mm(1:end-1));
            obj.latitude  = (dd + mm/60).*sgn;

            [dd,mm]=strtok(strtrim(obj.longitude));dd=str2num(dd);
            sgn=1;if mm(end)=='W';sgn = -1;end              
            mm = str2num(mm(1:end-1));
            obj.longitude = (dd + mm/60).*sgn;

        end

        function obj = from_t_tide_tidestruct(T)
        %from_tide_tidestruct gmenerate from t_tide tidestruct output structure (in memory)

            obj = tide_iho;

            if isfield(T,'lat')
            obj.latitude         = T.lat;
            end
            %obj.timeZone         = ;
            if isfield(T,'period')
            obj.observationStart = T.period(1);
            end
            if isfield(T,'period')          
            obj.observationEnd   = T.period(2);
            end

            obj.component_name   = cellstr(T.name);
            obj.speed            = 360*T.freq; % [cyc/hr] to [deg/hr]
            obj.amplitude        = T.tidecon(:,1);
            obj.phaseAngle       = T.tidecon(:,3);
            obj.amplitudeError   = T.tidecon(:,2); % <not IHO standard>
            obj.phaseAngleError  = T.tidecon(:,4); % <not IHO standard>

            obj.comments         = 'method=t_tide';
       
        end % function
        
        function obj = from_utide_coef(T)
        %from_tide_tidestruct gmenerate from t_tide tidestruct output structure (in memory)

            obj = tide_iho;

            obj.latitude         = T.aux.lat;
            %obj.timeZone         = ;
            if isfield(T,'period')
            obj.observationStart = T.period(1);
            end
            if isfield(T,'period')          
            obj.observationEnd   = T.period(2);
            end

            obj.component_name   = T.name;
            obj.speed            = 360*T.aux.frq; % [cyc/hr] to [deg/hr]
            obj.amplitude        = T.A;
            obj.phaseAngle       = T.g;
            obj.amplitudeError   = T.A_ci; % <not IHO standard>
            obj.phaseAngleError  = T.g_ci; % <not IHO standard>
            
            obj.comments         = 'method=utide';            

        end % function        
        
    end % methods
    
    methods
    
        function  varargout = to_iho_xml(obj,xmlfile)
            %to_iho_xml save to IHO xml file
            %
            % <xml> = to_iho_xml(obj,<xmlfile>)
            %
            %See also: tide_iho.from_iho_xml
            
            str = '';
            str = [str sprintf('<?xml version="1.0" encoding="UTF-8"?>')];
            str = [str sprintf('<Transfer xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="HC_Schema_V1.xsd">')];
            str = [str sprintf('	<Port>\n')];
            
            % 3.1 Port Name
            % Full port or tidal station name with no abbreviations, this is a mandatory field.

            str = [str sprintf('		<name>%s</name>\n',obj.platform_name)];
            
            % 3.2 Country
            % IHO Country code, this is a mandatory field. 

            str = [str sprintf('		<country>%s</country>\n',obj.country)];
            str = [str sprintf('		<position>\n')];
        
            % 3.3 Position
            % A Latitude and Longitude position of observation station quoted as DDD-MM.MM together 
            % with the correct suffix dependant on the hemisphere (N-S) and the direction from the
            % Greenwich Meridian (E-W), this is a mandatory field.            
            
            lat.dd = floor(abs(obj.latitude ));lat.mm = 60*(abs(obj.latitude) -  lat.dd);if obj.latitude  < 0;lat.sgn = 'S'; else lat.sgn = 'N';end
            lon.dd = floor(abs(obj.longitude));lon.mm = 60*(abs(obj.longitude) - lon.dd);if obj.longitude < 0;lon.sgn = 'W'; else lon.sgn = 'E';end
            
            str = [str sprintf('			<latitude>%s %s%s</latitude>  <!-- %f -->\n',num2str(lat.dd),num2str(lat.mm),lat.sgn,obj.latitude)];  % string: example: -90 27.09S
            str = [str sprintf('			<longitude>%s %s%s</longitude><!-- %f -->\n',num2str(lon.dd),num2str(lon.mm),lon.sgn,obj.longitude)]; % string: example: 109 27W
            str = [str sprintf('		</position>\n')];
            
            % 3.4 Time Zone
            % The difference in hours and minutes to Universal Time (UT) using standard 
            % International Maritime convention (e.g. Greece -0200; Belize +0600), this is a mandatory field.

            str = [str sprintf('		<timeZone>%s</timeZone>\n',obj.timeZone)];
            
            % 3.5 Units
            % The unit of measure used to specify the Amplitude (H), this is a mandatory field.
            
            str = [str sprintf('		<units>%s</units>\n',obj.units)];
            
            % 3.6 Observation
            % The start and end dates of the observation period quoted as YYYY-MM-DD, this is a mandatory field.
            
            str = [str sprintf('		<observationStart>%s</observationStart>\n',datestr(obj.observationStart,'yyyy-mm-dd HH:MM:SS'))]; % date
            str = [str sprintf('		  <observationEnd>%s</observationEnd>\n',    datestr(obj.observationEnd  ,'yyyy-mm-dd HH:MM:SS'))]; % date
            if isempty(obj.comments)
            str = [str sprintf('		<comments/>\n')];
            else
            str = [str sprintf('		<comments>%s</comments>\n',    obj.comments)];
            end

            str = [str sprintf('<!--     ')];
            str = [str sprintf('      %s       '        ,'string')]; % for strings, padding a space is not meaningless
            str = [str sprintf('          %s           '    ,' bool')];
            str = [str sprintf('            %s             ',' degree')];
            str = [str sprintf('           %s            '  ,'       m')];
            str = [str sprintf('       %s        '          ,'  deg/hr')];
            str = [str sprintf('        -->\n')];
            for i=1:length(obj.amplitude)
            str = [str     sprintf('<Harmonic>')];
            str = [str pad(sprintf('<name>%s</name>'        ,strtrim(obj.component_name{i})),18,' '        )]; % for strings, padding a space is not meaningless
            str = [str sprintf('<inferred>%s</inferred>'    ,pad('false'                           ,-5,' '))];
            str = [str sprintf('<speed>%s</speed>'          ,pad(num2str(obj.speed(i) ,'%0.4f'),-8,' '))];
            str = [str sprintf('<amplitude>%s</amplitude>'  ,pad(num2str(obj.amplitude(i) ,'%0.4f'),-8,' '))];
            str = [str sprintf('<phaseAngle>%s</phaseAngle>',pad(num2str(obj.phaseAngle(i),'%0.2f'),-7,' '))];
            
            if ~isempty(obj.amplitudeError)
            str = [str sprintf('<amplitudeError>%s</amplitudeError>',pad(num2str(obj.amplitudeError(i),'%0.4f'),-8,' '))];
            end
            if ~isempty(obj.phaseAngleError)
            str = [str sprintf('<phaseAngleError>%s</phaseAngleError>',pad(num2str(obj.phaseAngleError(i),'%0.3f'),-7,' '))];
            end
            if ~isempty(obj.SNR)
            str = [str sprintf('<SNR>%s</SNR>',pad(num2str(obj.SNR(i),'%0.3f'),-7,' '))];
            end            
            
            str = [str sprintf('</Harmonic>\n')];
            end
            str = [str sprintf('</Port>')];
            str = [str sprintf('</Transfer>')];

            if nargin>1
               savestr(xmlfile,str)
            end

            if nargout>0
            varargout = {str};
            end            
        end

        function    T = to_t_tide_tidestruct(obj)
            %from_t_tide_tidestruct export to t_tide struct to run t_predic
            %
            %   T = to_t_tide_tidestruct(obj)
            %
            %See also: t_predic

            if ~isempty(obj.latitude)
            T.lat           = obj.latitude;
            end
            %obj.timeZone
            if ~isempty(obj.observationStart)
            T.period(1)     = obj.observationStart;
            end
            if ~isempty(obj.observationEnd)         
            T.period(2)     = obj.observationEnd;
            end

            T.name          = char(obj.component_name);
            T.freq          = obj.speed/360; % [deg/hr] back to [cyc/hr]
            T.tidecon(:,1)  = obj.amplitude      ;
            T.tidecon(:,3)  = obj.phaseAngle     ;
            T.tidecon(:,2)  = obj.amplitudeError ; % <not IHO standard>
            T.tidecon(:,4)  = obj.phaseAngleError; % <not IHO standard>
            
        end % function  
        
        function    T = to_utide_coef(obj)
            %to_utide_coef export to t_tide struct to run ut_solv
            %
            %   T = to_t_tide_tidestruct(obj)
            %
            %See also: ut_solv            

            T.aux.lat   = obj.latitude;
            %obj.timeZone         = ;
            if ~isempty(obj.observationStart)
            T.period(1) = obj.observationStart;
            end
            if ~isempty(obj.observationEnd)         
            T.period(2) = obj.observationEnd;
            end

            T.name      = obj.component_name ;
            T.aux.frq   = obj.speed/360      ; % [deg/hr] back to [cyc/hr]
            T.A         = obj.amplitude      ;
            T.g         = obj.phaseAngle     ;
            T.A_ci      = obj.amplitudeError ; % <not IHO standard>
            T.g_ci      = obj.phaseAngleError; % <not IHO standard>
            
            %% ut_reconstr() requires
            T.aux.opt.twodim     = 0;
            T.aux.opt.nodsatlint = 0;
            T.aux.opt.nodsatnone = 0;
            T.aux.opt.gwchlint   = 0;
            T.aux.opt.gwchnone   = 0;
            T.aux.opt.prefilt    = [];
            T.aux.opt.notrend    = 0;
            T.aux.reftime        = mean(T.period);
            T.mean               = 0;
            T.slope              = 0;
            ut_constants = load('ut_constants.mat');
            for j=1:length(T.name)
                T.aux.lind(j,1)=strmatch(T.name{j},ut_constants.const.name);
            end
            disp(['tide_iho.to_utide_coef: default: reftime=',datestr(T.aux.reftime),' and 0=mean/slope/twodim/nodsatlint/nodsatnone/gwchlint/gwchnone/prefilt/notrend'])
            
        end % function         
        
        function ok = to_nc(obj,ncfile)
            %to_nc save to netCDF-CF  file  
            
            OPT.swap = 0;            

            nc.Name   = '/';
            nc.Format = 'classic';

            nc.Attributes(    1) = struct('Name','title'         ,'Value',  'IHO tidal components');
            nc.Attributes(end+1) = struct('Name','institution'   ,'Value',  '');
            nc.Attributes(end+1) = struct('Name','source'        ,'Value',  '');
            nc.Attributes(end+1) = struct('Name','history'       ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_grid_lat_lon_curvilinear.m $ $Id: ncwritetutorial_grid_lat_lon_curvilinear.m 8907 2013-07-10 12:39:16Z boer_g $');
            nc.Attributes(end+1) = struct('Name','references'    ,'Value',  'http://svn.oss.deltares.nl');
            nc.Attributes(end+1) = struct('Name','email'         ,'Value',  '');
            nc.Attributes(end+1) = struct('Name','featureType'   ,'Value',  '');

            nc.Attributes(end+1) = struct('Name','comment'       ,'Value',  '');
            nc.Attributes(end+1) = struct('Name','version'       ,'Value',  '');

            nc.Attributes(end+1) = struct('Name','Conventions'   ,'Value',  'CF-1.9');

            nc.Attributes(end+1) = struct('Name','terms_for_use' ,'Value',  'please specify');
            nc.Attributes(end+1) = struct('Name','disclaimer'    ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

            %% Dimensions   

            nc.Dimensions(    1) = struct('Name', 'frequency'    ,'Length',length(obj.speed));m.f = 1;
            nc.Dimensions(end+1) = struct('Name', 'points'       ,'Length',1);m.xy = length(nc.Dimensions);
            nc.Dimensions(end+1) = struct('Name', 'time'         ,'Length',2);m.t = length(nc.Dimensions);
            nc.Dimensions(end+1) = struct('Name', 'bounds'       ,'Length',2);m.b = length(nc.Dimensions);
            nc.Dimensions(end+1) = struct('Name', 'component_name_length','Length',size(char(obj.component_name),2));m.sc = length(nc.Dimensions);
            nc.Dimensions(end+1) = struct('Name', 'platform_name_length' ,'Length',size(char(obj.platform_name ),2));m.sp = length(nc.Dimensions);  

            %% Coordinates
            % swap variable dimensions following C convention, and mimic agioncmd.ftn90

            M.time         = struct('Name','units'        ,'Value',['days since 1970-01-01 ', obj.timeZone]);
            M.time(end+1)  = struct('Name','calendar'     ,'Value','gregorian');
            M.time(end+1)  = struct('Name','standard_name','Value','time');
            M.time(end+1)  = struct('Name','long_name'    ,'Value','time');
            
            M.n            = struct('Name','standard_name','Value','platform_name');
            M.n(end+1)     = struct('Name','long_name'    ,'Value','platform_name');               

            M.x            = struct('Name','units'        ,'Value','degrees_east');
            M.x(end+1)     = struct('Name','standard_name','Value','longitude');
            M.x(end+1)     = struct('Name','long_name'    ,'Value','longitude');   

            M.y            = struct('Name','units'        ,'Value','degrees_north');
            M.y(end+1)     = struct('Name','standard_name','Value','latitude');
            M.y(end+1)     = struct('Name','long_name'    ,'Value','latitude');

            M.f            = struct('Name','units'        ,'Value','frequency');
            M.f(end+1)     = struct('Name','standard_name','Value','');
            M.f(end+1)     = struct('Name','long_name'    ,'Value','frequency');
            
            M.comp            = struct('Name','long_name'    ,'Value','platform_name');   
            M.comp(end+1)     = struct('Name','standard_name','Value','platform_name');

            nc.Variables(    1) = struct('Name','time'          ,'Datatype','double','Dimensions',nc.Dimensions([m.t     ]),'Attributes',M.time);
            nc.Variables(end+1) = struct('Name','platform_name' ,'Datatype','char'  ,'Dimensions',nc.Dimensions([m.sp    ]),'Attributes',M.n);
            nc.Variables(end+1) = struct('Name','longitude'     ,'Datatype','double','Dimensions',nc.Dimensions([m.xy    ]),'Attributes',M.x);
            nc.Variables(end+1) = struct('Name','latitude'      ,'Datatype','double','Dimensions',nc.Dimensions([m.xy    ]),'Attributes',M.y);  
            nc.Variables(end+1) = struct('Name','speed'         ,'Datatype','double','Dimensions',nc.Dimensions([m.f     ]),'Attributes',M.f);  
            nc.Variables(end+1) = struct('Name','component_name','Datatype','char'  ,'Dimensions',nc.Dimensions([m.sc m.f]),'Attributes',M.comp);  
            
            %% Variables            

            objnames = {'amplitude','amplitudeError','phaseAngle','phaseAngleError','SNR'};% TODO,'fmin','emin','finc','einc'};   
            fldnames = {'fmaj','emaj','pha','epha','snr'};% TODO,'fmin','emin','finc','einc'};   
            lngnames = {'amplitude','amplitudeError','phaseAngle','phaseAngleError','Signal to Noise Ratio'};
            units    = {obj.units,obj.units,'degree','degree','1'};

            for ivar=1:length(objnames)

                ncname = objnames{ivar}; % fldnames{ivar};

                M.(ncname)(    1) = struct('Name','long_name'     ,'Value',lngnames{ivar});
                M.(ncname)(end+1) = struct('Name','units'         ,'Value',units{ivar});
                M.(ncname)(end+1) = struct('Name','standard_name' ,'Value','');
                M.(ncname)(end+1) = struct('Name','coordinates'   ,'Value','longitude latitude');
                M.(ncname)(end+1) = struct('Name','cell_methods'  ,'Value','time: period area: point');
                M.(ncname)(end+1) = struct('Name','t_tide_name'   ,'Value',fldnames{ivar});

                if OPT.swap
                nc.Variables(end+1) = struct('Name',ncname,'Datatype','double','Dimensions',nc.Dimensions([m.f m.xy]),'Attributes',M.(ncname));
                else
                nc.Variables(end+1) = struct('Name',ncname,'Datatype','double','Dimensions',nc.Dimensions([m.xy m.f]),'Attributes',M.(ncname));
                end

            end   

            %% Create file      

            if exist(ncfile,'file')
               disp(['File already exist, press enter to replace it, press CTRL_C to quit: ''',ncfile,''''])
               pause
               delete(ncfile)
            end
            ncwriteschema(ncfile, nc);
            ncdisp(ncfile)
            nc_dump(ncfile,'',[filepathstrname(ncfile),'.cdl'])

            %% write
            ncwrite(ncfile,'time'            ,[obj.observationStart obj.observationEnd] - datenum(1970,0,0))
            ncwrite(ncfile,'platform_name'   ,char(obj.platform_name));
            ncwrite(ncfile,'longitude'       ,obj.longitude);
            ncwrite(ncfile,'latitude'        ,obj.latitude); 
            ncwrite(ncfile,'speed'           ,obj.speed); 
            ncwrite(ncfile,'component_name'  ,char(obj.component_name)'); 
            ncwrite(ncfile,'amplitude'       ,obj.amplitude');     
            ncwrite(ncfile,'amplitudeError'  ,obj.amplitudeError');    
            ncwrite(ncfile,'phaseAngle'      ,obj.phaseAngle');     
            ncwrite(ncfile,'phaseAngleError' ,obj.phaseAngleError');     

        end % function
        
        function    ok = to_t_tide_asc(obj,ascfile)
            %to_t_tide_asc save to t_tide ascii file    

            error('not implemented')            
        end % function
      
        function    tidestruct = from_nc(obj)
            %from_nc load from netCDF-CF file    

            error('not implemented')            
        end % function     
        
    end % methods
    
end % classdef
