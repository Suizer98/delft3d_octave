function opt=muppet_setDefaultParameterPropertiesForGUI(opt)

opt.active=1;

% M
opt.previousm=1;
opt.mtext='';
opt.mmaxtext='';
opt.selectallm=0;

% N
opt.previousn=1;
opt.ntext='';
opt.nmaxtext='';
opt.selectalln=0;

% K
opt.previousk=1;
opt.ktext='';
opt.kmaxtext='';
opt.selectallk=0;

% Times
opt.previoustimestep=1;
opt.timestepsfromlist=1;
opt.timesteptext='';
opt.tmaxtext='';
opt.showtimes=1;
opt.selectalltimes=0;
opt.timelist={''};

% Stations
opt.stations={''};
opt.stationnumber=1;
opt.previousstationnumber=1;
opt.stationfromlist=1;
opt.selectallstations=0;

% Domains
opt.domainnames={''};
opt.domainnumber=1;

% Subfields
opt.subfieldnames={''};
opt.subfieldnumber=1;

opt.previousxcoordinate='pathdistance';
