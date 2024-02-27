      function [names,weight,varargout] = nesthd_detnst  (x,y,icom,xbnd,ybnd,sphere,itime)

      %detnst  determines coordinates nest stations and belonging weight factors
      %
      %See also: inpolygon, nesthd1, poly_fun

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % delft hydraulics                         marine and coastal management
      %
      % subroutine         : detnst
      % version            : v1.0
      % date               : June 1997
      % programmer         : Theo van der kaaij
      %
      % function           : determines coordinates nest stations and
      %                      belonging weight factors
      % error messages     :
      %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      no_pnt = size(xbnd,2);

      mcnes (1:no_pnt,4) = 0 ;
      ncnes (1:no_pnt,4) = 0 ;
      weight(1:no_pnt,4) = 0.0;
      x_nest(1:no_pnt,4) = 0. ;
      y_nest(1:no_pnt,4) = 0. ;

      mold                = [];
      nold                = [];

      mmax                = size(x,1);
      nmax                = size(x,2);

      for i_pnt = 1: no_pnt

          waitbar(((itime-1)*no_pnt + i_pnt)/(no_pnt*3));

          xbsp = xbnd  (i_pnt);
          ybsp = ybnd  (i_pnt);
          %
          %-----------find surrounding depth points overall model
          %
          if ~isnan(xbsp)

              inside = false;

              %
              %% First check vicinity previous found point to speed up the proces
              if ~isempty (mold)
                  for m = max(mnst - 2,1): min(mnst + 2,mmax - 1)
                      for n = max(nnst - 2,1): min(nnst + 2,nmax - 1)
                          if icom(m+1,n+1) == 1
                              xx(1) = x(m  ,n  );yy(1) = y(m  ,n  );
                              xx(2) = x(m+1,n  );yy(2) = y(m+1,n  );
                              xx(3) = x(m+1,n+1);yy(3) = y(m+1,n+1);
                              xx(4) = x(m  ,n+1);yy(4) = y(m  ,n+1);
                              in = inpolygon(xbsp,ybsp,xx,yy);
                              if in
                                  inside = in;
                                  mnst   = m;
                                  nnst   = n;
                                  mold   = mnst;
                                  nold   = nnst;
                                  %
                                  % Determine relative distances (within a
                                  % computational cell)
                                  %
                                  [rmnst,rnnst] = nesthd_reldif(xbsp,ybsp,xx,yy,sphere);
                                  break;
                              end
                          end
                      end
                  end
              end

              %
              %% Not found ==> cycle over all points
              if ~inside
                  for m = 1: mmax - 1
                      for n = 1: nmax - 1
                          if icom(m+1,n+1) == 1
                              xx(1) = x(m  ,n  );yy(1) = y(m  ,n  );
                              xx(2) = x(m+1,n  );yy(2) = y(m+1,n  );
                              xx(3) = x(m+1,n+1);yy(3) = y(m+1,n+1);
                              xx(4) = x(m  ,n+1);yy(4) = y(m  ,n+1);
                              in = inpolygon(xbsp,ybsp,xx,yy);
                              if in
                                  inside = in;
                                  mnst   = m;
                                  nnst   = n;
                                  mold   = mnst;
                                  nold   = nnst;
                                  %
                                  % Determine relative distances (within a
                                  % computational cell)
                                  %
                                  [rmnst,rnnst] = nesthd_reldif(xbsp,ybsp,xx,yy,sphere);
                                  break;
                              end
                          end
                      end
                  end
              end

              if inside

                  %
                  %--------------from depth points to zeta points
                  %
                  rmnst = rmnst + 0.5;
                  rnnst = rnnst + 0.5;

                  if rmnst > 1.
                      mnst  = mnst  + 1  ;
                      rmnst = rmnst - 1.0;
                  end

                  if rnnst > 1.
                      nnst  = nnst  + 1  ;
                      rnnst = rnnst - 1.0;
                  end

                  %
                  %------------------fill mcnes and ncnes and compute weights
                  %
                  mcnes (i_pnt,1) = mnst;
                  ncnes (i_pnt,1) = nnst;
                  weight(i_pnt,1) = (1.- rmnst)*(1. - rnnst);

                  mcnes (i_pnt,2) = mcnes (i_pnt,1) + 1;
                  ncnes (i_pnt,2) = ncnes (i_pnt,1);
                  weight(i_pnt,2) = rmnst*(1. - rnnst);

                  mcnes (i_pnt,3) = mcnes (i_pnt,1);
                  ncnes (i_pnt,3) = ncnes (i_pnt,1) + 1;
                  weight(i_pnt,3) = (1.- rmnst)*rnnst;

                  mcnes (i_pnt,4) = mcnes (i_pnt,1) + 1;
                  ncnes (i_pnt,4) = ncnes (i_pnt,1) + 1;
                  weight(i_pnt,4) = rmnst*rnnst;
              end
          end
      end
      %
      %-----delete inactive points from mcnes and ncnes arrays
      %
      for i_pnt = 1: no_pnt
          noin = 0;
          for inst = 1: 4

              mnst = mcnes(i_pnt,inst);
              nnst = ncnes(i_pnt,inst);

              if mnst ~= 0
                  if icom(mnst,nnst) ~= 1
                      noin = noin + 1;
                      mcnes (i_pnt,inst) = 0 ;
                      ncnes (i_pnt,inst) = 0 ;
                      weight(i_pnt,inst) = 0.;
                  end
              else
                  noin = noin + 1;
              end
          end
          if noin == 4
              %
              %--------------no active surrounding overall model points found
              %              search nearest active point (not for diagonal vel bnd.)
              %

              if ~isnan(xbnd(i_pnt))
                  [mcnes(i_pnt,1),ncnes(i_pnt,1)] = nesthd_nearmn (xbnd(i_pnt),ybnd(i_pnt),x,y,icom,'spherical',sphere);
                  weight(i_pnt,1) = 1.0;
              end
          end
      end
      %
      %-----finally normalize weights
      %
      for i_pnt = 1: no_pnt
          wtot = 0.;
          for inst = 1: 4
              if weight(i_pnt,inst) <= 0.
                  weight (i_pnt,inst) = 1.0e-6;
              end
              wtot = wtot + weight(i_pnt,inst);
          end

          for inst = 1: 4
              weight (i_pnt,inst) = weight (i_pnt,inst)/wtot;
          end
      end

      %
      % Convert mnes and nnes into a string
      %

      for i_pnt = 1: no_pnt
          for i_nes = 1: 4
              names{i_pnt,i_nes} = nesthd_convertmn2string(mcnes(i_pnt,i_nes),ncnes(i_pnt,i_nes));
          end
      end

      %
      % Determine world coordinates of the nesting station
      %

      for i_pnt = 1: no_pnt
          for i_nes = 1: 4
              if mcnes(i_pnt,i_nes) ~= 0
                  x_nest(i_pnt,i_nes) =  0.25*(x(mcnes(i_pnt,i_nes)    ,ncnes(i_pnt,i_nes)    ) + ...
                                               x(mcnes(i_pnt,i_nes) - 1,ncnes(i_pnt,i_nes)    ) + ...
                                               x(mcnes(i_pnt,i_nes)    ,ncnes(i_pnt,i_nes) - 1) + ...
                                               x(mcnes(i_pnt,i_nes) - 1,ncnes(i_pnt,i_nes) - 1) );
                  y_nest(i_pnt,i_nes) =  0.25*(y(mcnes(i_pnt,i_nes)    ,ncnes(i_pnt,i_nes)    ) + ...
                                               y(mcnes(i_pnt,i_nes) - 1,ncnes(i_pnt,i_nes)    ) + ...
                                               y(mcnes(i_pnt,i_nes)    ,ncnes(i_pnt,i_nes) - 1) + ...
                                               y(mcnes(i_pnt,i_nes) - 1,ncnes(i_pnt,i_nes) - 1) );
              end
          end
      end

      varargout{1} = x_nest;
      varargout{2} = y_nest;

