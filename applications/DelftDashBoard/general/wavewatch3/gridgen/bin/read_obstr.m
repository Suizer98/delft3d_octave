function [m1,m2] = read_obstr(fname,Nx,Ny)

% -------------------------------------------------------------------------
%|                                                                        |
%|                    +----------------------------+                      |
%|                    | GRIDGEN          NOAA/NCEP |                      |
%|                    |                            |                      |
%|                    | Last Update :  23-Oct-2012 |                      |
%|                    +----------------------------+                      | 
%|                     Distributed with WAVEWATCH III                     |
%|                                                                        |
%|                 Copyright 2009 National Weather Service (NWS),         |
%|  National Oceanic and Atmospheric Administration.  All rights reserved.|
%|                                                                        |
%| DESCRIPTION                                                            |
%| Read obstruction data from file                                        |
%|                                                                        |
%| [m1,m2] = read_obstr(fname,Nx,Ny)                                      |
%|                                                                        |
%| INPUT                                                                  |
%|  fname       : Input file name containing data                         |
%|  Nx,Ny       : Array dimensions in x and y                             |
%|                                                                        |
%| OUTPUT                                                                 |
%|  m1           : 2D array with x obstruction data                       |
%|  m2           : 2D array with y obstruction data                       |
% -------------------------------------------------------------------------

  
fid = fopen(fname,'r');

[messg,errno] = ferror(fid);

if (errno == 0)
   a = fscanf(fid,'%d',Nx*Ny);
   m1 = (reshape(a,Nx,Ny))';
   a = fscanf(fid,'%d',Nx*Ny);
   m2 = (reshape(a,Nx,Ny))';
else
   fprintf(1,'!!ERROR!!: %s \n',messg);
end;

fclose(fid);
return;
