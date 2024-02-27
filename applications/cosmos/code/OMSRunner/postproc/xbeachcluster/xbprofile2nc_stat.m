function xbprofile2nc_stat(inputdir,outputdir,archivedir,mopid,tref)

% lst=dir([outputdir '*.dat']);
% k=0;
% for i=1:length(lst)
%     switch lst(i).name
%         case{'dims.dat','rugau001.dat','xy.dat','wetz.dat'}
%         otherwise
%             k=k+1;
%             datfil{k}=lst(i).name;
%             par{k}=lst(i).name(1:end-4);
%     end
% end

datfil{1}='zb.dat';
par{1}='zb';
tpar{1}='global';
ttype{1}='all';

datfil{2}='zs_mean.dat';
par{2}='zs_mean';
tpar{2}='stat';
ttype{2}='all';

datfil{3}='zs_max.dat';
par{3}='zs_max';
tpar{3}='stat';
ttype{3}='all';

datfil{4}='H_max.dat';
par{4}='H_max';
tpar{4}='stat';
ttype{4}='all';

runuppar={'runup','runup_u','runup_v','runup_xw','runup_yw','runup_xz'};

% Read boundary input
% Wave statistics from input sp2 files
% unzip([inputdir 'sp2.zip'],inputdir);
[twavbnd,Dp,Tp,Hs] = calc_wavestats(inputdir);
delete([inputdir '*.sp2']);
ntwavbnd=length(twavbnd);

% Tide time series
s=load([inputdir 'tide.txt']);
twl=tref+s(:,1)/86400;
wl=s(:,2);
ntwl=length(twl);

% Load model setup and dimension information.
XBdims=getdimensions(outputdir);

for i=1:length(datfil)
    d0.(par{i})=readvar([outputdir datfil{i}],XBdims);
    data.(par{i})=squeeze(d0.(par{i})(:,1,:));
    
%     if strcmpi(datfil{i},'zb.dat')
%         data.([par{i} '_begin'])=d0.(par{i})(:,1,1);
%         data.([par{i} '_end'])=d0.(par{i})(:,1,end);
%     else
%         if length(datfil{i})>8
%             switch(datfil{i}(end-8:end-4))
%                 case{'_max'}
%                     data.([par{i} '_max'])=max(d0.(par{i}),3);
%                 case{'_min'}
%                     data.([par{i} '_min'])=min(d0.(par{i}),3);
%                 case{'mean'}
%                     data.([par{i} '_mean'])=mean(d0.(par{i}),3);
%             end
%         end
%     end
end


ncid     = netcdf.create([archivedir mopid '.nc'],'clobber');

%% Defining dimensions

netcdf.defDim(ncid,          'x',           XBdims.nx+1);
netcdf.defDim(ncid,          'y',           XBdims.ny+1);
netcdf.defDim(ncid,          'tspoints',    XBdims.ntp);
netcdf.defDim(ncid,          'tswavbnd',    ntwavbnd);
netcdf.defDim(ncid,          'tswl',        ntwl);
netcdf.defDim(ncid,          'tsglobal',    XBdims.nt);
netcdf.defDim(ncid,          'tsmean',      XBdims.ntm);

idx  = netcdf.inqDimID(ncid,'x');
idy  = netcdf.inqDimID(ncid,'y');
idtp = netcdf.inqDimID(ncid,'tspoints');
idtwavbnd = netcdf.inqDimID(ncid,'tswavbnd');
idtwl = netcdf.inqDimID(ncid,'tswl');
idtglob = netcdf.inqDimID(ncid,'tsglobal');
idtmean = netcdf.inqDimID(ncid,'tsmean');

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
varid=netcdf.defVar(ncid,  'tspoints','int',idtp);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tswavbnd','int',idtwavbnd);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tswl','int',idtwl);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tsglobal','int',idtglob);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');
varid=netcdf.defVar(ncid,  'tsmean','int',idtmean);
netcdf.putAtt(ncid,varid,'units','seconds since 1970-1-1');

par=fieldnames(data);

% Variables
for i=1:length(par)
    tp='float';
    switch lower(tpar{i})
        case{'stat'}
            netcdf.defVar(ncid,par{i}, tp,[idx idy idtmean]);
        case{'global'}
            netcdf.defVar(ncid,par{i}, tp,[idx idy idtglob]);
    end
end

netcdf.defVar(ncid,  'sedlayer', 'float',[idx idy]);

% Run-up parameters
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
netcdf.putVar(ncid,varid,XBdims.x);
varid = netcdf.inqVarID(ncid,'y');
netcdf.putVar(ncid,varid,XBdims.y);
varid = netcdf.inqVarID(ncid,'xc');
netcdf.putVar(ncid,varid,XBdims.xc);
varid = netcdf.inqVarID(ncid,'yc');
netcdf.putVar(ncid,varid,XBdims.yc);

% Times
t0=datenum(1970,1,1);

t=(tref-t0)*86400+XBdims.tspoints;
varid = netcdf.inqVarID(ncid,'tspoints');
netcdf.putVar(ncid,varid,t);

t=(twavbnd-t0)*86400;
varid = netcdf.inqVarID(ncid,'tswavbnd');
netcdf.putVar(ncid,varid,t);

t=(twl-t0)*86400;
varid = netcdf.inqVarID(ncid,'tswl');
netcdf.putVar(ncid,varid,t);

t=(tref-t0)*86400+XBdims.tsglobal;
varid = netcdf.inqVarID(ncid,'tsglobal');
netcdf.putVar(ncid,varid,t);

t=(tref-t0)*86400+XBdims.tsmean;
varid = netcdf.inqVarID(ncid,'tsmean');
netcdf.putVar(ncid,varid,t);

% Variables
for i=1:length(par)
    p=par{i};
    varid = netcdf.inqVarID(ncid,p);
    netcdf.putVar(ncid,varid,data.(p));
end

sedlayer=load([inputdir 'sedlayer.dep']);
sedlayer=squeeze(sedlayer(1,:))';
varid = netcdf.inqVarID(ncid,'sedlayer');
netcdf.putVar(ncid,varid,sedlayer);

r = readpoint([outputdir 'rugau001.dat'],XBdims,6);

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
