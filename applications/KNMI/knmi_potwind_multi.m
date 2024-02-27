function W = knmi_potwind_multi(fnames,varargin)
%KNMI_POTWIND_MULTI   read multiple knmi_potwind files
%
%    W = knmi_potwind(filename) 
%
% read multiple knmi_potwind files (can be zipped) and make one 
% timeseries of continous data.
%
% syntax indentical to that of KNMI_POTWIND, except that the
% filename is a cellstr with multiple file names.
%
% Example: make one time series of the following 3 K13 time series:
%
% W = knmi_potwind_multi({'s252.asc'        ,...     % from http://www.knmi.nl/samenw/hydra/index.html
%                         'potwind_252_1991',...     % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
%                         'potwind_252_2001.zip'});  % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
%
% KNMI_POTWIND_MULTI checks for non-compatible timeseries (e.g. different station names).
%
% An extra field 'file' is added that gives the file sequenc enumber form which 
% each data point has been taken.
%
% Note that for each file only the data until the first datenum in the 
% subsequent file are used. The data in last file supplied is fully returned.
%
%See also: KNMI_POTWIND

% TO DO: use netCDF files for this, or incporporate this in knmi_potwind2nc.m

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
%   -------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_potwind_multi.m 7856 2012-12-19 13:39:00Z boer_g $
% $Date: 2012-12-19 21:39:00 +0800 (Wed, 19 Dec 2012) $
% $Author: boer_g $
% $Revision: 7856 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_potwind_multi.m $
% $Keywords: $

   OPT.debug = 0;

%% read all

   for ii=1:length(fnames)
   w(ii) = knmi_potwind(fnames{ii},varargin{:}); 
   end

   % w(1) = knmi_potwind('.\s252.asc'        ); % from http://www.knmi.nl/samenw/hydra/index.html
   % w(2) = knmi_potwind('.\potwind_252_1991'); % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
   % w(3) = knmi_potwind('.\potwind_252_2001'); % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/

%% Set result equal to first file
%  and delete array fields

   W               = w(1);
   W.DD            = [];
   W.QQD           = [];
   W.UP            = [];
   W.QUP           = [];
   W.datenum       = [];
   W.origin_number = [];
   
   W.file.name     = [];
   W.file.date     = [];
   W.file.bytes    = [];
   W.roughness     = []; % numeric
   W.height        = []; % char!: contains comment "Begroeing in 1999 in NW en N (310-010) te hoog geworden" for station 235.
   W.version       = [];
   W.read.at       = [];
   
%% merge, where later overwrites earlier

   w(end+1).datenum = Inf; % add axtra dummy file to allow processing of last file in loop
   
   for ii=[1:length(w)-1]
       
   %% Copy relevant non-overlapping parts of time series

      mask            = w(ii).datenum < min(w(ii+1).datenum);

      W.DD            = [W.DD(:)'                  w(ii).DD(     mask)']';
      W.QQD           = [W.QQD(:)'                 w(ii).QQD(    mask)']';
      W.UP            = [W.UP(:)'                  w(ii).UP(     mask)']';
      W.QUP           = [W.QUP(:)'                 w(ii).QUP(    mask)']';
      W.datenum       = [W.datenum(:)'             w(ii).datenum(mask)']';
      W.origin_number = [W.origin_number(:)' ii+0.*w(ii).datenum(mask)']'; % 1 for 1st file, 2 for 2nd etc.

   %% Check all     meta-info that is non unique per file

     %if ~strcmpi        (w(ii).comments,w(1).comments        );   error('meta-info not unique for comments        ');end %          comments: {1x22 cell}
      if ~strcmpi(   w(ii).stationnumber,w(1).stationnumber   );   error('meta-info not unique for stationnumber   ');end %     stationnumber: '252'
      if ~strcmpi(     w(ii).stationname,w(1).stationname     );   error('meta-info not unique for stationname     ');end %       stationname: 'K13'
      if ~isequal(            w(ii).xpar,w(1).xpar            );   error('meta-info not unique for xpar            ');end %              xpar: 10240
      if ~isequal(            w(ii).ypar,w(1).ypar            );   error('meta-info not unique for ypar            ');end %              ypar: 583356
      if ~isequal(             w(ii).lon,w(1).lon             );   error('meta-info not unique for lon             ');end %               lon: 3.22
      if ~isequal(             w(ii).lat,w(1).lat             );   error('meta-info not unique for lat             ');end %               lat: 53.218
      if ~isequal(          w(ii).height,w(1).height          ); warning('meta-info not unique for height          ');end %            height: 73.8
      if ~strcmpi(            w(ii).over,w(1).over            );   error('meta-info not unique for over            ');end %              over: 'WATER'
      if ~strcmpi(        w(ii).timezone,w(1).timezone        );   error('meta-info not unique for timezone        ');end %          timezone: 'GMT'
      if ~strcmpi(     w(ii).DD_longname,w(1).DD_longname     );   error('meta-info not unique for DD_longname     ');end %       DD_longname: 'WIND DIRECTION IN DEGREES NORTH'
      if ~strcmpi(    w(ii).QQD_longname,w(1).QQD_longname    );   error('meta-info not unique for QQD_longname    ');end %      QQD_longname: 'QUALITY CODE DD'
      if ~strcmpi(     w(ii).UP_longname,w(1).UP_longname     );   error('meta-info not unique for UP_longname     ');end %       UP_longname: 'POTENTIAL WIND SPEED IN M/S'
      if ~strcmpi(    w(ii).QUP_longname,w(1).QUP_longname    );   error('meta-info not unique for QUP_longname    ');end %      QUP_longname: 'QUALITY CODE UP'
      if ~strcmpi(w(ii).datenum_longname,w(1).datenum_longname);   error('meta-info not unique for datenum_longname');end %  datenum_longname: 'days since 00:00 Jan 0 0000'
      if ~strcmpi(        w(ii).UP_units,w(1).UP_units        );   error('meta-info not unique for UP_units        ');end %          UP_units: 'm/s'
      if ~strcmpi(       w(ii).QQD_units,w(1).QQD_units       );   error('meta-info not unique for QQD_units       ');end %         QQD_units: 'm/s'
      if ~strcmpi(        w(ii).DD_units,w(1).DD_units        );   error('meta-info not unique for DD_units        ');end %          DD_units: '[-1,0,2,3,6,7,100,990]'
      if ~strcmpi(       w(ii).QUP_units,w(1).QUP_units       );   error('meta-info not unique for QUP_units       ');end %         QUP_units: '[-1,0,2,3,6,7,100,990]'
      if ~strcmpi(   w(ii).datenum_units,w(1).datenum_units   );   error('meta-info not unique for datenum_units   ');end %     datenum_units: 'day'
      if ~strcmpi(       w(ii).read.with,w(1).read.with       );   error('meta-info not unique for read.with       ');end %          iomethod: [1x80 char]
      if ~isequal(   w(ii).read.iostatus,w(1).read.iostatus   );   error('meta-info not unique for read.iostatus   ');end %          iostatus: 1

   %% Copy  remaing meta-info that is     unique per file

      W.file.name{ii}  = w(ii).file.name ;
      W.file.date{ii}  = w(ii).file.date ;
      W.file.bytes{ii} = w(ii).file.bytes;
      W.roughness(ii)  = w(ii).roughness;
      W.height{ii}     = w(ii).height;
      W.version{ii}    = w(ii).version;
      W.read.at{ii}    = w(ii).read.at;
   
   end
   
%% debug

   if OPT.debug
       TMP = figure;
       plot    (W.datenum,W.origin_number,'.-')
       datetick('x')
       
       set(gca,'ytick'    ,[1:length(w)])
       set(gca,'yticklabel',W.file.name)
       
       pausedisp
       try
           close(TMP);
       end
   end
   
%% EOF