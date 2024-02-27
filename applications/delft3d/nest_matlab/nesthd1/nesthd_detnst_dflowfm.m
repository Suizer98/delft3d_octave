      function [names,weight,x_nes,y_nes] = nesthd_detnst  (x,y,name_coarse,xbnd,ybnd,sphere,i_type)

      % detnst_dflowfm determines coordinates nest stations and belonging weight factors
      %

      %% initialise
      no_pnt                = size(xbnd,2);
      x_nes (1:no_pnt,4  ) = 0 ;
      y_nes (1:no_pnt,4  ) = 0 ;
      weight(1:no_pnt,4  ) = 0.0;
      for i_pnt = 1: no_pnt
          for i_nes = 1:4
              names {i_pnt,i_nes} = '';
          end
      end

      %% Create triangulation netwerk through flow nodes (cell centres)
      tri = delaunay(x,y);

      %% For all of the boundary support points
      for i_pnt = 1: no_pnt

          waitbar(((i_type-1)*no_pnt + i_pnt)/(3*no_pnt));
          xbsp = xbnd  (i_pnt);
          ybsp = ybnd  (i_pnt);

          %% find surrounding flow nodes
          if ~isnan(xbsp)

              inside = false;
              if i_pnt > 1
                  %% First search neighbouring points
                  % create selection of neighbouring nodes
                  neighbours = [];
                  points    = idualface;
                  for i_depth = 1: 3
                      for i_corner_1 =  1: 3
                          for i_corner_2 = 1: 3
                              for ii_pnt = 1: length(points)
                                  [tmp]      = find(tri(:,i_corner_2) == tri(points(ii_pnt),i_corner_1));
                                  neighbours = [neighbours; tmp];
                              end
                          end
                      end
                      neighbours  = unique(neighbours);
                      points      = neighbours;
                  end
                  % see if point can be found within neighbouring point
                  for i_neighbour = 1: length(neighbours)
                      inside = insidepoly(xbsp, ybsp, x(tri(neighbours(i_neighbour),1:3)), y(tri(neighbours(i_neighbour),1:3)));
                      if inside
                          idualface = neighbours(i_neighbour);
                          break;
                      end
                  end
              end

              %% not found within neigbouring points
              if inside ~= 1
                  idualface=0;
                  while idualface < size(tri,1) && inside~=1,
                      idualface=idualface+1;
                      inside = insidepoly(xbsp, ybsp, x(tri(idualface,1:3)), y(tri(idualface,1:3)));
                  end
              end

              %% found !!!
              if inside

                  %% Set coordinates of nesting stations,names of nesting stations and determine weights
                  for i_nes = 1: 3
                      x_nes(i_pnt,i_nes) = x(tri(idualface,i_nes));
                      y_nes(i_pnt,i_nes) = y(tri(idualface,i_nes));
                      names{i_pnt,i_nes} = name_coarse{tri(idualface,i_nes)};
                  end

                  weight(i_pnt,1:3) = nesthd_triweights(x_nes(i_pnt,1:3),y_nes(i_pnt,1:3),xbsp,ybsp);

              else

                  %% Not found, find nearest stations
                  dist      = nesthd_detlength(x,y,xbsp,ybsp,'Spherical',sphere);
                  [~,index] = min(dist);
                  x_nes(i_pnt,1) = x(index);
                  y_nes(i_pnt,1) = y(index);
                  names{i_pnt,i_nes} = name_coarse{index};
              end
          end
      end
