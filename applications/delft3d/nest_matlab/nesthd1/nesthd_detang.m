      function angle = detang (x     , y     , icom  , bnd   ,sphere)

      % detangle: determines orientation of a boundary segment
      % delft hydraulics                         marine and coastal management
      %
      % subroutine         : detang
      % version            : v1.0
      % date               : June 1997
      % programmer         : Theo van der Kaaij
      %
      % function           : determines orientation of a boundary segment

      angle(1:length(bnd.DATA)) = NaN;

%
% -   for all boundary sections
%
      for ibnd = 1: length(bnd.DATA)
         ma = bnd.m(ibnd,1);
         na = bnd.n(ibnd,1);
         mb = bnd.m(ibnd,2);
         nb = bnd.n(ibnd,2);

%
% -------determine orientation (angle) (not for diagonal boundaries)
%
         if mb > ma || nb > na
             if ~sphere
                dx = x   (ibnd,2) - x   (ibnd,1);
                dy = y   (ibnd,2) - y   (ibnd,1);
             else
                 x1  = x  (ibnd,2);
                 x2  = x  (ibnd,1);
                 y12 = (y(ibnd,1) + y(ibnd,2))/2;
                 dx = sign(x (ibnd,2) - x(ibnd,1)) * nesthd_detlength(x1,y12,x2,y12,'Spherical',sphere);
                 y1  = y  (ibnd,2);
                 y2  = y  (ibnd,1);
                 x12 = (x(ibnd,1) + x(ibnd,2))/2;
                 dy = sign(y (ibnd,2) - y(ibnd,1)) * nesthd_detlength(x12,y1,x12,y2,'Spherical',sphere);
             end
         else
            if ~sphere
                dx = x   (ibnd,1) - x   (ibnd,2);
                dy = y   (ibnd,1) - y   (ibnd,2);
            else
                 x1  = x  (ibnd,1);
                 x2  = x  (ibnd,2);
                 y12 = (y(ibnd,1) + y(ibnd,2))/2;
                 dx = sign(x (ibnd,1) - x(ibnd,2)) * nesthd_detlength(x1,y12,x2,y12,'Spherical',sphere);
                 y1  = y  (ibnd,1);
                 y2  = y  (ibnd,2);
                 x12 = (x(ibnd,1) + x(ibnd,2))/2;
                 dy = sign(y (ibnd,1) - y(ibnd,2)) * nesthd_detlength(x12,y1,x12,y2,'Spherical',sphere);
             end
         end

         angle (ibnd) = atan2(dy,dx)*180./pi;
%
% -------add 180 degr. for upper or lower boundary (n direction)
%
%         if na == 1
%            angle (ibnd) = angle (ibnd) + 180.;
%         elseif na == size(icom,2)
%            angle (ibnd) = angle (ibnd) + 180.;
%         elseif icom (ma,na + 1) == 1 || icom (ma,na - 1) == 1
%            angle (ibnd) = angle (ibnd) + 180.;
%         end
          if na == nb
             angle (ibnd) = angle (ibnd) + 180.;
          end
      end
