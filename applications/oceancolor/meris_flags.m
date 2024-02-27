function flags = meris_flags(varargin),
%MERIS_FLAGS  select from table with MERIS flag bits and descriptions
%
% T = MERIS_FLAGS(<bit>)
%
% when no bit is supplied, all bits are returned.
%
% returns a struct T with the bit #s, names and properties fo all 24 MERIS flags.
%
% Table 2.35 from MERIS product handbook <http://envisat.esa.int/handbooks/meris/>
% 
% +----------------------------------------------------------------------------------------------------------+
% |bit symbol       type        Relevant to surface type    description                                      |
% | #                              water land  cloud	                                                     |
% +----------------------------------------------------------------------------------------------------------+
% |23  LAND         class           1     1     1       land product available      }                        |
% |22  CLOUD        class           1     1     1       cloud product available     } mutually exclusive     |
% |21  WATER        class           1     1     1       water product available     }                        |
% |20  PCD_1_13     confidence      1     1     1       confidence flag for MDS 1 to 13                      |
% |19  PCD_1_14     confidence      1     1     1       confidence flag for MDS 14                           |
% |18  PCD_1_15     confidence      1     1     1       confidence flag for MDS 15                           |
% |17  PCD_1_16     confidence      1     0     0       confidence flag for MDS 16                           |
% |16  PCD_1_17     confidence      1     1     0       confidence flag for MDS 17                           |
% |15  PCD_1_18     confidence      1     1     1       confidence flag for MDS 18                           |
% |14  PCD_1_19     confidence      1     1     1       confidence flag for MDS 19                           |
% |13  COASTLINE    science         1     1     1       coastline flag                                       |
% |12  COSMETIC     science         1     1     1       cosmetic flag (from level-1b)                        |
% |11  SUSPECT      science         1     1     1       suspect flag (from level-1b)                         |
% |10  ABSOA_CONT   science         1     0     0       continental absorbing aerosol                        |
% | 9  ABSOA_DUST   science         1     0     0       dust-like absorbing aerosol                          |
% | 8  CASE2_S      science         1     0     0       turbid water                                         |
% | 7  CASE2_ANOM   science         1     0     0       anomalous scattering water                           |
% | 6  CASE2_Y      science         1     0     0       yellow substance loaded water                        |
% | 5  ICE_HAZE     science         1     0     0       ice or high aerosol loaded pixel                     |
% | 4  MEDIUM_GLINT science         1     0     0       corrected for glint                                  |
% | 3  DDV          science         0     1     0       dense dark vegetation                                |
% | 2  HIGH)_GLINT  science         1     1     1       high (uncorrected) glint                             |
% | 1  P_CONFIDENCE science         1     1     1       the 2 pressure estimates do not compare successfully |
% | 0  LOW_PRESSURE science         1     1     1       computed pressure lower than ECMWF one               |
% +----------------------------------------------------------------------------------------------------------+
%
% Note that the bits are ZERO_based, so the bit is not the index in 
% the table, because matlab is 1-based!
%
%See also: BITAND, MERIS_NAME2META, MERIS_MASK, MODIS_FLAGS, SEAWIFS_FLAGS
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Oct. Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: meris_flags.m 3249 2010-11-09 12:52:47Z boer_g $
% $Date: 2010-11-09 20:52:47 +0800 (Tue, 09 Nov 2010) $
% $Author: boer_g $
% $Revision: 3249 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_flags.m $
% $Keywords: $


   flags.bit  = [23:-1:0];
   flags.name = ...
             {'LAND',...        % 23
              'CLOUD',...       % 22
              'WATER',...       % 21
              'PCD_1_13',...    % 20
              'PCD_1_14',...    % 19
              'PCD_1_15',...    % 18
              'PCD_1_16',...    % 17
              'PCD_1_17',...    % 16
              'PCD_1_18',...    % 15
              'PCD_1_19',...    % 14
              'COASTLINE',...   % 13
              'COSMETIC',...    % 12
              'SUSPECT',...     % 11
              'ABSOA_CONT',...  % 10
              'ABSOA_DUST',...  % 9
              'CASE2_S',...     % 8
              'CASE2_ANOM',...  % 7
              'CASE2_Y',...     % 6
              'ICE_HAZE',...    % 5
              'MEDIUM_GLINT',...% 4
              'DDV',...         % 3
              'HIGH_GLINT',...  % 2
              'P_CONFIDENCE',...% 1
              'LOW_PRESSURE',...% 0
             };
   flags.type = ...
             {'class',...      % 23
              'class',...      % 22
              'class',...      % 21
              'confidence',... % 20
              'confidence',... % 19
              'confidence',... % 18
              'confidence',... % 17
              'confidence',... % 16
              'confidence',... % 15
              'confidence',... % 14
              'science',...    % 13
              'science',...    % 12
              'science',...    % 11
              'science',...    % 10
              'science',...    % 9
              'science',...    % 8
              'science',...    % 7
              'science',...    % 6
              'science',...    % 5
              'science',...    % 4
              'science',...    % 3
              'science',...    % 2
              'science',...    % 1
              'science',...    % 0
             };
   flags.description = ...
             {'land product available',...                                 % 23
              'cloud product available',...                                % 22
              'water product available',...                                % 21
              'confidence flag for MDS 1 to 13',...                        % 20
              'confidence flag for MDS 14',...                             % 19
              'confidence flag for MDS 15',...                             % 18
              'confidence flag for MDS 16',...                             % 17
              'confidence flag for MDS 17',...                             % 16
              'confidence flag for MDS 18',...                             % 15
              'confidence flag for MDS 19',...                             % 14
              'coastline flag',...                                         % 13
              'cosmetic flag (from level-1b)',...                          % 12
              'suspect flag (from level-1b)',...                           % 11
              'continental absorbing aerosol',...                          % 10
              'dust-like absorbing aerosol',...                            % 9
              'turbid water',...                                           % 8
              'anomalous scattering water',...                             % 7
              'yellow substance loaded water',...                          % 6
              'ice or high aerosol loaded pixel',...                       % 5
              'corrected for glint',...                                    % 4
              'dense dark vegetation',...                                  % 3
              'high (uncorrected) glint',...                               % 2
              'the two pressure estimates do not compare successfully',... % 1
              'computed pressure lower than ECMWF one',...                 % 0
             };
   %                       23 22 21 20   19 18 17 16 15   14 13 12 11 10   9  8  7  6  5    4  3  2  1  0
   flags.relevant.water = [1  1  1  1    1  1  1  1  1    1  1  1  1  1    1  1  1  1  1    1  0  1  1  1  ];
   flags.relevant.land  = [1  1  1  1    1  1  0  1  1    1  1  1  1  0    0  0  0  0  0    0  1  1  1  1  ];
   flags.relevant.cloud = [1  1  1  1    1  1  0  0  1    1  1  1  1  0    0  0  0  0  0    0  0  1  1  1  ];
   
   %% Extract one bit if requested
   %% -----------------------------
   
   if nargin==1
      bit   = varargin{1};
      index = find(flags.bit==bit);

      flags.bit              = flags.bit(index)           ;
      flags.name             = flags.name{index}          ;
      flags.type             = flags.type{index}          ;
      flags.description      = flags.description{index}   ;
      flags.relevant.water   = flags.relevant.water(index);
      flags.relevant.land    = flags.relevant.land(index) ;
      flags.relevant.cloud   = flags.relevant.cloud(index);
      
   end

%% EOF