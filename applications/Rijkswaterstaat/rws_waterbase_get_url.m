function varargout = rws_waterbase_get_url(varargin);
%RWS_WATERBASE_GET_URL   load data from <a href="http://live.waterbase.nl">live.waterbase.nl</a>
%
% Download data from the <a href="http://live.waterbase.nl">live.waterbase.nl</a> website for one specified
% substance at one or more specified locations during one specified
% year. All available data are written to a specified ASCII file.
%
% Without input arguments a GUI is launched.
%
%    rws_waterbase_get_url(<Code>    ) % or
%    rws_waterbase_get_url(<FullName>) % NOTE: NOT CodeName
%
% where Code or FullName are the unique DONAR numeric or string
% substance identifier respectively (e.g. 22 and 
% 'Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater').
% Use RWS_WATERBASE_GET_SUBSTANCES to get all Codes.
%
%    rws_waterbase_get_url( Code     ,<ID>)
%    rws_waterbase_get_url( FullName ,<ID>)
%
% where ID is  the unique DONAR string location identifier (e.g. 'AUKFPFM').
% Use RWS_WATERBASE_GET_LOCATIONS to get all IDs.
%
%    rws_waterbase_get_url( Code     ,ID,<datenum>)
%    rws_waterbase_get_url( FullName ,ID,<datenum>)
%
% where datenum is a 2 element vector with teh start and end time
% of the query in datenumbers (e.g. datenum([1961 2008],1,1)).
%
%    rws_waterbase_get_url( Code     ,ID,datenum,<FileName>)
%    rws_waterbase_get_url( FullName ,ID,datenum,<FileName>)
%
% where FileName is the name of the output file. When it is a directory
% the FileName will be chosen as DONAR does (with extension '.txt').
%
%    name = rws_waterbase_get_url(...) returns the local filename to which the data was written.
%
% Example:
%
%    rws_waterbase_get_url(22,'AUKFPFM',datenum([1961 2008],1,1),pwd)
%
% See also: <a href="http://live.waterbase.nl">live.waterbase.nl</a>, rijkswaterstaat,
%           <a href="http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.html">netCDF cache of waterbase</a>
%           rws_waterbase_get_substances, rws_waterbase_get_locations,  rws_waterbase_read

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Y. Friocourt
%
%       yann.friocourt@deltares.nl
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%   --------------------------------------------------------------------

% $Id: rws_waterbase_get_url.m 13206 2017-03-09 14:07:43Z kaaij $
% $Date: 2017-03-09 22:07:43 +0800 (Thu, 09 Mar 2017) $
% $Author: kaaij $
% $Revision: 13206 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase_get_url.m $
% 2009 mar 19: allow for selection of multiple years (all years between 1st and last) [Yann Friocourt]

% 2009 jan 27: moved pieces to separate functions getWaterbaseData_locations and getWaterbaseData_substances [Gerben de Boer]
% 2009 jan 27: allow for argument input of all chocie, to allow for batch running [Gerben de Boer]
% 2009 jan 27: use urlwrite for query of one location, as urlwrite often returns status=0 somehow [Gerben de Boer]
% 2009 apr 01: added 'exact' to strmatch to prevent finding more statiosn with similar subnames (e.g. MOOK and MOOKHVN)

%% TO DO: return url as argument used to get data

%% Substance names

   OPT.strmatch = 'exact';
   OPT.version  = 2; % 1 is before summer 2009, 2 is after mid dec 2009
   OPT.baseurl  = 'http://live.waterbase.nl';

%% Substance names
   Substance = [];
   while isempty(Substance)
      Substance = rws_waterbase_get_substances;
      if isempty(Substance)
      fprintf(2,[OPT.baseurl,': Online source not available. Trying again to get list of: Substances']);
      pause(5)
      end
   end
  %Substance = rws_waterbase_get_substances_csv('rws_waterbase_substances.csv');

%% Select substance name

   if nargin>0
      indSub = varargin{1};
      if    isnumeric(indSub);indSub = find    (indSub==Substance.Code    );
      else ~isnumeric(indSub);indSub = strmatch(indSub, Substance.FullName);
      end
      ok        = 1;
   else
      [indSub, ok] = listdlg('ListString', Substance.FullName, .....
                          'SelectionMode', 'single', ...
                           'PromptString', 'Select the substance to download', ....
                                   'Name', 'Selection of substance',...
                               'ListSize', [500, 300]);
      if (ok == 0);OutputName = [];return;end
   end

   disp(['message: rws_waterbase_get_url: Substance # ',num2str(indSub           ,'%0.3d'),': ',...
                                                           num2str(Substance.Code(indSub),'%0.3d'),' "',...
                                                                   Substance.FullName{indSub},'"'])

%% Get pre-defined location names

   if nargin>1
      if iscell(varargin{2})
          indLoc  = varargin{2}{1};
          LOC     = varargin{2}{2};
      else
          indLoc = varargin{2};
          LOC = [];
          while isempty(LOC)
             LOC = rws_waterbase_get_locations(Substance.Code(indSub),Substance.CodeName{indSub});
             if isempty(LOC)
             fprintf(2,[OPT.baseurl,' failed. Trying again to get list of: Stations']);
             pause(5)
             end
          end      
      end
      if   ~isnumeric(indLoc);
          indLoc = strmatch(indLoc, LOC.ID, OPT.strmatch);
      end
      ok     = 1;

%% Select Location names

   else
      LOC = [];
      while isempty(LOC)
         LOC = rws_waterbase_get_locations(Substance.Code(indSub),Substance.CodeName{indSub});
         if isempty(LOC)
         fprintf(2,[OPT.baseurl,' failed. Trying again to get list of: Stations']);
         pause(5)
         end
      end
      [indLoc, ok] = listdlg('ListString', LOC.FullName, ...
                          'SelectionMode', 'multiple', ...
                           'InitialValue', [1:length(LOC.FullName)], ...
                           'PromptString', 'Select the locations', ....
                                   'Name', 'Selection of locations')
      if (ok == 0);OutputName = [];return;end
   end

   if length(indLoc)>1
   disp(['message: rws_waterbase_get_url: Location    ',num2str(length(indLoc),'%0.3d'),'x: #',num2str(indLoc(:)','%0.3d,')])
   else
   disp(['message: rws_waterbase_get_url: Location  # ',num2str(indLoc,'%0.3d'),': ',LOC.ID{indLoc},' "',LOC.FullName{indLoc},'"'])
   end

%% Times

   if nargin>2
      indDate   = varargin{3};
      startdate = [datestr(indDate(1),'yyyymmddHHMM')]; %,'01010000'];
      enddate   = [datestr(indDate(2),'yyyymmddHHMM')]; %,'12312359'];
      ok        = 1;
   else
      ListYear  = '1961';
      for iYear = 1962:str2num(datestr(date,'yyyy'))
          ListYear = strvcat(ListYear, sprintf('%d', iYear));
      end
      ListYear  = cellstr(ListYear);

      [indDate, ok] = listdlg('ListString', ListYear, ...
                           'SelectionMode', 'multiple', ...
                            'InitialValue', [length(ListYear)], ...
                            'PromptString', 'Select the year', ....
                                    'Name', 'Selection of year');

      if (ok == 0)
         OutputName = [];
         return;
      end
      startdate = [ListYear{min(indDate)} '01010000'];
      enddate   = [ListYear{max(indDate)} '12312359'];
   end

   disp(['message: rws_waterbase_get_url: startdate        ',startdate]);
   disp(['message: rws_waterbase_get_url: enddate          ',enddate]);

%% TO DO on filename: make sure user can only select directory and not file name, as locationcode is only in automatic filename !!

   if nargin>3
      indName  = varargin{4};
      if exist(indName)==7
         FilePath = indName;
        %FileName = ['id',num2str(Substance.Code(indSub)),'-',LOC.ID{indLoc(1)},'-',startdate,'-',enddate,'.txt'];
         FileName = ['id',num2str(Substance.Code(indSub)),'-',LOC.ID{indLoc(1)},'.txt'];
      else
         [FilePath,FileName,EXT] = fileparts(indName);
      end
   else
      [FileName, FilePath] = uiputfile('*.txt','Save data');
      if (isequal(FileName, 0));return;OutputName = [];end
   end

   disp(['message: rws_waterbase_get_url: file             ',fullfile(FilePath,FileName)]);
   
%% get data = f(Substance.Code, LOC.ID, startdate, enddate

   OutputName    = fullfile(FilePath,FileName);
   OutputNameUrl = fullfile(FilePath,[filename(FileName),'.url']);

% DONE save *.url file ?
% DONE remove query datelims from OutputName

%% Directly write file returned for one location

   if length(indLoc)==1

      iLoc = 1;

      if OPT.version==1
      urlName = [OPT.baseurl,'/Sites/waterbase/wbGETDATA.xitng?ggt=id' ...
             sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
          startdate '&loc=' LOC.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];
          
      elseif OPT.version==2

      urlName = [OPT.baseurl,'/wswaterbase/cgi-bin/wbGETDATA?ggt=id' ...
             sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
          startdate '&loc=' LOC.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];

     end

      %disp(urlName)
      status=0;
      while status==0
          [s status] = urlwrite([urlName],OutputName);

          if (status == 0)
            disp([OPT.baseurl,': Online source not available. Trying again to get ',Substance.FullName{indSub},' at ',Substance.Code(indSub)]);
            pause(5)
          else
            fidurl = fopen(OutputNameUrl, 'w+');
            fprintf(fidurl,'[InternetShortcut]\r\n'); % window eol (as *.url is IE thing)
            fprintf(fidurl,'URL=%s',urlName);
            fclose(fidurl);
            % TO DO add time of last update
          end
      end
   else

%% Pad multiple files returned for multiple locations

      h = waitbar(0,'Downloading data...');

      fid = fopen(OutputName, 'w+');
      for iLoc = 1:length(indLoc)

            urlName = [OPT.baseurl,'/Sites/waterbase/wbGETDATA.xitng?ggt=id' ...
                   sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
                startdate '&loc=' LOC.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];

            disp(urlName)
            
            [s status] = urlread([urlName]);
            if (status == 0)
              disp([OPT.baseurl,' may be offline or you are not connected to the internet','Online source not available']);
              close(h);
              return;
            end
            ind    = regexp(s, '\n');
            nLines = length(ind);
            if (iLoc == 1)
             for iLine = 1:6
              fprintf(fid, '%s', s(ind(iLine):ind(iLine+1)-1));
             end
            end
            if (length(regexp(s, 'Geen data beschikbaar')) == 0)
              for iLine = 7:nLines-1
                if (length(s(ind(iLine):ind(iLine+1)-1)) > 5)
                        fprintf(fid, '%s', s(ind(iLine):ind(iLine+1)-1));
                end
              end
            end

            waitbar(iLoc/length(indLoc),h)
         end
         close(h);

   end
   
   if nargout==1
   varargout = {OutputName};
   else
   varargout = {OutputName,urlName};
   end

%% EOF
