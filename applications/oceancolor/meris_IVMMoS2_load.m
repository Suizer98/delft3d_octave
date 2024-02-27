function D = meris_IVMMoS2_load(fname)
%MERIS_IVMMoS2_LOAD  load processed MERIS *.mat file as defined by IVMMoS2
%
%    D = load(fname)
%
% loads data and meta-data from:
%
%   'MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000_deltares.mat'
%
% fname should point to this mat filename.
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Get meta info

   D = meris_name2meta(fname);

%% Add known meta info

   D.institution                 = 'IVM';
   D.references                  = 'http://www.vu.nl/ivm';
   D.email                       = 'marieke.eleveld@ivm.vu.nl';
   
   D.timezone                    = '+00:00'; % GMT
   D.epsg                        = 4326;      % wgs84
   D.longitude_of_prime_meridian = 0.0;       % http://www.epsg-registry.org/
   D.semi_major_axis             = 6378137.0;
   D.inverse_flattening          = 298.257223563;
   D.flags                       = meris_flags;
   
   % units

%% Load data

   load(fullfile(filepathstr(D.filename),[D.basename,'.mat']));
   D = mergestructs(D,d);
   clear 'd';

%% Processing meta info

   D.metaData.T          = [0 1 1 1];
   D.metaData.Ci         = [1 5 5 0.3000];
   D.metaData.b	         = [1 2 3 4 5 6 7 9];
   D.metaData.Fdiff      = 0.4000;
   D.metaData.method     = 1;
   D.metaData.errormodel = 0;
   D.metaData.maxIter    = 100;
   D.metaData.SIOP       = 'NEWSIOP2006_5_ASnHGnPCD113yBIy'; % ME NEWSIOP2006_5_ASnHGnPCD113yBIy
   D.metaData.fName      = 'C:\Bio-Opti\AAN\LUT16.dat';
   
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
      8     
      9];      % ME we used bands 1..7 & 9
  
   D.bands.wavelength = [...
      412.5  
      442.5 	
      490 	
      510 	
      560 	
      620 	
      665 	
      681.25 
      709];    % ME we used bands 1..7 & 9
   
   D.bands.width = [...
      10  	
      10 	
      10 	
      10 	
      10 	
      10 	
      10 	
      7.5
      10];     % ME we used bands 1..7 & 9
   
   D.bands.description = {...
      'Yellow substance, turbidity',...
      'Chlorophyll absorption maximum',...
      'Chlorophyll, other pigments',...
      'Turbidity, suspended sediment, red tides',...
      'Chlorophyll reference, suspended sediment',...
      'Suspended sediment',...
      'Chlorophyll absorption',...
      'Chlorophyll fluorescence',...
      ''};
      
%% EOF      
