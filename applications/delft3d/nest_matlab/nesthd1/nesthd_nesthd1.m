      function nesthd1 (varargin)

      % nesthd1 nesting for delft3d and simona (first stage)

      % Matlab version of Nesthd1 (based on the original fortran code) beta
      % release
      %

      %% Initialisation
      types      = {'WL ','UVp','UVt'};
      types_conv = {'z',  'p',  'p'};   % for FM
      files  = varargin{1};
      x_nest = [];
      y_nest = [];
      h      = waitbar(0,'Generate the nest administration','Color',[0.831 0.816 0.784]);

      %% determine type of nesting
      type_coarse   = EHY_getModelType(files{1});
      type_nest     = EHY_getModelType(files{2});
      type_bnd      = EHY_getModelType(files{3});
      type_obs      = EHY_getModelType(files{4});

      %% Open files
      fid_obs       = fopen(files{4},'w+');
      fid_adm       = fopen(files{5},'w+');
      sphere        = false;

      %% Read overall grid; Make the icom matrix (active, inactive)
      switch type_coarse
          case {'d3d' 'simona'}
              grid_coarse = wlgrid  ('read',files{1});
              icom_coarse = nesthd_det_icom(grid_coarse.X,grid_coarse.MissingValue);
              [grid_coarse.Xcen,grid_coarse.Ycen] = nesthd_det_cen(grid_coarse.X,grid_coarse.Y,icom_coarse);
              if strcmpi(grid_coarse.CoordinateSystem,'Spherical');sphere = true;end
          case 'dfm'
              try
                  %% old map file
                  G = dflowfm.readNetOld(files{1});
                  grid_coarse.Xcen = G.face.FlowElem_x;
                  grid_coarse.Ycen = G.face.FlowElem_y;
                  name_coarse{length(G.face.FlowElem_x)} = [];
                  for i_node = 1: length(G.face.FlowElem_x)
                      name_coarse{i_node} = ['FlowNode_' num2str(i_node,'%8.8i')];
                  end
                  if strncmpi(ncreadatt(files{1},'projected_coordinate_system','grid_mapping_name'),'latitu',6) sphere = true; end;
              catch
                  %% new map file
                  G = dflowfm.readNet   (files{1});
                  grid_coarse.Xcen = G.face.FlowElem_x;
                  grid_coarse.Ycen = G.face.FlowElem_y;
                  name_coarse{length(G.face.FlowElem_x)} = [];
                  for i_node = 1: length(G.face.FlowElem_x)
                      name_coarse{i_node} = ['FlowNode_' num2str(i_node,'%8.8i')];
                  end
                  try     % wgs84 not guaranteed to exist
                      if strncmpi(ncreadatt(files{1},'wgs84','grid_mapping_name'),'latitu',6)
                          sphere = true;
                      end
                  catch
                      sphere = false;  % for completeness, not necessary
                  end
                  
              end
      end

      %% Read detailled grid; Make the icom matrix (active, inactive), not needed for DFLOWFM because all information is in the pli's
      switch type_nest
          case {'d3d' 'simona'}
              grid_fine = wlgrid   ('read',files{2});
              icom_fine = nesthd_det_icom (grid_fine.X,grid_fine.MissingValue,files{6});
      end

      %% Read the boundary data
      switch type_bnd
          case {'d3d' 'simona'}
              bnd = nesthd_get_bnd_data (files{3});
          case 'dfm'
              bnd = dflowfm_io_bnd      ('read',files{3});
      end

      %% For the various types of boundary conditions
      for i_type = 1: length(types)

          %% Determine world coordinates of boundary support points for type{i_type}
          switch type_bnd
              case {'d3d'  'simona'}
                  [X_bnd,Y_bnd,positi]  = nesthd_detxy (grid_fine.X,grid_fine.Y,bnd,icom_fine,types{i_type});
                  % Convert to point structure
                  X_bnd        = reshape(X_bnd'    ,size(X_bnd    ,1)*2,1);
                  Y_bnd        = reshape(Y_bnd'    ,size(Y_bnd    ,1)*2,1);
                  string_mnbsp = reshape(bnd.Name' ,size(bnd.Name ,1)*2,1);
                  positi       = reshape([positi;positi],size(bnd.Name ,1)*2,1);
              case 'dfm'
                  X_bnd  = cell2mat({bnd.DATA.X})';
                  Y_bnd  = cell2mat({bnd.DATA.Y})';
                  string_mnbsp = (bnd.Name);
                  for i_bnd = 1: length(X_bnd) positi{i_bnd} = 'in';end
          end

          %% Determine coordinates and relative weights of the required nesting stations
          switch type_coarse
              case {'d3d' 'simona'}
                  [string_mnnes,weight,x_nest,y_nest] = nesthd_detnst        (grid_coarse.X   ,grid_coarse.Y   ,icom_coarse,X_bnd',Y_bnd',sphere,i_type);
              case 'dfm'
                  [string_mnnes,weight,x_nest,y_nest] = nesthd_detnst_dflowfm(grid_coarse.Xcen,grid_coarse.Ycen,name_coarse,X_bnd',Y_bnd',sphere,i_type);
          end

          %% Determine the orientation of the boundary (not needed for water level boundaries)
          angles (1:length(X_bnd)) = NaN;
          if ~strcmp (types{i_type},'WL ')
              switch type_bnd
                  case {'d3d' 'simona'}
                      [help_X,help_Y,~]      = nesthd_detxy (grid_fine.X,grid_fine.Y,bnd,icom_fine,'UVp');
                      angles                 = nesthd_detang (help_X,help_Y,icom_fine,bnd,sphere);
                      angles                 = reshape([angles;angles],size(bnd.Name,1)*2,1);
                  case 'dfm'
                      % todo, detrmine orientation of the boundary such
                      % that inflow is positive
                      angles(1:length(X_bnd)) = 90.;

              end
          end

          %% Write to station and administration file
          nesthd_wrista_2 (fid_obs,type_obs,string_mnnes,x_nest,y_nest);
          nesthd_wrinst_2 (fid_adm,string_mnbsp,string_mnnes,weight,types{i_type},angles,positi,x_nest,y_nest);

          clear X_bnd Y_bnd positi string_mnbsp string_mnnes weight angles positi x_nest y_nest

      end

      close  (h);
      fclose (fid_adm);
      fclose (fid_obs);

      %% Rewrite the file with stations with only unique station positions
      nesthd_uniqfil(files{4});

