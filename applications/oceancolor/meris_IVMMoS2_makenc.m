%MERIS_IVMMoS2_makenc  rewrite processed MERIS file as defined by IVMMoS2 into NetCDF files
%
%
%See also: MERIS_MASK, MERIS_FLAGS, MERIS_NAME2META,MERIS_IVMMoS2_LOAD

% TO DO check units
% TO DO check definition of standard error
% TO DO check display of originator info & use rights (cf Creative Commons & GNU licensing)
% TO DO add flags description next to names
% TO DO arrays as attributes
% TO DO check CF feature type

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 August IVM-VU
%       N.O.de Reus
%
%       nils.de.reus@ivm.vu.nl	
%
%       Institute for Environmental Studies
%       De Boelelaan 1085/1087
%       1081 HV Amsterdam
%       The Netherlands
%
%   This work is derived from meris_WaterInsight2nc V0.3.
%   All conditions apply as detailed in the original copyright below:
%
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Initialize

   OPT.dump           = 0;
   OPT.pause          = 0;
   OPT.debug          = 0;
   OPT.zip            = 0; % when data becomes to big, zip or bzip2 the nc files (TO DO).
   OPT.version        = 'V0.3-2 DeReus-Blaas';
   
%% File loop

%
%   Hardcoding paths is absolutely hideous, but since everyone was using their own path aliases and shortcuts to
%   the data, there was just no guarantee that the correct path could be constructed from the input argument.
%
    OPT.directory.raw  = [pwd,filesep,'mat'];
%   OPT.directory.raw  = 'E:\Remote Sensing\PROJECTS\Active\MoS2\Oplevering\codeandresults\intermediate';
    OPT.directory.nc   = [pwd,filesep,'nc'];
%   OPT.directory.nc   = 'E:\Remote Sensing\PROJECTS\Active\MoS2\Oplevering\RepoMoS2\trunk\meris';
   
   mkpath(OPT.directory.nc)

   OPT.files          = dir([OPT.directory.raw filesep 'MER*.mat']);
   
   [IMAGE_names,extensions] = meris_directory(OPT.directory.raw);

   for ifile=1:length(IMAGE_names)  
   
      OPT.filename = ([OPT.directory.raw, filesep, IMAGE_names{ifile}]); % MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000*.mat
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(IMAGE_names)),': ',filename(OPT.filename)])

%% 0 Read raw data

      D = meris_IVMMoS2_load(OPT.filename);
      D.version = OPT.version;
      
      if OPT.debug
      pcolorcorcen(D.lon,D.lat,D.l2_flags)
      end

%% 1a Create file
   
      OPT.ext = '';

      outputfile    = [OPT.directory.nc,filesep,D.basename,OPT.ext,'.nc']; % 30 (ISO 8601) 'yyyymmddTHHMMSS' name
   
      meris2nc(outputfile)
      
%% 6 Check
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
%% Pause
   
      if OPT.pause
         pausedisp
      end
      
   end %for ifile=1:length(IMAGE_names)  

%% EOF