function varargout = seawifs_l2_read(fname,varargin);
%SEAWIFS_L2_READ   load one image from a SeaWiFS/MODIS (subscened) L2 HDF file
%
%   D = seawifs_l2_read(filename,<varname>,<keyword,value>)
%
% load one image from a <a href="http://oceancolor.gsfc.nasa.gov/SeaWiFS/">SeaWiFS</a> L2 HDF file 
% incl. full lat, lon arrays and L2 flags. The L2 hdf file can be gzipped or bz2 zipped.
% seawifs_L2_read is a wrapper for the Matlab hdf tools as HDFTOOL.
% D contains geophysical data (not integer data), l2_flags, units and long_name.
%
%  [D,M] = seawifs_l2_read(...) also returns RAW meta-data.
%
% For <keyword,value> pairs call: OPT = seawifs_l2_read()
%
% Example:
% 
%   D = seawifs_L2_read('S1998045125841.L2_HDUN_ZUNO.gz','nLw_555','plot',1)
%
%See also: SEAWIFS_DATENUM, SEAWIFS_MASK, SEAWIFS_FLAGS, 
%          HDFINFO, SDLOAD_CHAR, HDFVLOAD

%% Copyright notice
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: seawifs_L2_read.m 5128 2011-08-29 10:19:40Z boer_g $
% $Date: 2011-08-29 18:19:40 +0800 (Mon, 29 Aug 2011) $
% $Author: boer_g $
% $Revision: 5128 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/seawifs_L2_read.m $
% $Keywords: $

% TO DO: calculate mask in D ?

%% Keywords

   OPT.debug   = 0;
   OPT.plot    = 0;
   OPT.export  = 1; % only when plot=1
   OPT.geo     = 1; % 0 = raw int data, 1 = geophysical DATA
   OPT.unzip   = 1; % unzip *.gz  and *.bz2 files
   OPT.delete  = 0; % cleanup unzipped files after any kind of unzip
   OPT.mask    = 1; % remove clouds, ice and land
   OPT.mumm    = 1;
   OPT.ldb     = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_c.nc';
   OPT.ldb     = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc';
   
   if odd(nargin)
      OPT        = setproperty(OPT,varargin{:});
   elseif nargin==0
      varargout = {OPT};
      return
   else
      OPT        = setproperty(OPT,varargin{2:end});
      varname    = varargin{1};
   end
   
%% unzip (and clean up at end of function)

   if     OPT.unzip & strcmpi(fname(end-2:end),'.gz')
      gunzip(fname)
      zipname = fname;
      hdfname = fname(1:end-3);
      zipped  = 1;
   elseif OPT.unzip & strcmpi(fname(end-3:end),'.zip')
      unzip(fname)
      zipname = fname;
      hdfname = fname(1:end-4);
      zipped  = 1;
   elseif OPT.unzip & strcmpi(fname(end-3:end),'.bz2')
      uncompress(fname,'outpath',fileparts(fname));
      zipname = fname;
      hdfname = fname(1:end-4);
      zipped  = 1;
   else
      hdfname = fname;
      zipped  = 0;
   end
   
   D.fname = fname;

%% Variable selection

% TO DO; check  for existence of file

   I       = hdfinfo(hdfname);
   
   if ~isfield(I,'Vgroup')   ; % happens for instance when ancillary data was missing
   
      fprintf(2, '??? Warning using ==> seawifs_L2_read: skipped empty hdf file: %s \n', fname); % this gives red letters
      
      %varargout = {[],[],[]};
      %return; % thos does not clean up unzipped hdf !!
      
   else   
   
      %% find correct group
      
      % TO DO group_index = h4_group_find(I,'group_name')
      
      for group=1:length(I.Vgroup);if strcmpi(I.Vgroup(group).Name,'Geophysical Data');
         break;end
      end
      
%%    parameter meta-info
      
      H.varnames = {I.Vgroup(group).SDS.Name};
      
      for ivar=1:length(H.varnames)
      
         for isds=1:length(I.Vgroup(group).SDS); 
         
            if strcmpi(I.Vgroup(group).SDS(isds).Name,H.varnames{ivar});
         
            M = I.Vgroup(group).SDS(isds);
         
            break;end;
            
         end   
      
         % TO DO D.(att_name) = h4_att_get(I,'sds_name','att_name')
      
         for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'long_name');
            H.long_names{ivar} = M.Attributes(iatt).Value(1:end-1);break;end % remove trailing char(0)
         end   
         
         for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'units');
            H.units{ivar}      = M.Attributes(iatt).Value(1:end-1);break;end % remove trailing char(0)
         end   
         
      end
      
      H.txt = [          addrowcol(char(H.varnames  ),0,-1,' '),...
                         addrowcol(char(H.long_names),0,-1,' - '), ...
               addrowcol(addrowcol(char(H.units     ),0,1 ,']'),0,-1,'[')];

%%    selection box

      if odd(nargin)
      
         [varind, ok] = listdlg('ListString', H.txt, .....
                             'SelectionMode', 'single', ...                           % we can only plot one for now
                              'PromptString', 'Select a geophysical parameter:', .... % title of pulldown menu
                                      'Name', 'Loading SeaWiFS/MODIS L2 file:',...    % title of window
                                  'ListSize', [500, 300]);
          varname = H.varnames{varind};
      else
          varind = strmatch(varname,H.varnames)
      end
      
      
      D.name      = H.varnames{varind};
      D.long_name = H.long_names{varind};
      D.units     = H.units{varind};
      
%%    Data, coordinates, time
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'start time'      );break;end;end   
      D.datenum(1) = seawifs_datenum(I.Attributes(iatt).Value);
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'end time'        );break;end;end   
      D.datenum(2) = seawifs_datenum(I.Attributes(iatt).Value);
      
      for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'Input Parameters');break;end;end   
      val = I.Attributes(iatt).Value;
      
%%    Special MUMM case 2 parameters (only in when processed by MUMM seadas special)
      
      if OPT.mumm

      val  = I.Attributes(iatt).Value;
      ind  = strfind(val,'MUMM_ALPHA');
      if ~isempty(ind)
      ind2 = strfind(val(ind:end),'=');
      ind3 = strfind(val(ind:end),'|');
      D.mumm_alpha = str2num(val(ind + (ind2:ind3-2)));
      end
      
      val  = I.Attributes(iatt).Value;
      ind  = strfind(val,'MUMM_GAMMA');
      if ~isempty(ind)
      ind2 = strfind(val(ind:end),'=');
      ind3 = strfind(val(ind:end),'|');
      D.mumm_gamma = str2num(val(ind + (ind2:ind3-2)));
      end
      
      val  = I.Attributes(iatt).Value;
      ind  = strfind(val,'MUMM_EPSM78');
      if ~isempty(ind)
      ind2 = strfind(val(ind:end),'=');
      ind3 = strfind(val(ind:end),'|');
      D.mumm_epsm78 = str2num(val(ind + (ind2:ind3-2)));
      end

      end
      
%%    Flags
      
      D.(varname)    = hdfread(hdfname,varname);
      if ~strcmpi(varname,'l2_flags')
      D.l2_flags     = hdfread(hdfname,'l2_flags');
      D.flags        = seawifs_flags;
      end
      T.lon          = hdfread(hdfname,'longitude');
      T.lat          = hdfread(hdfname,'latitude' );
      T.cntl_pt_rows = hdfread(hdfname,'cntl_pt_rows');
      T.cntl_pt_cols = hdfread(hdfname,'cntl_pt_cols');
      
%%    (geodata = rawdata * slope + intercept)
%     http://www.icess.ucsb.edu/seawifs/software/seadas4.8/src/idl_utils/io/wr_swf_hdf_sd.pro
      
      if OPT.geo & isfield(D,'slope') & isfield(D,'intercept') % note l2_flags have no slope, intercept
      D.(varname) = double(D.(varname)).*double(D.slope) + double(D.intercept);
      end
      
%%    georeference full matrices
%     http://oceancolor.gsfc.nasa.gov/forum/oceancolor/topic_show.pl?pid=2029
%     for each swath the (lat,lon) arrays are only stored every 8th pixel.
%     To get the full matrix interpolate to the full pixel range, with a spline.
      
% TO DO: make seperate untie function
% [lon,lat]=@(lon,lat,cntl_pt_cols,cntl_pt_rows)

      if size(D.(varname),1)==length(T.cntl_pt_rows)
         D.lon       = repmat(nan,size(D.(varname)));
         D.lat       = repmat(nan,size(D.(varname)));
         nrow        =            size(D.(varname),1);
         ncol        =            size(D.(varname),2);
         for irow = 1:nrow
            D.lon(irow,:) = interp1(single(T.cntl_pt_cols),double(T.lon(irow,:)),1:ncol,'spline');
            D.lat(irow,:) = interp1(single(T.cntl_pt_cols),double(T.lat(irow,:)),1:ncol,'spline');
         end
      
      end   
      
%%    debug: show results last row   
      
      if OPT.debug
         clf
         subplot(1,2,1)
         plot(single(T.cntl_pt_cols),T.lon(irow,:),'.-b','Displayname','per 8')
         hold on
         plot(                1:ncol,D.lon(irow,:),'.-r','Displayname','interp1')
         xlabel('pixel #')
         xlabel('longitude')
      
         subplot(1,2,2)
         plot(single(T.cntl_pt_cols),T.lat(irow,:),'.-b','Displayname','per 8')
         hold on
         plot(                1:ncol,D.lat(irow,:),'.-r','Displayname','interp1')
         xlabel('pixel #')
         xlabel('latitude')
         
      end
      
      %% mask
      
      if OPT.mask
         D.mask      = seawifs_mask(D.l2_flags,[2 10],'disp',0); % remove clouds, ice and land
         D.(varname) = double(D.(varname)).*D.mask; % yu cannot mix int16 and int32(flags)
      end
      
      %% plot image (can be slow: no default)
      
      if OPT.plot
         h.fig = figure;
         pcolorcorcen(D.lon,D.lat,double(D.(varname)))
         title(['SeaWiFS image ',...
                datestr(D.datenum(1),'yyyy-mm-dd  HH:MM:SS'),' - ',...
                datestr(D.datenum(2),            'HH:MM:SS'),' (doy:',...
                num2str(yearday(D.datenum(1))),')'])
         colorbarwithhtext([char(D.long_name),'  [',mktex(D.units),']'],'horiz');
         axislat
         grid on
         tickmap('ll')
         %% plot outline of image
         hold on
         plot(D.lon(  1,  :),D.lat(  1,  :),'color',[.5 .5 .5])
         plot(D.lon(  :,  1),D.lat(  :,  1),'color',[.5 .5 .5])
         plot(D.lon(end,  :),D.lat(end,  :),'color',[.5 .5 .5])
         plot(D.lon(  :,end),D.lat(  :,end),'color',[.5 .5 .5])
         %% plot land
         try
          L.lon = nc_varget(OPT.ldb,'lon');
          L.lat = nc_varget(OPT.ldb,'lat');
          hold on
          plot(L.lon,L.lat,'k')
         end
         text(1,0,mktex(' image: $Id: seawifs_L2_read.m 5128 2011-08-29 10:19:40Z boer_g $'),'units','normalized','rotation',90,'verticalalignment','top','fontsize',6)
         if OPT.export
            print2screensize([hdfname,'_',varname,'.png']);
         end
         try;close(h.fig);end
         
      end
      
   end % empty file

   if      OPT.delete & OPT.unzip & zipped
      delete(hdfname)
   elseif ~OPT.delete & OPT.unzip & zipped
      disp(['gunzipped ',zipname,': monitor diskspace or use seawifs_L2_read(...,''delete'',1).']);
   end
   
   if     nargout==1
        varargout = {D};
   elseif nargout==2
        varargout = {D,M};
   else
        varargout = {D,M};
   end
   
%% EOF   