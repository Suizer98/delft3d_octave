function flags = seawifs_flags(varargin),
%SEAWIFS_FLAGS  select from table with SeaWiFS/MODIS L2/L3 flag codes and descriptions
%
%    T = seawifs_flags(<code>)
%
% when no code is supplied, all codes are returned (modis_flags = seawifs_flags).
%
% returns a struct T with the codes, names and properties fo all 24 MERIS flags.
%
% Table 3 from SeaWiFS Ocean_Level-2_Data_Products.pdf <http://oceancolor.gsfc.nasa.gov/VALIDATION/flags.html>
% <http://oceancolor.gsfc.nasa.gov/DOCS/>
% <http://modis-atmos.gsfc.nasa.gov/tools_bit_interpretation.html>
% 
% +---------------------------------------------------------------------------------- 
% |code =  algorithm name    condition indicated
% |bit+1                  3 are masked at Level 3 - ocean color processing, * = spare
% +---------------------------------------------------------------------------------- 
% | 1      ATM_FAIL       3  Atmospheric correction failure
% | 2      LAND           3  Pixel is over land
% | 3      PRODWARN          One or more product warnings
% | 4      HIGLINT           High sun glint
% | 5      HILT           3  Observed radiance very high or saturated
% | 6      HISATZEN       3  High sensor view zenith angle
% | 7      COASTZ            Pixel is in shallow water
% | 8      NEGLW           * negative water leaving radiance
% | 9      STRAYLIGHT     3  Straylight contamination is likely
% |10      CLDICE         3  Probable cloud or ice contamination
% |11      COCCOLITH      3  Coccolithofores detected
% |12      TURBIDW           Turbid water detected
% |13      HISOLZEN       3  High solar zenith
% |14      HITAU           * high aearosol concentration
% |15      LOWLW          3  Very low water-leaving radiance (cloud shadow)
% |16      CHLFAIL        3  Derived product algorithm failure
% |17      NAVWARN        3  Navigation quality is reduced
% |18      ABSAER            possible absorbing aerosol (disabled)
% |19      TRICHO            trichodesmium
% |20      MAXAERITER     3* Aerosol iterations exceeded max
% |21      MODGLINT          Moderate sun glint contamination
% |22      CHLWARN        3  Derived product quality is reduced
% |23      ATMWARN        3  Atmospheric correction is suspect
% |24      DARKPIXEL       * dark pixel(Lt - Lt < 0) for any band
% |25      SEAICE            Possible sea ice contamination
% |26      NAVFAIL        3  Bad navigation
% |27      FILTER         3  Pixel rejected by user-defined filter
% |28      SSTWARN           SST quality is reduced
% |29      STTFAIL           SST quality is bad
% |30      HIPOL             High degree of polarization
% |31      PRODFAIL          Derived product failure
% |32      OCEAN           * clear ocean data (no clouds, land or ice)
% +---------------------------------------------------------------------------------- 
% Table indicates flags used in Fourth SeaWiFS Data Reprocessing.
%
% Note that for NASA ocean color products, the FLAG codes are the ABOVE 1-based indices, 
% i.e. the code is the index into the above table. Handy, as matlab indices are 1-based!
% (for these codes holds: code = 0-based-bit + 1, which is taken care of inside seawifs_mask).
%
%See also: BITAND, SEAWIFS_MASK, SEAWIFS_L2_READ, MERIS_FLAGS, MODIS_FLAGS
 
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
% $Id: seawifs_flags.m 4005 2011-02-08 21:04:45Z boer_g $
% $Date: 2011-02-09 05:04:45 +0800 (Wed, 09 Feb 2011) $
% $Author: boer_g $
% $Revision: 4005 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/seawifs_flags.m $
% $Keywords: $

   flags.bit  = [0:31]; % code = bit + 1
   flags.code = [1:32]; % code = bit + 1
   flags.name = ...
                {'ATM_FAIL',...    %  1
                 'LAND',...        %  2
                 'PRODWARN',...    %  3
                 'HIGLINT',...     %  4
                 'HILT',...        %  5
                 'HISATZEN ',...   %  6
                 'COASTZ',...      %  7
                 'NEGLW',...       %  8
                 'STRAYLIGHT',...  %  9
                 'CLDICE',...      % 10
                 'COCCOLITH',...   % 11
                 'TURBIDW',...     % 12
                 'HISOLZEN',...    % 13
                 'HITAU',...       % 14
                 'LOWLW',...       % 15
                 'CHLFAIL',...     % 16
                 'NAVWARN',...     % 17
                 'ABSAER',...      % 18
                 'TRICHO',...      % 19
                 'MAXAERITER',...  % 20
                 'MODGLINT',...    % 21
                 'CHLWARN',...     % 22
                 'ATMWARN',...     % 23
                 'DARKPIXEL',...   % 24
                 'SEAICE',...      % 25
                 'NAVFAIL',...     % 26
                 'FILTER',...      % 27
                 'SSTWARN',...     % 28
                 'STTFAIL',...     % 29
                 'HIPOL',...       % 30
                 'PRODFAIL',...    % 31
                 'OCEAN'};         % 32
 
    flags.description = ...
                {'Atmospheric correction failure',... %  1
                 'Pixel is over land',... %  2
                 'One or more product warnings',... %  3
                 'High sun glint',... %  4
                 'Observed radiance very high or saturated',... %  5
                 'High sensor view zenith angle',... %  6
                 'Pixel is in shallow water',... %  7
                 'negative water leaving radiance',... %  8
                 'Straylight contamination is likely',... %  9
                 'Probable cloud or ice contamination',... % 10
                 'Coccolithofores detected',... % 11
                 'Turbid water detected',... % 12
                 'High solar zenith',... % 13
                 'high aearosol concentration',... % 14
                 'Very low water-leaving radiance (cloud shadow)',... % 15
                 'Derived product algorithm failure',... % 16
                 'Navigation quality is reduced',... % 17
                 'possible absorbing aerosol (disabled)',... % 18
                 'trichodesmium',... % 19
                 'Aerosol iterations exceeded max',... % 20
                 'Moderate sun glint contamination',... % 21
                 'Derived product quality is reduced',... % 22
                 'Atmospheric correction is suspect',... % 23
                 'dark pixel(Lt - Lt < 0) for any band',... % 24
                 'Possible sea ice contamination',... % 25
                 'Bad navigation',... % 26
                 'Pixel rejected by user-defined filter',... % 27
                 'SST quality is reduced',... % 28
                 'SST quality is bad',... % 29
                 'High degree of polarization',... % 30
                 'Derived product failure',... % 31
                 'clear ocean data (no clouds, land or ice)'};   % 32  
                 
%% Extract one bit if requested

   if nargin==1
      code   = varargin{1};
      index = find(flags.code==code);

      flags.code             = flags.code(index)          ;
      flags.bit              = flags.bit(index)          ;
      flags.name             = flags.name{index}          ;
      flags.description      = flags.description{index}   ;
      
   end

%% EOF