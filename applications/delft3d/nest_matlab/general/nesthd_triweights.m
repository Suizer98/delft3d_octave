       function [zp] = nesthd_triweights(xt ,yt ,xp ,yp)


       % nesthd_linweight, deteremines weight factors belonging with triangular interpolation
       %                   method identical to method applied in dflowfm

       %% Initialise
       zp  = [];

       %% Determine distances
       a11 = xt(2) - xt(1);
       a21 = yt(2) - yt(1);
       a12 = xt(3) - xt(1);
       a22 = yt(3) - yt(1);
       b1  = xp - xt(1);
       b2  = yp - yt(1);

       %% Determine weights
       det = a11*a22 - a12*a21;
       if (abs(det)<1E-9)
          zp(1:3) = NaN;
       else
          zp(2) = (  a22*b1 - a12*b2)/det;
          zp(3) = ( -a21*b1 + a11*b2)/det;
          zp(1) =   1d0 - zp(2) - zp(3);
       end

