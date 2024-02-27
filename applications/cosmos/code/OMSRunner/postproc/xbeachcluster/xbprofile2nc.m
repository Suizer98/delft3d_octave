function xbprofile2nc(inputdir,outputdir,archivedir,mopid,tref)

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

% Load model setup and dimension information.
data.XBdims=getdimensions(outputdir);

for i=1:length(datfil)
    data.(par{i})=readvar([outputdir datfil{i}],data.XBdims);
end

ncid     = netcdf.create([archivedir mopid '.nc'],'clobber');
globalid = netcdf.getConstant('NC_GLOBAL');

netcdf.defDim(ncid,          'x',           data.XBdims.nx+1);
netcdf.defDim(ncid,          'y',           data.XBdims.ny+1);
netcdf.defDim(ncid,          'tsglobal',    data.XBdims.nt);
netcdf.defDim(ncid,          'tspoints',    data.XBdims.ntp);
netcdf.defDim(ncid,          'tsmean',      data.XBdims.ntm);

idx  = netcdf.inqDimID(ncid,'x');
idy  = netcdf.inqDimID(ncid,'y');
idt  = netcdf.inqDimID(ncid,'tsglobal');
idtp = netcdf.inqDimID(ncid,'tspoints');
idtm = netcdf.inqDimID(ncid,'tsmean');

varid=netcdf.defVar(ncid,  'x', 'double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'y', 'double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'xc','double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');
varid=netcdf.defVar(ncid,  'yc','double',[idx idy]);
netcdf.putAtt(ncid,varid,'units','m');

varid=netcdf.defVar(ncid,  'tsglobal','int',idt);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tsmean',  'int',idtm);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tspoints','int',idtp);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');

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

netcdf.endDef(ncid);

varid = netcdf.inqVarID(ncid,'x');
netcdf.putVar(ncid,varid,data.XBdims.x);
varid = netcdf.inqVarID(ncid,'y');
netcdf.putVar(ncid,varid,data.XBdims.y);
varid = netcdf.inqVarID(ncid,'xc');
netcdf.putVar(ncid,varid,data.XBdims.xc);
varid = netcdf.inqVarID(ncid,'yc');
netcdf.putVar(ncid,varid,data.XBdims.yc);

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

netcdf.close(ncid);
