function varargout = matroos_get_series(varargin);
%MATROOS_GET_SERIES  retrieve timeseries from Rijkswaterstaat MATROOS database
%
% matlab wrapper for <a href="http://matroos.deltares.nl">MATROOS</a> url call /direct/get_series.php
% on http://matroos.deltares.nl. You need a free password for this.
%
%  struct                 = matroos_get_series(<keyword,value>);
% [ t, values ]           = matroos_get_series(<keyword,value>);
% [ t, values , metainfo] = matroos_get_series(<keyword,value>);
%
% where the following <keyword,value> are defined:
% (NB matroos_get_series() returns all <keyword,value> pairs)
% REQUIRED matroos url keywords:
% - loc       : The location as known by Matroos (see MATROOS_LIST).
%               note: several locations can be a ; separated list of locations.
%               provided check = 0
% - source    : The source as known by Matroos (see MATROOS_LIST).
% - unit      : A unit as known by Matroos (see MATROOS_LIST).
% - tstart    : First time for the timeseries in format YYYYMMDDHHMM.
%               Any '-', <space>, or ':' will be ignored, so a format like 
%               YYYY-MM-DD HH:MM will be accepted as well
% - tstop     : Last time for the timeseries in the same format as tstart.
% keywords for this Matlab function:
% * check     : check existence of: loc, source, unit:
%               0,nan,'' no check (FAST) / 'c' check with local cached table / 's' check with server
% * debug     : display some debugging info
% * file      : filename for saving data (optionally, default '' means that no file will be saved)
%
% Example:
% [t,wl]=matroos_get_series( 'unit','waterlevel',...
%                  'source','observed',...
%                     'loc','hoekvanholland',...
%                  'tstart',datestr(now)-7,... % 7 days history
%                  'tstart',datestr(now)+3,... % 3 day forecast
%                   'check','');               % fast, in batch mode after being tested
%
% Example 2:
%
% D = matroos_get_series('unit','wave_height','loc','amelander zeegat, boei 1-1','source','observed','tstart',datenum(2009,1,1),'tstop',now)
%
%See also: MATROOS, MATROOS_LIST

% TO DO

%          OPTIONAL matroos url keywords:
% - tinc      : Time increment in minutes. If given, alle timesteps will
%               be output with missing values filled in.
%               No time-interpolation will be done. Default: empty
% - timezone  : MET, GMT or GMT[+/-][hours] default GMT.
% - anal_time : analyse time, default 'most recent'. If given, analyses
%               after this time will be ignored
% - last_anal : if last_anal=1, only returns data of the last analysis
%               at or before anal_time.
% - fc_min    : minimum forecast lead time; default no minimum.
% - fc_max    : maximum forecast lead time; default no maximum.
% - print_anal: add an extra column in the output containing the analyse
%               time of that value (anal_time=Y or anal_time=1)
%               Default: when anal_time=0 or anal_time='' analyse time is not printed
% - get_anal  : if Y(es) or 1, only the available analyse times between
%               tstart and tstop are given
% - list      : if Y(es) or 1, just print available locations, sources
%               and units combinations
% - format    : 'text' or 'XML' output; default 'text'


%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Martin Verlaan
%
%       Martin.Verlaan@deltares.nl
%
%       Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: matroos_get_series.m 11354 2014-11-07 16:32:18Z gerben.deboer.x $
% $Date: 2014-11-08 00:32:18 +0800 (Sat, 08 Nov 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11354 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_get_series.m $
% $Keywords: $

%% Options
   
   OPT.server     = matroos_server;
   
   OPT.loc        = ''; % always
   OPT.source     = ''; % always
   OPT.unit       = ''; % always
   OPT.tstart     = []; % always
   OPT.tstop      = []; % always
   
 % OPT.tinc       = ''; 
 % OPT.timezone   = ''; 
 % OPT.anal_time  = ''; 
 % OPT.last_anal  = ''; 
 % OPT.fc_min     = ''; 
 % OPT.fc_max     = ''; 
 % OPT.print_anal = ''; 
 % OPT.get_anal   = ''; 
 % OPT.list       = ''; 
 % OPT.format     = ''; 

   OPT.check      = 'server'; 
   OPT.debug      = 0;   
   OPT.file       = '';  
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:});
   
%% check input

   if isempty(OPT.unit  );error('unit     empty, minimally define: unit, source, location.');end
   if isempty(OPT.source);error('source   empty, minimally define: unit, source, location.');end
   if isempty(OPT.loc   );error('location empty, minimally define: unit, source, location.');end

   if ~(isempty(OPT.check) | OPT.check==0 | isnan(OPT.check))
   
      if     strcmpi(OPT.check(1),'s')
         [locs,sources,units]=matroos_list('server',OPT.server);
      elseif strcmpi(OPT.check(1),'c')
         [locs,sources,units]=matroos_list('server','');
      end
      
      iunit   = strmatch(OPT.unit  ,units  ,'exact');if(length(iunit)==0),  error(['could not find unit: '''    ,OPT.unit  ,'''']);end;
      isource = strmatch(OPT.source,sources,'exact');if(length(isource)==0),error(['could not find source: '''  ,OPT.source,'''']);end;
      iloc    = strmatch(OPT.loc   ,locs   ,'exact');if(length(iloc)==0),   error(['could not find location: ''',OPT.loc   ,'''']);end;
      
      if isempty(intersect(intersect(iunit,isource),iloc))
      error(['could not find combination of unit: ''',OPT.unit,''', source: ''',OPT.source,''', location: ''',OPT.loc])
      end

   end

%% prepare input

   OPT.unit    = strrep (OPT.unit    ,' ','%20'); % %20=<space>
   OPT.source  = strrep (OPT.source  ,' ','%20'); % %20=<space>
   OPT.loc     = strrep (OPT.loc     ,' ','%20'); % %20=<space>
   OPT.tstart  = datestr(OPT.tstart ,'yyyymmddHHMM');
   OPT.tstop   = datestr(OPT.tstop  ,'yyyymmddHHMM');
   
   if OPT.debug
   fprintf('unit      =%s\n',OPT.unit    );
   fprintf('source    =%s\n',OPT.source  );
   fprintf('location  =%s\n',OPT.loc     );
   fprintf('first time=%s\n',OPT.tstart  );
   fprintf('last time =%s\n',OPT.tstop   );
   end

%% get data from matroos server

   serverurl = [OPT.server,'/direct/get_series.php?'];

   urlChar = sprintf('%sunit=%s&source=%s&loc=%s&tstart=%s&tstop=%s', ...
       serverurl,OPT.unit,OPT.source,OPT.loc,OPT.tstart,OPT.tstop);
   if OPT.debug;disp(urlChar);;end
   %eg temp=geturl('http://user:passwd@matroos.deltares.nl/direct/get_series.php?loc=hoekvanholland&source=observed&unit=waterlevel&tstart=200802180000&tstop=200802190000')
   allLines = matroos_urlread(urlChar);
   
%% save to NOOS file (optional)

   if ~isempty(OPT.file)
      fid = fopen(OPT.file,'w');
      for i=1:length(allLines)
      fprintf(fid,'%s \n',allLines{i});
      end
      fclose(fid);
   end

%% parse NOOS data

   [t,v,h] = noos_read(allLines,'varname',OPT.unit);

   if ~isempty(t)
      % re-format the variables h,t and v
      % this is necessary if only one location was read with noos_read.m (in fact noos_read.m is not providing a suitable format in that case)
      if isnumeric(t)
          h={h};
          t={t};
          v={v};
      end
      for iloc=1:length(t)
      D(iloc) = matroos_noos_header(h{iloc}); % not official NOOS, so not in NOOS_READ
      end
      
      for iloc=1:length(t)
      D(iloc).datenum    = t{iloc};
      D(iloc).(OPT.unit) = v{iloc};
      D(iloc).header     = h{iloc};
      end
   else
      disp('matroos_get_series: *** no data found ***')
      D = matroos_noos_header(h); % not official NOOS, so not in NOOS_READ
      D.datenum    = [];
      D.(OPT.unit) = [];
      D.header     = h;
   end

%% deal output

   if nargout==1
      varargout       = {D};
   elseif nargout==2
      varargout       = {D.datenum, D.(OPT.unit) };
   elseif nargout==3
      varargout       = {D.datenum, D.(OPT.unit) ,D};
   end

%% EOF

%% 2010 feb 16
% ----------------------
% script: get_series.php
% ----------------------
% 
% Purpose
% -------
% Get timeseries from the Matroos series database.
% 
% Usage
% -----
% http://matroos.deltares.nl/direct/get_series.php?loc=&source=&unit=&tstart=&tstop=&anal_time=&print_anal=&get_anal=
% 
% The part after '?' is meant to define parameters for the script.
% Each parameter should be given as <param>=<value>, the different
% parameters are separated by the '&' sign.
% 
% Example, when used with 'wget'
% ------------------------------
% wget --proxy=off -O output.txt \
% 'http://matroos.deltares.nl/direct/get_series.php?loc=hoekvanholland&source=observed&unit=waterlevel&tstart=201002160000&tstop=201002170000'
% 
% Cut and paste the above URL in the address bar of the explorer to get an example of the output.
% 
% Parameters
% ----------
% - loc       : The location as known by Matroos (see below).
% - source    : The source as known by Matroos (see below).
% - unit      : A unit as known by Matroos (see below).
% - tstart    : First time for the timeseries in format YYYYMMDDHHMM.
%               Any '-', <space>, or ':' will be ignored, so a format like 
%               YYYY-MM-DD HH:MM will be accepted as well
% - tstop     : Last time for the timeseries in the same format as tstart.
% - tinc      : Time increment in minutes. If given, alle timesteps will
%               be output with missing values filled in.
%               No time-interpolation will be done. Default: empty
% - timezone  : MET, GMT or GMT[+/-][hours] default GMT.
% - anal_time : analyse time, default 'most recent'. If given, analyses
%               after this time will be ignored
% - last_anal : if last_anal=1, only returns data of the last analysis
%               at or before anal_time.
% - fc_min    : minimum forecast lead time; default no minimum.
% - fc_max    : maximum forecast lead time; default no maximum.
% - print_anal: add an extra column in the output containing the analyse
%               time of that value (anal_time=Y or anal_time=1)
%               Default: when anal_time=0 or anal_time='' analyse time is not printed
% - get_anal  : if Y(es) or 1, only the available analyse times between
%               tstart and tstop are given
% - list      : if Y(es) or 1, just print available locations, sources
%               and units combinations
% - format    : 'text' or 'XML' output; default 'text'
% 
% Remark: If either loc, source or unit is left empty, a list with available
%         locations, sources and/or units will be presented at the bottom of this
%         help page. E.g. just fill in 'unit=wind_direction' and see the result below.
%         If either loc, source or unit has the value 'all', a page is presented
%         giving only the available locations, sources and units.
% 
% Available locations, sources and units
% --------------------------------------
% Locations: A121, aalesund, aarhus, aberdeen, Aetran, akkaert, alblasserdam, almen, amay, 
%            amelander zeegat, boei 1-1, amelander zeegat, boei 1-2, 
%            amelander zeegat, boei 2-1, amelander zeegat, boei 2-2, 
%            amelander zeegat, boei 3-1, amelander zeegat, boei 3-2, 
%            amelander zeegat, boei 4-1, amelander zeegat, boei 4-2, 
%            amelander zeegat, boei 5-1, amelander zeegat, boei 5-2, 
%            amelander zeegat, boei 6-1, amelander zeegat, boei 6-2, amerongen beneden, 
%            amerongen boven, amsterdam surinamekade, anasuria, andernach, angleur, 
%            antifer (Fr), Aranmore Island, Arkona-40m, arkonawr, arnhem, aukfield platform, 
%            AWG, ballen, ballycotton, ballyglass, balmoral, barmouth, barseback, 
%            beerenplaat, beerkanaal, belfeld beneden, belfeld boven, beneluxhaven, 
%            bergen (N), berkhout, bernisse, bilbao, bingen, Bjoernegaardsvingen, bodoe, 
%            bol van heist, bonn, borgharen beneden, borgharen dorp, borgharen julianakanaal, 
%            borkum, botlek nieuwe waterweg, botlekbrug, bournemouth, brakelsveer, 
%            breesem boei 1, breezanddijk binnen, breezanddijk buiten, 
%            breezanddijk buiten boei 1, Brekke_bru, bremerhaven, brent alpha 1, brest, 
%            brienenoordbrug, brouwershavensegat 2, brouwershavensegat 2 boven, 
%            brouwershavensegat 2 onder, brouwershavensegat 8, brouwershavensegat 8 boven, 
%            brouwershavensegat 8 onder, buesum, buiksloot, Bulken, bunde, buoy_M1 (Ire), 
%            buoy_M2 (Ire), buoy_M3 (Ire), buoy_M4 (Ire), buoy_M5 (Ire), buoy_M6 (Ire), 
%            cadzand, calais, castletownbere, chaudfontaine, cherbourg, chooz, cochem, 
%            cromer, culemborg brug, cuxhaven, d151, dantziggat, darsser sill 19m, 
%            darsser sill 2m, darsser sill 7m, darssersillwr, daverdisse, de kooij, 
%            de steeg haven, delfzijl, den helder, den oever, den oever binnen, 
%            den oever buiten, deurlo, deventer, dintelhaven2, dnz_554, dnz_BRN, dnz_EFA, 
%            dnz_FE, dnz_IJ03, dnz_MW4, dnz_NHRSE, dodewaard, doesburg brug, dordrecht, 
%            dover, driel beneden, driel boven, drogden, dublin_Port, duesseldorf, dundalk, 
%            dunkerque, dunmore east, edam, eemhaven, eemshaven, eijsden grens, elbe, elburg, 
%            elsloo, emden, emhoern, emmerich, enkhuizen, esbjerg, eurogeul, eurogeul DWE, 
%            eurogeul E13, eurogeul E5, europahaven, europlatform, europlatform 2, 
%            europlatform 3, F161, fehmarn belt 1m, fehmarn belt 23m, fehmarn belt 6m, 
%            felixstowe, ferring, ferrol, FINO, FINO1_-33m, FINO1_12m, FINO1_15m, FINO1_30m, 
%            FINO1_6m, fishguard, Flaksvatn, forsmark, Fosseroed, frederikshavn, furuogrund, 
%            galway city, galway port, gedser2, gendron, genemuiden, gennep, german bight, 
%            gijon, Gjedlakleiv, Gjerstad, Glomma, Goeta, goidschalxoord, golf_FL25_2006, 
%            golf_FL26_2006, golf_FL2_2006, golf_FL5_2006, golf_FL9_2006, 
%            goteborg torshamnen, grave beneden, grave boven, grebbe, grenaa, grevenbicht, 
%            GWEms, haccourt, hagestein, hagestein beneden, hagestein boven, hanstholm, 
%            hardersluis noord, hardersluis zuid, haringvliet 10, haringvliet 10 boven, 
%            haringvliet 10 onder, haringvlietbrug 02, haringvlietsluizen binnen, harlingen, 
%            hartel-kuwait, hartelbrug, hartelhaven, hartelkering, hartelkering zeedijde, 
%            hasselt, Haugland, havneby, hedel, heel beneden, heel boven, heerjansdam, 
%            heesbeen, helgeroa, helgoland, hellevoetsluis, heysham, hinkley point, 
%            hirtshals, Hoegfoss, hoek van holland noorderdam, hoekvanholland, 
%            hoekvanholland maasgeul noordboei, hoekvanholland maasmond, 
%            hoekvanholland NAP-2.5m, hoekvanholland NAP-4.5m, hoekvanholland NAP-9.0m, 
%            hoekvanholland stroompaal -2,-10m, hoekvanholland stroompaal -2,-15m, 
%            hoekvanholland stroompaal -2,-5m, hoekvanholland stroompaal 1, 
%            hohensaaten-finow, hollandse brug, holyhead, hoorn, hoorn/terschelling, 
%            hornbaek2, Hornindalsvatn, houtribsluizen noord, houtribsluizen zuid, Hovefoss, 
%            howth, huibertgat, husum, huvudskarOst, huvudskarOst-2m, huvudskarOst-50m, 
%            huvudskarOst-90m, hvide sande havn, hvide sande ydermole, ij-geul IJ5, 
%            ij-geul stroompaal 1, ijmond erosieput, ijmond stroompaal, ijmond stroompaal 2, 
%            ijmuiden, ijmuiden 05 a, ijmuiden kop pier, ijmuiden munitiestort 1, 
%            ijmuiden munitiestort 2, ijmuiden spuisluis zeezijde, ijsselkop, 
%            ijsselmeer midden, ilfracombe, immingham, inishmore, intschede, J61, K141, 
%            kadoelen, kalix, kampen, kampen bovenhaven, kamperhoek, katerveer, kaub, 
%            keizersveer, kessel, keteldiep, Ketelhaven, ketelmeer west, ketelmond, kiel 13m, 
%            kiel 4m, kiel-holtenau, killybegs, kimstergat, kittiwake, klagshamn, koblenz, 
%            koeln, kop van het land, kornwerderzand, Kornwerderzand binnen, 
%            Kornwerderzand buiten, kornwerderzand buiten boei 3, kornwerderzand2, 
%            kornwerderzand3, korsoer, krabbersgatsluizen noord, krabbersgatsluizen zuid, 
%            krimpen a/d ijssel, krimpen a/d lek, kungsholmsfort, kungsvik, Kvina_Sira, L91, 
%            Laagen, Lagan, lanaken, landsort, landsortnorra, laso ost, laso ost 10m, 
%            laso ost 2m, laso ost 70m, laso ost2 2m, laso ost2 5m, lauwersoog, le havre, 
%            leith, lemmer, les minquiers (Fr), les pierres noires, lichteiland goeree 1, 
%            lichteiland goeree 2, linne beneden, lith, lith boven, lith dorp, liverpool, 
%            lobith, Lovatn, lowestoft, maaseik, maaseik B, Maasgeul-km00, Maasgeul-km01, 
%            Maasgeul-km02, Maasgeul-km03, Maasgeul-km04, Maasgeul-km05, Maasgeul-km06, 
%            Maasgeul-km07, Maasgeul-km08, Maasgeul-km09, Maasgeul-km10, Maasgeul-km11, 
%            Maasgeul-km12, Maasgeul-km13, Maasgeul-km14, Maasgeul-km15, maassluis, 
%            maeslantkering rivierzijde, maeslantkering zeezijde, mainz, malin head, 
%            malzwin boei 1, mannheim, marche, marken vuurtoren, markermeer midden, 
%            marknesse, martinrive, marviken, maxau, medemblik (recreatie terrein), 
%            meeswijk veer, meetboei_PBW1, meetboei_RZGN1, meetboei_UHW1, meetboei_WEO1, 
%            meetboei_WEW1, megen, membre, meppel, milford haven, mississippihaven, 
%            Mjoendalenbru, moerdijk, mond der vecht, mook, muiden, neer, nes, neu darchau, 
%            newhaven, newlyn, Nidelv, nieuw beerta, nieuwe maas boompjes (km 1008), 
%            nieuwe statenzijl, nieuwpoort, nijkerk, nijkerk nijkerkernauw, 
%            nijkerk nuldernauw, nijkerkersluis oost, nijkerkersluis west, nijmegen, Nissan, 
%            noorderbalgen, noordwijk meetpost, noordwijk meetpost 2, NordreOldevatn, 
%            north cormorant 1, northshields, nsb3, nsbII_-10m, nsbII_15m, nsbII_30m, 
%            nsbII_6m, nsbIII_-10m, nsbIII_15m, nsbIII_30m, nsbIII_6m, oderbank-12m, 
%            oderbank-3m, offharwi, olands norra udde, olst, ommen brug, oostende, 
%            oosterschelde 04, oosterschelde-11, oosterschelde-4 boven, 
%            oosterschelde-4 onder, oostvaardersdiep, oranjesluizen oost, oranjesluizen west, 
%            ortho, oscarsborg, oskarshamn, Oslofjord, Otra_Tovdalselv, oude schild, 
%            oude zeug, ouessant large (Fr), paardenboer, pannengat boei 1, pannerden, 
%            pannerdensche kop, pkf post, platform f3, platform k13a, platform k13a-2, 
%            platform k13a-3, plochingen, plymouth, pollendam, port erin, portpatrick, 
%            portsmouth, Q11, ramspolbrug, Randersfjord, ratan, raunheim, rees, rheinfelden, 
%            ringhals, robertville, rockenau, rodvig, Roenne_aelv, roermond, Roeykenes, 
%            roggebotsluis noord, roggebotsluis zuid, roggebotsluisspuikoker, roompot buiten, 
%            roscoff, rotterdam, rozenburgsesluis noordzijde, ruhrort, s-gravendeel, 
%            s.baltic, s.bothnian, salzinnes, sambeek beneden, sambeek boven, Sandvenvatn, 
%            schaar, schaar van ouden doel, schelle, schellingwoude, schellingwoude h1, 
%            schellingwoude inlaatsluis, scheur oost, scheur west, scheveningen, 
%            schiermonnikoog, schiermonnikoog westgat, schokkerhaven, schokland, schoonhoven, 
%            schouwenbank, sheerness, simrishamn, sint pieter, sjaellands odde, skagsudde, 
%            skanor, Skotfoss, sligo, slipshavn, smogen, Solbergfoss, solre sur sambre, 
%            speyer, spijkenisse, spijkenissebrug w.doorvaart (km 1002.6), spikarna, 
%            spooldersluis, stavanger, stavoren, stenungsund, stevensweert, stockholm, 
%            Stordalsvatn, stornoway, Stuvane, sylt, tabreux, Teita_bru, 
%            terschelling noordzee, texelhors, tholen, thorsminde, thyboron, tiel, torsminde, 
%            torsminde havn, torsminde ydermole, travemunde, tredge, treignes, trier, 
%            TW_Ems_-14m, TW_Ems_0m, TW_Ems_15m, TW_Ems_30m, TW_Ems_6m, 
%            UFS_Deutsche_Bucht_-14m, UFS_Deutsche_Bucht_0m, UFS_Deutsche_Bucht_15m, 
%            UFS_Deutsche_Bucht_30m, UFS_Deutsche_Bucht_6m, uikhoven, uk-Britannia, 
%            uk-Gryphon FPSO, uk-Janice, uk-Monarch, uk-Noble Ton van Langeveld, 
%            uk-Northern Producer, uk-Sedco 711, uk-Transocean John Shaw, urk, vaderoarna, 
%            valkenburg, vardoe, vechterweerd, veluwemeer midden, venlo, 
%            versen wehrdurchstich, vidaa, vidaasylt, viken, viker, Viksvatn, 
%            vilsteren beneden, vilsteren boven, visby, vise beneden, Viskan, vlaardingen, 
%            vlakte vd raan, vlakte vd raan boven, vlakte vd raan onder, vlieland, 
%            vlieland haven, vlissingen, vuren, wadden eierlandse gat, 
%            wadden schiermonnikoog, warnemunde, weesp, weesp west, well, werkendam buiten, 
%            wesel, westhinder, wexford, weymouth, whitby, wick, wieldrecht, wierumergronden, 
%            wijdenes, wijhe, wilhelminadorp, wittduen, wolderwijd midden, workington, worms, 
%            wuerzburg, zaltbommel, zdv8-2d-287-74, zdv8-2d-287-75, zdv8-2d-288-71, 
%            zdv8-2d-288-72, zdv8-2d-288-73, zdv8-2d-289-68, zdv8-2d-289-69, zdv8-2d-289-70, 
%            zdv8-2d-290-66, zdv8-2d-290-67, zdv8-2d-291-64, zdv8-2d-291-65, zdv8-2d-292-62, 
%            zdv8-2d-292-63, zdv8-2d-293-60, zdv8-2d-293-61, zdv8-2d-294-59, zdv8-2d-295-57, 
%            zdv8-2d-295-58, zdv8-2d-296-50, zdv8-2d-296-51, zdv8-2d-296-52, zdv8-2d-296-53, 
%            zdv8-2d-296-54, zdv8-2d-296-55, zdv8-2d-296-56, zdv8-2d-323-59, zdv8-2d-323-61, 
%            zdv8-2d-323-65, zdv8-2d-323-68, zdv8-2d-323-71, zeebrugge, zutphen, 
%            zvd8-2d-A094, zvd8-2d-ALBL, zvd8-2d-BEER, zvd8-2d-BGAT, zvd8-2d-BOTB, 
%            zvd8-2d-BOTL, zvd8-2d-BREE, zvd8-2d-BRIE, zvd8-2d-CALB, zvd8-2d-EEMH, 
%            zvd8-2d-HARK, zvd8-2d-HARM, zvd8-2d-HEYS, zvd8-2d-HOEK, zvd8-2d-MMND, 
%            zvd8-2d-PERN, zvd8-2d-ROTB, zvd8-2d-ROTE, zvd8-2d-ROTK, zvd8-2d-SCHK, 
%            zvd8-2d-SEIN, zvd8-2d-SGRA, zvd8-2d-SPYB, zvd8-2d-SUUR, zvd8-2d-VO85, 
%            zvd8-2d-WAAL, zvd8-2d-WIEL, zvd8-2d-ZAND, zwartsluis, zwolle
% Sources  : bma_noos_05, bma_noos_95, bma_noos_fc, bsh_oper, csm8_ecmwf_wind, 
%            csm8_ukmo_wind, dcsm_kalman_oper, dcsm_oper, dcsm_v6, dmi_bak, dmi_oper, 
%            dnmi_discharge, dnmi_oper, fews_rivieren, his_kust, hmcn_csm8, hmcn_ijmond, 
%            hmcn_kustfijn, hmcn_kustgrof, hmcn_zeedelta, hmcn_zeedelta_mv2_f0, 
%            hmcn_zeedelta_mv2_f1, hmcn_zuno, hmcz_csm8_p2, hmr_linux_csm8, hmr_linux_ijmond, 
%            hmr_linux_kustfijn, hmr_linux_kustgrof, hmr_linux_zeedelta, hmr_linux_zuno, 
%            ijsselmeer, imi_roms, knmi_ecmwf_wind, knmi_hirlam_wind, knmi_noos, 
%            knmi_noos_kalman, knmi_preoper, knmi_ukmo_wind, markermeer, mumm_omnecs_oper, 
%            mumm_oper, observed, observed_knmi, rws_oper_hmcz, rws_oper_hmr, rws_oper_svsd, 
%            rws_prediction, smhi_discharge, sobek_hmr, ukmo_oper, waves_ijsselmeer, 
%            wdij_ijsselmeer, wdij_markermeer, wdij_wind, wind_dsc_wdij
% Units    : air_pressure, discharge, precipitation, salinity, seiches_probability, 
%            swellwave_height_hm0, water_direction, water_speed, water_temperature, 
%            water_velocity, waterlevel, waterlevel_astro, waterlevel_astro_max, 
%            waterlevel_astro_min, waterlevel_max, waterlevel_min, waterlevel_model, 
%            waterlevel_model_max, waterlevel_model_min, waterlevel_surge, wave_dir_th0, 
%            wave_direction, wave_dirspread_s0bh, wave_height, wave_height_h1d10, 
%            wave_height_h1d3, wave_height_h1d50, wave_height_hm0, wave_height_hmax, 
%            wave_period, wave_period_t1d3, wave_period_th1d3, wave_period_tm02, 
%            wave_period_tm10, wave_period_tp, wave_period_tz, wind_blast, wind_direction, 
%            wind_speed, wind_speed_max
% 