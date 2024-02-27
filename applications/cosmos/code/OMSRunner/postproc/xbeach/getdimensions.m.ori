function XBdims=getdimensions(dr)
% XBdims=getdimensions
% 
% Must start in XBeach output directory
% Output structure XBdims
% XBdims.nt       = number of regular spatial output timesteps
% XBdims.nx       = number of grid cells in x-direcion
% XBdims.ny       = number of grid cells in y-direcion
% XBdims.ngd      = number of sediment classes
% XBdims.nd       = number of sediment class layers
% XBdims.ntp      = number of point output timesteps
% XBdims.ntm      = number of time-average output timesteps
% XBdims.tsglobal = times at which regular output is given
% XBdims.tspoints = times at which point output is given
% XBdims.tsmean   = times at which time-averaged output is given
% XBdims.x   = x-coordinates grid
% XBdims.y   = y-coordinates grid
% 
% Created 19-06-2008 : XBeach-group Delft

fid=fopen([dr 'dims.dat'],'r');
XBdims.nt=fread(fid,[1],'double'); 
XBdims.nx=fread(fid,[1],'double');         
XBdims.ny=fread(fid,[1],'double');        
XBdims.ngd=fread(fid,[1],'double');       
XBdims.nd=fread(fid,[1],'double');        
XBdims.ntp=fread(fid,[1],'double');       
XBdims.ntm=fread(fid,[1],'double');  
XBdims.tsglobal=fread(fid,[XBdims.nt],'double');
XBdims.tspoints=fread(fid,[XBdims.ntp],'double');
XBdims.tsmean=fread(fid,[XBdims.ntm],'double');
fclose(fid);

fidxy=fopen([dr 'xy.dat'],'r');
XBdims.x=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');   
XBdims.y=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');   
fclose(fidxy);
