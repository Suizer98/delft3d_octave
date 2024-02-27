function varargout = t_tide2iho(varargin)
%t_tide2iho    t_tide with tide_iho structure (class) output
%
%   [D,<fit>] = t_tide2struc(t,var,<keyword,value>)
%
% performs a t_tide tidal analysis and returns struct D that can 
% be written to file with tide_iho. The syntax is more natural than 
% pure t_tide by (i) passing full time vector and (ii) it allows to 
% analyse only a sub period. Note non-equidistant time-spacing is 
% allowed due to use of OpenEarth version of t_tide.
%
% Get t_tide struct TIDESTRUC too, needed for t_predic:
%
%   [D,<fit>,TIDESTRUC] = t_tide2struc(t_tide_ascii_file,<keyword,value>)
%
%See also: T_TIDE, UTide, t_tide2xml, t_tide2html, t_tide2nc, tide_iho

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares: Gerben J. de Boer
%                 2014: Van Oord DMC: Gerben J. de Boer
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

% $Id: t_tide2struc.m 10792 2014-06-03 10:23:13Z boer_g $
% $Date: 2014-06-03 12:23:13 +0200 (Tue, 03 Jun 2014) $
% $Author: boer_g $
% $Revision: 10792 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tide/t_tide2struc.m $
% $Keywords: $

%% Input

% t_tide

   OPT.period        = [];
   OPT.lat           = NaN;
   OPT.ddatenumeps   = 1e-8;
   OPT.synth         = 2;
   OPT.sort          = 'freq';
   OPT.ascfile       = '';
   
% IHO xml keywords	 
   
    D = tide_iho;

    if nargin==0
      varargout = {OPT};
      return
    end

%% Tidal analysis incl. temporal equidistance check

if odd(nargin) & ~isstruct(varargin{end}) % allow for passing OPT struct

      fname = varargin{1};
      
      OPT       = setproperty(OPT,varargin{2:end});
      D         = tide_iho.from_t_tide_asc(fname);
      OPT.synth = '{unknown, probably 2 (t_tide default)}'; % unknown, not in output

else

      t   = varargin{1};
      var = varargin{2};
   
      OPT = setproperty(OPT,varargin{3:end});
   
      if ~isempty(OPT.period)
          mask = find(( t >= OPT.period(1)) & (t <= OPT.period(end)));
          if t(1  ) > OPT.period(1);fprintf(2,['data starts after start of requested period ',datestr(t(  1)),'>',datestr(OPT.period(  1)),'\n']);
          end
          if t(end) < OPT.period(2);fprintf(2,['data stops before end of requested period '  ,datestr(t(end)),'<',datestr(OPT.period(end)),'\n']);
          end
      else
          mask = 1:length(t);
          OPT.period = [t(1) t(end)];
      end
      dt = diff(t(mask)).*24; % hour

      if length(unique([dt])) > 1
% Not any more with OET t_tide extension
%          if (max(dt) - min(dt)) > OPT.ddatenumeps
%             fprintf(2,'%s\n',['No equidistant time intervals: range: ',num2str(min(dt)),' - ',num2str(max(dt))])
%             varargout = {[]};
%             return
%          end
         t_tide_err = 'wboot'; % 'lin'; % prevent use of licensed Signal_Toolbox
      else
         dt = dt(1); % in hours
         t_tide_err = 'cboot';
      end
      
      output = 'none';
      if ~isempty(OPT.ascfile)
         mkdir(fileparts(OPT.ascfile));
         output = [OPT.ascfile];
      end
     
      [tidestruc,pout]=t_tide(var(mask),...
                 'latitude'  ,OPT.lat,... % required for nodal corrections
                 'start'     ,t(mask(1)),...
                 'interval'  ,dt,... % in hours
                 'output'    ,output,...
                 'error'     ,t_tide_err,...
                 'sort'      ,OPT.sort,...
                 'synth'     ,OPT.synth);

   %% Collect relevant data in struct, as if returned by D = nc2struct()                 

      D.data.name       = tidestruc.name;D.cf_units.name      = ''; D.long_name.name      = 'component name';
      D.data.frequency  = tidestruc.freq;D.cf_units.frequency = '1/hour'; D.long_name.frequency = 'frequency';
      if isreal(var)
      D.data.fmaj       = tidestruc.tidecon(:,1);D.name.fmaj = 'amplitude'      ;D.cf_units.fmaj = D0.units      ;D.long_name.fmaj = 'amplitude of tidal component';
      D.data.emaj       = tidestruc.tidecon(:,2);D.name.emaj = 'amplitude_error';D.cf_units.emaj = D0.units      ;D.long_name.emaj = 'estimate of error of amplitude of tidal component';
      D.data.pha        = tidestruc.tidecon(:,3);D.name.pha  = 'phase'          ;D.cf_units.pha  = 'degrees'     ;D.long_name.pha  = 'phase of tidal component';
      D.data.epha       = tidestruc.tidecon(:,4);D.name.epha = 'phase_error'    ;D.cf_units.epha = 'degrees'     ;D.long_name.epha = 'estimate of error of phase of tidal component';
      else
      D.data.fmaj       = tidestruc.tidecon(:,1);D.name.fmaj = 'sema'           ;D.cf_units.fmaj = D0.units      ;D.long_name.fmaj = 'major ellipse axis of tidal component';
      D.data.emaj       = tidestruc.tidecon(:,2);D.name.emaj = 'sema_error'     ;D.cf_units.emaj = D0.units      ;D.long_name.emaj = 'estimate of error of major ellipse axis of tidal component';
      D.data.fmin       = tidestruc.tidecon(:,3);D.name.fmin = 'semi'           ;D.cf_units.fmin = D0.units      ;D.long_name.fmin = 'minor ellipse axis of tidal component';
      D.data.emin       = tidestruc.tidecon(:,4);D.name.emin = 'semi_error'     ;D.cf_units.emin = D0.units      ;D.long_name.emin = 'estimate of error of minor ellipse axis of tidal component';
      D.data.finc       = tidestruc.tidecon(:,5);D.name.finc = 'inc'            ;D.cf_units.finc = 'degrees_true';D.long_name.finc = 'ellipse orientation';
      D.data.einc       = tidestruc.tidecon(:,6);D.name.einc = 'inc_error'      ;D.cf_units.einc = 'degrees_true';D.long_name.einc = 'estimate of error of ellipse orientation';
      D.data.pha        = tidestruc.tidecon(:,7);D.name.pha  = 'phase'          ;D.cf_units.pha  = 'degrees'     ;D.long_name.pha  = 'phase of tidal component';
      D.data.epha       = tidestruc.tidecon(:,8);D.name.epha = 'phase_error'    ;D.cf_units.epha = 'degrees'     ;D.long_name.epha = 'estimate of error of phase of tidal component';
      end
      D.data.snr          = (D.data.fmaj./D.data.emaj).^2;  % signal to noise ratio (t_tide line 523)
      D.data.significance = D.data.snr > OPT.synth;
      
      D.cf_units.snr          = '1'; D.long_name.snr          = 'signal to nosie ratio';
      D.cf_units.significance = '1'; D.long_name.significance = 'significance';
      
end

if ~isempty(OPT.period)
   D0.observationStart    = datestr(t(mask(  1)),31); % can be fed to datenum()
   D0.observationEnd      = datestr(t(mask(end)),31);
end

D = mergestructs('overwrite',D,D0); % add IHO keywords

%% output

if nargout==1
   varargout = {D};
elseif nargout==2
   varargout = {D,pout};
elseif nargout==3
   varargout = {D,pout,tidestruc};
end   

