function inp=hurrywave_initialize_input

inp.mmax=0;
inp.nmax=0;
inp.dx=10;
inp.dy=10;
inp.x0=0;
inp.y0=0;
inp.rotation=0;
inp.crs_name = 'WGS 84';
inp.crs_type = 'geographic';
inp.tref=floor(now);
inp.tstart=floor(now);
inp.tstop=floor(now+1);
inp.dt=300;
inp.tspinup=60;
inp.t0out=inp.tstart;
inp.dtmapout=600;
inp.dthisout=600;
inp.dtmaxout=999999;
inp.dtsp2out=0;
inp.dtwnd=1800;
inp.spinup_meteo   = 0;

inp.rhoa=1.25;
inp.rhow=1024;
%inp.dtmax=999;
inp.dmx1           = 0.2;
inp.dmx2           = 1e-05;
inp.freqmin        = 0.04;
inp.freqmax        = 0.5;
inp.nsigma         = 12;
inp.ntheta         = 36;
inp.gammajsp       = 3.3;
inp.quadruplets    = 0;

inp.depfile='';
inp.mskfile='';
inp.indexfile='';
inp.bndfile='';
inp.bhsfile='';
inp.btpfile='';
inp.bwdfile='';
inp.bdsfile='';
inp.spwfile='';
inp.amufile='';
inp.amvfile='';
inp.wndfile='';
inp.obsfile='';
inp.ospfile='';

inp.inputformat='bin';
inp.outputformat='net';

%cdnrb          = 3
%cdwnd          = 0  28  50
%cdval          = 0.001      0.0025      0.0015

%inp.cdnrb=3;
%inp.cdwnd=[0 28 50];
%inp.cdval=[0.001 0.0025 0.0015];
