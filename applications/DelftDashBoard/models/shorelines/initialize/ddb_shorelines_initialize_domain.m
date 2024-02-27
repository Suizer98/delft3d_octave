function handles=ddb_shorelines_initialize_domain(handles)

handles.model.shorelines.domain=[];

handles.model.shorelines.domain.runid='tst';

handles.model.shorelines.domain.handle=[];
handles.model.shorelines.domain.x_mc=[];
handles.model.shorelines.domain.y_mc=[];
handles.model.shorelines.domain.ds0=100;
handles.model.shorelines.domain.d=10;

yearnow=datevec(now);
yearnow(2:6)=[1,1,0,0,0];
handles.model.shorelines.domain.tref=datenum(yearnow);
handles.model.shorelines.domain.timenum0=now; 
handles.model.shorelines.domain.tend=now+365;

handles.model.shorelines.wave_opt='mean_and_spreading';
handles.model.shorelines.domain.Hso=1.;
handles.model.shorelines.domain.tper=7;
handles.model.shorelines.domain.phiw0=270;
handles.model.shorelines.domain.spread=60;

handles.model.shorelines.domain.WVCfile='';                                                              % wave time-series <-leave empty to use wave parameters ('S.Hso', 'S.phiw0' and 'S.spread')
handles.model.shorelines.domain.Waveclimfile='';                                                         % wave climate file
handles.model.shorelines.domain.wavefile='';
handles.model.shorelines.wavetrans_opt='none';
handles.model.shorelines.domain.ddeep=30;
handles.model.shorelines.domain.dnearshore=8;
handles.model.shorelines.domain.phif=[];
handles.model.shorelines.domain.surf_width_w=500;

handles.model.shorelines.domain.trform='CERC';
handles.model.shorelines.domain.b=1.e6;
handles.model.shorelines.domain.qscal=1;
handles.model.shorelines.domain.d50=.2e-3;
handles.model.shorelines.domain.porosity=0.4;
handles.model.shorelines.domain.tanbeta=0.03;
handles.model.shorelines.domain.Pswell=20;
handles.model.shorelines.domain.rhow=1025;
handles.model.shorelines.domain.rhos=2650;
handles.model.shorelines.domain.alpha=1.8;
handles.model.shorelines.domain.gamma=0.72;

handles.model.shorelines.spit_opt='off';
handles.model.shorelines.domain.spit_width=200;
handles.model.shorelines.domain.spit_headwidth=200;
handles.model.shorelines.domain.OWscale=0.1;
handles.model.shorelines.domain.Dsf=handles.model.shorelines.domain.d*0.8;
handles.model.shorelines.domain.Dsb=1*handles.model.shorelines.domain.Dsf;
handles.model.shorelines.domain.Bheight=2;
handles.model.shorelines.channel_opt='off';
handles.model.shorelines.domain.channel_width=500;
handles.model.shorelines.domain.channel_fac=0.08;
handles.model.shorelines.domain.tc=0.9;
handles.model.shorelines.domain.smoothfac=0.01;

handles.model.shorelines.nrshorelines=0;
handles.model.shorelines.activeshoreline=1;
handles.model.shorelines.shorelinenames={''};
handles.model.shorelines.domain.LDBcoastline='';
handles.model.shorelines.shorelines=[];
handles.model.shorelines.shorelines(1).name='';
handles.model.shorelines.shorelines(1).x=[];
handles.model.shorelines.shorelines(1).y=[];
handles.model.shorelines.shorelines(1).length=[];
handles.model.shorelines.newshoreline.handle=[];

handles.model.shorelines.nrstructures=0;
handles.model.shorelines.activestructure=1;
handles.model.shorelines.structurenames={''};
handles.model.shorelines.domain.LDBstructures='';
handles.model.shorelines.structures=[];
handles.model.shorelines.structures(1).name='';
handles.model.shorelines.structures(1).x=[];
handles.model.shorelines.structures(1).y=[];
handles.model.shorelines.structures(1).length=[];
handles.model.shorelines.structures(1).transmission=[];

handles.model.shorelines.nrnourishments=0;
handles.model.shorelines.activenourishment=1;
handles.model.shorelines.nourishmentnames={''};
handles.model.shorelines.domain.LDBnourish='';
handles.model.shorelines.nourishments=[];
handles.model.shorelines.nourishments(1).name='';
handles.model.shorelines.nourishments(1).x=[];
handles.model.shorelines.nourishments(1).y=[];
handles.model.shorelines.nourishments(1).length=[];
handles.model.shorelines.nourishments(1).transmission=[];
handles.model.shorelines.nourishments(1).tstart=datenum(floor(now));
handles.model.shorelines.nourishments(1).tend=datenum(floor(now))+61;
handles.model.shorelines.nourishments(1).volume=[];
handles.model.shorelines.nourishments(1).rate=[];
handles.model.shorelines.nourishments(1).nourlength=[];

handles.model.shorelines.nrchannels=0;
handles.model.shorelines.activechannel=1;
handles.model.shorelines.channelnames={''};
handles.model.shorelines.domain.LDBchannel='';
handles.model.shorelines.channels=[];
handles.model.shorelines.channels(1).name='';
handles.model.shorelines.channels(1).x=[];
handles.model.shorelines.channels(1).y=[];
handles.model.shorelines.channels(1).length=[];
handles.model.shorelines.channels(1).channel_width=[];
handles.model.shorelines.channels(1).channel_fac=[];


