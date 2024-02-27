function varargout = knmi_uurgeg(varargin)
%KNMI_UURGEg   Reads KNMI ASCII climate time series
%
%    W = knmi_uurgeg(filename) 
%
% reads a wind file (can be zipped) from
%    http://www.knmi.nl/klimatologie/daggegevens/download.html
% into a struct W.
%
%    [W,iostat] = knmi_uurgeg(filename) 
%
% returns error status in iostat (OK/cancel/file not found/)
%
%    W = knmi_uurgeg(filename,<keyword,value>) 
%
% where the following optional <keyword,value> pairs are implemented:
% (see: http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
% * debug    : debug or not (default 0
% * version  : version of knmi_uurgeg.csv descriptor to be used (default 'current')
% * nheader  : number of header lines skip (default: corrent for current version)
%
% Missing data are filled in with NaN.
%
% NOTE THAT THE VALUES FROM THE FILE HAVE BEEN MULTIPLIED WITH A FACTOR TO GET SI-UNITS.
%
% See also: KNMI_POTWIND, KNMI_uurgeg2NC, KNMI_uurgeg_GET_URL, KNMI_WMO_STATIONS

% based on knmi_etmgeg.m
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
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
% $Id: knmi_uurgeg.m 14946 2018-12-12 13:51:55Z bartgrasmeijer.x $
% $Date: 2018-12-12 21:51:55 +0800 (Wed, 12 Dec 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14946 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_uurgeg.m $
% $Keywords: $

%% 0 - command line file name or 
%      Launch file open GUI

%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'uurgeg*.*' ,'KNMI climate time series (uurgeg*.*)'; ...
         '*.*'       ,'All Files (*.*)'}, ...
         'KNMI climate time series (uurgeg*.*)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         W.file.name     = [];
         iostat         = 0;
      else
         W.file.name     = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(W.file.name)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

%% No file name specified if odd number of arguments

   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      W.file.name   = varargin{1};
      iostat       = 1;
   end
   
%% Keywords

      OPT.debug         = 0;
      OPT.version       = 'current';
      OPT.nheader       = 33;

      OPT = setproperty(OPT,varargin{2:end});
   
%% I - Check if file exists (actually redundant after file GUI)

   tmp = dir(W.file.name);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',W.file.name])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
%% Unzip optionally (and delete aftwewards)

      deletezip = '';
      if strcmpi(W.file.name(end-3:end),'.zip')
         disp([mfilename,': unzipping to temp dir'])
         fname       = fullfile(tempdir,[filename(W.file.name(1:end-4)),'.txt']);
         unzip(W.file.name,tempdir);
         deletezip   = fname;
      else
         fname = W.file.name;
      end

%% Read header

      fid             = fopen(fname);
      for iline = 1:(OPT.nheader)
         W.comments{iline} = fgetl(fid);
      end
      
%% Extract meta-info for use in interpretation

      W               = csv2struct([fileparts(mfilename('fullpath')),filesep,'knmi_uurgeg.',OPT.version,'.csv'],'delimiter',';');
      
      if iscell(W.slope)
      W.slope         = [W.slope{:}]; % all numeric now
      end

      W.knmi_name     = strtrim(W.knmi_name);
      W.long_name     = strtrim(W.long_name);
      W.standard_name = strtrim(W.standard_name);
      W.cell_methods  = strtrim(W.cell_methods);
      W.units         = strtrim(W.units);
         
%% Read data

      W.file.name     = tmp.name;
      W.file.date     = tmp.date;
      W.file.bytes    = tmp.bytes;
      
%% Read data
%   ------------------------------------------------------------------------------------------------------
%        STN,YYYYMMDD,   HH,   DD,   FH,   FF,   FX,    T,  T10,   TD,   SQ,    Q,   DR,   RH,    P,   VV,    N,    U,   WW,   IX,    M,    R,    S,    O,    Y
%        210,19510101,    1,  200,     ,   93,     ,   -4,     ,     ,     ,     ,     ,     , 9947,     ,    8,     ,    5,     ,     ,     ,     ,     ,     
%   ------------------------------------------------------------------------------------------------------
         
         RAW = textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n','delimiter',',');
         for icol=1:length(W.knmi_name)
             
            fldname          = W.knmi_name{icol};
            if ischar(W.slope(icol))
            W.slope{icol}    = str2num(W.slope(icol));
            end
            
            if ~(isnan(W.slope(icol)) | W.slope(icol)==0) % char data
               W.data.(fldname) = [RAW{icol}]*W.slope(icol);
            else
               W.data.(fldname) = [RAW{icol}];
            end
            
         end
         W.datenum = time2datenum(W.data.YYYYMMDD) + W.data.HH./24;
         fclose(fid);
         
   end % if length(tmp)==0
   
%% Append meta-info

   [W.code,W.platform_name,W.lon,W.lat,W.url] = KNMI_WMO_stations(unique(W.data.STN));

   W.read.with     = '$Id: knmi_uurgeg.m 14946 2018-12-12 13:51:55Z bartgrasmeijer.x $'; % SVN keyword, will insert name of this function
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