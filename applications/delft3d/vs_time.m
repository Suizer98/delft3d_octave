function varargout = vs_time(NFSstruct,varargin),
%VS_TIME   Read time information from NEFIS files into datenumbers
%
% T = vs_time(delft3d_file)
% Read all time data from NEFIS into a struct.
%
% Implemented:
% - comfile      (delf3d-FLOW)
% - trimfile     (delf3d-FLOW)
% - trih file    (delf3d-FLOW)
% - hwgxyfile    (delf3d-WAVE)
% - trk file     (delf3d-PART)
% - ada/hda file (delf3d-WAQ)
%
% T = vs_time(delft3d_file,timeindices)
% reads only the timesteps with index in timeindices:
%
% E.g. vs_time(delft3d_file,[1 2]) returns the 1st and 2nd
% times. timeindices = 0 returns all available times (default).
%
% T = vs_time(delft3d_file,timeindices,1) returns only
% a matlab datenum values array.
%
% - nt          # simulated timesteps
% - nt_storage  # timesteps in NEFIS file
% - nt_loaded   # timesteps loaded from NEFIS file
% - morft       # morphological time (days since start of simulation)
%
% See also: vs_use, vs_get, vs_let, vs_disp

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: vs_time.m 12030 2015-06-23 08:17:44Z bartgrasmeijer.x $
% $Date: 2015-06-23 16:17:44 +0800 (Tue, 23 Jun 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 12030 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_time.m $
% 2009 sep 28: added implementation of WAQ ada/hda files [Yann Friocourt]

if ischar(NFSstruct)
   NFSstruct = vs_use(NFSstruct);
end

if nargin>1
   Tindex = varargin{1};
else
   Tindex = 0;
end

if nargin>2
   simple = varargin{2};
else
   simple = 0;
end

if strcmp(NFSstruct.SubType,'Delft3D-trim')
%% -------------------------------------------

      T.t0            = vs_get  (NFSstruct,'map-const', 'ITDATE','quiet');
      % Reference date
      T.itdate0       = num2str(T.t0(1));
      % Reference time [s]
      T.s0            = T.t0(2);
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct,'map-const', 'TUNIT' ,'quiet');
      % Computational time step of simulation [tunit]
      T.dt_simulation = vs_let  (NFSstruct,'map-const', 'DT'    ,'quiet');
      % Computational time step of simulation [s]
      T.dt_simulation = T.dt_simulation*T.tunit;

      % Sequence numbers of simulation results in NFSstruct [#]
      T.nt_storage    = vs_get_grp_size(NFSstruct,'map-info-series');
      T.it            = (1:T.nt_storage)';

      if ~Tindex==0
      T.it            = T.it(Tindex);
      else
      Tindex          = 1:T.nt_storage;
      end

      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct,'map-info-series',{Tindex},'ITMAPC','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.dt_simulation;

      %% determine dt_storage, if possible
      %% ---------------------------------

      if length(Tindex)==1
         if T.nt_storage >1
            tmp.t              = vs_let  (NFSstruct,'map-info-series',{1:2},'ITMAPC','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t              = tmp.t.*T.dt_simulation;
            T.dt_storage       = diff(tmp.t(1:2));
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end
      
      %% 
      output = char(vs_find(NFSstruct,'MORFT'));
      if strcmp(output, 'map-infsed-serie');
          T.morft = vs_let(NFSstruct,'map-infsed-serie','MORFT');
      end
      

elseif strcmp(NFSstruct.SubType,'Delft3D-com')
%% -------------------------------------------

%% many rtime can be written
%% but only one is kept all the time
%% during only coupling to WAQ or WAVE

      % Reference date
      T.itdate0       = num2str(vs_let  (NFSstruct, 'PARAMS'   , 'IT01',  'quiet'));
      % Reference time [s]
      T.s0            = vs_let  (NFSstruct, 'PARAMS'   , 'IT02',  'quiet');
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct, 'PARAMS'   , 'TSCALE','quiet');
      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct, 'CURTIM'   , {Tindex},'TIMCUR','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.tunit;
      % Number of simulation results in NFSstruct [#]
      T.nt_storage    = vs_let  (NFSstruct, 'CURNT'    , 'NTCUR', 'quiet');

      %% determine dt_storage, if possible
      %% ---------------------------------

      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end

      if length(Tindex)==1
         if T.nt_storage >1
            % Time numbers of simulation results in NFSstruct [tunit]
            tmp.t             = vs_let  (NFSstruct, 'CURTIM'   , {1:2},'TIMCUR','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t             = tmp.t.*T.tunit;
            T.dt_storage       = diff(tmp.t(1:2));
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         disp('Only one timestep, cannot determine ''dt_storage'' ...')
      end

elseif strcmp(NFSstruct.SubType,'Delft3D-hwgxy')
%% -------------------------------------------

      % Reference date
      T.itdate0       = num2str(vs_let  (NFSstruct, 'PARAMS'   , 'IT01',  'quiet'));
      % Reference time [s]
      T.s0            = vs_let  (NFSstruct, 'PARAMS'   , 'IT02',  'quiet');
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct, 'PARAMS'   , 'TSCALE','quiet');

      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct, 'map-series', {Tindex},'TIME','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.tunit;

      % Number of simulation results in NFSstruct [#]
      T.nt_storage    = vs_get_grp_size(NFSstruct,'map-series');

      T.it            = (1:T.nt_storage)';
      if ~Tindex==0
      T.it            = T.it(Tindex);
      else
      Tindex          = 1:T.nt_storage;
      end

      %% determine dt_storage, if possible
      %% ---------------------------------

      if length(Tindex)==1
         if T.nt_storage >1

            % Time numbers of simulation results in NFSstruct [tunit]
            tmp.t             = vs_let  (NFSstruct, 'map-series', {1:2},'TIME','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t             = tmp.t.*T.tunit;

            T.dt_storage       = diff(tmp.t(1:2));

         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end


 elseif strcmp(NFSstruct.SubType,'Delft3D-trih')
 %% -------------------------------------------

      T.itdate        = vs_let(NFSstruct,'his-const '     ,'ITDATE',{0},'quiet');
      T.dt_simulation = vs_let(NFSstruct,'his-const '     ,'DT'    ,{0},'quiet');
      T.tunit         = vs_let(NFSstruct,'his-const '     ,'TUNIT' ,{0},'quiet');
      T.t             = vs_let(NFSstruct,'his-info-series',{Tindex},'ITHISC',{0},'quiet');
      T.t             = T.t.* T.dt_simulation.* T.tunit;
      T.nt_storage    = vs_get_grp_size(NFSstruct,'his-series'); % ???????????

      T.s0            = T.itdate(2);
      T.itdate0       = num2str(T.itdate(1));

      %% determine dt_storage, if possible
      %% ---------------------------------

      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end

      if length(Tindex)==1
         if T.nt_storage >1

            tmp.t              = vs_let(NFSstruct,'his-info-series',{1:2},'ITHISC',{0},'quiet');
            tmp.t              = tmp.t.* T.dt_simulation.* T.tunit;

            T.dt_storage       = diff(tmp.t(1:2));

         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end

 elseif strcmp(NFSstruct.SubType,'Delft3D-track')
 %% -------------------------------------------

      T.itdate        = vs_let(NFSstruct,'trk-const'     ,'ITDATE',{0});
      T.itdate0       = num2str(T.itdate(1));
      T.dt_simulation = vs_let(NFSstruct,'trk-const'     ,'DT'    ,{0});
      T.tunit         = vs_let(NFSstruct,'trk-const'     ,'TUNIT' ,{0});
      T.t             = vs_let(NFSstruct,'trk-info-series',{Tindex},'ITTRKC',{0});
      T.t             = T.t.*T.dt_simulation.*T.tunit;
      T.nt_storage    = vs_get_grp_size(NFSstruct,'trk-series');

      T.s0            = T.itdate(2);
      T.itdate0       = num2str(T.itdate(1));

      %% determine dt_storage, if possible
      %% ---------------------------------

      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end

      if length(Tindex)==1
         if T.nt_storage >1

            tmp.tunit         = vs_let(NFSstruct,'trk-const'     ,'TUNIT' ,{0});
            tmp.t             = vs_let(NFSstruct,'trk-info-series',{1:2},'ITTRKC',{0});

            T.dt_storage       = diff(tmp.t(1:2));

         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end

 elseif (strcmp(NFSstruct.SubType,'Delft3D-waq-map') || ...
         strcmp(NFSstruct.SubType,'Delft3D-waq-history'))
 %% -------------------------------------------

      tmp.title       = vs_let(NFSstruct,'DELWAQ_PARAMS'     ,'TITLE',{0});
      tmp.itdate0     = squeeze(tmp.title(1,:,:));
      T. datenum0     = datenum(tmp.itdate0(4,5:23), 'yyyy.mm.dd HH:MM:SS');
      [T.y0, T.m0, T.d0, T.h0, T.mi0, T.s0] = ...
                        datevec(T.datenum0);
      T.itdate0       = datestr(T.datenum0, 'yyyymmdd');
      T.t0(1,1)       = str2double(T.itdate0);
      T.t0(2,1)       = str2double(datestr(T.datenum0, 'HHMMSS'));
      T.nt_storage    = vs_get_grp_size(NFSstruct,'DELWAQ_RESULTS');
      T.t             = vs_let(NFSstruct,'DELWAQ_RESULTS',{Tindex},'TIME',{0});
      switch strtrim((tmp.itdate0(4,31:end-1)))
         case ('1s')
             T.tunit  = 1;
      end
      T.t             = T.t.*T.tunit;
      
 else
    
   error(['NEFIS type does not implemented: ',NFSstruct.SubType])

 end
 %% -------------------------------------------

      T.y0            = str2num(T.itdate0(1:4));
      T.m0            = str2num(T.itdate0(5:6));
      T.d0            = str2num(T.itdate0(7:8));
      T.h0            = 0;
      T.mi0           = 0;

%   try
%   T.dt_storage       = diff(T.t(1:2));
%   catch
%       disp('Only one timestep, cannot determine ''dt_storage'' ...')
%   end

   % Number of simulation results in NFSstruct [#]
   % If run crashes it contains not all timesteps:
   T.nt_loaded     = min(length(T.t),T.nt_storage);

   T.datenum0         = datenum(T.y0 ,T.m0 ,T.d0,...
                                T.h0 ,T.mi0,T.s0);

   T.datenum          = datenum(T.y0 ,T.m0 ,T.d0,...
                                T.h0 ,T.mi0,T.s0 + T.t);

%% remember input file as meta info
%% for later version checking
%% ------------------------

  %T.NFSstruct = NFSstruct;
   T.FileName  = NFSstruct.FileName;

   if simple
       varargout  = {T.datenum};
   else
       varargout  = {T};
   end
