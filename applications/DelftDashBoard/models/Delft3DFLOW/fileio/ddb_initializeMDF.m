function mdflower = ddb_initializeMDF
%DDB_INITIALIZEMDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   mdflower = ddb_initializeMDF
%
%   Input:

%
%   Output:
%   mdflower =
%
%   Example
%   ddb_initializeMDF
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
MDF.Ident = 'Delft3D-FLOW  .03.02 3.39.09';
MDF.Runtxt= '';
MDF.Runid = '';
MDF.Filcco= '';
MDF.Fmtcco= 'FR';
MDF.Anglat=  0.0000000e+000;
MDF.Grdang=  0.0000000e+000;
MDF.Filgrd= '';
MDF.Fmtgrd= 'FR';
MDF.MNKmax= [1 1 1];
MDF.Thick =  1.0000000e+002;
MDF.Fildep= '';
MDF.Fmtdep= 'FR';
%MDF.MNdry = [ ] [ ] [ ] [ ];
MDF.Fildry= '';
MDF.Fmtdry= 'FR';
%MDF.MNtd  = [ ] [ ] [ ] [ ] 'U';
MDF.Filtd = '';
MDF.Fmttd = 'FR';
MDF.Fil2dw = '';
%MDF.Nambar= '                    ';
%MDF.MNbar = [ ] [ ] ' ';
%MDF.MNwlos= [ ] [ ];
MDF.Itdate= '2000-01-01';
MDF.Tunit = 'M';
MDF.Tstart=  0.0000000e+000;
MDF.Tstop =  1.4400000e+003;
MDF.Dt    =  1.0000000e+000;
MDF.Tzone = 0;
MDF.Sub1  = '';
MDF.Sub2  = '';
MDF.Namc1 = '                    ';
MDF.Namc2 = '                    ';
MDF.Namc3 = '                    ';
MDF.Namc4 = '                    ';
MDF.Namc5 = '                    ';
MDF.Wnsvwp= 'N';
MDF.Filwnd= '';
MDF.Fmtwnd= 'FR';
MDF.Wndint= 'Y';
MDF.Filic = '';
MDF.Zeta0 = 0.0000000e+000;
%MDF.U0    = [.];
%MDF.V0    = [.];
%MDF.S0    = [.];
%MDF.T0    = [.];
%MDF.C01   =  0.0000000e+000;
%MDF.I0    = [.];
MDF.Restid= '';
MDF.Filbnd= '';
MDF.Fmtbnd= 'FR';
MDF.FilbcH= '';
MDF.FmtbcH= 'FR';
MDF.FilbcT= '';
MDF.FmtbcT= 'FR';
MDF.FilbcQ= '';
MDF.FmtbcQ= 'FR';
MDF.Filana= '';
MDF.Filcor= '';
MDF.FilbcC= '';
MDF.FmtbcC= 'FR';
MDF.Filbc0= '';
MDF.Fmtbc0= 'FR';
MDF.Rettis=  0.0000000e+000;
MDF.Rettib=  0.0000000e+000;
MDF.Ag    =  9.8100000e+000;
MDF.Rhow  =  1.0000000e+003;
%MDF.Alph0 = [.];
MDF.Tempw =  1.5000000e+001;
MDF.Salw  =  3.1000000e+001;
MDF.Rouwav= 'FR84';
MDF.Wstres=  [6.3000000e-004  0.0000000e+000  7.2300000e-003  3.0000000e+001];
MDF.Rhoa  =  1.0000000e+000;
MDF.Betac =  5.0000000e-001;
MDF.Equili= 'N';
MDF.Tkemod= '            ';
MDF.Ktemp = 0;
MDF.Fclou =  0.0000000e+000;
MDF.Sarea =  0.0000000e+000;
MDF.Secchi=  3.0000000e+000;
MDF.Stantn=  1.3000000e-003;
MDF.Dalton=  1.3000000e-003;
MDF.Filtmp= '';
MDF.Fmttmp= 'FR';
MDF.Temint= 'Y';
MDF.Tidfor= '';
%MDF.Tstmp = [.] [.];
MDF.Roumet= 'C';
MDF.Filrgh= '';
MDF.Ccofu =  6.5000000e+001;
MDF.Ccofv =  6.5000000e+001;
MDF.Xlo   =  0.0000000e+000;
MDF.Filedy= '';
MDF.Vicouv=  1.0000000e+000;
MDF.Dicouv=  1.0000000e+000;
MDF.Vicoww= 1.00000000e-006;
MDF.Dicoww= 1.00000000e-006;
MDF.Htur2d= 'N';
MDF.Irov  = 0;
MDF.Filsed= '';
MDF.Filmor= '';
MDF.Iter  =  2;
MDF.Dryflp= 'YES';
MDF.Dpsopt= 'MAX';
MDF.Dpuopt= 'MEAN';
MDF.Dryflc=  1.0000000e-001;
MDF.Dco   =  1.0000000e+000;
MDF.Tlfsmo=  6.0000000e+002;
MDF.ThetQH=  0.0000000e+000;
MDF.Forfuv= 'Y';
MDF.Forfww= 'N';
MDF.Sigcor= 'N';
MDF.Trasol= 'Cyclic-method';
MDF.Momsol= 'Cyclic';
MDF.Filsrc= '';
MDF.Fmtsrc= 'FR';
MDF.Fildis= '';
MDF.Fmtdis= 'FR';
MDF.Filsta= '';
MDF.Fmtsta= 'FR';
MDF.Filcrs= '';
MDF.Fmtcrs= 'FR';
MDF.Filpar= '';
MDF.Fmtpar= 'FR';
MDF.SMhydr= 'YYYYY'     ;
MDF.SMderv= 'YYYYYY'    ;
MDF.SMproc= 'YYYYYYYYYY';
MDF.PMhydr= 'YYYYYY'    ;
MDF.PMderv= 'YYY'       ;
MDF.PMproc= 'YYYYYYYYYY';
MDF.SHhydr= 'YYYY'      ;
MDF.SHderv= 'YYYYY'     ;
MDF.SHproc= 'YYYYYYYYYY';
MDF.SHflux= 'YYYY'      ;
MDF.PHhydr= 'YYYYYY'    ;
MDF.PHderv= 'YYY'       ;
MDF.PHproc= 'YYYYYYYYYY';
MDF.PHflux= 'YYYY'      ;
MDF.Filfou= '';
MDF.Online= 'NO';
MDF.Waqmod= 'N';
MDF.WaveOL= 'N';
MDF.Prhis =  [0.0000000e+000  0.0000000e+000  0.0000000e+000];
MDF.Flmap =  [0.0000000e+000  0.0000000e+000  0.0000000e+000];
MDF.Flhis =  [0.0000000e+000  0.0000000e+000  0.0000000e+000];
MDF.Flpp  =  [0.0000000e+000  0.0000000e+000  0.0000000e+000];
MDF.Flrst =  [0.0000000e+000];
MDF.Filwp = '';
MDF.Filwu = '';
MDF.Filwv = '';
MDF.Filwr = '';
MDF.Filwc = '';
MDF.Filwt = '';
MDF.Wndgrd= 'A';
MDF.MNmaxw= [0 0];
MDF.Filweb = '';
MDF.TraFrm = '';
MDF.Filz0l = '';

MDF.Filwpr = '';
MDF.Fileva = '';
MDF.Evaint = '';
MDF.Maseva = '';

%% lower case
fnames=fieldnames(MDF);
for i=1:length(fnames)
    mdflower.(lower(fnames{i}))=MDF.(fnames{i});
end


% MDF.Ident = 'Delft3D-FLOW  .03.02 3.39.26';
% MDF.Anglat= 0.0;
% MDF.Grdang= 0.0;
% MDF.Filcco= '';
% MDF.Fmtcco= 'FR';
% MDF.Filgrd= '';
% MDF.Fmtgrd= 'FR';
% MDF.MNKmax= [1 1 1];
% MDF.Thick =  1.0000000e+002;
% MDF.Fildep= '';
% MDF.Fmtdep= 'FR';
% MDF.Fildry= '';
% MDF.Fmtdry= 'FR';
% MDF.Itdate= '2000-01-01';
% MDF.Tunit = 'M';
% MDF.Tstart=  0.0000000e+000;
% MDF.Tstop =  2880.0000000e+000;
% MDF.Dt    = 1;
% MDF.Tzone = 0;
% MDF.Sub1  = '    ';
% MDF.Sub2  = '   ';
% MDF.Wnsvwp= 'N';
% MDF.Wndint= 'Y';
% MDF.Filic = '';
% MDF.Fmtic = 'FR';
% MDF.Filbnd= '';
% MDF.Fmtbnd= 'FR';
% MDF.Filana= '';
% MDF.Fmtana= 'FR';
% MDF.FilbcH= '';
% MDF.FmtbcH= 'FR';
% MDF.FilbcT= '';
% MDF.FmtbcT= 'FR';
% MDF.Ag    =  9.8100000e+000;
% MDF.Rhow  =  1.0250000e+003;
% MDF.Alph0 = [];
% MDF.Tempw =  1.5000000e+001;
% MDF.Salw  =  3.1000000e+001;
% MDF.Rouwav= '    ';
% MDF.Wstres=  [6.3000000e-004  0.0000000e+000  7.2300000e-003  1.0000000e+002];
% MDF.Rhoa  =  1.0000000e+000;
% MDF.Betac =  5.0000000e-001;
% MDF.Equili= 'N';
% MDF.Tkemod= '            ';
% MDF.Ktemp = 0;
% MDF.Fclou =  0.0000000e+000;
% MDF.Sarea =  0.0000000e+000;
% MDF.Temint= 'Y';
% MDF.Tidfor= 'M2 S2 N2 K2 ';
% MDF.Tidfor= 'K1 O1 P1 Q1 ';
% MDF.Tidfor= 'MF MM SSA---';
% MDF.Roumet= 'C';
% MDF.Ccofu =  6.5000000e+001;
% MDF.Ccofv =  6.5000000e+001;
% MDF.Xlo   =  0.0000000e+000;
% MDF.Vicouv=  1.0000000e+000;
% MDF.Dicouv=  1.0000000e+001;
% MDF.Htur2d= 'N';
% MDF.Irov  = 0;
% MDF.Iter  =      2;
% MDF.Dryflp= 'YES';
% MDF.Dpsopt= 'MEAN';
% MDF.Dpuopt= 'MEAN';
% MDF.Dryflc=  1.0000000e-001;
% MDF.Dco   =  2.0000000e+001;
% MDF.Tlfsmo=  6.0000000e+001;
% MDF.ThetQH=  0.0000000e+000;
% MDF.Forfuv= 'Y';
% MDF.Forfww= 'N';
% MDF.Sigcor= 'N';
% MDF.Trasol= 'Cyclic-method';
% MDF.Momsol= 'Cyclic';
% MDF.Filsta= '';
% MDF.Fmtsta= 'FR';
% MDF.SMhydr= 'YYYYY';
% MDF.SMderv= 'YYYYYY';
% MDF.SMproc= 'YYYYYYYYYY';
% MDF.PMhydr= 'YYYYYY';
% MDF.PMderv= 'YYY';
% MDF.PMproc= 'YYYYYYYYYY';
% MDF.SHhydr= 'YYYY';
% MDF.SHderv= 'YYYYY';
% MDF.SHproc= 'YYYYYYYYYY';
% MDF.SHflux= 'YYYY';
% MDF.PHhydr= 'YYYYYY';
% MDF.PHderv= 'YYY';
% MDF.PHproc= 'YYYYYYYYYY';
% MDF.PHflux= 'YYYY';
% MDF.Online= 'N';
% MDF.Flmap =  [0.0000000e+000 1  1.0000000e+000];
% MDF.Flhis =  [0.0000000e+000 1  1.0000000e+000];
% MDF.Flpp  =  [0.0000000e+000 0  0.0000000e+000];
% MDF.Flrst = 0;

