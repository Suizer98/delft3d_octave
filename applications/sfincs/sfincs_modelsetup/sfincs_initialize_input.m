function inp=sfincs_initialize_input

inp.mmax=0;
inp.nmax=0;
inp.dx=10;
inp.dy=10;
inp.x0=0;
inp.y0=0;
inp.rotation=0;
inp.latitude=0;
inp.tref=floor(now);
inp.tstart=floor(now);
inp.tstop=floor(now+1);
inp.tspinup=60;
inp.t0out=inp.tstart;
inp.dtmapout=600;
inp.dthisout=600;
inp.dtmaxout=0;
inp.dtwnd=1800;
inp.alpha=0.75;
inp.theta=0.90;
inp.huthresh=0.01;
inp.manning=0.04;
inp.manning_land=0.04;
inp.manning_sea=0.02;
inp.rgh_lev_land=0;
inp.zsini=0;
inp.qinf=0;
inp.igperiod=''; %120;
inp.rhoa=1.25;
inp.rhow=1024;
inp.dtmax=60;
inp.maxlev=999.0;
inp.bndtype=1;
inp.advection=0;
inp.baro=0;
inp.pavbnd=0;
inp.gapres=101200;
inp.advlim=9999.9;
inp.stopdepth=100;

% inp.depfile='sfincs.dep';
% inp.mskfile='sfincs.msk';
% inp.geomskfile='sfincs.gms';
% inp.indexfile='sfincs.ind';
% inp.cstfile='sfincs.cst';
% inp.bndfile='sfincs.bnd';
% inp.bzsfile='sfincs.bzs';
% inp.bzifile='';
% inp.bwvfile='sfincs.bwv';
% inp.bhsfile='sfincs.bhs';
% inp.btpfile='sfincs.btp';
% inp.bwdfile='sfincs.bwd';
% inp.srcfile='';
% inp.disfile='';
% inp.hmaxfile='hmax.dat';
% inp.hmaxgeofile='hmaxgeo.dat';
% inp.zsfile='zs.dat';
% inp.vmaxfile='';
% inp.spwfile='';
% inp.wndfile='';
% inp.precipfile='';
% inp.obsfile='';

inp.depfile='';
inp.mskfile='';
inp.indexfile='';
inp.cstfile='';
inp.bndfile='';
inp.bzsfile='';
inp.bzifile='';
inp.bwvfile='';
inp.bhsfile='';
inp.btpfile='';
inp.bwdfile='';
inp.srcfile='';
inp.disfile='';
inp.inifile='';
inp.sbgfile='';

inp.spwfile='';
inp.amufile='';
inp.amvfile='';
inp.amprfile='';
inp.wndfile='';
inp.precipfile='';
inp.obsfile='';
inp.crsfile='';
inp.thdfile='';
inp.manningfile='';

inp.inputformat='bin';
inp.outputformat='bin';

inp.cdnrb=3;
inp.cdwnd=[0 28 50];
inp.cdval=[0.001 0.0025 0.0015];

