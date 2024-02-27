function dataset=muppet_setDefaultDatasetProperties(dataset)

%% General
dataset.name='';
dataset.filename='';
dataset.filetype='';
dataset.combineddataset=0;
dataset.runid=[];
dataset.active=1;
dataset.type='';
dataset.lgafile='';

%% Data
dataset.x=[];
dataset.y=[];
dataset.z=[];
dataset.xz=[];
dataset.yz=[];
dataset.zz=[];
dataset.u=[];
dataset.v=[];
dataset.w=[];
dataset.times=[];

%% Options
dataset.xcoordinate='';
dataset.ycoordinate='';
dataset.parameter='';
dataset.ucomponent='';
dataset.vcomponent='';
dataset.m=[];
dataset.n=[];
dataset.k=[];
dataset.timestep=[];
dataset.block=[];
dataset.time=[];
dataset.station=[];
dataset.stationnumber=[];
dataset.domain=[];
dataset.subfield=[];
%dataset.plotcoordinate='pathdistance';
dataset.plotcoordinate='';
dataset.xcoordinate=[];
dataset.ycoordinate=[];
dataset.quantity='scalar';
dataset.selectedquantity='scalar';
dataset.component=[];
dataset.tc='c';
dataset.nrquantities=1;
dataset.unstructuredgrid=0;

dataset.nrdomains=0;
dataset.domains={''};
dataset.nrsubfields=0;
dataset.subfields={''};
dataset.subfieldnumber=1;

dataset.nrblocks=0;

dataset.polygonfile='';

dataset.adjustname=1;

dataset.nrquantities=1;
dataset.quantities={'scalar','vector2d','vector3d'};
dataset.selectedquantity='scalar';

dataset.selectxcoordinate=0;
dataset.selectycoordinate=0;
dataset.selectparameter=1;
dataset.selectuvcomponent=0;
dataset.selectquantity=0;
dataset.scalar_or_vector=0;
dataset.from_gui=0;

dataset.activeparameter=[];

dataset.georeferencefile='';
dataset.imagefile='';
dataset.interpolatedemonimage=0;

dataset.selectedtextnumber=1;
dataset.alltextselected=1;
dataset.annotationtext='';

dataset.coordinatesystem.name='unspecified';
dataset.coordinatesystem.type='projected';

% Free text
dataset.text='';
dataset.rotation=0;
dataset.curvature=0;

% Combined dataset
dataset.multiplya=1.0;
dataset.multiplyb=1.0;
dataset.uniformvalue=1.0;
dataset.dataseta='';
dataset.datasetb='';
dataset.operation='Add';

% Unstructured grids
dataset.G=[];

% Tide stations
dataset.tidalcomponent='M2';
dataset.tidalcomponentlist={''};
dataset.tidalcomponentset='all';
dataset.tidalparameter='amplitude';

