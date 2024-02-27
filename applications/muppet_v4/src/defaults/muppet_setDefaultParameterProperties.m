function opt=muppet_setDefaultParameterProperties(opt)

% Store information about dimensions of different parameters

%opt.name='';
opt.datatype='unknown';
opt.active=1;

opt.dimflag=[0 0 0 0 0];
opt.size=[0 0 0 0 0];

opt.times=[];

opt.stations={''};

opt.nrdomains=0;
opt.domains={''};

opt.nrsubfields=0;
opt.subfields={''};

opt.timename='time';
opt.xname='x';
opt.yname='y';
opt.zname='z';
opt.valname='val';
opt.uname='u';
opt.vname='v';
opt.wname='w';
opt.uamplitudename='amplitude_u';
opt.vamplitudename='amplitude_v';
opt.uphasename='phase_u';
opt.vphasename='phase_v';

opt.location='';
