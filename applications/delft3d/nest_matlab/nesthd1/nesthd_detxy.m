      function [Xbnd, Ybnd,positi] = detxy (X,Y,bnd,icom,type)

      % detxy: Determine the world coordinates of the boundary support points for both water level and velocity boundaries

      %
      % Determine the world coordinates of the boundary support points for both water level and velocity boundaries
      %

%-----------------------------------------------------------------------
%---- 1. determine X,Y co-ordinates of boundary support points
%        in WL and UV points
%-----------------------------------------------------------------------

       mmax                  = size(icom,1);
       nmax                  = size(icom,2);

       for ibnd = 1: length(bnd.DATA)
          ma = bnd.m(ibnd,1);
          na = bnd.n(ibnd,1);
          mb = bnd.m(ibnd,2);
          nb = bnd.n(ibnd,2);
%
%--------For Riemann type boundary conditions determine if inflow is
%        positive or negative
%
          positi{ibnd} = 'in';
          sign         = nesthd_detsign(ma,na,mb,nb,icom);
          if sign == -1 positi{ibnd} = 'out'; end
%
%---- 1.1 determine the orientation of the boundary section
%
%....... boundary section along a vertical grid line
%
         if  ma == mb && na ~= nb
%
%.......... check left or right side active grid
            m     = ma;
            mstep = 1;
            if ma > 1
               n = round((na + nb) / 2);
               if icom(ma-1,n) ==  1
                  m     = ma - 1 ;
                  mstep = -1;
               end
            end
%
%.......... then determine x and y coordinates boundary support points
%
            for iside = 1: 2
               n    = bnd.n(ibnd,iside);
               xmid = 0.5 * ( X(m,n) + X(m,n-1) );
               ymid = 0.5 * ( Y(m,n) + Y(m,n-1) );
               dx   = 0.5 * ( X(m  ,n  ) - X(m+mstep,n  )      ...
                            + X(m  ,n-1) - X(m+mstep,n-1) );
               dy   = 0.5 * ( Y(m  ,n  ) - Y(m+mstep,n  )      ...
                            + Y(m  ,n-1) - Y(m+mstep,n-1) );
               if type == 'UVp'
                  Xbnd   (ibnd,iside) = xmid;
                  Ybnd   (ibnd,iside) = ymid;
               elseif type == 'UVt'
                  Xbnd   (ibnd,iside) = X(m,n) + 0.5 * dx;
                  Ybnd   (ibnd,iside) = Y(m,n) + 0.5 * dy;
               elseif type == 'WL '
                  Xbnd (ibnd,iside) = xmid + 0.5 * dx;
                  Ybnd (ibnd,iside) = ymid + 0.5 * dy;
               end
            end
%
%....... boundary section
%        along a horizontal grid line
%
         elseif na == nb && ma ~= mb
%
%.......... check lower or upper side active grid
%
            n     = na;
            nstep = 1;
            if na > 1
               m = round((ma + mb) / 2);
               if icom(m,na-1) == 1
                  n     = na - 1;
                  nstep = -1;
               end
            end
%
%.......... then determine x and y coordinates boundary support points
%
            for iside = 1: 2
               m    = bnd.m(ibnd,iside);
               xmid = 0.5 * ( X(m,n) + X(m-1,n) );
               ymid = 0.5 * ( Y(m,n) + Y(m-1,n) );
               dx   = 0.5 * ( X(m  ,n  ) - X(m  ,n+nstep)    ...
                            + X(m-1,n  ) - X(m-1,n+nstep) );
               dy   = 0.5 * ( Y(m  ,n  ) - Y(m  ,n+nstep)    ...
                            + Y(m-1,n  ) - Y(m-1,n+nstep) );
               if type == 'UVp'
                  Xbnd   (ibnd,iside) = xmid;
                  Ybnd   (ibnd,iside) = ymid;
               elseif type == 'UVt'
                  Xbnd   (ibnd,iside) = X(m,n) + 0.5 * dx;
                  Ybnd   (ibnd,iside) = Y(m,n) + 0.5 * dy;
               elseif type == 'WL '
                  Xbnd   (ibnd,iside) = xmid + 0.5 * dx;
                  Ybnd   (ibnd,iside) = ymid + 0.5 * dy;
               end
            end
         else

            % Diagonal (water level) boundaries
            if type == 'WL '
               if abs(na - nb) ~=  abs (ma - mb)
                  h_err = errordlg ({'Water level boundary not horizontal/vertical or diagonal'},'NestHD Error');
                  uiwait (h_err);
                  exit
               end

               for isize = 1: 2
                  m = bnd.m (ibnd,isize);
                  n = bnd.n (ibnd,isize);
                  if icom (min(m+1,mmax),n              ) == 1 && ...
                     icom (m            ,max(n-1,1     )) == 1
                     Xbnd (ibnd,isize) = 0.5*(X (m  ,n  ) + X (m-1,n-1));
                     Ybnd (ibnd,isize) = 0.5*(Y (m  ,n  ) + Y (m-1,n-1));
                  elseif icom (max(m-1,1), n           ) ==1   && ...
                         icom (m           , max(n-1,1)) == 1
                     Xbnd (ibnd,isize) = 0.5*(X (m-1,n  ) + X (m  ,n-1));
                     Ybnd (ibnd,isize) = 0.5*(Y (m-1,n  ) + Y (m  ,n-1));
                  elseif icom (m         , min(n+1,nmax)) == 1 && ...
                         icom (max(m-1,1), n            ) == 1
                     Xbnd (ibnd,isize) = 0.5*(X (m  ,n  ) + X (m-1,n-1));
                     Ybnd (ibnd,isize) = 0.5*(Y (m  ,n  ) + Y (m-1,n-1));
                  elseif icom (min(m+1,mmax), n            ) == 1 && ...
                         icom (m            , min(n+1,nmax)) == 1
                     Xbnd (ibnd,isize) = 0.5*(X (m  ,n-1) + X (m-1,n  ));
                     Ybnd (ibnd,isize) = 0.5*(Y (m  ,n-1) + Y (m-1,n  ));
                  elseif icom (m         ,max(n-1,1   )) ~= 1 && ...
                         icom (m         ,min(n+1,nmax)) ~= 1 && ...
                         icom (max(m-1,1),n            ) ~= 1

                     % left point diagonal boundary

                     xmid = 0.5*(X(m  ,n  ) + X(m  ,n-1));
                     ymid = 0.5*(Y(m  ,n  ) + Y(m  ,n-1));
                     mstep = 1;
                     dx   = 0.5 * ( X(m,n  ) - X(m+mstep,n  ) ...
                                  + X(m,n-1) - X(m+mstep,n-1) );
                     dy   = 0.5 * ( Y(m,n  ) - Y(m+mstep,n  ) ...
                                  + Y(m,n-1) - Y(m+mstep,n-1) );
                     Xbnd (ibnd,isize) = xmid + 0.5 * dx;
                     Ybnd (ibnd,isize) = ymid + 0.5 * dy;
                  elseif icom (m            ,max(n-1,1   )) ~= 1 && ...
                         icom (m            ,min(n+1,nmax)) ~= 1 && ...
                         icom (min(m+1,mmax),n            ) ~= 1

                     % right point diagonal boundary

                     m = m - 1;
                     mstep = -1;
                     xmid = 0.5*(X(m  ,n  ) + X(m  ,n-1));
                     ymid = 0.5*(Y(m  ,n  ) + Y(m  ,n-1));
                     dx   = 0.5 * ( X(m,n  ) - X(m+mstep,n  ) ...
                                  + X(m,n-1) - X(m+mstep,n-1) );
                     dy   = 0.5 * ( Y(m,n  ) - Y(m+mstep,n  ) ...
                                  + Y(m,n-1) - Y(m+mstep,n-1) );
                     Xbnd (ibnd,isize) = xmid + 0.5 * dx;
                     Ybnd (ibnd,isize) = ymid + 0.5 * dy;
                  elseif icom (max(m-1,1)   ,n            ) ~= 1 && ...
                         icom (min(m+1,mmax),n            ) ~= 1 && ...
                         icom (m            ,max(n-1,1   )) ~= 1

                     % lower point diagonal boundary

                     nstep = 1;

                     xmid = 0.5 * ( X(m,n) + X(m-1,n) );
                     ymid = 0.5 * ( Y(m,n) + Y(m-1,n) );
                     dx   = 0.5 * ( X(m  ,n) - X(m  ,n+nstep) ...
                                  + X(m-1,n) - X(m-1,n+nstep) );
                     dy   = 0.5 * ( Y(m  ,n) - Y(m  ,n+nstep) ...
                                  + Y(m-1,n) - Y(m-1,n+nstep) );
                     Xbnd (ibnd,isize) = xmid + 0.5 * dx;
                     Ybnd (ibnd,isize) = ymid + 0.5 * dy;
                  elseif icom (max(m-1,1)   ,n            ) ~= 1 && ...
                         icom (min(m+1,mmax),n            ) ~= 1 && ...
                         icom (m            ,min(n+1,nmax)) ~= 1

                     % upper point diagonal boundary

                     n = n - 1;
                     nstep = -1;

                     xmid = 0.5 * ( X(m,n) + X(m-1,n) );
                     ymid = 0.5 * ( Y(m,n) + Y(m-1,n) );
                     dx   = 0.5 * ( X(m  ,n) - X(m  ,n+nstep) ...
                                  + X(m-1,n) - X(m-1,n+nstep) );
                     dy   = 0.5 * ( Y(m  ,n) - Y(m  ,n+nstep) ...
                                  + Y(m-1,n) - Y(m-1,n+nstep) );

                     Xbnd (ibnd,isize) = xmid + 0.5 * dx;
                     Ybnd (ibnd,isize) = ymid + 0.5 * dy;

                  end
               end
            else

               % set default value in case of diagonal velocity boundaries

               for isize = 1: 2
                   
                   m = bnd.m (ibnd,isize);
                   n = bnd.n (ibnd,isize);
                   if m > 1
                       if icom(m-1,n) == 1
                           m = m - 1;
                       end
                   end
                   if n > 1
                       if icom(m,n-1) == 1
                           n = n - 1;
                       end
                   end
                   try
                       Xbnd (ibnd,isize) =  0.5 * ( X(m,n) + X(m-1,n) );
                       Ybnd (ibnd,isize) =  0.5 * ( Y(m,n) + Y(m-1,n) );
                   catch
                       Xbnd (ibnd,isize) =  0.5 * ( X(m,n) + X(m,n-1) );
                       Ybnd (ibnd,isize) =  0.5 * ( Y(m,n) + Y(m,n-1) );
                   end
               end
            end
         end
       end

