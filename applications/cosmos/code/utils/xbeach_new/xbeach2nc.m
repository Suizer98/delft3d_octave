function xbeach2nc(inputdir,outputdir,mopid)
% xbeach2nc.m  An M-file for writing xbeach data to netcdf for temporary 
% storage.
%
%    usage:  xbeach2nc(inputdir,outputdir,mopid,starttime);
%
%        where: inputdir - directory path where input data files are stored
%                       (ex: 'M:\Coastal_Hazards\Xbeach\netcdf\');
%               outputdir - directory path where netcdf output files are
%                       stored (ex: ''M:\Coastal_Hazards\Xbeach\netcdf\');
%               mopid - MOP profile ID which is used to name netcdf file with
%                       .nc extension (ex: 3401);
%               starttime - the start time of the model run as a Matlab
%                           datenumber (ex:     )
%
% JLE 8/31/09
% modified 9/23/09 to include runup output
% modified 11/10/09 for final bulk xbeach run setup
%
% Program written in Matlab Version 7.8.0.347 (R2009a)
%
% Toolbox Functions:
%   nccreate_xbeach.m
%   ncwrite_xbeach.m
% Other Required Functions:
%   getdimensions.m (m-file from Xbeach Manual p. 63 modified by R. McCall)
%   readvar.m (m-file from Xbeach Manual p. 64 modified by R. McCall)
%   readpoint.m (m-file from Xbeach manual p. 64 modified by R. McCall)
tic

% Check for existence of xbeach input metadata file in the input directory
l = dir([inputdir,'params.txt']);
if isempty(l)
    error('The input file params.txt does not exist in the input directory');
end

% Check for existence of Xbeach global variable and point output in the
% input directory
dat = dir([outputdir,'*.dat']);
dep = dir([inputdir,'*.dep']);
%inp = dir([inputdir,'*.inp']);
if isempty(dep)
    error('The input bathymetry file does not exist in this directory')
elseif isempty(dat)
    error('The global and point variable output files do not exist in this directory')
% elseif isempty(inp)
%     error('Input sediment distribution files do not exist in this directory')
else
    depFile = dep.name;
end

% Create and define your netcdf files
if nccreate_xbeach(inputdir,outputdir,mopid) < 0,
    error('Metadata failure in nccreate_xbeach')
end

%__________________________________________________________________________
% Load model setup and dimension information.
data.XBdims=getdimensions(outputdir);

% Create global and mean timeseries from input start time in julian day.
%[yr,mon,day,hr,min,sec] = datevec(starttime);

% for ii=1:length(data.XBdims.tsglobal)
%     tsglobal(ii) = julian([yr,mon,day,hr,min,sec+data.XBdims.tsglobal(ii)]);
% end
%data.timeg=tsglobal;
data.timeg=data.XBdims.tsglobal;

% for ii=1:length(data.XBdims.tsmean)
%     tsmean(ii) = julian([yr,mon,day,hr,min,sec+data.XBdims.tsmean(ii)]);
% end
% data.timem=tsmean;
data.timem=data.XBdims.tsmean;
clear tsmean tsglobal

% Read in original depth file
data.depth=load([inputdir,depFile])';
data.depth=data.depth(:,1);
% Read in sediment distribution files
data.sedlayer=load([inputdir,'sedlayer.dep'])';
data.sedlayer=data.sedlayer(:,1);
%data.gdist2=load([inputdir,'gdist2.inp'])';

% Load runup data
r = readpoint([outputdir,'rugau001.dat'],data.XBdims,6);
rtime=r(:,1);
% for ii=1:length(rtime)
%     runup_time(ii) = julian([yr,mon,day,hr,min,sec+rtime(ii)]);
% end
format('longg')
%data.runup_time=runup_time;
data.runup_time=rtime;
data.runup=r(:,2);
data.runup_u=r(:,3);
data.runup_v=r(:,4);
data.runup_xw=r(:,5);
data.runup_yw=r(:,6);
data.runup_xz=r(:,7);
%clear r runup_time
clear r 

% Load global variable data
zstemp=readvar([outputdir,'zs.dat'],data.XBdims);
zbtemp=readvar([outputdir,'zb.dat'],data.XBdims);
%wetztemp=readvar([inputdir,'wetz.dat'],data.XBdims);

% Reshape the global variable data arrays so that rows is time, columns is 
% easting, and the 3rd dimension is northing. This time dimension differs 
% from that in the NetCDF file. 
nt=data.XBdims.nt;
nx=data.XBdims.nx+1;
ny=data.XBdims.ny+1;
data.zs = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zs(ii,jj,kk)=zstemp(jj,kk,ii);
        end
    end
end
data.zb = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zb(ii,jj,kk)=zbtemp(jj,kk,ii);
        end
    end
end
% data.wetz = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.wetz(ii,jj,kk)=wetztemp(jj,kk,ii);
%         end
%     end
% end
clear zbtemp zstemp nt

% Load mean variable data
Hmeantemp=readvar([outputdir,'H_mean.dat'],data.XBdims);
Hmintemp=readvar([outputdir,'H_min.dat'],data.XBdims);
Hmaxtemp=readvar([outputdir,'H_max.dat'],data.XBdims);
Hvartemp=readvar([outputdir,'H_var.dat'],data.XBdims);
thetameantemp=readvar([outputdir,'thetamean_mean.dat'],data.XBdims);
thetamintemp=readvar([outputdir,'thetamean_min.dat'],data.XBdims);
thetamaxtemp=readvar([outputdir,'thetamean_max.dat'],data.XBdims);
thetavartemp=readvar([outputdir,'thetamean_var.dat'],data.XBdims);
% umeantemp=readvar([outputdir,'u_mean.dat'],data.XBdims);
% umintemp=readvar([outputdir,'u_min.dat'],data.XBdims);
% umaxtemp=readvar([outputdir,'u_max.dat'],data.XBdims);
% uvartemp=readvar([outputdir,'u_var.dat'],data.XBdims);
% vmeantemp=readvar([outputdir,'v_mean.dat'],data.XBdims);
% vmintemp=readvar([outputdir,'v_min.dat'],data.XBdims);
% vmaxtemp=readvar([outputdir,'v_max.dat'],data.XBdims);
% vvartemp=readvar([outputdir,'v_var.dat'],data.XBdims);
DRmeantemp=readvar([outputdir,'DR_mean.dat'],data.XBdims);
DRmintemp=readvar([outputdir,'DR_min.dat'],data.XBdims);
DRmaxtemp=readvar([outputdir,'DR_max.dat'],data.XBdims);
DRvartemp=readvar([outputdir,'DR_var.dat'],data.XBdims);
zsmeantemp=readvar([outputdir,'zs_mean.dat'],data.XBdims);
zsmintemp=readvar([outputdir,'zs_min.dat'],data.XBdims);
zsmaxtemp=readvar([outputdir,'zs_max.dat'],data.XBdims);
zsvartemp=readvar([outputdir,'zs_var.dat'],data.XBdims);

% Reshape the mean variable data arrays so that rows is time, columns is 
% easting, and the 3rd dimension is northing. This time dimension differs 
% from that in the NetCDF file. 
nt=data.XBdims.ntm;
data.Hmean = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.Hmean(ii,jj,kk)=Hmeantemp(jj,kk,ii);
        end
    end
end
data.Hmin = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.Hmin(ii,jj,kk)=Hmintemp(jj,kk,ii);
        end
    end
end
data.Hmax = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.Hmax(ii,jj,kk)=Hmaxtemp(jj,kk,ii);
        end
    end
end
data.Hvar = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.Hvar(ii,jj,kk)=Hvartemp(jj,kk,ii);
        end
    end
end
clear Hmeantemp Hmintemp Hmaxtemp Hvartemp
data.thetamean = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.thetamean(ii,jj,kk)=thetameantemp(jj,kk,ii);
        end
    end
end
data.thetamin = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.thetamin(ii,jj,kk)=thetamintemp(jj,kk,ii);
        end
    end
end
data.thetamax = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.thetamax(ii,jj,kk)=thetamaxtemp(jj,kk,ii);
        end
    end
end
data.thetavar = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.thetavar(ii,jj,kk)=thetavartemp(jj,kk,ii);
        end
    end
end
clear thetameantemp thetamaxtemp thetamintemp thetavartemp
data.umean = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.umean(ii,jj,kk)=umeantemp(jj,kk,ii);
%         end
%     end
% end
data.umin = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.umin(ii,jj,kk)=umintemp(jj,kk,ii);
%         end
%     end
% end
data.umax = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.umax(ii,jj,kk)=umaxtemp(jj,kk,ii);
%         end
%     end
% end
data.uvar = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.uvar(ii,jj,kk)=uvartemp(jj,kk,ii);
%         end
%     end
% end
clear umeantemp umintemp umaxtemp uvartemp
data.vmean = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.vmean(ii,jj,kk)=vmeantemp(jj,kk,ii);
%         end
%     end
% end
data.vmin = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.vmin(ii,jj,kk)=vmintemp(jj,kk,ii);
%         end
%     end
% end
data.vmax = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.vmax(ii,jj,kk)=vmaxtemp(jj,kk,ii);
%         end
%     end
% end
data.vvar = nan(nt,nx,ny);
% for ii=1:nt
%     for jj=1:nx
%         for kk=1:ny
%             data.vvar(ii,jj,kk)=vvartemp(jj,kk,ii);
%         end
%     end
% end
clear vmeantemp vmintemp vmaxtemp vvartemp
data.DRmean = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.DRmean(ii,jj,kk)=DRmeantemp(jj,kk,ii);
        end
    end
end
data.DRmin = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.DRmin(ii,jj,kk)=DRmintemp(jj,kk,ii);
        end
    end
end
data.DRmax = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.DRmax(ii,jj,kk)=DRmaxtemp(jj,kk,ii);
        end
    end
end
data.DRvar = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.DRvar(ii,jj,kk)=DRvartemp(jj,kk,ii);
        end
    end
end
clear DRmeantemp DRmintemp DRmaxtemp DRvartemp
data.zsmean = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zsmean(ii,jj,kk)=zsmeantemp(jj,kk,ii);
        end
    end
end
data.zsmin = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zsmin(ii,jj,kk)=zsmintemp(jj,kk,ii);
        end
    end
end
data.zsmax = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zsmax(ii,jj,kk)=zsmaxtemp(jj,kk,ii);
        end
    end
end
data.zsvar = nan(nt,nx,ny);
for ii=1:nt
    for jj=1:nx
        for kk=1:ny
            data.zsvar(ii,jj,kk)=zsvartemp(jj,kk,ii);
        end
    end
end
%__________________________________________________________________________

% Write xbeach data to netcdf file
ncwrite_xbeach(data,outputdir,mopid)
