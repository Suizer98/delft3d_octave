function varargout = swan_quantitytex
%SWAN_QUANTITYTEX         returns LaTaX names of SWAN output parameters
%
%  DAT       = SWAN_QUANTITYTEX returns LaTeX name per parameter
% [DAT,DAT0] = SWAN_QUANTITYTEX returns also properties per property
%
% where DAT is struct with field names as returned by 
% SWAN_SHORTNAME2KEYWORD, each with subfields
%
%  OVKEYW(IVTYPE) =    keyword used in SWAN command      
%  TEXNAM(IVTYPE) =    LaTeX name
%
% SWAN_QUANTITYTEX contains more parameters then 
% SWAN_QUANTITY, notably the parameters
% in the TEST output and the MUDF output.
%
%See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, 
%          SWAN_SHORTNAME2KEYWORD, SWAN_DEFAULTS, SWAN_QUANTITY

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

% $Id: swan_quantitytex.m 569 2009-06-22 09:31:10Z boer_g $
% $Date: 2009-06-22 17:31:10 +0800 (Mon, 22 Jun 2009) $
% $Author: boer_g $
% $Revision: 569 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_quantitytex.m $

% 2009 apr 23: added names from test output (source terms)

%% Pre-allocate for speed
%------------------------

   nval   = 57 + 3 + 8; % native + fluid mud + test output

   OVKEYW = cell(1,nval);
   TEXNAM = cell(1,nval);

%% Manually edited 3 things from code form SWANMAIN.for below
%------------------------
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
         TEXNAM{IVTYPE} = 'x [m]';
   %;
         IVTYPE = 2;
         OVKEYW{IVTYPE} = 'YP'                                        ;
         TEXNAM{IVTYPE} = 'y [m]';
   %;
         IVTYPE = 3;
         OVKEYW{IVTYPE} = 'DIST'                                      ;
         TEXNAM{IVTYPE} = 's [m]';
   %;
         IVTYPE = 4;
         OVKEYW{IVTYPE} = 'DEP'                                       ;
         TEXNAM{IVTYPE} = 'Depth [m]';
   %;
         IVTYPE = 5;
         OVKEYW{IVTYPE} = 'VEL'                                       ;
         TEXNAM{IVTYPE} = 'Velcoity [m/s]';
   %;
         IVTYPE = 6;
         OVKEYW{IVTYPE} = 'UBOT'                                      ;
         TEXNAM{IVTYPE} = 'U_{bot} [m/s]';
   %;
         IVTYPE = 7;
         OVKEYW{IVTYPE} = 'DISS'                                      ;
         TEXNAM{IVTYPE} = 'Dissipation [m^2/s]';
   %;
         IVTYPE = 8;
         OVKEYW{IVTYPE} = 'QB'                                        ;
         TEXNAM{IVTYPE} = 'Q_{breaking}';
   %;
         IVTYPE = 9;
         OVKEYW{IVTYPE} = 'LEA'                                       ;
         TEXNAM{IVTYPE} = 'E_{leak} [m^2/s]';
   %;
         IVTYPE = 10;
         OVKEYW{IVTYPE} = 'HS'                                        ;
         TEXNAM{IVTYPE} = 'H_s [m]';
   %                                                                  ;
         IVTYPE = 11;
         OVKEYW{IVTYPE} = 'TM01'                                      ;
         TEXNAM{IVTYPE} = 'T_{m01} [s]'                               ;
   %;
         IVTYPE = 12;
         OVKEYW{IVTYPE} = 'RTP'                                       ;
         TEXNAM{IVTYPE} = 'rel.T_{peak} [s]'                                 ;
   %;
         IVTYPE = 13;
         OVKEYW{IVTYPE} = 'DIR'                                       ;
         TEXNAM{IVTYPE} = 'Dir_{average} [\circ]';
         OVEXCV{IVTYPE} = -999.;
   %;
         IVTYPE = 14;
         OVKEYW{IVTYPE} = 'PDI'                                       ;
         TEXNAM{IVTYPE} = 'Dir_{Tpeak} [\circ]';
         OVEXCV{IVTYPE} = -999.;
   %;
         IVTYPE = 15;
         OVKEYW{IVTYPE} = 'TDI'                                       ;
         TEXNAM{IVTYPE} = 'Dir_{energy} [\circ]';
   %;
         IVTYPE = 16;
         OVKEYW{IVTYPE} = 'DSPR'                                      ;
         TEXNAM{IVTYPE} = 'Dir_{spreading} [\circ]';
   %;
         IVTYPE = 17;
         OVKEYW{IVTYPE} = 'WLEN'                                      ;
         TEXNAM{IVTYPE} = 'wavelength [m]';
   %;
         IVTYPE = 18;
         OVKEYW{IVTYPE} = 'STEE'                                      ;
         TEXNAM{IVTYPE} = 'steepness';
   %;
         IVTYPE = 19;
         OVKEYW{IVTYPE} = 'TRA'                                       ;
         TEXNAM{IVTYPE} = 'P [m^3/s]';
   %;
         IVTYPE = 20;
         OVKEYW{IVTYPE} = 'FOR'                                       ;
         TEXNAM{IVTYPE} = 'F [Pa/m^2]';
   %;
         IVTYPE = 21;
         OVKEYW{IVTYPE} = 'AAAA'                                      ;
         TEXNAM{IVTYPE} = 'Spectral Action Density [m^2s]';
   %;
         IVTYPE = 22;
         OVKEYW{IVTYPE} = 'EEEE'                                      ;
         TEXNAM{IVTYPE} = 'Spectral Energy Density [m^2]';
   %;
         IVTYPE = 23;
         OVKEYW{IVTYPE} = 'AAAA'                                      ;
         TEXNAM{IVTYPE} = 'Aux';
   %;
         IVTYPE = 24;
         OVKEYW{IVTYPE} = 'XC'                                        ;
         TEXNAM{IVTYPE} = 'x [m]';
   %;
         IVTYPE = 25;
         OVKEYW{IVTYPE} = 'YC'                                        ;
         TEXNAM{IVTYPE} = 'y [m]';
   %;
         IVTYPE = 26;
         OVKEYW{IVTYPE} = 'WIND'                                      ;
         TEXNAM{IVTYPE} = 'U_{10} [m/s]';
   %;
         IVTYPE = 27;
         OVKEYW{IVTYPE} = 'FRC'                                       ;
         TEXNAM{IVTYPE} = 'Friction';
   %                                                                  ;
         IVTYPE = 28;
         OVKEYW{IVTYPE} = 'RTM01'                                     ;
         TEXNAM{IVTYPE} = 'rel. T_{m01} [s]'                                  ;
   %;
         IVTYPE = 29                                                  ;
         OVKEYW{IVTYPE} = 'EEEE'                                      ;
         TEXNAM{IVTYPE} = 'Energy Density [m^2]';
   %;
         IVTYPE = 30                                                  ;
         OVKEYW{IVTYPE} = 'DHS'                                       ;
         TEXNAM{IVTYPE} = '\Delta_{iterations}H_{s} [m]';
   %;
         IVTYPE = 31                                                  ;
         OVKEYW{IVTYPE} = 'DRTM01'                                    ;
         TEXNAM{IVTYPE} = '\Delta_{iterations}T_{m01} [s]';
   %                                                                  ;
         IVTYPE = 32;
         OVKEYW{IVTYPE} = 'TM02'                                      ;
         TEXNAM{IVTYPE} = 'T_{m02} [s]';
   %                                                                  ;
         IVTYPE = 33;
         OVKEYW{IVTYPE} = 'FSPR'                                      ;
         TEXNAM{IVTYPE} = 'Spectral width \kappa [-]'                 ;
   %;
         IVTYPE = 34                                                  ;
         OVKEYW{IVTYPE} = 'URMS'                                      ;
         TEXNAM{IVTYPE} = 'U_{rms} [m/s]';
  %;
         IVTYPE = 35                                                  ;
         OVKEYW{IVTYPE} = 'UFRI'                                      ;
         TEXNAM{IVTYPE} = 'U_{fric} [m/s]';
   %;
         IVTYPE = 36                                                  ;
         OVKEYW{IVTYPE} = 'ZLEN'                                      ;
         TEXNAM{IVTYPE} = 'Zlen [m]';
   %;
         IVTYPE = 37                                                  ;
         OVKEYW{IVTYPE} = 'TAUW'                                      ;
         TEXNAM{IVTYPE} = 'TauW';
   %;
         IVTYPE = 38                                                  ;
         OVKEYW{IVTYPE} = 'CDRAG'                                     ;
         TEXNAM{IVTYPE} = 'Cdrag';
   %;
   %     *** wave-induced setup ***                                   ;
   %;
         IVTYPE = 39                                                  ;
         OVKEYW{IVTYPE} = 'SETUP'                                     ;
         TEXNAM{IVTYPE} = 'Setup [m]'                                     ;
   %;
         IVTYPE = 40                                                  ;
         OVKEYW{IVTYPE} = 'TIME'                                      ;
         TEXNAM{IVTYPE} = 'Time';
   %;
         IVTYPE = 41                                                  ;
         OVKEYW{IVTYPE} = 'TSEC'                                      ;
         TEXNAM{IVTYPE} = 'Tsec [s]';
   %                                                               ;
         IVTYPE = 42;
         OVKEYW{IVTYPE} = 'PER'                                       ;
         TEXNAM{IVTYPE} = 'T_{m} [s]'                                    ;
   %                                                               ;
         IVTYPE = 43;
         OVKEYW{IVTYPE} = 'RPER'                                      ;
         TEXNAM{IVTYPE} = 'rel.T_{m} [s]'                                   ;
   %;
         IVTYPE = 44                                                  ;
         OVKEYW{IVTYPE} = 'HSWE'                                      ;
         TEXNAM{IVTYPE} = 'H_{s,swell} [m]';
   %;
         IVTYPE = 45;
         OVKEYW{IVTYPE} = 'URSELL'                                    ;
         TEXNAM{IVTYPE} = 'Ursell';
   %;
         IVTYPE = 46;
         OVKEYW{IVTYPE} = 'ASTD'                                      ;
         TEXNAM{IVTYPE} = '\Delta T_{air-sea} [\circ]';
   %;
         IVTYPE = 47                                                  ;
         OVKEYW{IVTYPE} = 'TMM10';
         TEXNAM{IVTYPE} = 'T_{-10} [s]';
   %;
         IVTYPE = 48                                                  ;
         OVKEYW{IVTYPE} = 'RTMM10';
         TEXNAM{IVTYPE} = 'rel.T_{-10} [s]';
         OVEXCV{IVTYPE} = -9.;
   %;
         IVTYPE = 49;
         OVKEYW{IVTYPE} = 'DIFPAR'                                    ;
         TEXNAM{IVTYPE} = 'Diffraction';
   %;
         IVTYPE = 50                                                  ;
         OVKEYW{IVTYPE} = 'TMBOT';
         TEXNAM{IVTYPE} = 'T_{bottom} [s]';
   %;
         IVTYPE = 51                                                  ;
         OVKEYW{IVTYPE} = 'WATL';
         TEXNAM{IVTYPE} = 'water level [m]';
   %;
         IVTYPE = 52                                                  ;
         OVKEYW{IVTYPE} = 'BOTL';
         TEXNAM{IVTYPE} = 'bottom level [m]';
   %;
         IVTYPE = 53                                                  ;
         OVKEYW{IVTYPE} = 'TPS';
         TEXNAM{IVTYPE} = 'rel.T_{peak} [s]';
   %;
         IVTYPE = 54;
         OVKEYW{IVTYPE} = 'DISB'                                      ;
         TEXNAM{IVTYPE} = 'Dis_{bottom friction} [m^2/s]';
   %;
         IVTYPE = 55;
         OVKEYW{IVTYPE} = 'DISSU'                                     ;
         TEXNAM{IVTYPE} = 'Dis_{wave breaking} [m^2/s]';
   %;
         IVTYPE = 56;
         OVKEYW{IVTYPE} = 'DISW'                                      ;
         TEXNAM{IVTYPE} = 'Dis_{white cappping} [m^2/s]';
   %;
         IVTYPE = 57;
         OVKEYW{IVTYPE} = 'DISM'                                      ;
         TEXNAM{IVTYPE} = 'Dis_{mud} [m^2/s]';
   % MUD special;
         IVTYPE = 58;
         OVKEYW{IVTYPE} = 'WLENMR'                                    ;
         TEXNAM{IVTYPE} = 'Re(wavelength_{mud}) [m]';
   % % MUD special;
   %       IVTYPE = 59;
   %       OVKEYW{IVTYPE} = 'WLENMI'                                    ;
   %       TEXNAM{IVTYPE} = 'Wlenmi';
   % MUD special;
         IVTYPE = 59;
         OVKEYW{IVTYPE} = 'KI'                                    ;
         TEXNAM{IVTYPE} = 'Im(wave number) [rad/s]';
   % MUD special;
         IVTYPE = 60;
         OVKEYW{IVTYPE} = 'MUDL';
         TEXNAM{IVTYPE} = 'thick_{mud} [m]';
   
%% Parameter in test spectral output (see SWANPRE2.for) to be obtained with:
%  TEST 1 0 POINTS XY 0.0000 0 PAR 'x.par' S1D 'x.s1d' S2D 'x.s2d'
%------------------------

      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'VaDens';
      TEXNAM{IVTYPE} = 'Variance Density [m^2/Hz]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Swind';
      TEXNAM{IVTYPE} = 'Source wind [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Swcap';
      TEXNAM{IVTYPE} = 'Source whitecapping [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Sfric';
      TEXNAM{IVTYPE} = 'Source bottom friction [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Smud';
      TEXNAM{IVTYPE} = 'Source fluid mud [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Ssurf';
      TEXNAM{IVTYPE} = 'Source surf breaking [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Snl3';
      TEXNAM{IVTYPE} = 'Source triad [m^2]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'Snl4';
      TEXNAM{IVTYPE} = 'Source quadruplet [m^2]';
      
%% Parameter in MUDF
%------------------------

      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'KIMAG'                                    ;
      TEXNAM{IVTYPE} = 'Im(wave number) [rad/s]';
%;
      IVTYPE = IVTYPE + 1;
      OVKEYW{IVTYPE} = 'KREAL'                                    ;
      TEXNAM{IVTYPE} = 'Re(wave number) [rad/s]';

%% Put into struct
%------------------------

         DAT0.OVKEYW = OVKEYW;
         DAT0.TEXNAM = TEXNAM;
      
%% Restructure per parameter rather than per property
%------------------------

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