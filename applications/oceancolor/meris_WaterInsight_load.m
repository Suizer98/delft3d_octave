function D = meris_WaterInsight_load(fname,varargin)
%MERIS_WaterInsight_LOAD  load bundle of processed MERIS *.mat files as defined by WaterInsight
%
%    D = meris_WaterInsight_load(fname)
%
% loads data and meta-data from:
%
%   'MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000__hydropt74.mat'
%   'MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000__l2flags.mat'  
%   'MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000__latlon.mat'   
%
% fname can be either of these mat filenames.
%
%See also: MERIS_MASK, MERIS_FLAGS, MERIS_NAME2META

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Jul Deltares
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
% $Id: meris_WaterInsight_load.m 7364 2012-10-02 06:24:08Z boer_g $
% $Date: 2012-10-02 14:24:08 +0800 (Tue, 02 Oct 2012) $
% $Author: boer_g $
% $Revision: 7364 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_WaterInsight_load.m $
% $Keywords: $


   OPT.debug = 0; % does not load data (mat files)
   
   OPT = setproperty(OPT,varargin);

%% Get meta info

   D = meris_name2meta(fname);

%% Add known meta info

   D.institution                 = 'WaterInsight';
   D.references                  = 'http://www.waterinsight.nl';
   D.email                       = 'info@waterinsight.nl';
   D.version                     = [];

   D.timezone                    = '+00:00'; % GMT
   D.epsg                        = 4326;      % wgs84
   D.longitude_of_prime_meridian = 0.0;       % http://www.epsg-registry.org/
   D.semi_major_axis             = 6378137.0;
   D.inverse_flattening          = 298.257223563;
   D.flags                       = meris_flags;
   
   % units

if ~OPT.debug

%% Load data
  tmp_fnam=[filepathstr(D.filename),filesep,D.basename,'_hydropt74.mat'];
  if(exist(tmp_fnam))
    D = mergestructs(D,load(tmp_fnam));
  end
  
  tmp_fnam=[filepathstr(D.filename),filesep,D.basename,'_l2flags.mat'];
  if(exist(tmp_fnam))
    D = mergestructs(D,load(tmp_fnam));
  end
  
  tmp_fnam=[filepathstr(D.filename),filesep,D.basename,'_latlon.mat'];
  if(exist(tmp_fnam))
    D = mergestructs(D,load(tmp_fnam));
  end
  
  tmp_fnam=[filepathstr(D.filename),filesep,D.basename,'_wind.mat']; % note onyl wspeed is on image raster
  if(exist(tmp_fnam))
    D = mergestructs(D,load(tmp_fnam));
  end

  tmp_fnam=[filepathstr(D.filename),filesep,D.basename,'_SD.mat'];
  if(exist(tmp_fnam))   
    D = mergestructs(D,load(tmp_fnam));
 end
%% processing meta info

   D.metaData.SIOP = '>CLASSIFIED<';
   
%% Change field names to match those of IVMMoS2

   D.lon          = D.biglon;
   D.lat          = D.biglat;
  %D.?            = D.c (:,:,1);
  %D.?_std_err    = D.dc(:,:,1);
   D.Chla         = D.c (:,:,2);
   D.Chla_std_err = D.dc(:,:,2);
   D.TSM          = D.c (:,:,3);
   D.TSM_std_err  = D.dc(:,:,3);
   D.CDOM         = D.c (:,:,4);
   D.CDOM_std_err = D.dc(:,:,4);
   if(isfield(D,'sd2'))
    D.SD           = D.sd2(:,:);
   end
   D = rmfield(D,'biglon');
   D = rmfield(D,'biglat');
   D = rmfield(D,'c'     );
   D = rmfield(D,'dc'    );

end

%% Append meta-info
%  http://www.mumm.ac.be/OceanColour/Sensors/meris.php

   D.bands.nr = [...
      1
      2
      3
      4
      5
      6
      7
      8];
   
   D.bands.wavelength = [...
      412.5  
      442.5 	
      490 	
      510 	
      560 	
      620 	
      665 	
      681.25 ];
   
   D.bands.width = [...
      10  	
      10 	
      10 	
      10 	
      10 	
      10 	
      10 	
      7.5];
   
   D.bands.description = {...
      'Yellow substance, turbidity',...
      'Chlorophyll absorption maximum',...
      'Chlorophyll, other pigments',...
      'Turbidity, suspended sediment, red tides',...
      'Chlorophyll reference, suspended sediment',...
      'Suspended sediment',...
      'Chlorophyll absorption',...
      'Chlorophyll fluorescence'};
      
%% EOF      