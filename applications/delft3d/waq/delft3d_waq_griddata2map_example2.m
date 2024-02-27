%DELFT3D_WAQ_GRIDDATA2MAP_EXAMPLE2  Example to grid/write spatio-temporal data to WAQ *.map file 
%
% (c) WL | Delft Hydraulics, Z3451, G.J. de Boer, 2007 Jul 01st
% Script to bin IVM bi-monhtly SeaWiFS TSM data to WAQ map files.
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

% $Id: delft3d_waq_griddata2map_example2.m 2391 2010-03-30 16:52:40Z boer_g $
% $Date: 2010-03-31 00:52:40 +0800 (Wed, 31 Mar 2010) $
% $Author: boer_g $
% $Revision: 2391 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_griddata2map_example2.m $

%% G.J. de Boer <gerben.deboer@deltares.nl>, <g.j.deboer@tudelft.nl>

%% Input
%% ---------------------------------------------------

   OPT.directory.silt  = 'P:\z4351-ospar07\Data\From_IfM\Silt\eleveld\';
   OPT.year            = 2001;
   OPT.var             = 'TSM';
   OPT.units           = 'mg/l';
   OPT.nodatavalue     = 0;
   OPT.files.mat       = {'janfeb',...
                          'marapr',...
                          'mayjun',...
                          'julaug',...
                          'sepoct',...
                          'novdec'};
   OPT.refdatenum      = datenum(OPT.year,1,1);% reference date in WAQ simulation
   OPT.datenum_start   = datenum(OPT.year,1:2:11,1);              % start  of bi-monthyl time intervals
   OPT.datenum_end     = datenum(OPT.year,3:2:13,1);              % end    of bi-monthyl time intervals
   OPT.datenum         = (OPT.datenum_start + OPT.datenum_end)./2;% middle of bi-monthyl time intervals
   
%% Script options
%% ---------------------------------------------------

   OPT.plot.Segments   = 0;
   OPT.plot.silt       = 0;
   OPT.plot.silt2FLOW  = 1;
   OPT.export          = 1;
   OPT.FLOW2WAQ        = 1;
   OPT.clim            = [0 60]; % for color plot var
   
   
   OPT.binmethod       = 'bin2';     % FAST: 'interp2', SLOW: 'bin2' but bin2 most appropriate (fine to coarse) [VERY SLOW: 'griddata']
   OPT.interp2method   = 'linear';   % 'nearest' - nearest neighbor interpolation
                                     % 'linear'  - bilinear interpolation
                                     % 'spline'  - spline interpolation
                                     % 'cubic'   - bicubic interpolation as long as the data is
                                     %             uniformly spaced, otherwise the same as 'spline'

%% WAQ input/output
%% ---------------------------------------------------

   OPT.directory.waq   = 'P:\z4351-ospar07\GEMmodelling\grid\';
   OPT.files.waqgrid   = 'com-008.cco';
   OPT.backgroundvalue = 0;
                         %123456789_123456789_123456789_123456789_
   OPT.header          = {['z4351,G.J.deBoer,2007jul02,var:',OPT.var,' from '],...
                          ['IVM,SeaWiFS in [',OPT.units,'] onto ZUNOg 10layer'],...
                          ['with ',OPT.binmethod,', times=start intervals']}; % size 3 x 40 char, 4th line will contains time info
   OPT.k               = 1; % WAQ layer in which the 2D data field is written, rest is background
   

%% Load FLOW/WAQ grid
%% ---------------------------------------------------

   FLOW = delwaq('open',[OPT.directory.waq,filesep,OPT.files.waqgrid]);
   
   %% Remove moronic fields of which the meaning is unclear.
   %% due to moronic dummy rows and columns.
   %% Only add all dummy rows and columsn when aggregatting to WAQ grid.
   
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
   %% ----------------------------------

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
%% ----------------------------------

   L = sdload_char('promise-utm.hdf');
   
   [L.lon,L.lat] = ctransdv(L.x,L.y,'UTM','LONLAT',1,31);

%% Load silt data
%% ----------------------------------

   silt.datenum       = OPT.datenum;
   silt.datenum_start = OPT.datenum_start;
   silt.datenum_end   = OPT.datenum_end;
   silt.nt            = length(silt.datenum);

   for it=1:silt(1).nt
   if it==1
   tmp      = load([OPT.directory.silt,filesep,OPT.files.mat{it},num2str(OPT.year),'.mat'],'X');
   silt.lon = tmp.X;
   tmp      = load([OPT.directory.silt,filesep,OPT.files.mat{it},num2str(OPT.year),'.mat'],'Y');
   silt.lat = tmp.Y;
   end
   tmp      = load([OPT.directory.silt,filesep,OPT.files.mat{it},num2str(OPT.year),'.mat'],'Z');
   tmp.Z(tmp.Z==OPT.nodatavalue) = NaN;
   silt(it).(OPT.var)  = tmp.Z;
   end

   %% Plot silt data (debug)
   %% ----------------------------------

   if OPT.plot.silt
   figure('name','plotsilt')
   for it=1:silt(1).nt
      pcolorcorcen(silt(1).lon,silt(1).lat,silt(it).(OPT.var))
      hold on
      plot(L.lon,L.lat,'k')
      plot(FLOW.cor.lon ,FLOW.cor.lat ,'-','color',[.5 .5 .5]) % plot FLOW grid 'columns'
      plot(FLOW.cor.lon',FLOW.cor.lat','-','color',[.5 .5 .5]) % plot FLOW grid 'rows'
      axis([-3 9 49.5 57.5])
      axislat(52);
      caxis(OPT.clim)
      colorbarwithtitle({[OPT.var,' [',OPT.units,']']})
      
      title(['time: ',datestr(silt(1).datenum_start(it),0),...
             ' -    ',datestr(silt(1).datenum_end  (it),0)]);

      if OPT.export
         print2screensize(['silt_',OPT.var,'_time_',num2str(it,'%0.3d'),'_',filename(OPT.files.mat{it})]);
      end

   end
   end %for it = 1%:size(silt.(OPT.var),1)

%% Grid silt data to FLOW grid
%% ----------------------------------

   FLOW.cen.(OPT.var) = NaN.*zeros([silt.nt size(FLOW.cen.lon)]);
   
   %% interpolate from orthogonal data set
   %% goal vertices may not contain NaN
   %% so we pass a 1D of only real coordinates
   
   mask      = (~isnan(FLOW.cen.lon)) & ...
               (~isnan(FLOW.cen.lat));
   Z = nan.*ones(size(FLOW.cen.lon));
   
   for it = 1:silt(1).nt
   
      disp([num2str(it),'/',num2str(silt(1).nt)])
   
     %[lon,lat] = meshgrid(silt( 1).lon,...
     %                     silt( 1).lat);
     
      if strcmp(OPT.binmethod,'griddata')
        [lon,lat] = meshgrid(silt( 1).lon,...
                             silt( 1).lat);
         FLOW.cen.(OPT.var)(it,:,:) = griddata(lon,... % full matrix
                                               lat,... % full matrix
                                               silt(it).(OPT.var),... 
                                               FLOW.cen.lon,...
                                               FLOW.cen.lat,OPT.interp2method)
      elseif strcmp(OPT.binmethod,'bin2')
        [lon,lat] = meshgrid(silt( 1).lon,...
                             silt( 1).lat);
         Z = bin2(lon,... % full matrix
                  lat,... % full matrix
                  silt(it).(OPT.var),... 
                  FLOW.cor.lon,...
                  FLOW.cor.lat);
                            
         FLOW.cen.(OPT.var)(it,:,:) = Z.avg;    
      elseif strcmp(OPT.binmethod,'interp2')
         Z(~mask) = NaN;
         Z( mask) = interp2(silt( 1).lon,... % 1D vector
                            silt( 1).lat,... % 1D vector
                            silt(it).(OPT.var),... 
                            FLOW.cen.lon(mask),...
                            FLOW.cen.lat(mask),OPT.interp2method);
                            
         FLOW.cen.(OPT.var)(it,:,:) = Z;
      end
                                            
   end %for it = 1%:size(silt.(OPT.var),1)

   %% Plot silt data to FLOW grid (debug)
   %% ----------------------------------

   if OPT.plot.silt2FLOW
   figure('name','plotsilt2FLOW')
   for it = 1:silt(1).nt
      pcolorcorcen(FLOW.cor.lon,FLOW.cor.lat,FLOW.cen.(OPT.var)(it,:,:),[.5 .5 .5])
      hold on
      plot(L.lon,L.lat,'k')
      axis([-3 9 49.5 57.5])
      axislat(52);
      caxis(OPT.clim)
      colorbarwithtitle({[OPT.var,' [',OPT.units,']']})
      title({['time: ',datestr(silt(1).datenum_start(it),0),...
             ' -    ',datestr(silt(1).datenum_end  (it),0)],...
             ['Binning method: ',OPT.binmethod]})
      
      if OPT.export
         print2screensize(['silt2FLOW_',OPT.var,'_time_',num2str(it,'%0.3d'),'_',filename(OPT.files.mat{it}),'_',OPT.binmethod]);
      end

   end
   end

%% Aggregate FLOW data to WAQ grid
%% and write to WAQ file
%% ----------------------------------

   if OPT.FLOW2WAQ

   for it = 1:silt(1).nt

      %% add dummy rows and columsn to corect aggregation indexing
      %% ----------------------------------
      
      fullmatrix = FLOW.cen.(OPT.var)(it,:,:);
      
      %% make sure 1st dimension is n
      
      fullmatrix = permute(fullmatrix,[2 3 1]);

      fullmatrix = addrowcol(fullmatrix,[-1 1],[-1 1],NaN);
      
      fullmatrix(isnan(fullmatrix)) = OPT.backgroundvalue;
      
      %% Duplicate value for all KMAX layers, 
      %% as WAQ needs all data 3D in 3D computation, 
      %% even 2D data as bed shear stresses.
      %% All other dummy elements are set to zero.
      %%
      %% The 2D > 3D below method works only if all layers in all columns are active
      %% ----------------------
      
      WAQ2D.(OPT.var) = flow2waq3D(fullmatrix,FLOW.flow2waqcoupling2D);

      kmax   = FLOW.MNK(3);
      nWAQ2D = length(WAQ2D.(OPT.var));
      
      %% make 'emmty' 3D matrix
      WAQ.(OPT.var) = repmat(OPT.backgroundvalue,[1 nWAQ2D*kmax]);
      
      %% fill only one layer with 2D data 
      WAQ.(OPT.var)(1,(1:nWAQ2D) + nWAQ2D.*(OPT.k-1)) = WAQ2D.(OPT.var);
      
      %% Write to waq map file
      %% ----------------------------------

      if (it==1)
        STRUCT    = delwaq('write',['silt_',num2str(OPT.year),'_',OPT.binmethod,'.map'],...
                           char(OPT.header),...
                           OPT.var,...
                          [OPT.refdatenum 1],...
                           OPT.datenum_start(it),...
                           WAQ.(OPT.var))
        
      else
        StructOut = delwaq('write',...
                           STRUCT,...
                           OPT.datenum_start(it),...
                           WAQ.(OPT.var));
      
      end
   end
   end
   
%% EOF   