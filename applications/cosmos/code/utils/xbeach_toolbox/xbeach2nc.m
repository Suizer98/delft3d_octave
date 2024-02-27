function xbeach2nc(outFileRoot,dr)
% xbeach2nc.m  An M-file for writing xbeach data to netcdf for temporary 
% storage.
%
%    usage:  xbeach2nc(outFileRoot,dr);
%
%        where: outFileRoot - a string specifying the name given to the
%                              NetCDF output files, in single quotes
%                              excluding the NetCDF file extension .nc
%               dr - directory path where data files are stored
%                       (ex: 'M:\Coastal_Hazards\Xbeach\netcdf\')
%
% JLE 8/31/09
% modified 9/23/09 to include runup output
%
% Program written in Matlab Version 7.8.0.347 (R2009a)
%
% Toolbox Functions:
%   nccreate_xbeach.m
%   ncwrite_xbeach.m
% Other Required Functions:
%   getdimensions.m (m-file from Xbeach Manual p. 63)
%   readvar.m (m-file from Xbeach Manual p. 64)
%   readpoint.m (m-file from Xbeach manual p. 64)
tic

% Check inputs
if ~ischar(outFileRoot)
    error('File name should be surrounded in single quotes');
end

% Check existence of xbeach input metadata file
l = dir('params.txt');
if isempty(l)
    error('The input file params.txt does not exist in this directory');
end

% Check for existence of Xbeach global variable  and point output
dat = dir('*.dat');
dep = dir('*.dep');
if isempty(dep)
    error('The input bathymetry file does not exist in this directory')
elseif isempty(dat)
    error('The global and point variable output files do not exist in this directory')
else
    datFile = dat.name;
    depFile = dep.name;
end

% Create and define your netcdf files
if nccreate_xbeach(outFileRoot) < 0,
    error('Metadata failure in nccreate_xbeach')
end

% Load xbeach data from global variables
XBdims=getdimensions(dr);
data.tsglobal=XBdims.tsglobal;
data.x=XBdims.x;
data.y=XBdims.y;
r = readpoint('rugau001.dat',XBdims,1);
data.runup=r(:,2);
% Reshape the data arrays so that rows is time, columns is easting, and the
% 3rd dimension is northing. This time dimension differs from that in the 
% NetCDF file. 
nt=length(data.tsglobal);
nx=size(data.x,1);
ny=size(data.x,2);
zstemp=readvar('zs.dat',XBdims);
data.zs = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zs(ii,jj,kk)=zstemp(jj,kk,ii);
        end
    end
end
zbtemp=readvar('zb.dat',XBdims);
data.zb = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zb(ii,jj,kk)=zbtemp(jj,kk,ii);
        end
    end
end
Htemp=readvar('H.dat',XBdims);
data.H = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.H(ii,jj,kk)=Htemp(jj,kk,ii);
        end
    end
end
thetameantemp=readvar('thetamean.dat',XBdims);
data.thetamean = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.thetamean(ii,jj,kk)=thetameantemp(jj,kk,ii);
        end
    end
end
utemp=readvar('u.dat',XBdims);
data.u = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.u(ii,jj,kk)=utemp(jj,kk,ii);
        end
    end
end
vtemp=readvar('v.dat',XBdims);
data.v = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.v(ii,jj,kk)=vtemp(jj,kk,ii);
        end
    end
end
wetztemp=readvar('wetz.dat',XBdims);
data.wetz = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.wetz(ii,jj,kk)=wetztemp(jj,kk,ii);
        end
    end
end
 
% Get rid of old variables to preserve memory
clear zbtemp XBdims

% Read in original depth file
data.depth=load(depFile)';

% Write xbeach data to netcdf file
ncwrite_xbeach(data,outFileRoot)
