function vsrm=schwerdt1979(vmax,c)
% Schwerdt,R. W., F. P. Ho, and R. R. Watkins, 1979: Meteorological criteria for standard project hurricane and probable maximum hurricane wind fields, Gulf and East Coasts of the United States. NOAA Tech. Rep. NWS 23, 317 pp. [Available from National Hurricane Center Library, 11691 SW 117 St., Miami, FL 33165-2149.]
% Computes storm relative intensity
% All units are in knots!
a=1.5*c^0.63;
vsrm=vmax-a;

