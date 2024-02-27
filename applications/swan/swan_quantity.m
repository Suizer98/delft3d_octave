function varargout = swan_quantity
%SWAN_QUANTITY            returns default properties of SWAN output parameters
%
%  DAT       = SWAN_QUANTITY returns properties per parameter
% [DAT,DAT0] = SWAN_QUANTITY returns also properties per property
%
% where DAT is struct with field names as returned by 
% SWAN_SHORTNAME2KEYWORD, each with subfields
%
%  OVKEYW{IVTYPE} =    keyword used in SWAN command      
%  OVSNAM{IVTYPE} =    short name                        
%  OVLNAM{IVTYPE} =    long name                         
%  OVUNIT{IVTYPE} =    unit name                         
%  OVSVTY{IVTYPE} =    type (scalar/vector etc.)         
%  OVLLIM{IVTYPE} =    lower and upper limit for ascii plotting width
%  OVULIM{IVTYPE} =                                      
%  OVLEXP{IVTYPE} =    lowest and highest expected value: valid_range 
%  OVHEXP{IVTYPE} =                                      
%  OVEXCV{IVTYPE} =    exception value                   
%
%See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, 
%          SWAN_SHORTNAME2KEYWORD, SWAN_DEFAULTS, SWAN_QUANTITYTEX

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
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

% $Id: swan_quantity.m 11631 2015-01-13 09:31:14Z gerben.deboer.x $
% $Date: 2015-01-13 17:31:14 +0800 (Tue, 13 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_quantity.m $

% 2009 apr 23: added names from test output (source terms)

%% Pre-allocate for speed

   nval   = 57 + 3 + 8; % native + fluid mud + test output
   OVKEYW = cell(1,nval);
   OVSNAM = cell(1,nval);
   OVLNAM = cell(1,nval);
   OVUNIT = cell(1,nval);
   OVSVTY = cell(1,nval);
   OVLLIM = cell(1,nval);
   OVULIM = cell(1,nval);
   OVLEXP = cell(1,nval);
   OVHEXP = cell(1,nval);
   OVEXCV = cell(1,nval);
   OVCFUD = cell(1,nval); % TO DO CF UD units
   OVCFSD = cell(1,nval); % TO DO CF standard_names

%% Manually edited 3 things from code form SWANMAIN.for below
   %% 1
   %OVUNIT{IVTYPE} = UL
   %OVUNIT{IVTYPE} = UH
   %OVUNIT{IVTYPE} = UV
   %OVUNIT{IVTYPE} = UT
   %OVUNIT{IVTYPE} = UDI
   %OVUNIT{IVTYPE} = UF
   %% 2 removed version SWAN numbers
   %% 3 added ; at end of line using regular expressions


%;
      IVTYPE = 1;
      OVKEYW{IVTYPE} = 'XP'                                        ;
      OVSNAM{IVTYPE} = 'Xp';
      OVLNAM{IVTYPE} = 'X user coordinate';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
      OVCFNM{IVTYPE} = 'projection_x_coordinate';
%;
      IVTYPE = 2;
      OVKEYW{IVTYPE} = 'YP'                                        ;
      OVSNAM{IVTYPE} = 'Yp';
      OVLNAM{IVTYPE} = 'Y user coordinate';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
      OVCFNM{IVTYPE} = 'projection_x_coordinate';
%;
      IVTYPE = 3;
      OVKEYW{IVTYPE} = 'DIST'                                      ;
      OVSNAM{IVTYPE} = 'Dist';
      OVLNAM{IVTYPE} = 'distance along output curve';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = 'sea_floor_depth_below_sea_level ';
%;
      IVTYPE = 4;
      OVKEYW{IVTYPE} = 'DEP'                                       ;
      OVSNAM{IVTYPE} = 'Depth';
      OVLNAM{IVTYPE} = 'Depth';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 5;
      OVKEYW{IVTYPE} = 'VEL'                                       ;
      OVSNAM{IVTYPE} = 'Vel';
      OVLNAM{IVTYPE} = 'Current velocity';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -2.;
      OVHEXP{IVTYPE} = 2.;
      OVEXCV{IVTYPE} = 0.;
      OVCFNM{IVTYPE} = 'sea_water_x_velocity sea_water_y_velocity';
%;
      IVTYPE = 6;
      OVKEYW{IVTYPE} = 'UBOT'                                      ;
      OVSNAM{IVTYPE} = 'Ubot';
      OVLNAM{IVTYPE} = 'Orbital velocity at the bottom';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -10.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 7;
      OVKEYW{IVTYPE} = 'DISS'                                      ;
      OVSNAM{IVTYPE} = 'Dissip';
      OVLNAM{IVTYPE} = 'Energy dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 8;
      OVKEYW{IVTYPE} = 'QB'                                        ;
      OVSNAM{IVTYPE} = 'Qb';
      OVLNAM{IVTYPE} = 'Fraction breaking waves';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -1.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 9;
      OVKEYW{IVTYPE} = 'LEA'                                       ;
      OVSNAM{IVTYPE} = 'Leak';
      OVLNAM{IVTYPE} = 'Energy leak over spectral boundaries';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 10;
      OVKEYW{IVTYPE} = 'HS'                                        ;
      OVSNAM{IVTYPE} = 'Hsig';
      OVLNAM{IVTYPE} = 'Significant wave height';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_significant_height';
%                                                                  ;
      IVTYPE = 11;
      OVKEYW{IVTYPE} = 'TM01'                                      ;
      OVSNAM{IVTYPE} = 'Tm01'                                      ;
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_mean_period_from_variance_spectral_density_first_frequency_moment';
%;
      IVTYPE = 12;
      OVKEYW{IVTYPE} = 'RTP'                                       ;
      OVSNAM{IVTYPE} = 'RTpeak'                                    ;
      OVLNAM{IVTYPE} = 'Relative peak period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_period_at_variance_spectral_density_maximum';
%;
      IVTYPE = 13;
      OVKEYW{IVTYPE} = 'DIR'                                       ;
      OVSNAM{IVTYPE} = 'Dir';
      OVLNAM{IVTYPE} = 'Average wave direction';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_from_direction';
%;
      IVTYPE = 14;
      OVKEYW{IVTYPE} = 'PDI'                                       ;
      OVSNAM{IVTYPE} = 'PkDir';
      OVLNAM{IVTYPE} = 'direction of the peak of the spectrum';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 15;
      OVKEYW{IVTYPE} = 'TDI'                                       ;
      OVSNAM{IVTYPE} = 'TDir';
      OVLNAM{IVTYPE} = 'direction of the energy transport';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 16;
      OVKEYW{IVTYPE} = 'DSPR'                                      ;
      OVSNAM{IVTYPE} = 'Dspr';
      OVLNAM{IVTYPE} = 'directional spreading';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 60.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 17;
      OVKEYW{IVTYPE} = 'WLEN'                                      ;
      OVSNAM{IVTYPE} = 'Wlen';
      OVLNAM{IVTYPE} = 'Average wave length';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 200.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 18;
      OVKEYW{IVTYPE} = 'STEE'                                      ;
      OVSNAM{IVTYPE} = 'Steepn';
      OVLNAM{IVTYPE} = 'Wave steepness';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 19;
      OVKEYW{IVTYPE} = 'TRA'                                       ;
      OVSNAM{IVTYPE} = 'Transp';
      OVLNAM{IVTYPE} = 'Wave energy transport';
      OVUNIT{IVTYPE} = 'm3/s'                                      ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = 0.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 20;
      OVKEYW{IVTYPE} = 'FOR'                                       ;
      OVSNAM{IVTYPE} = 'WForce';
      OVLNAM{IVTYPE} = 'Wave driven force per unit surface';
      OVUNIT{IVTYPE} = 'UF'                                          ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -1.E5;
      OVULIM{IVTYPE} =  1.E5;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = 0.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 21;
      OVKEYW{IVTYPE} = 'AAAA'                                      ;
      OVSNAM{IVTYPE} = 'AcDens';
      OVLNAM{IVTYPE} = 'spectral action density';
      OVUNIT{IVTYPE} = 'm2s';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 22;
      OVKEYW{IVTYPE} = 'EEEE'                                      ;
      OVSNAM{IVTYPE} = 'EnDens';
      OVLNAM{IVTYPE} = 'spectral energy density';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 23;
      OVKEYW{IVTYPE} = 'AAAA'                                      ;
      OVSNAM{IVTYPE} = 'Aux';
      OVLNAM{IVTYPE} = 'auxiliary variable';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 24;
      OVKEYW{IVTYPE} = 'XC'                                        ;
      OVSNAM{IVTYPE} = 'Xc';
      OVLNAM{IVTYPE} = 'X computational grid coordinate';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 25;
      OVKEYW{IVTYPE} = 'YC'                                        ;
      OVSNAM{IVTYPE} = 'Yc';
      OVLNAM{IVTYPE} = 'Y computational grid coordinate';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 26;
      OVKEYW{IVTYPE} = 'WIND'                                      ;
      OVSNAM{IVTYPE} = 'Windv';
      OVLNAM{IVTYPE} = 'Wind velocity at 10 m above sea level';
      OVUNIT{IVTYPE} = 'UV'                                          ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -50.;
      OVHEXP{IVTYPE} = 50.;
      OVEXCV{IVTYPE} = 0.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 27;
      OVKEYW{IVTYPE} = 'FRC'                                       ;
      OVSNAM{IVTYPE} = 'FrCoef';
      OVLNAM{IVTYPE} = 'Bottom friction coefficient';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%                                                                  ;
      IVTYPE = 28;
      OVKEYW{IVTYPE} = 'RTM01'                                     ;
      OVSNAM{IVTYPE} = 'RTm01'                                     ;
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 29                                                  ;
      OVKEYW{IVTYPE} = 'EEEE'                                      ;
      OVSNAM{IVTYPE} = 'EnDens';
      OVLNAM{IVTYPE} = 'energy density integrated over direction'  ;
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 30                                                  ;
      OVKEYW{IVTYPE} = 'DHS'                                       ;
      OVSNAM{IVTYPE} = 'dHs';
      OVLNAM{IVTYPE} = 'difference in Hs between iterations';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 31                                                  ;
      OVKEYW{IVTYPE} = 'DRTM01'                                    ;
      OVSNAM{IVTYPE} = 'dTm';
      OVLNAM{IVTYPE} = 'difference in Tm between iterations';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 2.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%                                                                  ;
      IVTYPE = 32;
      OVKEYW{IVTYPE} = 'TM02'                                      ;
      OVSNAM{IVTYPE} = 'Tm02';
      OVLNAM{IVTYPE} = 'Zero-crossing period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_mean_period_from_variance_spectral_density_second_frequency_moment';
%                                                                  ;
      IVTYPE = 33;
      OVKEYW{IVTYPE} = 'FSPR'                                      ;
      OVSNAM{IVTYPE} = 'FSpr'                                      ;
      OVLNAM{IVTYPE} = 'Frequency spectral width {Kappa}';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 34                                                  ;
      OVKEYW{IVTYPE} = 'URMS'                                      ;
      OVSNAM{IVTYPE} = 'Urms';
      OVLNAM{IVTYPE} = 'RMS of orbital velocity at the bottom';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 35                                                  ;
      OVKEYW{IVTYPE} = 'UFRI'                                      ;
      OVSNAM{IVTYPE} = 'Ufric';
      OVLNAM{IVTYPE} = 'Friction velocity';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 36                                                  ;
      OVKEYW{IVTYPE} = 'ZLEN'                                      ;
      OVSNAM{IVTYPE} = 'Zlen';
      OVLNAM{IVTYPE} = 'Zero velocity thickness of boundary layer';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 37                                                  ;
      OVKEYW{IVTYPE} = 'TAUW'                                      ;
      OVSNAM{IVTYPE} = 'TauW';
      OVLNAM{IVTYPE} = '    ';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 38                                                  ;
      OVKEYW{IVTYPE} = 'CDRAG'                                     ;
      OVSNAM{IVTYPE} = 'Cdrag';
      OVLNAM{IVTYPE} = 'Drag coefficient';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
%     *** wave-induced setup ***                                   ;
%;
      IVTYPE = 39                                                  ;
      OVKEYW{IVTYPE} = 'SETUP'                                     ;
      OVSNAM{IVTYPE} = 'Setup'                                     ;
      OVLNAM{IVTYPE} = 'Setup due to waves'                        ;
      OVUNIT{IVTYPE} = 'm'                                         ;
      OVSVTY{IVTYPE} = 1                                           ;
      OVLLIM{IVTYPE} = -1.                                         ;
      OVULIM{IVTYPE} = 1.                                          ;
      OVLEXP{IVTYPE} = -1.                                         ;
      OVHEXP{IVTYPE} = 1.                                          ;
      OVEXCV{IVTYPE} = -9.                                         ;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 40                                                  ;
      OVKEYW{IVTYPE} = 'TIME'                                      ;
      OVSNAM{IVTYPE} = 'Time';
      OVLNAM{IVTYPE} = 'Date-time';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -99999.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 41                                                  ;
      OVKEYW{IVTYPE} = 'TSEC'                                      ;
      OVSNAM{IVTYPE} = 'Tsec';
      OVLNAM{IVTYPE} = 'Time in seconds from reference time';
      OVUNIT{IVTYPE} = 's';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100000.;
      OVLEXP{IVTYPE} = -100000.;
      OVHEXP{IVTYPE} = 1000000.;
      OVEXCV{IVTYPE} = -99999.;
      OVCFNM{IVTYPE} = '';
%                                                               ;
      IVTYPE = 42;
      OVKEYW{IVTYPE} = 'PER'                                       ;
      OVSNAM{IVTYPE} = 'Period'                                    ;
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wind_wave_period';
%                                                               ;
      IVTYPE = 43;
      OVKEYW{IVTYPE} = 'RPER'                                      ;
      OVSNAM{IVTYPE} = 'RPeriod'                                   ;
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wind_wave_period';
%;
      IVTYPE = 44                                                  ;
      OVKEYW{IVTYPE} = 'HSWE'                                      ;
      OVSNAM{IVTYPE} = 'Hswell';
      OVLNAM{IVTYPE} = 'Wave height of swell part';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_swell_wave_significant_height';
%;
      IVTYPE = 45; % 40.03
      OVKEYW{IVTYPE} = 'URSELL'                                    ;
      OVSNAM{IVTYPE} = 'Ursell';
      OVLNAM{IVTYPE} = 'Ursell number';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 46; % 40.03
      OVKEYW{IVTYPE} = 'ASTD'                                      ;
      OVSNAM{IVTYPE} = 'ASTD';
      OVLNAM{IVTYPE} = 'Air-Sea temperature difference';
      OVUNIT{IVTYPE} = 'K';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -50.;
      OVULIM{IVTYPE} =  50.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 47; % 40.41
      OVKEYW{IVTYPE} = 'TMM10';
      OVSNAM{IVTYPE} = 'Tm_10';
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_mean_period_from_variance_spectral_density_inverse_frequency_moment';
%;
      IVTYPE = 48; % 40.41
      OVKEYW{IVTYPE} = 'RTMM10';
      OVSNAM{IVTYPE} = 'RTm_10';
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_mean_period_from_variance_spectral_density_inverse_frequency_moment';
%;
      IVTYPE = 49; % 40.21
      OVKEYW{IVTYPE} = 'DIFPAR';
      OVSNAM{IVTYPE} = 'DifPar';
      OVLNAM{IVTYPE} = 'Diffraction parameter';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -50.;
      OVULIM{IVTYPE} =  50.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 50; % 40.51
      OVKEYW{IVTYPE} = 'TMBOT';
      OVSNAM{IVTYPE} = 'TmBot';
      OVLNAM{IVTYPE} = 'Bottom wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 51; % 40.51
      OVKEYW{IVTYPE} = 'WATL';
      OVSNAM{IVTYPE} = 'Watlev';
      OVLNAM{IVTYPE} = 'Water level';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 52; % 40.51
      OVKEYW{IVTYPE} = 'BOTL';
      OVSNAM{IVTYPE} = 'Botlev';
      OVLNAM{IVTYPE} = 'Bottom level';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 53; % 40.51
      OVKEYW{IVTYPE} = 'TPS';
      OVSNAM{IVTYPE} = 'TPsmoo';
      OVLNAM{IVTYPE} = 'Relative peak period {smooth}';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = 'sea_surface_wave_period_at_variance_spectral_density_maximum';
%;
      IVTYPE = 54;
      OVKEYW{IVTYPE} = 'DISB';  % 40.61
      OVSNAM{IVTYPE} = 'Sfric'; % 40.85
      OVLNAM{IVTYPE} = 'Bottom friction dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 55;
      OVKEYW{IVTYPE} = 'DISSU'; % 40.61
      OVSNAM{IVTYPE} = 'Ssurf'; % 40.85
      OVLNAM{IVTYPE} = 'Surf breaking dissipation'; % 40.85
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 56;
      OVKEYW{IVTYPE} = 'DISW';   % 40.61
      OVSNAM{IVTYPE} = 'Swcap'; % 40.85
      OVLNAM{IVTYPE} = 'Whitecapping dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = 57;
      OVKEYW{IVTYPE} = 'DISV';                                          % 40.61
      OVSNAM{IVTYPE} = 'Sveg';                                          % 40.85
      OVLNAM{IVTYPE} = 'Vegetation dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 58;                                                      % 40.64
      OVKEYW{IVTYPE} = 'QP';
      OVSNAM{IVTYPE} = 'Qp';
      OVLNAM{IVTYPE} = 'Peakedness';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 59;                                                      % 40.64
      OVKEYW{IVTYPE} = 'BFI';
      OVSNAM{IVTYPE} = 'BFI';
      OVLNAM{IVTYPE} = 'Benjamin-Feir index';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1000.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 60;
      OVKEYW{IVTYPE} = 'GENE';                                          % 40.85
      OVSNAM{IVTYPE} = 'Genera';
      OVLNAM{IVTYPE} = 'Energy generation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 61;
      OVKEYW{IVTYPE} = 'GENW';                                          % 40.85
      OVSNAM{IVTYPE} = 'Swind';
      OVLNAM{IVTYPE} = 'Wind source term';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 62;
      OVKEYW{IVTYPE} = 'REDI';                                          % 40.85
      OVSNAM{IVTYPE} = 'Redist';
      OVLNAM{IVTYPE} = 'Energy redistribution';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 63;
      OVKEYW{IVTYPE} = 'REDQ';                                          % 40.85
      OVSNAM{IVTYPE} = 'Snl4';
      OVLNAM{IVTYPE} = 'Total absolute 4-wave interaction';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 64;
      OVKEYW{IVTYPE} = 'REDT';                                          % 40.85
      OVSNAM{IVTYPE} = 'Snl3';
      OVLNAM{IVTYPE} = 'Total absolute 3-wave interaction';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 65;
      OVKEYW{IVTYPE} = 'PROPA';                                         % 40.85
      OVSNAM{IVTYPE} = 'Propag';
      OVLNAM{IVTYPE} = 'Energy propagation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 66;
      OVKEYW{IVTYPE} = 'PROPX';                                         % 40.85
      OVSNAM{IVTYPE} = 'Propxy';
      OVLNAM{IVTYPE} = 'xy-propagation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 67;
      OVKEYW{IVTYPE} = 'PROPT';                                         % 40.85
      OVSNAM{IVTYPE} = 'Propth';
      OVLNAM{IVTYPE} = 'theta-propagation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 68;
      OVKEYW{IVTYPE} = 'PROPS';                                         % 40.85
      OVSNAM{IVTYPE} = 'Propsi';
      OVLNAM{IVTYPE} = 'sigma-propagation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 69;
      OVKEYW{IVTYPE} = 'RADS';                                          % 40.85
      OVSNAM{IVTYPE} = 'Radstr';
      OVLNAM{IVTYPE} = 'Radiation stress';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 70;
      OVKEYW{IVTYPE} = 'NPL';                                           % 41.12
      OVSNAM{IVTYPE} = 'Nplant';
      OVLNAM{IVTYPE} = 'Plants per m2';
      OVUNIT{IVTYPE} = '1/m2';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 71;
      OVKEYW{IVTYPE} = 'LWAVP';                                         % 41.15
      OVSNAM{IVTYPE} = 'Lwavp';
      OVLNAM{IVTYPE} = 'Peak wave length';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 200.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 72;
      OVKEYW{IVTYPE} = 'DISTU';
      OVSNAM{IVTYPE} = 'Stur';
      OVLNAM{IVTYPE} = 'Turbulent dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 73;
      OVKEYW{IVTYPE} = 'TURB';
      OVSNAM{IVTYPE} = 'Turb';
      OVLNAM{IVTYPE} = 'Turbulent viscosity';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 74;
      OVKEYW{IVTYPE} = 'DISM';                                          % 40.61
      OVSNAM{IVTYPE} = 'Smud';                                          % 40.85
      OVLNAM{IVTYPE} = 'Fluid mud dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'DISM'                                      ;
      OVSNAM{IVTYPE} = 'Dismud';
      OVLNAM{IVTYPE} = 'Fluid mud dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
% MUD special;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'WLENMR'                                    ;
      OVSNAM{IVTYPE} = 'Wlenmr';
      OVLNAM{IVTYPE} = 'Average wave length with mud real part';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 200.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
% % MUD special;
%       IVTYPE = IVTYPE + 1;
%       OVKEYW{IVTYPE} = 'WLENMI'                                    ;
%       OVSNAM{IVTYPE} = 'Wlenmi';
%       OVLNAM{IVTYPE} = 'Average wave length with mud imag part';
%       OVUNIT{IVTYPE} = 'UL';
%       OVSVTY{IVTYPE} = 1;
%       OVLLIM{IVTYPE} = 0;
%       OVULIM{IVTYPE} = 1000000000.;
%       OVULIM{IVTYPE} = 9999990000.;
%       OVLEXP{IVTYPE} = 0.;
%       OVHEXP{IVTYPE} = 100000000. ;
%       OVHEXP{IVTYPE} = 999999000. ;
%       OVEXCV{IVTYPE} = -999.;
%       OVCFNM{IVTYPE} = '';
% MUD special;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'KI'                                    ;
      OVSNAM{IVTYPE} = 'ki';
      OVLNAM{IVTYPE} = 'Average wave number with mud imag part';
      OVUNIT{IVTYPE} = 'rad/m';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
      OVCFNM{IVTYPE} = '';
% MUD special;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'MUDL';
      OVSNAM{IVTYPE} = 'Mudlayer';
      OVLNAM{IVTYPE} = 'Mudlayer thickness';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1   ;
      OVLLIM{IVTYPE} = 0   ;% ! -1.E4
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = 0   ;%!-100.
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
      
%% Parameter in test spectral output (see SWANPRE2.for) to be obtained with:
%  TEST 1 0 POINTS XY 0.0000 0 PAR 'x.par' S1D 'x.s1d' S2D 'x.s2d'
%------------------------

      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'VaDens';
      OVSNAM{IVTYPE} = 'VaDens';
      OVLNAM{IVTYPE} = 'spectral variance density';
      OVUNIT{IVTYPE} = 'm2/Hz';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Swind';
      OVSNAM{IVTYPE} = 'Swind';
      OVLNAM{IVTYPE} = 'wind source term';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Swcap';
      OVSNAM{IVTYPE} = 'Swcap';
      OVLNAM{IVTYPE} = 'whitecapping dissipation';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Sfric';
      OVSNAM{IVTYPE} = 'Sfric';
      OVLNAM{IVTYPE} = 'bottom friction dissipation';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Smud';
      OVSNAM{IVTYPE} = 'Smud';
      OVLNAM{IVTYPE} = 'fluid mud dissipation';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Ssurf';
      OVSNAM{IVTYPE} = 'Ssurf';
      OVLNAM{IVTYPE} = 'surf breaking dissipation';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Snl3';
      OVSNAM{IVTYPE} = 'Snl3';
      OVLNAM{IVTYPE} = 'triad interactions';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Snl4';
      OVSNAM{IVTYPE} = 'Snl4';
      OVLNAM{IVTYPE} = 'quadruplet interactions';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
      OVCFNM{IVTYPE} = '';
% extra from manual
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'PDIR';
      OVSNAM{IVTYPE} = 'PkDir';
      OVLNAM{IVTYPE} = 'peak wave direction';
      OVUNIT{IVTYPE} = 'degr';
      OVSVTY{IVTYPE} = NaN;
      OVLLIM{IVTYPE} = NaN;
      OVULIM{IVTYPE} = NaN;
      OVLEXP{IVTYPE} = NaN;
      OVHEXP{IVTYPE} = NaN;
      OVEXCV{IVTYPE} = NaN;
      OVCFNM{IVTYPE} = '';            
%% Parameter in MUDF
%------------------------

%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'KIMAG';
      OVSNAM{IVTYPE} = 'KIMAG';
      OVLNAM{IVTYPE} = 'Wave number with mud imag part';
      OVUNIT{IVTYPE} = 'rad/m';
      OVSVTY{IVTYPE} = NaN;
      OVLLIM{IVTYPE} = NaN;
      OVULIM{IVTYPE} = NaN;
      OVLEXP{IVTYPE} = NaN;
      OVHEXP{IVTYPE} = NaN;
      OVEXCV{IVTYPE} = NaN;
      OVCFNM{IVTYPE} = '';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'KREAL';
      OVSNAM{IVTYPE} = 'KREAL';
      OVLNAM{IVTYPE} = 'Wave number with mud real part';
      OVUNIT{IVTYPE} = 'rad/m';
      OVSVTY{IVTYPE} = NaN;
      OVLLIM{IVTYPE} = NaN;
      OVULIM{IVTYPE} = NaN;
      OVLEXP{IVTYPE} = NaN;
      OVHEXP{IVTYPE} = NaN;
      OVEXCV{IVTYPE} = NaN;
      OVCFNM{IVTYPE} = '';


%% Put into struct

      DAT0.OVKEYW = OVKEYW;
      DAT0.OVSNAM = OVSNAM;
      DAT0.OVLNAM = OVLNAM;
      DAT0.OVUNIT = OVUNIT;
      DAT0.OVSVTY = OVSVTY;
      DAT0.OVLLIM = OVLLIM;
      DAT0.OVULIM = OVULIM;
      DAT0.OVLEXP = OVLEXP;
      DAT0.OVHEXP = OVHEXP;
      DAT0.OVEXCV = OVEXCV;
      DAT0.OVCFNM = OVCFNM;
      
%% Restructure per parameter rather than per property

      for ipar=1:length(DAT0.OVKEYW)
       
         parname = DAT0.OVKEYW{ipar};

         valnames = fieldnames(DAT0);

         for ival=1:length(valnames)
         
            valname = valnames{ival};
         
            DAT.(parname).(valname) = DAT0.(valname){ipar};
       
         end
         
      end
      
if     nargout==1
     varargout = {DAT};
elseif nargout==2
     varargout = {DAT,DAT0};
end

%% EOF