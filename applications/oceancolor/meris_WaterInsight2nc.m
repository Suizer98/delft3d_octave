function varargout = meris__WaterInsight2nc(rawdir,ncdir)
%MERIS_WATERINSIGHT2NC(rawdir,ncdir)  rewrite bundle of processed MERIS files as defined by WaterInsight into NetCDF files
%
%
%See also: MERIS_MASK, MERIS_FLAGS, MERIS_NAME2META,MERIS_WaterInsight_LOAD

% TO DO check units Chla, CDOM
% TO DO check definition of standard error
% TO DO check display of originator info & use rights (cf Creative Commons & GNU licensing)
% TO DO add flags description next to names
% TO DO arrays as attributes
% TO DO check CF feature type
% To DO CHECK if sensible to add phi0, phiv, theta0,thetav, windu, windv, wspeed, spectral band width 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 July Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: meris_WaterInsight2nc.m 4539 2011-05-02 21:05:23Z boer_g $
% $Date: 2011-05-03 05:05:23 +0800 (Tue, 03 May 2011) $
% $Author: boer_g $
% $Revision: 4539 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_WaterInsight2nc.m $
% $Keywords: $

%% Initialize

   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   OPT.dump           = 0;
   OPT.pause          = 0;
   OPT.debug          = 0;
   OPT.zip            = 0; % when data becomes to big, zip or bzip2 the nc files (TO DO).
   OPT.version        = 'V1.1 Twigt-DeBoer-Blaas';
   
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention

%% File loop

   OPT.directory.raw  = rawdir;
   OPT.directory.nc   = ncdir;

   mkpath(OPT.directory.nc)
  [IMAGE_names,extensions] = meris_directory([OPT.directory.raw]);

   for ifile=1:length(IMAGE_names)  
   
      OPT.filename = ([OPT.directory.raw, filesep, IMAGE_names{ifile}]); 
      % MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(IMAGE_names)),': ',filename(OPT.filename)])

%% 0 Read raw data

      D         = meris_WaterInsight_load(OPT.filename);
      D.version = OPT.version;
      
      if OPT.debug
      pcolorcorcen(D.lon,D.lat,D.l2_flags)
      end

%% 1a Create file
   
      OPT.ext = '';

      outputfile    = [OPT.directory.nc,filesep,D.basename,OPT.ext,'.nc']; % 30 (ISO 8601) 'yyyymmddTHHMMSS' name
   
      meris2nc(outputfile,D)

%% 6 Check
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
%% Pause
   
      if OPT.pause
         pausedisp
      end
      
   end %for ifile=1:length(IMAGE_names)  %1 if subdirs made by Steef

%% EOF