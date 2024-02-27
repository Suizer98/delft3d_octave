function ncwrite_xbeach(data,outputdir,outFileRoot)
% ncwrite_adcpWvs.m  A function to write the xbeach data to a
%                    netCDF file.  
%
%   usage:  ncwrite_xbeach(data,outputdir,outFileRoot);
%
%       where:  data - a structure with the following fields
%                   XBdims      - structure with model dimensions and grid 
%                                 information
%                   depth       - depth information input to xbeach
%                   runup_time  - times at which runup output is given (matlab datenumber)
%                   runup       - water surface elevation of last wet cell (m)
%                   runup_u     - (GLM) x-velocity at runup location (m/s)
%                   runup_v     - (GLM) y-velocity at runup location (m/s)
%                   runup_xw    - world x-coordinate of runup location (m)
%                   runup_yw    - world y-coordinate of runup location (m)
%                   runup_xz    - xbeach x-coordinate of runup location (m)
%                   timeg       - times at which global output is given (matlab datenumber)
%                   zb          - global bed level output for grid (m)
%                   zs          - global water level output for grid (m)
%                   wetz        - global mask wet/dry eta-points for grid
%                   timem       - times at which mean output is given (matlab datenumber)
%                   Hmean       - mean wave height output for grid over last timestep (m)
%                   Hmax        - maximum wave height output for grid over last timestep (m)
%                   Hmin        - minimum wave height output for grid over last timestep (m)
%                   Hvar        - variance in wave height output for grid over last timestep (m)
%                   thetamean   - average mean wave angle output for grid over last timestep (deg)
%                   thetamax    - maximum mean wave angle output for grid over last timestep (deg)
%                   thetamin    - minimum mean wave angle output for grid over last timestep (deg)
%                   thetavar    - variance in mean wave angle output for grid over last timestep (deg)
%                   umean       - mean (GLM) x-velocity cell center for grid over last timestep (m/s)
%                   umax        - maximum (GLM) x-velocity cell center for grid over last timestep (m/s)
%                   umin        - minimum (GLM) x-velocity cell center for grid over last timestep (m/s)
%                   uvar        - variance in (GLM) x-velocity cell center for grid over last timestep (m/s)
%                   vmean       - mean (GLM) y-velocity cell center for grid over last timestep (m/s)
%                   vmax        - maximum (GLM) y-velocity cell center for grid over last timestep (m/s)
%                   vmin        - minimum (GLM) y-velocity cell center for grid over last timestep (m/s)
%                   vvar        - variance in (GLM) y-velocity cell center for grid over last timestep (m/s)
%                   DRmean      - mean roller energy dissipation for grid over last timestep (W/m^2)
%                   DRmax       - maximum roller energy dissipation for grid over last timestep (W/m^2)
%                   DRmin       - minimum roller energy dissipation for grid over last timestep (W/m^2)
%                   DRvar       - variance in roller energy dissipation for grid over last timestep (W/m^2)
%                   zsmean      - mean water level output for grid over last timestep (m)
%                   zsmax       - maximum water level output for grid over last timestep (m)
%                   zsmin       - minimum water level output for grid over last timestep (m)
%                   zsvar       - variance in water level output for grid over last timestep (m)

%               outputdir       - directory path where netcdf output files are
%                                 stored (ex: ''M:\Coastal_Hazards\Xbeach\netcdf\');
%               outFileRoot     - name given to the processed data NetCDF file
%
% JLE 9/1/09
% modified 11/10/09 for final bulk xbeach run setup
nrecg=data.XBdims.nt;
nrecm=data.XBdims.ntm;
nrecp=data.XBdims.ntp;
nx=data.XBdims.nx+1;
ny=data.XBdims.ny+1;
nd=data.XBdims.nd;

% Write coordinate variables to NetCDF
nc=netcdf([outputdir,outFileRoot,'.nc'],'write');

% Write data to NetCDF
disp(['Writing xbeach output data to ',outFileRoot,'.nc'])
nc{'x'}(1:nx,1:ny) = data.XBdims.x;
nc{'y'}(1:nx,1:ny) = data.XBdims.y;
nc{'xc'}(1:nx,1:ny) = data.XBdims.xc;
nc{'yc'}(1:nx,1:ny) = data.XBdims.yc;
nc{'depth'}(1:nx,1:ny) = data.depth;
% nc{'gdist1'}(1:nx,1:(ny*nd)) = data.gdist1;
% nc{'gdist2'}(1:nx,1:(ny*nd)) = data.gdist2;
nc{'timeglobal'}(1:nrecg) = data.timeg; 
%nc{'timeglobal'}(1:nrecg) = floor(data.timeg);                                 
%nc{'timeglobal2'}(1:nrecg) = (data.timeg-floor(data.timeg)).*(24*3600*1000);  
nc{'zb'}(1:nrecg,1:nx,1:ny) = data.zb;
nc{'zs'}(1:nrecg,1:nx,1:ny) = data.zs;
%nc{'wetz'}(1:nrecg,1:nx,1:ny) = data.wetz;
nc{'runup_time'}(1:nrecp) = data.runup_time; 
%nc{'runup_time'}(1:nrecp) = floor(data.runup_time);                                 
%nc{'runup_time2'}(1:nrecp) = (data.runup_time-floor(data.runup_time)).*(24*3600*1000); 
nc{'runup'}(1:nrecp) = data.runup;
nc{'runup_u'}(1:nrecp) = data.runup_u;
nc{'runup_v'}(1:nrecp) = data.runup_v;
nc{'runup_xw'}(1:nrecp) = data.runup_xw;
nc{'runup_yw'}(1:nrecp) = data.runup_yw;
nc{'runup_xz'}(1:nrecp) = data.runup_xz;
nc{'timemean'}(1:nrecm) = data.timem;    
%nc{'timemean'}(1:nrecm) = floor(data.timem);                                 
%nc{'timemean2'}(1:nrecm) = (data.timem-floor(data.timem)).*(24*3600*1000);  
nc{'Hmean'}(1:nrecm,1:nx,1:ny) = data.Hmean;
nc{'Hmin'}(1:nrecm,1:nx,1:ny) = data.Hmin;
nc{'Hmax'}(1:nrecm,1:nx,1:ny) = data.Hmax;
nc{'Hvar'}(1:nrecm,1:nx,1:ny) = data.Hvar;
nc{'thetamean'}(1:nrecm,1:nx,1:ny) = data.thetamean;
nc{'thetamin'}(1:nrecm,1:nx,1:ny) = data.thetamin;
nc{'thetamax'}(1:nrecm,1:nx,1:ny) = data.thetamax;
nc{'thetavar'}(1:nrecm,1:nx,1:ny) = data.thetavar;
nc{'umean'}(1:nrecm,1:nx,1:ny) = data.umean;
nc{'umax'}(1:nrecm,1:nx,1:ny) = data.umax;
nc{'umin'}(1:nrecm,1:nx,1:ny) = data.umin;
nc{'uvar'}(1:nrecm,1:nx,1:ny) = data.uvar;
nc{'vmean'}(1:nrecm,1:nx,1:ny) = data.vmean;
nc{'vmax'}(1:nrecm,1:nx,1:ny) = data.vmax;
nc{'vmin'}(1:nrecm,1:nx,1:ny) = data.vmin;
nc{'vvar'}(1:nrecm,1:nx,1:ny) = data.vvar;
nc{'DRmean'}(1:nrecm,1:nx,1:ny) = data.DRmean;
nc{'DRmax'}(1:nrecm,1:nx,1:ny) = data.DRmax;
nc{'DRmin'}(1:nrecm,1:nx,1:ny) = data.DRmin;
nc{'DRvar'}(1:nrecm,1:nx,1:ny) = data.DRvar;
nc{'zsmean'}(1:nrecm,1:nx,1:ny) = data.zsmean;
nc{'zsmax'}(1:nrecm,1:nx,1:ny) = data.zsmax;
nc{'zsmin'}(1:nrecm,1:nx,1:ny) = data.zsmin;
nc{'zsvar'}(1:nrecm,1:nx,1:ny) = data.zsvar;

% Add the following NetCDF global attributes
nc.CREATION_DATE = ncchar(datestr(now,0));

% Update the NetCDF history attribute
history = nc.history(:);
history_new = ['Xbeach output converted to NetCDF by ',...
               'xbeach2nc:ncwrite_xbeach.m on ',...
               datestr(now,0),'; ',history];
nc.history = ncchar(history_new);

% Close NetCDF file
nc = close(nc);

disp(['Finished writing xbeach data. ',num2str(toc/60),' minutes elapsed'])

return
