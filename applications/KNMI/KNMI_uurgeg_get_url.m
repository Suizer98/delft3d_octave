function varargout = KNMI_uurgeg_get_url(varargin)
%KNMI_uurgeg_get_url   downloads uurgeg data from KNMI and make netCDF
%
%   KNMI_uurgeg_GET_URL(<basepath>)
%
% downloads all uurgeg data from KNMI website and stores relative to 'basepath' in:
%
%   .\OpenEarthRawData\KNMI\uurgeg\raw\
%
% Implemented <keyword,value> pairs are:
% * download : switch whether to download from url (default 1)
% * unzip    : switch whether to unzip downloaded data (default 1)
% * nc       : switch whether to make netCDF from unzipped data (default 0)
% * opendap  : switch whether to put netCDF files on OPeNDAP server (default 0)
% * url      : base url from where to download (default 
%              http://www.knmi.nl/klimatologie/uurgegevens/)
%
%See also: KNMI_POTWIND, KNMI_ETMGEG, KNMI_POTWIND_GET_URL, KNMI_ETMGEG_GET_URL

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% $Id: KNMI_uurgeg_get_url.m 15926 2019-11-07 08:41:22Z verploe $
% $Date: 2019-11-07 16:41:22 +0800 (Thu, 07 Nov 2019) $
% $Author: verploe $
% $Revision: 15926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/KNMI_uurgeg_get_url.m $
% $Keywords: $

   if nargin < 1
      error('syntax: KNMI_uurgeg_get_url(basepath)')
   end
   
      basepath = '';
   if odd(nargin)
      basepath = varargin{1};
      varargin = varargin{2:end};
   end

%% Set <keyword,value> pairs

   OPT.debug           = 0; % load local download.html from DIR.raw
   OPT.download        = 1;
   OPT.nc              = 0;
   OPT.opendap         = 1; 
   OPT.directory_raw   = [basepath,filesep,'raw'      ,filesep]; % zip files
   OPT.directory_nc    = [basepath,filesep,'processed',filesep];
   OPT.url             = '"datafiles/'; % unique string to recognize datafiles in html page
   OPT.preurl          = 'http://projects.knmi.nl/klimatologie/uurgegevens/'; % prefix to relative link in OPT.url

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
   website   = urlread ('http://www.knmi.nl/klimatologie/uurgegevens/');
               urlwrite('http://www.knmi.nl/klimatologie/uurgegevens/',...
                        [OPT.directory_raw,'download.html']);
   else
   website = urlread(['file:///',OPT.directory_raw,filesep,'download.html']);
   end

%% Extract names of files to be downloaded from webpage

   indices = strfind(website,OPT.url);
   
   % includes current running year:  jaar.txt
   % includes current running month: maand.txt
   
   nfile     = 0;
   for index=indices
   
      dindex = strfind(website(index:end),'"')-1;
      
      nfile  = nfile +1;
      
      %% mind to leave out "" brackets
      OPT.files{nfile} = [OPT.preurl,website(index+1:index+dindex(2)-1)];
   
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
      
         knmi_uurgeg2nc('directory_raw'  ,OPT.directory_raw,...
                         'directory_nc'  ,OPT.directory_nc)
   end
   
%% Output 

   if nargout==1
      varargout = {OPT};
   end

%% EOF
