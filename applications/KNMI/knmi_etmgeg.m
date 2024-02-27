function varargout = knmi_etmgeg(varargin)
%KNMI_ETMGEG   Reads KNMI ASCII climate time series
%
%    W = knmi_etmgeg(filename) 
%
% reads a wind file (can be zipped) from
%    http://www.knmi.nl/klimatologie/daggegevens/download.html
% into a struct W.
%
%    [W,iostat] = knmi_etmgeg(filename) 
%
% returns error status in iostat (OK/cancel/file not found/)
%
%    W = knmi_etmgeg(filename,<keyword,value>) 
%
% where the following optional <keyword,value> pairs are implemented:
% (see: http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
% * debug    : debug or not (default 0
% * version  : version of knmi_etmgeg.csv descriptor to be used (default 'current')
% * nheader  : number of header lines skip (default: corrent for current version)
%
% Missing data are filled in with NaN.
%
% NOTE THAT THE VALUES FROM THE FILE HAVE BEEN MULTIPLIED WITH A FACTOR TO GET SI-UNITS.
%
% See also: KNMI_POTWIND, KNMI_ETMGEG2NC, KNMI_ETMGEG_GET_URL, KNMI_WMO_STATIONS

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
% $Id: knmi_etmgeg.m 13970 2017-11-17 14:35:49Z gerben.deboer.x $
% $Date: 2017-11-17 22:35:49 +0800 (Fri, 17 Nov 2017) $
% $Author: gerben.deboer.x $
% $Revision: 13970 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_etmgeg.m $
% $Keywords: $

%% 0 - command line file name or 
%      Launch file open GUI

%% No file name specified if even number of arguments
%  i.e. 2 or 4 input parameters

   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'etmgeg*.*' ,'KNMI climate time series (etmgeg*.*)'; ...
         '*.*'       ,'All Files (*.*)'}, ...
         'KNMI climate time series (etmgeg*.*)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         W.filename     = [];
         iostat         = 0;
      else
         W.filename     = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(W.filename)
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
      OPT.nheader       = 49; % 35; 27; due to 9 extra parameters in datafiles2, another extra 15 in datafiles3

      OPT = setproperty(OPT,varargin{2:end});
   
%% I - Check if file exists (actually redundant after file GUI)

   tmp = dir(W.file.name);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',W.filename])
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
         fname = W.file.name
      end

%% Read header

      fid             = fopen(fname);
      for iline = 1:(OPT.nheader)
         W.comments{iline} = fgetl(fid);
      end
      
%% Extract meta-info for use in interpretation
      W               = csv2struct([fileparts(mfilename('fullpath')),filesep,'knmi_etmgeg.',OPT.version,'.csv'],'delimiter',';');
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
      
%     1        2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17
%   ------------------------------------------------------------------------------------------------------
% older  STN,YYYYMMDD,DDVEC,   FG,  FHX,   FX,   TG,   TN,   TX,   SQ,   SP,   DR,   RH,   PG,  VVN,   NG,   UG
% older
% older  235,20010101,  177,   88,  110,  170,   40,    9,   76,    0,    0,   71,   88, 9944,   22,    8,   93
%   ------------------------------------------------------------------------------------------------------
% datafiles2
% old    STN,YYYYMMDD,DDVEC,   FG,  FHX,  FHN,   FX,   TG,   TN,   TX, T10N,   SQ,   SP,    Q,   DR,   RH,   PG,  PGX,  PGN,  VVN,  VVX,   NG,   UG,   UX,   UN, EV24
% old   
% old    210,19510101,  202,  108,  190,   51,     ,   15,   -9,   42,     ,     ,     ,     ,     ,     , 9882, 9947, 9821,     ,     ,    7,     ,     ,     ,     ,
%          RAW = textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n','delimiter',',');
%   ------------------------------------------------------------------------------------------------------
% datafiles3
%        STN,YYYYMMDD,DDVEC,FHVEC,   FG,  FHX, FHXH,  FHN, FHNH,  FXX, FXXH,   TG,   TN,  TNH,   TX,  TXH, T10N,T10NH,   SQ,   SP,    Q,   DR,   RH,  RHX, RHXH,   PG,   PX,  PXH,   PN,  PNH,  VVN, VVNH,  VVX, VVXH,   NG,   UG,   UX,  UXH,   UN,  UNH, EV24
%        210,19510101,  202,   93,  108,  190,   17,   51,   23,     ,     ,   15,   -9,    1,   42,   18,     ,     ,     ,     ,     ,     ,     ,     ,     , 9882, 9947,     , 9821,     ,     ,     ,     ,     ,    7,     ,     ,     ,     ,     ,     ,
%   ------------------------------------------------------------------------------------------------------
         
         RAW = textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n','delimiter',',');
         
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
         W.datenum = time2datenum(W.data.YYYYMMDD);
         fclose(fid);
         
   end % if length(tmp)==0
   
%% Append meta-info

   [W.code,W.platform_name,W.lon,W.lat,W.url] = KNMI_WMO_stations(unique(W.data.STN));
   if isempty(W.code) % catch missing station metadata, like 209 IJmond
       W.code = unique(W.data.STN);
       W.platform_name = 'unknown';
       W.lon = nan;
       W.lat = nan;
       W.url = '';
   end

   W.read.with     = '$Id: knmi_etmgeg.m 13970 2017-11-17 14:35:49Z gerben.deboer.x $'; % SVN keyword, will insert name of this function
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