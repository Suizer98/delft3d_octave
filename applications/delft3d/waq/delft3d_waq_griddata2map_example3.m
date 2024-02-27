%DELFT3D_WAQ_GRIDDATA2MAP_EXAMPLE3  Example to grid/write spatio-temporal data to WAQ *.map file 
%
% (c) WL | Delft Hydraulics, G.J. de Boer, 2007 May 13th.
% Script to bin WAVM SWAN to WAQ map files.
%
% Note that the fortran tools map2sgf of Jan v Beek is needed
% to convert the resulting WAQ *.map file to WAQ *.sgf file.
% Because the *.sgf does not contain any meta-information (not quite Good Modelling Practise ...),
% it is trongly advised to store only the *.map files (that may contain
% a little bit of meta-information, notably UNTIS!!), and convert them only to 
% *.sgf files when actually running WAQ.
%
% Do mind during this script:
% * cell corner/center differences
% * any dummy rows in the Delft3D-FLOW/WAQ grids
%
%See also: DELWAQ, FLOW2WAQ3D, ADDROWCOL, CORNER2CENTER

% $Id: delft3d_waq_griddata2map_example3.m 5498 2011-11-17 15:21:46Z sittoni $
% $Date: 2011-11-17 23:21:46 +0800 (Thu, 17 Nov 2011) $
% $Author: sittoni $
% $Revision: 5498 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_griddata2map_example3.m $

%% G.J. de Boer <gerben.deboer@deltares.nl>, <g.j.deboer@tudelft.nl>

%% Input
% ---------------------------------------------------

   OPT.directory.wavm  = 'F:\vanClaire\';
   OPT.files.wavm      = 'vWind1';
   OPT.refdatenum      = datenum(2008,1,1);% reference date in WAQ simulation
   
%% Script options
% ---------------------------------------------------

   OPT.plot.Segments   = 1;
   OPT.pause           = 1;
   OPT.export          = 1;
   OPT.plot.tau        = 1;
   OPT.FLOW2WAQ        = 1;
   OPT.clim            = [0 2]; % for color plot var

   OPT.roughness_formulation = 'swart';
   OPT.rough                 = 0.05;% roughness value [m]
   OPT.gamma                 = 0.6; % depth limitation Hs
   
   OPT.binmethod       = 'griddata'; % FAST: 'interp2', SLOW: 'bin2' but bin2 most appropriate (fine to coarse) [VERY SLOW: 'griddata']
   OPT.interp2method   = 'linear';   % 'nearest' - nearest neighbor interpolation
                                     % 'linear'  - bilinear interpolation
                                     % 'spline'  - spline interpolation
                                     % 'cubic'   - bicubic interpolation as long as the data is
                                     %             uniformly spaced, otherwise the same as 'spline'

%% WAQ input/output
% ---------------------------------------------------

   OPT.directory.waq   = 'F:\vanClaire\';
   OPT.files.waqgrid   = 'S1S2_M2M4M6.cco';
   OPT.backgroundvalue = 0;
                         %123456789_123456789_123456789_123456789_
   OPT.header          = {['G.J.deBoer,2008may13, tau [Pa] from'],...
                          [OPT.directory.waq],...
                          ['with ',OPT.binmethod,',ks=',num2str(OPT.rough)]}; % size 3 x 40 char, 4th line will contains time info
   OPT.k               = 1; % WAQ layer in which the 2D data field is written, rest is background
   

%% Load FLOW/WAQ grid
% ---------------------------------------------------

   FLOW = delwaq('open',[OPT.directory.waq,filesep,OPT.files.waqgrid]);
   
   % Remove moronic fields of which the meaning is unclear.
   % due to moronic dummy rows and columns.
   % Only add all dummy rows and columsn when aggregatting to WAQ grid.
   
   FLOW.cor.x    = FLOW.X(1:end-1,1:end-1);
   FLOW.cor.y    = FLOW.Y(1:end-1,1:end-1);
   FLOW          = rmfield(FLOW,'X');
   FLOW          = rmfield(FLOW,'Y');
  [FLOW.cen.x,...
   FLOW.cen.y]   = corner2center(FLOW.cor.x,FLOW.cor.y);

   FLOW.cen.Index                   = FLOW.Index(2:end-1,2:end-1,:);
   FLOW.cen.Index(FLOW.cen.Index==0)= NaN; % We do not remove FLOW field 'Index' as we require it with all dummy rows for aggregation.
   FLOW.flow2waqcoupling2D          = flow2waq3d_coupling(FLOW.Index(:,:,1),FLOW.NoSegPerLayer,'i'); % new flow2waq3d_coupling !! per 2008 May 13
   FLOW.flow2waqcoupling3D          = flow2waq3d_coupling(FLOW.Index       ,FLOW.NoSeg        ,'i'); % new flow2waq3d_coupling !! per 2008 May 13  
   
   %% Plot FLOW/WAQ grid (debug)
   % ----------------------------------

   if OPT.plot.Segments
   figure('name','plotSegments')
   for k=1:size(FLOW.cen.Index,3)
      cla
      pcolorcorcen(FLOW.cor.x,FLOW.cor.y,FLOW.cen.Index(:,:,k),[.5 .5 .5])
      title(['Layer: '       ,num2str(k),...
             ' Seg # range: ',num2str(nanmin(make1d(FLOW.cen.Index(:,:,k)))),...
             '  ',            num2str(nanmax(make1d(FLOW.cen.Index(:,:,k))))])
      colorbarwithtitle('Seg #')
      
      if OPT.export
         print2screensize(['Segment_nr_layer_',num2str(k,'%0.3d')]);
      end
   end
   end

%% Generate tau data
% ----------------------------------

   %% Load WAVM data in struct W<ave>
   % ----------------------------------

wavm = vs_use([OPT.directory.wavm,filesep,'wavm-',OPT.files.wavm,'.def']);
T    = vs_time(wavm);
   
for it = 1:T.nt_loaded
   
   disp([num2str(it),'/',num2str(T.nt_loaded)])
   
   % note SWAN calculates at grid corners
   
   W.cor.x    = permute(vs_let(wavm,'map-series',{it},'XP'     ,{0,0}),[2 3 1]);
   W.cor.y    = permute(vs_let(wavm,'map-series',{it},'YP'     ,{0,0}),[2 3 1]);
   W.cor.Hs   = permute(vs_let(wavm,'map-series',{it},'HSIGN'  ,{0,0}),[2 3 1]);
   W.cor.Tm   = permute(vs_let(wavm,'map-series',{it},'PERIOD' ,{0,0}),[2 3 1]);
   W.cor.rTp  = permute(vs_let(wavm,'map-series',{it},'RTP'    ,{0,0}),[2 3 1]);
   W.cor.Tm   = permute(vs_let(wavm,'map-series',{it},'PERIOD' ,{0,0}),[2 3 1]);
   W.cor.dep  = permute(vs_let(wavm,'map-series',{it},'DEPTH'  ,{0,0}),[2 3 1]);
   W.cor.ubot = permute(vs_let(wavm,'map-series',{it},'UBOT'   ,{0,0}),[2 3 1]); % rms
   W.cor.L    = permute(vs_let(wavm,'map-series',{it},'WLENGTH',{0,0}),[2 3 1]);
   
   W.cor.code = permute(vs_let(wavm,'map-series',{it},'CODE'   ,{0,0}),[2 3 1])==1;

  %W.cor.x   (~W.cor.code) = nan;% NOT OTHWERISE GRIDDATA FAILS
  %W.cor.y   (~W.cor.code) = nan;% NOT OTHWERISE GRIDDATA FAILS
   W.cor.Hs  (~W.cor.code) = nan;
   W.cor.Tm  (~W.cor.code) = nan;
   W.cor.rTp (~W.cor.code) = nan;
   W.cor.Tm  (~W.cor.code) = nan;
   W.cor.dep (~W.cor.code) = nan;
   W.cor.ubot(~W.cor.code) = nan; % rms
   W.cor.L   (~W.cor.code) = nan;

   %% Calculate wave-induced bed shear stress intro struct C<alculated>
   % ------------------------------------

   C.cor.L = wavedispersion(W.cor.Tm,W.cor.dep);

   % in lien wth FLOW use calculated ubot instead of W.cor.ubot
   C.cor.ubot = (min(W.cor.Hs,OPT.gamma.*W.cor.dep)./2)... % a
                .*(2*pi./W.cor.Tm)...                     % * omega
                ./sinh(2.*pi.*W.cor.dep./C.cor.L);         % / sinh(hk), Battjes, korte golven dictaat Eq. 3.21
                                                           % Not equal to FLOW manual Eq. (9.173) due to factor by Thornton and Guza (1986) 

   switch lower(OPT.roughness_formulation)
     case 'tamminga'
     case 'swart'
     
       rhow   = 1000;

       % Swart, D. H., 1974: Offshore sediment transport and 
       % equilibrium beach profiles. Delft Hydraulics Laboratory Publ. No. 131, 302 pp., (page 146+ ?? Eq 6.73)
       % See Delft3d manual page 9-68 Eq. 9.174
       % See korte golven dictaat Eq. (3.20)
       
       % r = A./ks
       C.cor.r                   = C.cor.ubot./OPT.rough./(2*pi./W.cor.Tm);    % ubot./omega./r, FLOW manual Eq. (9.175)
       C.cor.fw                  = real(0.00251.*exp(5.21.*C.cor.r.^(-0.194))); % FLOW manual Eq. (9.174)
       C.cor.fw(C.cor.r <= pi/2) = 0.32;
       
     case 'soulsby'
     
   end
   
   C.cor.tau  = (rhow/2).*C.cor.fw.*(C.cor.ubot.^2); % FLOW manual Eq. (9.172), use /2 for max, and /4 for mean tau during wave period
   
   C.cor.tau  = abs(C.cor.tau); % get rid of complex numbers

%% Grid WAVM to FLOW grid
% ----------------------------------

   % interpolate from orthogonal data set
   % goal vertices may not contain NaN
   % so we pass a 1D of only real coordinates
   
   mask     = (~isnan(FLOW.cen.x)) & ...
              (~isnan(FLOW.cen.y));
   Z = nan.*ones(size(FLOW.cen.x));
   
   if strcmp(OPT.binmethod,'griddata')
      FLOW.cen.tau(:,:) = griddata(W.cor.x,... % full matrix
                                   W.cor.y,... % full matrix
                                   C.cor.tau,... 
                                   FLOW.cen.x,...
                                   FLOW.cen.y,OPT.interp2method)
   elseif strcmp(OPT.binmethod,'bin2')
      FLOW.cen.tau(:,:) = bin2(W.cor.x,... % full matrix
                               W.cor.y,... % full matrix
                               C.cor.tau,... 
                               FLOW.cor.x,...
                               FLOW.cor.y);
   elseif strcmp(OPT.binmethod,'interp2')
      Z(~mask) = NaN;
      disp('Using interp2(x(1,:),y(:,1)), PLEASE VERIFY THESE ARE THE ORTHOGONAL VECTORS')
      Z( mask) = interp2(W.cor.x(1,:),... % 1D vector
                         W.cor.y(:,1),... % 1D vector
                         C.cor.tau,... 
                         FLOW.cen.x(mask),...
                         FLOW.cen.y(mask),OPT.interp2method);
                         
      FLOW.cen.tau(:,:) = Z;
   end
                                            
   %% Plot silt data to FLOW grid (debug)
   % ----------------------------------

   if OPT.plot.tau
   figure('name','plotsilt2FLOW')
      pcolorcorcen(FLOW.cor.x,FLOW.cor.y,FLOW.cen.tau(:,:),[.5 .5 .5])
      hold on
      caxis(OPT.clim)
      colorbarwithtitle({['tau [Pa]']})
      title({['Binning method: ',OPT.binmethod]})
      
      if OPT.export
         print2screensize([OPT.directory.waq,filesep,'silt2FLOW_tau_time_',OPT.binmethod,'_',num2str(it,'%0.3d')]);
      end

   end

%% Aggregate FLOW data to WAQ grid
% and write to WAQ file
% ----------------------------------

   if OPT.FLOW2WAQ

      %% add dummy rows and columsn to corect aggregation indexing
      % ----------------------------------
      
      fullmatrix = FLOW.cen.tau(:,:);
      
      %% make sure 1st dimension is n
      
      fullmatrix = permute(fullmatrix,[1 2]);

      fullmatrix = addrowcol(fullmatrix,[-1 1],[-1 1],NaN);
      
      fullmatrix(isnan(fullmatrix)) = OPT.backgroundvalue;
      
      % Duplicate value for all KMAX layers, 
      % as WAQ needs all data 3D in 3D computation, 
      % even 2D data as bed shear stresses.
      % All other dummy elements are set to zero.
      %
      % The 2D > 3D below method works only if all layers in all columns are active
      % ----------------------
      
      WAQ2D.tau = flow2waq3d(fullmatrix,FLOW.flow2waqcoupling2D);

      kmax   = FLOW.MNK(3);
      nWAQ2D = length(WAQ2D.tau);
      
      %% make 'emmty' 3D matrix
      WAQ.tau = repmat(OPT.backgroundvalue,[1 nWAQ2D*kmax]);
      
      %% fill only one layer with 2D data 
      WAQ.tau(1,(1:nWAQ2D) + nWAQ2D.*(OPT.k-1)) = WAQ2D.tau;
      
      %% Write to waq map file
      % ----------------------------------

      if (it==1)
        STRUCT    = delwaq('write',[OPT.directory.waq,filesep,'tau.map'],...
                           char(OPT.header),...
                           'tau_ship',...
                          [OPT.refdatenum 1],...
                             T.datenum(it),...
                           WAQ.tau)
        
      else
        StructOut = delwaq('write',...
                           STRUCT,...
                           T.datenum(it),...
                           WAQ.tau);
      
      end

   end % OPT.FLOW2WAQ

   if OPT.pause
      disp('Press key to continue...')
      pause
   end
end % time
   
%% EOF   