function varargout = KNMI_potwind_get_url(varargin)
%KNMI_POTWIND_GET_URL   downloads potwind data from KNMI and make netCDF
%
%   knmi_potwind_get_url(<basepath>)
%
% downloads all potwind data from KNMI website and stores relative to 'basepath' in:
%
%   .\raw\
%
% Implemented <keyword,value> pairs are:
% * download : switch whether to download from url (default 1)
% * unzip    : switch whether to unzip downloaded data (default 1)
% * nc       : switch whether to make netCDF from unzipped data (default 0)
% * opendap  : switch whether to put netCDF files on OPeNDAP server (default 0)
% * url      : base url from where to download (default 
%              http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/)
% Example:
%   OPT.download = 1;
%   OPT.directory_raw = 'c:\Data\wind_from_knmi\raw\';
%   OPT.directory_nc = 'c:\Data\wind_from_knmi\nc\';
%   OPT.make_nc = 1;
%   KNMI_potwind_get_url        ('download'       , OPT.download,...
%                                'directory_raw'  , OPT.directory_raw,...
%                                'directory_nc'   , OPT.directory_nc,...
%                                'nc'             , OPT.make_nc)
%
%See also: wind_plot, KNMI_POTWIND, KNMI_ETMGEG, KNMI_ETMGEG_GET_URL

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
% $Id: KNMI_potwind_get_url.m 9897 2013-12-17 17:12:27Z santinel $
% $Date: 2013-12-18 01:12:27 +0800 (Wed, 18 Dec 2013) $
% $Author: santinel $
% $Revision: 9897 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/KNMI_potwind_get_url.m $
% $Keywords: $

   if nargin < 1
      error('syntax: KNMI_potwind_get_url(basepath)')
   end
   
      basepath = '';
   if odd(nargin)
      basepath = varargin{1};
      varargin = varargin{2:end};
   end

%% Set <keyword,value> pairs
   
   OPT.debug           = 0; % load local download.html from OPT.directory_raw
   OPT.download        = 1;
   OPT.nc              = 0;
   OPT.opendap         = 1; 
   OPT.directory_raw   = [basepath,filesep,'raw'      ,filesep]; % zip files
   OPT.directory_nc    = [basepath,filesep,'processed',filesep];
   OPT.url             =  'http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/'; %datafiles/

   OPT = setproperty(OPT,varargin{:});

if OPT.download

%% Settings
   
   if ~(exist(OPT.directory_raw)==7)
      disp('The following target path ')
      disp(OPT.directory_raw)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkpath(OPT.directory_raw)
   end   

%% Load website

   if ~(OPT.debug)
   website   = urlread ('http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/');

   
               urlwrite('http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/',...
                        [OPT.directory_raw,'download.html']);
   else
   website = urlread(['file:///',OPT.directory_raw,filesep,'download.html'])
   end

%% Extract names of files to be downloaded from webpage

   indices   = strfind(website,'"potwind_');
   
   nfile     = 0;
   for index=indices
   
      dindex = strfind(website(index:end),'"')-1;
      
      nfile  = nfile +1;
      
      %% mind to leave out "" brackets
      OPT.files{nfile} = website(index+1:index+dindex(2)-1);
   
   end

   nfile = length(OPT.files);
   
%% Download *.zip files

      multiWaitbar(mfilename,0,'label','Looping files.','color',[0.3 0.8 0.3])

      for ifile=1:nfile
      
         disp(['Downloading: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         multiWaitbar(mfilename,ifile/nfile,'label',['Processing station: ',OPT.files{ifile}])
         
         mkpath([OPT.directory_raw,'/',filepathstr(OPT.files{ifile})])
         
         urlwrite([OPT.url  ,'/',OPT.files{ifile}],... % *.zip
                  [OPT.directory_raw,'/',OPT.files{ifile}]); 
         
      end   

end % download

%% Transform to *.nc files (directly from zipped files)

   if OPT.nc
      
         knmi_potwind2nc('directory_raw'  ,OPT.directory_raw,...
                         'directory_nc'   ,OPT.directory_nc)
   
   end
   
%% Output 

   if nargout==1
      varargout = {OPT};
   end

%% EOF
