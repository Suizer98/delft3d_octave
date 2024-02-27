%DELFT3D_WAQ_GRIDDATA2MAP_EXAMPLE1  Example to grid/write spatio-temporal data to WAQ *.map file 
%
% (c) WL | Delft Hydraulics, Z3451, G.J. de Boer, 2007 Jul 01st
% Script to bin atmospheric deposition NC files to WAQ map files.
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
% Any missing m=files are in:
% * wl_settings
% * p:/McTools/
% * bulletin/boer_g
% * absent, because they were project speficic, this file is just an example
% ---------------------------------------------------
%
%See also: DELWAQ, FLOW2WAQ3D, ADDROWCOL, CORNER2CENTER

% $Id: delft3d_waq_griddata2map_example1.m 11709 2015-02-16 09:58:50Z gerben.deboer.x $
% $Date: 2015-02-16 17:58:50 +0800 (Mon, 16 Feb 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11709 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_griddata2map_example1.m $

%% G.J. de Boer <gerben.deboer@deltares.nl>, <g.j.deboer@tudelft.nl>

%% Input

   OPT.directory.emep  = 'D:\HOME\WL\z4351-ospar07\Data\From_IfM\AtmDeposition';
   OPT.year            = 2002;
   OPT.ncVar           = 'DDEP_OXN';
   OPT.ncUnits         = 'mg(N)m-2';
   OPT.files.nc        = ['monthly',num2str(OPT.year),'_for_sea.nc'];
   
   OPT.directory.waq   = 'D:\HOME\WL\z4351-ospar07\GEMmodelling\hydro\grid\';
   OPT.files.waqgrid   = 'com-008.cco';
   OPT.backgroundvalue = 0;
   OPT.refdatenum      = datenum(OPT.year,1,1);% reference date in WAQ simulation
   OPT.datenum_start   = datenum(OPT.year,1:12,1); % start of EMEP time intervals, nc file only contains middle of time intervals.
                         %123456789_123456789_123456789_123456789_
   OPT.header          = {['z4351,G.J.deBoer,2007jun28,var:',OPT.ncVar],...
                          ['from:',OPT.files.nc,'in [',OPT.ncUnits,']'],...
                          ['onto>ZUNOg 10layer,times=start intervals']}; % size 3 x 40 char, 4th line will contains time info
   OPT.k               = 1; % WAQ layer in which the 2D data field is written, rest is background
   
   OPT.plot.Segments   = 0;
   OPT.plot.EMEP       = 1;
   OPT.plot.EMEP2FLOW  = 1;
   OPT.export          = 1;
   OPT.clim            = [5 40]; % for color plot ncVar
   
   OPT.griddatamethod  = 'linear';

%% Load FLOW/WAQ grid

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
  [FLOW.cor.lon,...
   FLOW.cor.lat] = ctransdv     (FLOW.cor.x,FLOW.cor.y,'PARIJS','LONLAT');
  [FLOW.cen.lon,...
   FLOW.cen.lat] = ctransdv     (FLOW.cen.x,FLOW.cen.y,'PARIJS','LONLAT');

   FLOW.cen.Index                   = FLOW.Index(2:end-1,2:end-1,:);
   FLOW.cen.Index(FLOW.cen.Index==0)= NaN; % We do not remove FLOW field 'Index' as we require it with all dummy rows for aggregation.
   FLOW.flow2waqcoupling2D          = flow2waq3d_coupling(FLOW.Index(:,:,1),FLOW.NoSegPerLayer,'i'); % new flow2waq3d_coupling !! per 2008 May 13
   FLOW.flow2waqcoupling3D          = flow2waq3d_coupling(FLOW.Index       ,FLOW.NoSeg        ,'i'); % new flow2waq3d_coupling !! per 2008 May 13
   
   %% Plot FLOW/WAQ grid (debug)

   if OPT.plot.Segments
   figure('name','plotSegments')
   for k=1:size(FLOW.cen.Index,3)
      cla
      pcolorcorcen(FLOW.cor.lon,FLOW.cor.lat,FLOW.cen.Index(:,:,k),[.5 .5 .5])
      axis([-3 9 49.5 57.5])
      axislat(52);
      title(['Layer: '       ,num2str(k),...
             ' Seg # range: ',num2str(nanmin(make1d(FLOW.cen.Index(:,:,k)))),...
             '  ',            num2str(nanmax(make1d(FLOW.cen.Index(:,:,k))))])
      colorbarwithtitle('Seg #')
      
      if OPT.export
         print2screensize(['Segment_nr_layer_',num2str(k,'%0.3d')]);
      end
   end
   end

%% Load landboundary

   L = sdload_char('promise-utm.hdf');
   
   [L.lon,L.lat] = ctransdv(L.x,L.y,'UTM','LONLAT',1,31);

%% Load EMEP data

   [EMEP.(OPT.ncVar),OK] = nc_varget([OPT.directory.emep,filesep,OPT.files.nc],OPT.ncVar);
   [EMEP.lon        ,OK] = nc_varget([OPT.directory.emep,filesep,OPT.files.nc],'lon');
   [EMEP.lat        ,OK] = nc_varget([OPT.directory.emep,filesep,OPT.files.nc],'lat');
   
   [EMEP.time       ,OK] = nc_varget([OPT.directory.emep,filesep,OPT.files.nc],'time');
    EMEP.datenum = datenum(1970,1,1,0,0,EMEP.time);
    
    EMEP.nt = length(EMEP.datenum);

   %% Plot EMEP data (debug)

   if OPT.plot.EMEP
   figure('name','plotEMEP')
   for it = 1:size(EMEP.(OPT.ncVar),1)
      pcolorcorcen(EMEP.lon,EMEP.lat,EMEP.(OPT.ncVar)(it,:,:),[.5 .5 .5])
      hold on
      plot(L.lon,L.lat,'k')
      axis([-3 9 49.5 57.5])
      axislat(52);
      caxis(OPT.clim)
      colorbarwithtitle({[OPT.ncVar,' [',OPT.ncUnits,']']})
      
      title(['time: ',datestr(EMEP.datenum(it),0)])

      if OPT.export
         print2screensize([filename(OPT.files.nc),'_EMEP_',OPT.ncVar,'_time_',num2str(it,'%0.3d')]);
      end

   end
   end %for it = 1%:size(EMEP.(OPT.ncVar),1)

%% Grid EMEP data to FLOW grid

   FLOW.cen.(OPT.ncVar) = NaN.*zeros([EMEP.nt size(FLOW.cen.lon)]);
   
   % make subselection of to large set of data coordinates for speed up
   % and allow only data within dlat or dlong Manhattan distance
   % from the grid to be used.
   
   dlat  = 0.5;
   dlong = 0.5.*cosd(52); %'real' flat distance longitude degree depends on latitude
   
   EMEP.mask = (EMEP.lon(:) >  min(FLOW.cor.lon(:) - dlong) & ...%min(FLOW.cor.lon(:)) & ...%-10 & ...
                EMEP.lon(:)  < max(FLOW.cor.lon(:) + dlong) & ...%max(FLOW.cor.lon(:)) & ...% 15 & ...
                EMEP.lat(:) >  min(FLOW.cor.lat(:) - dlat ) & ...%min(FLOW.cor.lat(:)) & ...% 45 & ...
                EMEP.lat(:)  < max(FLOW.cor.lat(:) + dlat ));    %max(FLOW.cor.lat(:)));    % 60);    
   
   for it = 1:size(EMEP.(OPT.ncVar),1)
   
      Zin  = permute(EMEP.(OPT.ncVar)(it,:,:),[2 3 1]);% make sure  1st and 2nd dim agree with vertices
      
      FLOW.cen.(OPT.ncVar)(it,:,:) = griddata(EMEP.lon(EMEP.mask),...
                                              EMEP.lat(EMEP.mask),...
                                                   Zin(EMEP.mask),... 
                                              FLOW.cen.lon,...
                                              FLOW.cen.lat,OPT.griddatamethod);
                      
   end %for it = 1%:size(EMEP.(OPT.ncVar),1)

   % Plot EMEP data to FLOW grid (debug)

   if OPT.plot.EMEP2FLOW
   figure('name','plotEMEP2FLOW')
   for it = 1:size(EMEP.(OPT.ncVar),1)
      pcolorcorcen(FLOW.cor.lon,FLOW.cor.lat,FLOW.cen.(OPT.ncVar)(it,:,:),[.5 .5 .5])
      hold on
      plot(L.lon,L.lat,'k')
      axis([-3 9 49.5 57.5])
      axislat(52);
      caxis(OPT.clim)
      colorbarwithtitle({[OPT.ncVar,' [',OPT.ncUnits,']']})
      title(['time: ',datestr(EMEP.datenum(it),0)])
      
      if OPT.export
         print2screensize([filename(OPT.files.nc),'_EMEP2FLOW_',OPT.ncVar,'_time_',num2str(it,'%0.3d')]);
      end

   end
   end

% Aggregate FLOW data to WAQ grid
% and write to WAQ file

   for it = 1:size(EMEP.(OPT.ncVar),1)

      % add dummy rows and columsn to corect aggregation indexing
      
      fullmatrix = FLOW.cen.(OPT.ncVar)(it,:,:);
      
      %% make sure 1st dimension is n
      
      fullmatrix = permute(fullmatrix,[2 3 1]);

      fullmatrix = addrowcol(fullmatrix,[-1 1],[-1 1],NaN);
      
      fullmatrix(isnan(fullmatrix)) = OPT.backgroundvalue;
      
      %% Duplicate value for all KMAX layers, 
      % as WAQ needs all data 3D in 3D computation, 
      % even 2D data as bed shear stresses.
      % All other dummy elements are set to zero.
      %
      % The 2D > 3D below method works only if all layers in all columns are active
      
      WAQ2D.(OPT.ncVar) = flow2waq3D(fullmatrix,FLOW.flow2waqcoupling2D);

      kmax   = FLOW.MNK(3);
      nWAQ2D = length(WAQ2D.(OPT.ncVar));
      
      %% make 'empty' 3D matrix
      WAQ.(OPT.ncVar) = repmat(OPT.backgroundvalue,[1 nWAQ2D*kmax]);
      
      %% fill only one layer with 2D data 
      WAQ.(OPT.ncVar)(1,(1:nWAQ2D) + nWAQ2D.*(OPT.k-1)) = WAQ2D.(OPT.ncVar);
      
      %% Write to waq map file

      if (it==1)
        STRUCT    = delwaq('write',[filename(OPT.files.nc),'.map'],...
                           char(OPT.header),...
                           OPT.ncVar,...
                          [OPT.refdatenum 1],...
                           OPT.datenum_start(it),...
                           WAQ.(OPT.ncVar))
        
      else
        StructOut = delwaq('write',...
                           STRUCT,...
                           OPT.datenum_start(it),...
                           WAQ.(OPT.ncVar));
      
      end
   end