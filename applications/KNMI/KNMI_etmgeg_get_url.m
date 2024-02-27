function varargout = knmi_etmgeg_get_url(varargin)
%KNMI_ETMGEG_GET_URL   downloads etmgeg data from KNMI and make netCDF
%
%   KNMI_ETMGEG_GET_URL(<basepath>)
%
% downloads all etmgeg data from KNMI website and stores relative to 'basepath' in:
%
%   .\OpenEarthRawData\KNMI\potwind\raw\
%
%   code long_name         starttime   endtime
%   210   Valkenburg       19510101    present
%   225   IJmuiden         19710101    present
%   235   De Kooy          19060101    present
%   240   Schiphol         19510101    present
%   242   Vlieland         19850101    present
%   249   Berkhout         19990312    present
%   251   Hoorn (Tersch.)  19940526    present
%   257   Wijk aan Zee     20010430    present
%   260   De Bilt          19010101    present
%   265   Soesterberg      19510910    20081118
%   267   Stavoren         19900618    present
%   269   Lelystad         19900117    present
%   270   Leeuwarden       19510101    present
%   273   Marknesse        19890101    present
%   275   Deelen           19510101    present
%   277   Lauwersoog       19910318    present
%   278   Heino            19910101    present
%   279   Hoogeveen        19890926    present
%   280   Eelde            19060101    present
%   283   Hupsel           19891016    present
%   286   Nieuw Beerta     19900117    present
%   290   Twenthe          19510101    present
%   310   Vlissingen       19060101    present
%   319   Westdorpe        19910625    present
%   323   Wilhelminadorp   19891105    present
%   330   Hoek van Holland 19710101    present
%   340   Woensdrecht      19930401    present
%   344   Rotterdam        19561001    present
%   348   Cabauw           19860301    present
%   350   Gilze-Rijen      19510103    present
%   356   Herwijnen        19890926    present
%   370   Eindhoven        19510101    present
%   375   Volkel           19510301    present
%   377   Ell              19990501    present
%   380   Maastricht       19060101    present
%   391   Arcen            19900618    present
%
% Implemented <keyword,value> pairs are:
% * download : switch whether to download from url (default 1)
% * unzip    : switch whether to unzip downloaded data (default 1)
% * nc       : switch whether to make netCDF from unzipped data (default 0)
% * opendap  : switch whether to put netCDF files on OPeNDAP server (default 0)
% * url      : base url from where to download (default 
%              http://www.knmi.nl/klimatologie/daggegevens/)
%
%See also: KNMI_POTWIND, KNMI_ETMGEG, KNMI_POTWIND_GET_URL

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G (Gerben).J. de Boer
%
%       gerben.deboer@deltares.nl 
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% $Id: KNMI_etmgeg_get_url.m 13970 2017-11-17 14:35:49Z gerben.deboer.x $
% $Date: 2017-11-17 22:35:49 +0800 (Fri, 17 Nov 2017) $
% $Author: gerben.deboer.x $
% $Revision: 13970 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/KNMI_etmgeg_get_url.m $
% $Keywords: $

   if nargin < 1
      error('syntax: KNMI_etmgeg_get_url(basepath)')
   end
   
      basepath = '';
   if odd(nargin)
      basepath = varargin{1};
      if nargin==1
      varargin = {};
      else
      varargin = {varargin{2:end}};
      end
   end

%% Set <keyword,value> pairs

   OPT.debug           = 0; % load local download.html from DIR.raw
   OPT.download        = 1;
   OPT.nc              = 1;
   OPT.opendap         = 1; 
   OPT.directory_raw   = [basepath,filesep,'raw'      ,filesep]; % zip files
   OPT.directory_nc    = [basepath,filesep,'processed',filesep];
   OPT.url             = '//cdn.knmi.nl/knmi/map/page/klimatologie/gegevens/daggegevens/'; % unique string to recognize datafiles in html page
   OPT.preurl          = 'http:'; % prefix to relative link in OPT.url

   OPT = setproperty(OPT,varargin{:});

if OPT.download

%% Settings

   if ~(exist(OPT.directory_raw)==7)
      disp('The following target path ')
      disp(OPT.directory_raw)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkdir(OPT.directory_raw)
   end   
   
%% Load website

   if ~(OPT.debug)
   website   = urlread ('http://www.knmi.nl/nederland-nu/klimatologie/daggegevens');
               urlwrite('http://www.knmi.nl/nederland-nu/klimatologie/daggegevens',...
                        [OPT.directory_raw,'daggegevens.html']);
   else
   website = urlread(['file:///',OPT.directory_raw,filesep,'daggegevens.html']);
   end

%% Extract names of files to be downloaded from webpage

   indices = strfind(website,OPT.url);
   
   % includes current running year:  jaar.txt
   % includes current running month: maand.txt
   
   nfile     = 0;
   for index=indices
   
      dindex = strfind(website(index:end),'.zip');      
      dindex = dindex(1)+2;
      nfile  = nfile+1;
      
      %% mind to leave out "" brackets
      OPT.files{nfile} = [OPT.preurl,website(index:index+dindex)];
   
   end
   nfile = length(OPT.files);
   
%% Download *.zip files

      multiWaitbar(mfilename,0,'label','Looping files.','color',[0.3 0.8 0.3])

      for ifile=1:nfile
      
         disp(['Downloading: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         multiWaitbar(mfilename,ifile/nfile,'label',['Processing station: ',OPT.files{ifile}])
         
         urlwrite([OPT.files{ifile}],... % *.zip
                  [OPT.directory_raw,filesep,filenameext(OPT.files{ifile})]); 
         
      end   

end % download

%% Transform to *.nc files (directly from zipped files)

   if OPT.nc
      
         knmi_etmgeg2nc('directory_raw'  ,OPT.directory_raw,...
                         'directory_nc'  ,OPT.directory_nc)
   end
   
%% Output 

   if nargout==1
      varargout = {OPT};
   end

%% EOF
