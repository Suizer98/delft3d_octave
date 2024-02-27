function cosmos_preProcessWW3(hm,m)

model=hm.models(m);
dr=model.dir;
tmpdir=hm.tempDir;

%% Get restart file
trst1=[];
zipfilename=[dr 'restart' filesep model.waveRstFile '.zip'];
if exist(zipfilename,'file')
    trst1=model.tWaveStart;
    [success,message,messageid]=copyfile(zipfilename,tmpdir,'f');
end

%% Get nest file
if model.waveNested
%    nr=model.waveNestNr;
    mm=model.waveNestModelNr;
    outputdir=[hm.models(mm).dir 'archive' filesep 'output' filesep hm.cycStr filesep];
%    fname=[outputdir 'nest' num2str(nr) '.ww3'];
    fname=[outputdir 'nest.' model.name '.ww3'];
    if exist(fname,'file')
        [success,message,messageid]=copyfile(fname,[tmpdir 'nest.ww3'],'f');
    end
end

%% Get output locations
[nestrid,nestnames,x,y]=cosmos_getWW3outputPoints(hm,m);

%% Get start and stop times
inpfile=[hm.tempDir 'ww3_shel.inp'];
dtrst=hm.runInterval/24;

trststart=model.restartTime;

trststop=trststart;
toutstart=model.tOutputStart;
dtrst=dtrst*86400;
dt=3600;

%% Write ww3_shel.inp
cosmos_write_ww3_shell(inpfile,model.tWaveStart,toutstart,model.tStop,dt,trststart,trststop,dtrst,nestrid,x,y);

%% Write ww3_grid.inp
inpfile=[hm.tempDir 'ww3_grid.inp'];
boundary_points_file=[tmpdir model.name '.bnd'];
% Nested WW3 models
output_boundary_points_files=[];
n=0;
for i=1:hm.nrModels
    if hm.models(i).waveNested && strcmpi(hm.models(i).type,'ww3') && strcmpi(hm.models(i).waveNestModel,model.name)
        n=n+1;
        output_boundary_points_files{n}=[hm.models(i).datafolder 'nesting' filesep model.name '.nst'];
    end
end
% Obstructions
includeobstructions=0;
if exist([tmpdir model.name '.obs'],'file')
    includeobstructions=1;
end
    
cosmos_write_ww3_grid(inpfile,model,boundary_points_file,output_boundary_points_files,includeobstructions);

%% Get meteo data

meteoname=model.meteowind;
meteodir=[hm.meteofolder meteoname filesep];
fname='ww3.wnd';
xlim=model.xLim;
ylim=model.yLim;
tstart=model.tWaveStart;
tstop=model.tStop;
parameter={'u','v'};
mdl='ww3';

% Perhaps inlcude spiderweb file?
spwfile=[];
dx=[];
dy=[];
dt=60;
if ~isempty(model.meteospw)
    spwfile=[hm.meteofolder 'spiderwebs' filesep model.meteospw];
    dx=0.1;
    dy=0.1;
    dt=60; % time step in minutes
end

s=write_meteo_file(meteodir, meteoname, parameter, tmpdir, fname, xlim, ylim, tstart, tstop, 'dx',dx,'dy',dy,'dt',dt,'spwfile',spwfile,'model',mdl, ...
    'interpolationmethod','spline','dt',dt);

ww3_write_prep_inp([tmpdir 'ww3_prep.inp'],s.parameter(1).x,s.parameter(1).y,'WND');

clear s


%% Pre and post-processing input files

% % ww3_grid
% writeWW3grid([tmpdir 'ww3_grid.inp']);

tstart=model.tWaveStart;
nt=(model.tStop-tstart)*24+1;
dt=3600;

% ww3_outp

% observations points

ip0=model.nrStations;

inest=0;
if ip0>0
    % Table output (wave statistics)
    writeWW3outp([tmpdir 'ww3_outp_' model.name '.inp'],tstart,dt,nt,2,1:ip0);
    % 2D Spectra output
    writeWW3outp([tmpdir 'ww3_outp_' model.name '_sp2.inp'],tstart,dt,nt,1,1:ip0);
    inest=inest+1;
end

% 2d spectra
for i=inest+1:length(nestnames)
    np=length(x{i});
    ipoints=ip0+1:ip0+np;
    writeWW3outp([tmpdir 'ww3_outp_' nestnames{i} '.inp'],tstart,dt,nt,1,ipoints);
    ip0=ip0+np;
end

% ww3_outp
writeWW3gxoutf([tmpdir 'gx_outf.inp'],toutstart,dt,nt);

%% Make batch file
switch lower(model.runEnv)
    case{'win32'}
%         [success,message,messageid]=copyfile([hm.ww3_home 'ww3_grid.exe'],tmpdir,'f');
%         [success,message,messageid]=copyfile([hm.ww3_home 'ww3_prep.exe'],tmpdir,'f');
%         [success,message,messageid]=copyfile([hm.ww3_home 'ww3_shel.exe'],tmpdir,'f');
%         [success,message,messageid]=copyfile([hm.ww3_home 'ww3_outp.exe'],tmpdir,'f');
%         [success,message,messageid]=copyfile([hm.ww3_home 'gx_outf.exe'],tmpdir,'f');
        writeWW3batchWin32([tmpdir 'run.bat'],nestnames,datestr(model.tWaveStart,'yymmddHH'),trst1,trststart,hm.ww3_home,hm.mpi_home,hm.exeDir);
    case{'h4','h4i7'}
        writeWW3batchH4([tmpdir 'run.sh'],nestnames,datestr(model.tWaveStart,'yymmddHH'),trst1,trststart);
end
