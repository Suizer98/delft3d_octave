function varargout = bct2bca(varargin)
%BCT2BCA          performs tidal analysis to generate *.bca from *.bct <<beta version!>>
%
%       bct2bca(keyword_struct)
% BCA = bct2bca(<keyword,value>)
%
% Analyses a Delft3D FLOW *.bct file (time series boundary condition)
% into a  *.bca file (astronomic components boundary conditions).
% using the  *.bnd file (boundary definition file) and using T_TIDE.
%
% Note that the *.bnd file should contain astronomical boundaries
% for all time series present in the *.bct file!!!
%
% Works for now only for 2D boundaries, not for 3D boundary specifications!
%
% The following <keyword,value> pairs are implemented (not case sensitive):
%
%    * bctfile:     bct file. --> Required
%    * bcafile:     bca file. --> Required
%    * bndfile:     bnd file. --> Required
%
%    * timezone:    hours to be SUBTRACTED from to the timeseries to get UTC times.
%                   E.G. for CET set timeshift to + 1 (default 0).
%    * period:      a two element vector to specify the start and end
%                   datenumber. Make sure you obey the Rayleigh criterion.
%                   When set to NaN the entire timeserie in the bctfile is used (default).
%    * components:  set of component names (e.g.: {'K1','O1','P1','Q1','K2','M2','N2','S2'})
%                   By default t_tide selects components based on Rayleigh criterion.
%                   NOTE 1. names in delft3d and t_tide are different, and
%                           are mapped via preliminary T_TIDE_NAME2DELFT3D
%                   NOTE 2. Not all components you specify have to be present
%                           in the *.bca file, depending on the automatic Rayleigh
%                           criterion selection by T_TIDE.
%
%    * A0      :    include mean component A0 in *.bca (default 1)
%                   Note: t_tide does not generally return an A0 component.
%
% The following keywords are simply passed from/to  t_tide
%
%    * latitude:    see t_tide [] default (same effect as none in t_tide)
%
%    NOTE THAT ANY LATITUDE IS REQUIRED FOR T_TIDE TO INCLUDE NODAL FACTORS AT ALL
%
%    * shallow:     see t_tide (default '')
%    * secular:     see t_tide (default 'mean')
%
%    * infername  = see t_tide (default {}), can be passed as cell array, e.g. {'P1';'K2';'NU2'}.
%    * inferfrom  = see t_tide (default {}), can be passed as cell array, e.g. {'K1';'S2';'N2' }.
%    * infamp     = see t_tide (default []),                              e.g. [0.295;0.276;0.215].
%    * infphase   = see t_tide (default []),                              e.g. [-13.8;-13.7;3.6].
%
%    * method:      't_tide' (default)
%
%    * plot:        0/1 to plot time series and residue (default 1)
%                   combine this with either pause or export to te bale to actually inspect the plots
%    *   pause:     0/1 to pause after each plot (default 1)
%    *   export:    0/1 to print plot (default 0)
%
%    * output:      where to send printed output:
%                   'none'    (no printed output)
%                   'screen'  (to screen) - default
%                   1         (to a separate file per analysed time series, for which the
%                              name differs per boundary support endpoint. DO not use a
%                              file name here, that will be rewritten every time!!)
%
%    * residue:     Writes bct of residual  time series (value is name of *.bct file, default [])
%    * prediction:  Writes bct of predicted time series (value is name of *.bct file, default [])
%
%    * unwrap:      Delft3D programmers in the past decided to interpolate
%                   the phases inside a boundary segment linearly (as a scalar)
%                   without correction  for the generally-known phase range
%                   [0 360]: so the average of 359 and 1 will end up as 180
%                   rather than 360. Therefore this bct2bch makes sure
%                   that the two phase values along one boundary can be
%                   interpolated linearly where [359 1] should be specified as
%                   [359 361]. logical, default 1.
%
%    * error:       See t_tide help, default is 'cboot', but can return an error if the Matlab
%                   signal toolbox is not available, other options are 'linear' and 'wboot', to
%                   overcome this error when not having this toolbox available
%
%    Note. The end points of two subsequent boundaries are not the same, they 
%    are defined on the adjacent waterlevel points, not on the common corner point !
%    To ensure that two boudnary segments use the same end point, make the boundaries
%    overlap one (m,n) index (the GUI does not support this, but it is allowed).
%
%    OPT = bct2bca returns struct with default <keyword,value> pairs
%
%  It is also to possible to call with all the <keyword,value> pairs as struct fields:
%  bct2bca(bctfile,bcafile,bndfile,struct)
% 
% Example 1 (keyword structure):
%
% H.components  = {'K1','P1','O1','M2','N2','S2','K2','M4','MS4'};
% H.infername   = {'P1'   ;'K2'};
% H.inferfrom   = {'K1'   ;'S2'};
% H.infamp      = [ 0.320 ; 0.291 ];
% H.infphase    = [-4.25  ; 0.0   ];
% H.latitude    = 22.5; % eps; %52;
% H.plot        = 0;
% H.pause       = 0;
% H.output      = 'none';
% H.residue     = [];
% H.prediction  = [];
% H.A0          = 1;
% H.bctfile     = 'test.bct'; % --> Required
% H.bcafile     = 'test.bca'; % --> Required
% H.bndfile     = 'test.bnd'; % --> Required
%
% bct2bca(H);
%
%
% Example 2 (<keyword,value> pairs):
%
% bca_data = bct2bca('bctfile','test.bct','bcafile','test.bca','bndfile','test.bnd');
% % Note that the *.bct, *.bca and *.bnd files are required input)
%
% See also: BCT2BCA, DELFT3D_NAME2T_TIDE, T_TIDE_NAME2DELFT3D,
%           TIME2DATENUM, BCT2BCH,
%           BCT_IO, DELFT3D_IO_BCA, DELFT3D_IO_BND,
%           T_TIDE (http://www.eos.ubc.ca/~rich/)

% 2008 Feb 14  * updated to include latitude as extra parameter as suggested by Arjan Mol and Anton de Fockert
% 2008 Jul 11: * changed name of t_tide output (to prevent error due to ':' in current column name) [Anton de Fockert]
%              * added comment NOT to use a fixed output file name [Anton de Fockert]
%              * added actual bca output again [Anton de Fockert]
% 2008 Jul 21  * added inference as arguments

% Requires the following m-functions:
% - bct_io
% - delft3d_io_bca
% - delft3d_io_bnd
% - time2datenum
% - datenum2index
% - rad2deg
% - t_tide and associated stuff

% TO DO:
% - Allow for input of BCT, BND structs instead of their filenames.
% - Allow for input of BCA to be empty, to have it only returned as argument.
% - Allow t_tide_name2delft3d to return [] when there is no equivalent delft3d name

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   Update 2017:
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%       freek.scheel@deltares.nl
%
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: bct2bca.m 13215 2017-03-23 08:21:43Z scheel $
% $Date: 2017-03-23 16:21:43 +0800 (Thu, 23 Mar 2017) $
% $Author: scheel $
% $Revision: 13215 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/bct2bca.m $

%% Defaults

   OPT.timezone   = 0;
   OPT.period     = nan;
   OPT.components = {}; %{'K1','O1','P1','Q1','K2','M2','N2','S2'};
   OPT.method     = 't_tide';
   OPT.A0         = 1;

   OPT.plot       = 1;
   OPT.pause      = 1;
   OPT.export     = 0;
   OPT.output     = 'screen';
   OPT.latitude   = [];
   OPT.error      = 'cboot';

   OPT.shallow    = '';
   OPT.secular    = 'mean';

   OPT.residue    = [];
   OPT.prediction = [];

   OPT.unwrap     = 1;

   OPT.infername  = {};
   OPT.inferfrom  = {};
   OPT.infamp     = [];
   OPT.infphase   = [];
   
   OPT.bctfile    = '';
   OPT.bcafile    = '';
   OPT.bndfile    = '';

%% Return defaults

   if nargin==0
      varargout = {OPT};
      return
   end

%% Input

   OPT = setproperty(OPT,varargin{:});
   
%% Put interference in Nx4 format required by t_tide

   if ~isempty(OPT.infername);
      if iscell(OPT.infername);OPT.infername = pad(char(OPT.infername),' ',4);
      end
   end

   if ~isempty(OPT.inferfrom);
      if iscell(OPT.inferfrom);OPT.inferfrom = pad(char(OPT.inferfrom),' ',4);
      end
   end

%% go

   if  isempty(OPT.latitude);warning('No latitude passed, performing simple harmonic analysis, not tidal analysis!');end

   OPT.directory = filepathstr(OPT.bctfile);

%% Loop over boundary segments

   BND          = delft3d_io_bnd('read',OPT.bndfile);

   disp(['Loading ',OPT.bctfile,'...']); % sometimes slow, especially moronic fixed width files with zillions of spaces as produced by NESTHDx
   BCT          = bct_io        ('read',OPT.bctfile);

%% Write residue/prediction to bct file

   if ~isempty(OPT.residue)
      BCTres = BCT;
   end

   if ~isempty(OPT.prediction)
      BCTprd = BCT;
   end

%% Loop over boundary segments = Tables

BCA.DATA = [];

   for itable = 1:BCT.NTables

      ncol = size(BCT.Table(itable).Data,2);

      d3d_days                  = +              BCT.Table(itable).Data(:,1)./60./24; % minutes 2 days

      BCT.Table(itable).datenum = + d3d_days ...
                                  + time2datenum(BCT.Table(itable).ReferenceTime) ...
                                  - OPT.timezone/24;
      if isnan(OPT.period)
         OPT.period = BCT.Table(itable).datenum([1 end]);
      end

      for icol = 2:ncol; % 1st column is date in minutes wrt the refdate

         %% !!!!!!!!! actually only for new endpoints, what about 3D data
         T.location      = BCT.Table(itable).Location;
         T.index         = datenum2index(BCT.Table(itable).datenum,OPT.period([1 end]));
         T.datenum       =               BCT.Table(itable).datenum(T.index,1     );
         T.quantity      =               BCT.Table(itable).Data   (T.index,icol  );
         T.quantity_name =               BCT.Table(itable).Parameter(icol).Name;
         T.quantity_unit =               BCT.Table(itable).Parameter(icol).Unit;
         T.datenum0      =               BCT.Table(itable).datenum(T.index(1    ));
         T.interval      =          diff(BCT.Table(itable).datenum(T.index([1 2])))*24;

         if strcmpi(OPT.method(1),'t') % t_tide

              BASEFILENAME = [filename(BCT.FileName),'.',...
                              OPT.method              ,'.',...
                              T.location            ,'.',...
                       strrep(T.quantity_name,':','')]; % to be used for both t_tide *.txt files and *.png

              if isnumeric(OPT.output)


                 if isempty(OPT.latitude)
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'rayleigh'  ,OPT.components,...
                              'inference' ,OPT.infername,OPT.inferfrom,OPT.infamp,OPT.infphase,...
                              'interval'  ,T.interval,...
                              'output'    ,[BASEFILENAME,'.cmp'],...
                              'error'     ,OPT.error);
                 else
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'rayleigh'  ,OPT.components,...
                              'inference' ,OPT.infername,OPT.inferfrom,OPT.infamp,OPT.infphase,...
                              'interval'  ,T.interval,...
                              'latitude'  ,OPT.latitude,...
                              'output'    ,[BASEFILENAME,'.cmp'],...
                              'error'     ,OPT.error);
                 end
              else
                 if isempty(OPT.latitude)
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'rayleigh'  ,OPT.components,...
                              'inference' ,OPT.infername,OPT.inferfrom,OPT.infamp,OPT.infphase,...
                              'interval'  ,T.interval,...
                              'output'    ,OPT.output,...
                              'error'     ,OPT.error);
                 else
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'rayleigh'  ,OPT.components,...
                              'inference' ,OPT.infername,OPT.inferfrom,OPT.infamp,OPT.infphase,...
                              'interval'  ,T.interval,...
                              'latitude'  ,OPT.latitude,...
                              'output'    ,OPT.output,...
                              'error'     ,OPT.error);
                 end
              end

            %% Take care of A0 (in components AND residue)

              if OPT.A0
                 A0 = nanmean(T.quantity);

                 tidestruc.name    = strvcat('Z0  ',tidestruc.name);
                 tidestruc.freq    = [0; ...
                                      tidestruc.freq];
                 tidestruc.tidecon = [A0 0 0 0;...
                                      tidestruc.tidecon];
	
                 pout = pout - A0;
              end

            %% Plot

            if OPT.plot

               TMP = figure;

                  % t_plot(T.datenum,T.quantity,pout,tidestruc)
                  plot    (T.datenum,T.quantity       ,'b','DisplayName','timeseries');
                  hold on
                  plot    (T.datenum,pout             ,'g','DisplayName','prediction');
                  plot    (T.datenum,T.quantity - pout,'r','DisplayName','residue'   );
                  legend  show
                  datetick('x')
                  xlabel  (['year: ',num2str(unique(year(xlim)))])
                  disp('Press key to continue bct2bca ...')
                  Handles.title  = title ({['Boundary location name: ',T.location]});
                  Handles.ylabel = ylabel({['Boundary series   name: ',T.quantity_name],...
                                                                       T.quantity_unit}); % is empty in NESTHD *.bct files

                  set(Handles.title ,'interpreter','none')
                  set(Handles.ylabel,'interpreter','none')
                  grid
	
                  if OPT.pause
                     disp('Press key to continue ...')
                     pause
                  end

                  if OPT.export
                     print([BASEFILENAME,'.png'],'-dpng')
                  end


               try
               close(TMP)
               end

            end

         %% Write residue/prediction to bct file

            if ~isempty(OPT.residue)
               BCTres.Table(itable).Data(T.index,icol  ) = T.quantity - pout;
            end

            if ~isempty(OPT.prediction)
               BCTprd.Table(itable).Data(T.index,icol  ) = pout;
            end

         %% Rename to delft3d names
         %% '' when no equivalent is present

            tidestruc.name = cellstr(tidestruc.name);
            keep           = ones(size(tidestruc.freq)); % all 1
            for j=1:length(tidestruc.name)
               tidestruc.name{j} = t_tide_name2delft3d(tidestruc.name{j});
               if isempty(tidestruc.name{j})
                  keep(j)           = 0;
               end
            end

         %% Remove components that are unknown to Delft3D (tidestruc.name='')

            tidestruc0 = tidestruc;
            clear        tidestruc
            kept       = 0;
            for j=1:length(keep)
              if keep(j)
                kept = kept +1;
                tidestruc.name   {kept}   = tidestruc0.name   {j}  ;% {n x 1 cell}
                tidestruc.freq   (kept)   = tidestruc0.freq   (j)  ;% [n x 1 double]
                tidestruc.tidecon(kept,:) = tidestruc0.tidecon(j,:);% [n x 4 double]
              end
            end

         %% Use only selected components

            mask           = 0.*[1:(length(tidestruc.name))];
            if isempty(OPT.components)
                mask=mask+1;
            else
                for j=1:length(tidestruc.name)
                    for jj=1:length(OPT.components)
                        if strcmpi(strtrim(char(tidestruc.name{ j})),...
                                strtrim(char(OPT.components  (jj))));
                            mask(j) = 1;
                        end
                    end
                end
            end

            mask = logical(mask);
            tidestruc.name    = char(tidestruc.name);
            tidestruc.name    = tidestruc.name   (mask,:);
            tidestruc.freq    = tidestruc.freq   (mask);
            tidestruc.tidecon = tidestruc.tidecon(mask,:);

%           tidestruc.name    = char(tidestruc.name);
%           tidestruc.name    = tidestruc.name   (:,:);
%           tidestruc.freq    = tidestruc.freq   (:,:);
%           tidestruc.tidecon = tidestruc.tidecon(:,:);

         %% Put in *.bca struct
         
            BCA.DATA(end+1).names = tidestruc.name        ;% [n x 2 char]
            BCA.DATA(end).label   = [T.location,'_',num2str(icol-1)];            % 'north_001A'
            BCA.DATA(end).amp     = tidestruc.tidecon(:,1);% [0.0670 0.1085 0.0244 0.0292 0.0172 0.0252 0.0663 0.0723]
            BCA.DATA(end).phi     = tidestruc.tidecon(:,3);% [168.2587 106.2307 162.9063 81.0589 143.1680 -86.1792 -84.3035 119.0369]
            if icol==2
                BND.DATA(itable).labelA = BCA.DATA(end).label;
            else
                BND.DATA(itable).labelB = BCA.DATA(end).label;
            end
            BND.DATA(itable).datatype = 'A';
         end

         %% Make sure there are no transitions across the 360 boundary inside one boundary segment
         %  because Delft3D-FLOW interpolates linearly (as a scalar) inside the boundary segment.
         % 
         %  This does probably also deal correctly with 3D velocity boundaries
         %  where also in the vertical some interpolation is required.

            if OPT.unwrap

              % all |steps| > 180 are changed
              % BCOPT.phases(1:end,itable,ifreq) =  domain2angle(BCOPT.phases(1:end,itable,ifreq),0,360,180);
              BCA.DATA(end).phi =  rad2deg(unwrap(deg2rad(BCA.DATA(end).phi)));

            end

      end % for icol = 2:ncol;

      disp(['Processed boundary ',num2str(itable,'%0.3d'),' of ',num2str(BCT.NTables,'%0.3d')]); % max 200 in Delft3d, so 3 digits OK

   end % for itable = BCT.NTables

%% Write residue/prediction to bct file

   if ~isempty(OPT.residue)
      BCT = bct_io('write',OPT.residue,BCTres);
   end

   if ~isempty(OPT.prediction)
      BCT = bct_io('write',OPT.prediction,BCTprd);
   end

%% Output

   delft3d_io_bca('write',[OPT.bcafile],BCA)
   if length(OPT.bndfile) < 5
       OPT.bndfile = [OPT.bndfile '.bnd'];
   elseif ~strcmp(OPT.bndfile(1,end-3:end),'.bnd')
       OPT.bndfile = [OPT.bndfile '.bnd'];
   end
   if isempty(strfind(OPT.bndfile,filesep))
       delft3d_io_bnd('write',[filename(OPT.bndfile),'_from_bct2bca.bnd'],BND);
   else
       delft3d_io_bnd('write',[filepathstr(OPT.bndfile),filesep,filename(OPT.bndfile),'_from_bct2bca.bnd'],BND);
   end
   
   if nargout==1
      varargout = {BCA};
   end

%%%%%%%%%%%%%%%%%%%%%%%%%

   function index = datenum2index(t,tlims)
   %DATENUM2INDEX
   %
   % index = datenum2index(datenum,datenum_lims)
   %
   % returns indices in timevector where
   %
   % index = find(t >= tlims(1) & t <= tlims(2));

   index = find(t >= tlims(1) & t <= tlims(2));

