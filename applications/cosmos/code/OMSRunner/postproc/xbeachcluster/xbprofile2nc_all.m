function xbprofile2nc_all(inputdir,outputdir,archivedir,mopid,tref)

lst=dir([outputdir '*.dat']);
k=0;
for i=1:length(lst)
    switch lst(i).name
        case{'dims.dat','rugau001.dat','xy.dat','wetz.dat'}
        otherwise
            k=k+1;
            datfil{k}=lst(i).name;
            par{k}=lst(i).name(1:end-4);
    end
end

runuppar={'runup','runup_u','runup_v','runup_xw','runup_yw','runup_xz'};

% Read boundary input
% Wave statistics from input sp2 files
[twavbnd,Dp,Tp,Hs] = calc_wavestats(inputdir);
ntwavbnd=length(twavbnd);
% Tide time series
s=load([inputdir 'tide.txt']);
%s3.parameter='Water level';
twl=tref+s(:,1)/86400;
wl=s(:,2);
ntwl=length(twl);
% fname=[dr 'wl.' profile '.mat'];
% save(fname,'-struct','s3','Name','Parameter','Time','Val');




% Load model setup and dimension information.
data.XBdims=getdimensions(outputdir);

for i=1:length(datfil)
    data.(par{i})=readvar([outputdir datfil{i}],data.XBdims);
end

ncid     = netcdf.create([archivedir mopid '.nc'],'clobber');
globalid = netcdf.getConstant('NC_GLOBAL');


%% Defining dimensions

netcdf.defDim(ncid,          'x',           data.XBdims.nx+1);
netcdf.defDim(ncid,          'y',           data.XBdims.ny+1);
netcdf.defDim(ncid,          'tsglobal',    data.XBdims.nt);
netcdf.defDim(ncid,          'tspoints',    data.XBdims.ntp);
netcdf.defDim(ncid,          'tsmean',      data.XBdims.ntm);
netcdf.defDim(ncid,          'tswavbnd',    ntwavbnd);
netcdf.defDim(ncid,          'tswl',        ntwl);

idx  = netcdf.inqDimID(ncid,'x');
idy  = netcdf.inqDimID(ncid,'y');
idt  = netcdf.inqDimID(ncid,'tsglobal');
idtp = netcdf.inqDimID(ncid,'tspoints');
idtm = netcdf.inqDimID(ncid,'tsmean');
idtwavbnd = netcdf.inqDimID(ncid,'tswavbnd');
idtwl = netcdf.inqDimID(ncid,'tswl');

%% Defining variables
% Horizontal coordinates
varid=netcdf.defVar(ncid,  'x', 'double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'y', 'double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'xc','double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'yc','double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');

% Times
varid=netcdf.defVar(ncid,  'tsglobal','int',idt);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tsmean',  'int',idtm);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tspoints','int',idtp);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tswavbnd','int',idtwavbnd);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tswl','int',idtwl);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');

% Variables
for i=1:length(par)
    tp='float';
    if size(data.(par{i}),3)==data.XBdims.nt
        netcdf.defVar(ncid,  par{i}, tp,[idx idy idt]);
    else
        netcdf.defVar(ncid,  par{i}, tp,[idx idy idtm]);
    end
end
netcdf.defVar(ncid,  'sedlayer', 'float',[idx idy]);
netcdf.defVar(ncid,  'wetz', 'int',[idx idy idt]);

for i=1:length(runuppar)
    switch lower(runuppar{i})
        case{'runup_xw','runup_yw'}
            tp='double';
        otherwise
            tp='float';
    end
    netcdf.defVar(ncid,  runuppar{i}, tp,idtp);
end

% Boundary data
netcdf.defVar(ncid,  'hs', 'float',idtwavbnd);
netcdf.defVar(ncid,  'tp', 'float',idtwavbnd);
netcdf.defVar(ncid,  'wavdir', 'float',idtwavbnd);
netcdf.defVar(ncid,  'wl', 'float',idtwl);

netcdf.endDef(ncid);

%% Settings variables
% Horizontal coordinates
varid = netcdf.inqVarID(ncid,'x');
netcdf.putVar(ncid,varid,data.XBdims.x);
varid = netcdf.inqVarID(ncid,'y');
netcdf.putVar(ncid,varid,data.XBdims.y);
varid = netcdf.inqVarID(ncid,'xc');
netcdf.putVar(ncid,varid,data.XBdims.xc);
varid = netcdf.inqVarID(ncid,'yc');
netcdf.putVar(ncid,varid,data.XBdims.yc);

% Times
t0=datenum(1970,1,1);

t=(tref-t0)*86400+data.XBdims.tsglobal;
varid = netcdf.inqVarID(ncid,'tsglobal');
netcdf.putVar(ncid,varid,t);

t=(tref-t0)*86400+data.XBdims.tsmean;
varid = netcdf.inqVarID(ncid,'tsmean');
netcdf.putVar(ncid,varid,t);

t=(tref-t0)*86400+data.XBdims.tspoints;
varid = netcdf.inqVarID(ncid,'tspoints');
netcdf.putVar(ncid,varid,t);

t=(twavbnd-t0)*86400;
varid = netcdf.inqVarID(ncid,'tswavbnd');
netcdf.putVar(ncid,varid,t);

t=(twl-t0)*86400;
varid = netcdf.inqVarID(ncid,'tswl');
netcdf.putVar(ncid,varid,t);

% Variables
for i=1:length(par)
    varid = netcdf.inqVarID(ncid,par{i});
    netcdf.putVar(ncid,varid,data.(par{i}));
end

sedlayer=load([inputdir 'sedlayer.dep']);
sedlayer=squeeze(sedlayer(1,:))';
varid = netcdf.inqVarID(ncid,'sedlayer');
netcdf.putVar(ncid,varid,sedlayer);

wetz=readvar([outputdir 'wetz.dat'],data.XBdims,'2D');
varid = netcdf.inqVarID(ncid,'wetz');
netcdf.putVar(ncid,varid,wetz);

r = readpoint([outputdir 'rugau001.dat'],data.XBdims,6);

for i=1:length(runuppar)
    varid = netcdf.inqVarID(ncid,runuppar{i});
    netcdf.putVar(ncid,varid,squeeze(r(:,i+1)));
end

% Boundary data
varid = netcdf.inqVarID(ncid,'hs');
netcdf.putVar(ncid,varid,Hs);
varid = netcdf.inqVarID(ncid,'tp');
netcdf.putVar(ncid,varid,Tp);
varid = netcdf.inqVarID(ncid,'wavdir');
netcdf.putVar(ncid,varid,Dp);
varid = netcdf.inqVarID(ncid,'wl');
netcdf.putVar(ncid,varid,wl);

netcdf.close(ncid);
