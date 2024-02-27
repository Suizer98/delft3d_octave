      function [mp,np] = nesthd_nearmn (xp,yp,x,y,kcs,varargin)

      % given a pair of X,Y co-ordinates, find the M,N co-ordinates of the nearest grid cell

      % function           : given a pair of Xp,Yp co-ordinates, find the
      %                      M,N co-ordinates of the nearest (X,Y) grid cell

      dist0 = 1.0e37;
      mp    = NaN;
      np    = NaN;

      %% Sferic or not
      OPT.spherical = false;
      OPT           = setproperty(OPT,varargin);

      for m = 2: size(x,1)
         for n = 2: size(x,2)
            if kcs(m,n) == 1
%
%---------- Determine coordinates cell centre
%
               xz = 0.25 * (x (m  ,n  ) + x (m-1,n  ) + x (m-1,n-1) + x (m  ,n-1));
               yz = 0.25 * (y (m  ,n  ) + y (m-1,n  ) + y (m-1,n-1) + y (m  ,n-1));
%
%------------- distance from specified location and centre of grid cell
%

               dist = nesthd_detlength(xp,yp,xz,yz,'Spherical',OPT.spherical);

%
%------------- if closer set M,N co-ordinates and reset minimal distance
%
               if dist < dist0
                  mp  = m;
                  np  = n;
                  dist0 = dist;
               end

            end

         end

      end

