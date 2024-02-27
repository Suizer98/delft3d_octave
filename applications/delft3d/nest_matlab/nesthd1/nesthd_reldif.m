      function [rel_m,rel_n] = reldif(xp,yp,xx,yy,sphere)

      % reldif: Determines relative position iside a computational cell

      %
      % Determines relative position iside a computational cell
      %
      a     = nesthd_detlength(xx(1),yy(1),xx(2),yy(2),'Spherical',sphere);
      b     = nesthd_detlength(xx(1),yy(1),xp   ,yp   ,'Spherical',sphere);
      c     = nesthd_detlength(xx(2),yy(2),xp   ,yp   ,'Spherical',sphere);
      rel_m = 0.5 + (b*b - c*c)/(2*a*a);

      a     = nesthd_detlength(xx(1),yy(1),xx(4),yy(4),'Spherical',sphere);
      c     = nesthd_detlength(xx(4),yy(4),xp   ,yp   ,'Spherical',sphere);
      rel_n = 0.5 + (b*b - c*c)/(2*a*a);

