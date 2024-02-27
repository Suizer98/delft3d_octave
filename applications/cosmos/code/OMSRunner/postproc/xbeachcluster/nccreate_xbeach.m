function status = nccreate_xbeach(inputdir,outputdir,outFileRoot)
% nccreate_xbeach.m  A function to gather metadata and create empty netCDF 
%                     files that will store xbeach output data.   
%
%    usage:  nccreate_xbeach(outputdir,outFileRoot);
%
%        where: outFileRoot - a string specifying the name given to the
%                             NetCDF output files, in single quotes
%                             excluding the NetCDF file extension .nc
%               outputdir       - directory path where netcdf output files are
%                                 stored (ex:
%                                 ''M:\Coastal_Hazards\Xbeach\netcdf\');
% JLE 8/31/09
% modified 11/12/09 for final bulk xbeach run setup


status = 1;

ncr = netcdf([outputdir,outFileRoot,'.nc'],'clobber');

% Gather and write NetCDF metadata from the params.txt and dims.dat files
if ~isempty(dir([inputdir,'params.txt'])) && ~isempty(dir([outputdir,'dims.dat']))
    disp('Reading Xbeach params.txt and dims.dat files ...') 
    [xbMeta,xbMetaDefs,xbMDim,xbMDimDefs] = get_meta_xbeach(inputdir,outputdir);
    write_xbeach_meta(ncr,xbMeta,xbMetaDefs,xbMDim,xbMDimDefs)
elseif isempty(dir([inputdir,'params.txt']))
    disp('Unable to find Xbeach params.txt file')
    status = -1;
    return
elseif isempty(dir([outputdir,'dims.dat']))   
    disp('Unable to find Xbeach dims.dat file')
    status = -1;
    return
end

ncr.DATA_TYPE = ncchar('Xbeach Model Output');

%Define NetCDF dimensions
ncr('time') = ncr.XBDim.nt(:);
ncr('timep') = ncr.XBDim.ntp(:);
ncr('timem') = ncr.XBDim.ntm(:);
ncr('easting') = ncr.nx(:)+1;
ncr('northing') = ncr.ny(:)+1;
% ncr('northing2') = (ncr.ny(:)+1)*(ncr.XBDim.nd(:));

% Define NetCDF variables
disp(['Defining NetCDF variables in ',outFileRoot,'.nc'])
define_xbeach_vars(ncr);

endef(ncr);
ncr=close(ncr);

return

% --------- Subfunction: Gather Xbeach configuration data ------------- %
function [xbMeta,xbMetaDefs,xbMDim,xbMDimDefs] = get_meta_xbeach(inputdir,outputdir)

% Read dimensions from xbeach output file and save.
% (XBeach manual p. 63 describes definitions)
fid = fopen([outputdir,'dims.dat'],'r');
xbMDimDefs{1,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{2,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{3,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{4,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{5,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{6,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{7,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{8,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{9,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{10,1} = num2str(fread(fid,[1],'double'));
fclose(fid)

xbMDim{1,1} = 'nt';
xbMDim{2,1} = 'nx';
xbMDim{3,1} = 'ny';
xbMDim{4,1} = 'ntheta';
xbMDim{5,1} = 'kmax';
xbMDim{6,1} = 'ngd';
xbMDim{7,1} = 'nd';
xbMDim{8,1} = 'ntp';
xbMDim{9,1} = 'ntc';
xbMDim{10,1} = 'ntm';

% Gather user-defined model parameters
disp(' ')
disp('Reading Xbeach params.txt file ...')
configFile ='params.txt';
ind = 1;
fid = fopen([inputdir,configFile],'r');
while 1 
    tline = fgetl(fid);
    eqpos = strfind(tline,'=');
    if ~isempty(eqpos)
        xbMeta{ind,1} = tline(1:eqpos-1);
        xbMetaDefs{ind,1} = tline(eqpos+1:end);
        %deblank removes trailing whitespace
        xbMeta = deblank(xbMeta);
        ind = ind + 1;
    end
    if ~ischar(tline), break, end
end
fclose(fid);
     
return

% --------- Subfunction: Write NetCDF metadata -------------------------- %
function write_xbeach_meta(nc,xbMeta,xbMetaDefs,xbMDim,xbMDimDefs)

    for a=1:length(xbMeta)
        theField = xbMeta{a};
        theFieldDef = xbMetaDefs{a};
        if ~isempty(str2num(theFieldDef))
            nc.(theField) = str2num(theFieldDef);
        else
            nc.(theField) = theFieldDef;
        end
    end
    
    for a=1:length(xbMDim)
        theField = xbMDim{a};
        theFieldDef = xbMDimDefs{a};
        if ~isempty(str2num(theFieldDef)) 
            nc.XBDim.(theField) = str2num(theFieldDef);
        else
            nc.XBDim.(theField) = theFieldDef;
        end
    end
        
return

% --------- Subfunction: Define NetCDF variables ------------------------ %
function define_xbeach_vars(nc)  

    nc{'x'} = ncdouble('easting','northing');
    nc{'x'}.long_name=ncchar('World x-coordinates grid (m)');
    nc{'x'}.name = ncchar('x');
    nc{'x'}.units=ncchar('m');
    nc{'x'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'y'} = ncdouble('easting','northing');
    nc{'y'}.long_name=ncchar('World y-coordinates grid (m)');
    nc{'y'}.name = ncchar('y');
    nc{'y'}.units=ncchar('m');
    nc{'y'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'xc'} = ncdouble('easting','northing');
    nc{'xc'}.long_name=ncchar('X-coordinates calculation grid');
    nc{'xc'}.name = ncchar('xc');
    nc{'xc'}.units=ncchar('m');
    nc{'xc'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'yc'} = ncdouble('easting','northing');
    nc{'yc'}.long_name=ncchar('Y-coordinates calculation grid');
    nc{'yc'}.name = ncchar('yc');
    nc{'yc'}.units=ncchar('m');
    nc{'yc'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'depth'} = ncdouble('easting','northing');
    nc{'depth'}.long_name=ncchar('Depth (m)');
    nc{'depth'}.name = ncchar('depth');
    nc{'depth'}.units=ncchar('m');
    nc{'depth'}.FORTRAN_format=ncchar('F10.2');
    
%     nc{'gdist1'} = ncdouble('easting','northing2');
%     nc{'gdist1'}.long_name=ncchar('Sediment distribution for sediment class 1');
%     nc{'gdist1'}.name = ncchar('gdist1');
%     nc{'gdist1'}.units=ncchar('proportion (0-1)');
%     nc{'gdist1'}.FORTRAN_format=ncchar('F4.1');
%     
%     nc{'gdist2'} = ncdouble('easting','northing2');
%     nc{'gdist2'}.long_name=ncchar('Sediment distribution for sediment class 1');
%     nc{'gdist2'}.name = ncchar('gdist2');
%     nc{'gdist2'}.units=ncchar('proportion (0-1)');
%     nc{'gdist2'}.FORTRAN_format=ncchar('F4.1');
    
    nc{'timeglobal'} = nclong('time'); 
    nc{'timeglobal'}.FORTRAN_format = ncchar('F10.2');
    nc{'timeglobal'}.units = ncchar('sec');
    nc{'timeglobal'}.type = ncchar('UNEVEN');

%     nc{'timeglobal'} = nclong('time'); 
%     nc{'timeglobal'}.FORTRAN_format = ncchar('F10.2');
%     nc{'timeglobal'}.units = ncchar('True Julian Day');
%     nc{'timeglobal'}.type = ncchar('UNEVEN');
%     nc{'timeglobal'}.epic_code = nclong(624);
    
%     nc{'timeglobal2'} = nclong('time');
%     nc{'timeglobal2'}.FORTRAN_format = ncchar('F10.2');
%     nc{'timeglobal2'}.units = ncchar('msec since 0:00 GMT');
%     nc{'timeglobal2'}.type = ncchar('UNEVEN');
%     nc{'timeglobal2'}.epic_code = nclong(624);
    
    nc{'zb'} = ncdouble('time','easting','northing');
    nc{'zb'}.long_name=ncchar('Bed Level');
    nc{'zb'}.name = ncchar('zb');
    nc{'zb'}.units=ncchar('m');
    nc{'zb'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zs'} = ncdouble('time','easting','northing');
    nc{'zs'}.long_name=ncchar('Water Level');
    nc{'zs'}.name = ncchar('zs');
    nc{'zs'}.units=ncchar('m');
    nc{'zs'}.FORTRAN_format=ncchar('F10.2');
    
%     nc{'wetz'} = ncdouble('time','easting','northing');
%     nc{'wetz'}.long_name=ncchar('mask wet/dry eta points');
%     nc{'wetz'}.name = ncchar('v');
%     nc{'wetz'}.units=ncchar('-');
%     nc{'wetz'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'runup_time'} = nclong('timep'); 
    nc{'runup_time'}.FORTRAN_format = ncchar('F10.2');
    nc{'runup_time'}.units = ncchar('sec');
    nc{'runup_time'}.type = ncchar('UNEVEN');

%     nc{'runup_time'} = nclong('timep'); 
%     nc{'runup_time'}.FORTRAN_format = ncchar('F10.2');
%     nc{'runup_time'}.units = ncchar('True Julian Day');
%     nc{'runup_time'}.type = ncchar('UNEVEN');
%     
%     nc{'runup_time2'} = nclong('timep');
%     nc{'runup_time2'}.FORTRAN_format = ncchar('F10.2');
%     nc{'runup_time2'}.units = ncchar('msec since 0:00 GMT');
%     nc{'runup_time2'}.type = ncchar('UNEVEN');
    
    nc{'runup'} = ncfloat('timep'); 
    nc{'runup'}.FORTRAN_format = ncchar('F10.5');
    nc{'runup'}.units = ncchar('m');
    nc{'runup'}.type = ncchar('UNEVEN');
    nc{'runup'} .long_name('Water surface elevation of last wet cell'); 
    
    nc{'runup_u'} = ncfloat('timep'); 
    nc{'runup_u'}.FORTRAN_format = ncchar('F10.5');
    nc{'runup_u'}.units = ncchar('m/s');
    nc{'runup_u'}.type = ncchar('UNEVEN');
    nc{'runup_u'}.long_name('GLM) x-velocity at runup location (m/s)');
    
    nc{'runup_v'} = ncfloat('timep'); 
    nc{'runup_v'}.FORTRAN_format = ncchar('F10.5');
    nc{'runup_v'}.units = ncchar('m/s');
    nc{'runup_v'}.type = ncchar('UNEVEN');
    nc{'runup_v'}.long_name('GLM) y-velocity at runup location (m/s)');
    
    nc{'runup_xw'} = ncfloat('timep'); 
    nc{'runup_xw'}.FORTRAN_format = ncchar('F12.5');
    nc{'runup_xw'}.units = ncchar('m');
    nc{'runup_xw'}.type = ncchar('UNEVEN');
    nc{'runup_xw'}.long_name('World x-coordinate of runup location');
    
    nc{'runup_yw'} = ncfloat('timep');
    nc{'runup_yw'}.FORTRAN_format = ncchar('F12.5');
    nc{'runup_yw'}.units = ncchar('m');
    nc{'runup_yw'}.type = ncchar('UNEVEN'); 
    nc{'runup_yw'}.long_name('World y-coordinate of runup location');
    
    nc{'runup_xz'} = nclong('timep'); 
    nc{'runup_xz'}.FORTRAN_format = ncchar('F10.2');
    nc{'runup_xz'}.units = ncchar('m');
    nc{'runup_xz'}.type = ncchar('UNEVEN');
    nc{'runup_xz'}.long_name('Xbeach x-coordinate of runup location');
    
    nc{'timemean'} = nclong('timem'); 
    nc{'timemean'}.FORTRAN_format = ncchar('F10.2');
    nc{'timemean'}.units = ncchar('sec');
    nc{'timemean'}.type = ncchar('UNEVEN');
    
%     nc{'timemean'} = nclong('timem'); 
%     nc{'timemean'}.FORTRAN_format = ncchar('F10.2');
%     nc{'timemean'}.units = ncchar('True Julian Day');
%     nc{'timemean'}.type = ncchar('UNEVEN');
%     nc{'timemean'}.epic_code = nclong(624);
%     
%     nc{'timemean2'} = nclong('timem');
%     nc{'timemean2'}.FORTRAN_format = ncchar('F10.2');
%     nc{'timemean2'}.units = ncchar('msec since 0:00 GMT');
%     nc{'timemean2'}.type = ncchar('UNEVEN');
%     nc{'timemean2'}.epic_code = nclong(624);
    
    nc{'Hmean'} = ncdouble('timem','easting','northing');
    nc{'Hmean'}.long_name=ncchar('Mean wave height over last timestep (m)');
    nc{'Hmean'}.name = ncchar('Hmean');
    nc{'Hmean'}.units=ncchar('m');
    nc{'Hmean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'Hmax'} = ncdouble('timem','easting','northing');
    nc{'Hmax'}.long_name=ncchar('Maximum wave height over last timestep (m)');
    nc{'Hmax'}.name = ncchar('Hmax');
    nc{'Hmax'}.units=ncchar('m');
    nc{'Hmax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'Hmin'} = ncdouble('timem','easting','northing');
    nc{'Hmin'}.long_name=ncchar('Minimum wave height over last timestep (m)');
    nc{'Hmin'}.name = ncchar('Hmin');
    nc{'Hmin'}.units=ncchar('m');
    nc{'Hmin'}.FORTRAN_format=ncchar('F10.2'); 
    
    nc{'Hvar'} = ncdouble('timem','easting','northing');
    nc{'Hvar'}.long_name=ncchar('Variance in wave height over last timestep (m)');
    nc{'Hvar'}.name = ncchar('Hvar');
    nc{'Hvar'}.units=ncchar('m');
    nc{'Hvar'}.FORTRAN_format=ncchar('F10.2'); 
    
    nc{'thetamean'} = ncdouble('timem','easting','northing');
    nc{'thetamean'}.long_name=ncchar('Average mean wave angle over last timestep');
    nc{'thetamean'}.name = ncchar('thetamean');
    nc{'thetamean'}.units=ncchar('deg');
    nc{'thetamean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'thetamax'} = ncdouble('timem','easting','northing');
    nc{'thetamax'}.long_name=ncchar('Maximum mean wave angle over last timestep');
    nc{'thetamax'}.name = ncchar('thetamax');
    nc{'thetamax'}.units=ncchar('deg');
    nc{'thetamax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'thetamin'} = ncdouble('timem','easting','northing');
    nc{'thetamin'}.long_name=ncchar('Minimum mean wave angle over last timestep');
    nc{'thetamin'}.name = ncchar('thetamin');
    nc{'thetamin'}.units=ncchar('deg');
    nc{'thetamin'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'thetavar'} = ncdouble('timem','easting','northing');
    nc{'thetavar'}.long_name=ncchar('Variance in mean wave angle over last timestep');
    nc{'thetavar'}.name = ncchar('thetavar');
    nc{'thetavar'}.units=ncchar('deg');
    nc{'thetavar'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'umean'} = ncdouble('timem','easting','northing');
    nc{'umean'}.long_name=ncchar('Mean (GLM) x-velocity cell center over last timestep');
    nc{'umean'}.name = ncchar('umean');
    nc{'umean'}.units=ncchar('m/s');
    nc{'umean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'umax'} = ncdouble('timem','easting','northing');
    nc{'umax'}.long_name=ncchar('Maximum (GLM) x-velocity cell center over last timestep');
    nc{'umax'}.name = ncchar('umax');
    nc{'umax'}.units=ncchar('m/s');
    nc{'umax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'umin'} = ncdouble('timem','easting','northing');
    nc{'umin'}.long_name=ncchar('Minimum (GLM) x-velocity cell center over last timestep');
    nc{'umin'}.name = ncchar('umin');
    nc{'umin'}.units=ncchar('m/s');
    nc{'umin'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'uvar'} = ncdouble('timem','easting','northing');
    nc{'uvar'}.long_name=ncchar('Variance in (GLM) x-velocity cell center over last timestep');
    nc{'uvar'}.name = ncchar('uvar');
    nc{'uvar'}.units=ncchar('m/s');
    nc{'uvar'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'vmean'} = ncdouble('timem','easting','northing');
    nc{'vmean'}.long_name=ncchar('Mean (GLM) y-velocity cell center over last timestep');
    nc{'vmean'}.name = ncchar('vmean');
    nc{'vmean'}.units=ncchar('m/s');
    nc{'vmean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'vmax'} = ncdouble('timem','easting','northing');
    nc{'vmax'}.long_name=ncchar('Maximum (GLM) y-velocity cell center over last timestep');
    nc{'vmax'}.name = ncchar('vmax');
    nc{'vmax'}.units=ncchar('m/s');
    nc{'vmax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'vmin'} = ncdouble('timem','easting','northing');
    nc{'vmin'}.long_name=ncchar('Minimum (GLM) y-velocity cell center over last timestep');
    nc{'vmin'}.name = ncchar('vmin');
    nc{'vmin'}.units=ncchar('m/s');
    nc{'vmin'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'vvar'} = ncdouble('timem','easting','northing');
    nc{'vvar'}.long_name=ncchar('Variance in (GLM) y-velocity cell center over last timestep');
    nc{'vvar'}.name = ncchar('vvar');
    nc{'vvar'}.units=ncchar('m/s');
    nc{'vvar'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'DRmean'} = ncdouble('timem','easting','northing');
    nc{'DRmean'}.long_name=ncchar('Mean roller energy dissipation for grid over last timestep');
    nc{'DRmean'}.name = ncchar('DRmean');
    nc{'DRmean'}.units=ncchar('W/m^2');
    nc{'DRmean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'DRmax'} = ncdouble('timem','easting','northing');
    nc{'DRmax'}.long_name=ncchar('Maximum roller energy dissipation for grid over last timestep');
    nc{'DRmax'}.name = ncchar('DRmax');
    nc{'DRmax'}.units=ncchar('W/m^2');
    nc{'DRmax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'DRmin'} = ncdouble('timem','easting','northing');
    nc{'DRmin'}.long_name=ncchar('Minimum roller energy dissipation for grid over last timestep');
    nc{'DRmin'}.name = ncchar('umin');
    nc{'DRmin'}.units=ncchar('W/m^2');
    nc{'DRmin'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'DRvar'} = ncdouble('timem','easting','northing');
    nc{'DRvar'}.long_name=ncchar('Variance in roller energy dissipation for grid over last timestep');
    nc{'DRvar'}.name = ncchar('uvar');
    nc{'DRvar'}.units=ncchar('W/m^2');
    nc{'DRvar'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zsmean'} = ncdouble('timem','easting','northing');
    nc{'zsmean'}.long_name=ncchar('Mean water level output for grid over last timestep');
    nc{'zsmean'}.name = ncchar('zsmean');
    nc{'zsmean'}.units=ncchar('m');
    nc{'zsmean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zsmax'} = ncdouble('timem','easting','northing');
    nc{'zsmax'}.long_name=ncchar('Maximum water level output for grid over last timestep');
    nc{'zsmax'}.name = ncchar('zsmax');
    nc{'zsmax'}.units=ncchar('m');
    nc{'zsmax'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zsmin'} = ncdouble('timem','easting','northing');
    nc{'zsmin'}.long_name=ncchar('Minimum water level output for grid over last timestep');
    nc{'zsmin'}.name = ncchar('zsmin');
    nc{'zsmin'}.units=ncchar('m');
    nc{'zsmin'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zsvar'} = ncdouble('timem','easting','northing');
    nc{'zsvar'}.long_name=ncchar('Variance in water level output for grid over last timestep');
    nc{'zsvar'}.name = ncchar('zsvar');
    nc{'zsvar'}.units=ncchar('m');
    nc{'zsvar'}.FORTRAN_format=ncchar('F10.2');
return

