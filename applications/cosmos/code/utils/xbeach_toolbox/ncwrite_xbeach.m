function ncwrite_xbeach(data,outFileRoot)
% ncwrite_adcpWvs.m  A function to write the xbeach data to a
%                    netCDF file.  
%
%   usage:  ncwrite_xbeach(data,outFileRoot);
%
%       where:  data - a structure with the following fields
%                   tsglobal- times at which regular output is given
%                   x       - x-coordinates grid
%                   y       - y-coordinates grid
%                   depth   - depth information input to xbeach
%                   runup   - water surface elevation of runup (m)
%                   zb      - bed level output for grid (m)
%                   zs      - water level output for grid (m)
%                   H       - wave height output for grid (m)
%                   thetamean - mean wave angle output for grid (m)
%                   u       - (GLM) x-velocity cell center for grid (m/s)
%                   v       - (GLM) y-velocity cell center for grid (m/s)
%                   wetz    - mask wet/dry eta-points
%               outFileRoot - name given to the processed data NetCDF file
%
% JLE 9/1/09


nrec=length(data.tsglobal);

% Write coordinate variables to NetCDF
nc=netcdf([outFileRoot,'.nc'],'write');
nc{'tsglobal'}(1:nrec) = data.tsglobal;                                 

% Write data to NetCDF
disp(['Writing xbeach output data to ',outFileRoot,'.nc'])
nc{'x'}(1:size(data.x,1),1:size(data.x,2)) = data.x;
nc{'y'}(1:size(data.x,1),1:size(data.x,2)) = data.y;
nc{'depth'}(1:size(data.x,1),1:size(data.x,2)) = data.depth;
nc{'runup'}(1:nrec) = data.runup;
nc{'zb'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.zb;
nc{'zs'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.zs;
nc{'H'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.H;
nc{'thetamean'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.thetamean;
nc{'u'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.u;
nc{'v'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.v;
nc{'wetz'}(1:nrec,1:size(data.x,1),1:size(data.x,2)) = data.wetz;

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
