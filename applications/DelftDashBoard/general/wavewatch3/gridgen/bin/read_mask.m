function m = read_mask(fname,Nx,Ny)

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
%| Read data from file                                                    |
%|                                                                        |
%| m = read_mask(fname,Nx,Ny)                                             |
%|                                                                        |
%| INPUT                                                                  |
%|  fname       : Input file name containing data                         |
%|  Nx,Ny       : Array dimensions in x and y                             |
%|                                                                        |
%| OUTPUT                                                                 |
%|  m           : 2D array with data                                      |
% -------------------------------------------------------------------------
  
fid = fopen(fname,'r');

[messg,errno] = ferror(fid);

if (errno == 0)
   a = fscanf(fid,'%d');
   m = (reshape(a,Nx,Ny))';
else
   fprintf(1,'!!ERROR!!: %s \n',messg);
end;

fclose(fid);
return;
