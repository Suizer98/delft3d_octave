function status = nccreate_xbeach(outFileRoot)
% nccreate_xbeach.m  A function to gather metadata and create empty netCDF 
%                     files that will store xbeach output data.   
%
%    usage:  nccreate_xbeach(outFileRoot);
%
%        where: outFileRoot - a string specifying the name given to the
%                             NetCDF output files, in single quotes
%                             excluding the NetCDF file extension .nc

% JLE 8/31/09

status = 1;

ncr = netcdf([outFileRoot,'.nc'],'clobber');

% Gather and write NetCDF metadata from the params.txt and dims.dat files
if ~isempty(dir('params.txt')) && ~isempty(dir('dims.dat'))
    disp('Reading Xbeach params.txt and dims.dat files ...') 
    [xbMeta,xbMetaDefs,xbMDim,xbMDimDefs] = get_meta_xbeach;
    write_xbeach_meta(ncr,xbMeta,xbMetaDefs,xbMDim,xbMDimDefs)
elseif isempty(dir('params.txt'))
    disp('Unable to find Xbeach params.txt file')
    status = -1;
    return
elseif isempty(dir('dims.dat'))   
    disp('Unable to find Xbeach dims.dat file')
    status = -1;
    return
end

ncr.DATA_TYPE = ncchar('Xbeach Global Parameter Output');
ncr.VAR_DESC = ncchar('tsglobal:x:y:depth:runup:zb:zs:H:thetamean:u:v');

%Define NetCDF dimensions
ncr('time') = 0;
ncr('easting') = ncr.nx(:)+1;
ncr('northing') = ncr.ny(:)+1;

% Define NetCDF variables
disp(['Defining NetCDF variables in ',outFileRoot,'.nc'])
define_xbeach_vars(ncr);

endef(ncr);
ncr=close(ncr);

return

% --------- Subfunction: Gather Xbeach configuration data ------------- %
function [xbMeta,xbMetaDefs,xbMDim,xbMDimDefs] = get_meta_xbeach

% Read dimensions from xbeach output file and save.
% (XBeach manual p. 63 describes definitions)
fid = fopen('dims.dat','r');
xbMDimDefs{1,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{2,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{3,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{4,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{5,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{6,1} = num2str(fread(fid,[1],'double'));
xbMDimDefs{7,1} = num2str(fread(fid,[1],'double'));
fclose(fid)
xbMDim{1,1} = 'nt';
xbMDim{2,1} = 'nx';
xbMDim{3,1} = 'ny';
xbMDim{4,1} = 'ngd';
xbMDim{5,1} = 'nd';
xbMDim{6,1} = 'ntp';
xbMDim{7,1} = 'ntm';

% Gather user-defined model parameters
disp(' ')
disp('Reading Xbeach params.txt file ...')
configFile ='params.txt';
ind = 1;
fid = fopen(configFile,'r');
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
        if str2num(theFieldDef)
            nc.(theField) = str2num(theFieldDef);
        else
            nc.(theField) = theFieldDef;
        end
    end
    
    for a=1:length(xbMDim)
        theField = xbMDim{a};
        theFieldDef = xbMDimDefs{a};
        if str2num(theFieldDef) 
            nc.XBDim.(theField) = str2num(theFieldDef);
        else
            nc.XBDim.(theField) = theFieldDef;
        end
    end
        
return

% --------- Subfunction: Define NetCDF variables ------------------------ %
function define_xbeach_vars(nc)
    
    nc{'tsglobal'} = nclong('time'); 
    nc{'tsglobal'}.FORTRAN_format = ncchar('F10.2');
    nc{'tsglobal'}.units = ncchar('seconds');
    nc{'tsglobal'}.type = ncchar('UNEVEN');
    
    nc{'x'} = ncdouble('easting','northing');
    nc{'x'}.long_name=ncchar('x-coordinates grid (m)');
    nc{'x'}.name = ncchar('x');
    nc{'x'}.units=ncchar('m');
    nc{'x'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'y'} = ncdouble('easting','northing');
    nc{'y'}.long_name=ncchar('y-coordinates grid (m)');
    nc{'y'}.name = ncchar('y');
    nc{'y'}.units=ncchar('m');
    nc{'y'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'depth'} = ncdouble('easting','northing');
    nc{'depth'}.long_name=ncchar('Depth (m)');
    nc{'depth'}.name = ncchar('depth');
    nc{'depth'}.units=ncchar('m');
    nc{'depth'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'runup'} = ncfloat('time'); 
    nc{'runup'}.FORTRAN_format = ncchar('F10.4');
    nc{'runup'}.units = ncchar('m');
    nc{'runup'}.type = ncchar('UNEVEN');

    nc{'zb'} = ncdouble('time','easting','northing');
    nc{'zb'}.long_name=ncchar('Bed Level (m)');
    nc{'zb'}.name = ncchar('zb');
    nc{'zb'}.units=ncchar('m');
    nc{'zb'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'zs'} = ncdouble('time','easting','northing');
    nc{'zs'}.long_name=ncchar('Water Level (m)');
    nc{'zs'}.name = ncchar('zs');
    nc{'zs'}.units=ncchar('m');
    nc{'zs'}.FORTRAN_format=ncchar('F10.2');

    nc{'H'} = ncdouble('time','easting','northing');
    nc{'H'}.long_name=ncchar('Wave height (m)');
    nc{'H'}.name = ncchar('H');
    nc{'H'}.units=ncchar('m');
    nc{'H'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'thetamean'} = ncdouble('time','easting','northing');
    nc{'thetamean'}.long_name=ncchar('Mean wave angle (rad)');
    nc{'thetamean'}.name = ncchar('thetamean');
    nc{'thetamean'}.units=ncchar('rad');
    nc{'thetamean'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'u'} = ncdouble('time','easting','northing');
    nc{'u'}.long_name=ncchar('(GLM) x-velocity cell centre');
    nc{'u'}.name = ncchar('u');
    nc{'u'}.units=ncchar('m/s');
    nc{'u'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'v'} = ncdouble('time','easting','northing');
    nc{'v'}.long_name=ncchar('(GLM) y-velocity cell centre');
    nc{'v'}.name = ncchar('v');
    nc{'v'}.units=ncchar('m/s');
    nc{'v'}.FORTRAN_format=ncchar('F10.2');
    
    nc{'wetz'} = ncdouble('time','easting','northing');
    nc{'wetz'}.long_name=ncchar('mask wet/dry eta points');
    nc{'wetz'}.name = ncchar('v');
    nc{'wetz'}.units=ncchar('-');
    nc{'wetz'}.FORTRAN_format=ncchar('F10.2');
    
return

