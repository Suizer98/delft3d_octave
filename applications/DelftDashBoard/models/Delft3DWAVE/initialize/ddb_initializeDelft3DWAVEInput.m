function handles=ddb_initializeDelft3DWAVEInput(handles,runid)

input.runid              =  runid;
input.attName            =  runid;
input.mdwfile            =  [runid '.mdw'];

%% General
input.projectname        = '';
input.projectnr          = '';
input.description1       = '';				             
input.description2       = '';				             
input.description3       = '';				             
input.description        = {'','',''};				             
input.timestep           = 10.0;
input.onlyinputverify    = 0;
input.simmode            = 'stationary';
input.dirconvention      = 'nautical';
input.referencedate      = floor(now);
input.obstaclefile       = '';
input.tseriesfile        = '';
input.timepntblock       = [];
input.timepoint          = floor(now);                             
input.waterlevel         = 0.0;                             
input.xveloc             = 0.0;                             
input.yveloc             = 0.0;                             
input.windspeed          = 0.0;                             
input.winddir            = 0.0;                             
input.dirspace           = 'circle';                                     
input.ndir               = 36;                                        
input.startdir           = 0.0;
input.enddir             = 360;                             
input.nfreq              = 24;                                         
input.freqmin            = 0.05;                             
input.freqmax            = 1.0;
input.hotfileid          = '';
input.meteofile          = '';

input.flowbedlevel=1;
input.flowwaterlevel=1;
input.flowvelocity=1;
input.flowwind=1;
input.coupling='uncoupled';
input.coupledwithflow=0;
input.useflowtexts={'No','Yes','Yes, and extend'};
input.useflowvalues=[0 1 2];
input.mdffile            = '';
%input.availableflowtimes = [];
input.nravailableflowtimes = 0;
input.activetimepoint = 1;
input.selectedtime = floor(now);
input.listtimes={datestr(input.selectedtime,'yyyy mm dd HH MM SS')};
input.listflowtimes={''};
input.waterlevelatselectedtime = 0;
input.xvelocityatselectedtime = 0;
input.yvelocityatselectedtime = 0;
input.wind = 'uniform';

input.simmodes       = {'stationary','non-stationary'};

%% Constants
input.gravity           = 9.81;
input.waterdensity      = 1000;
input.northdir          = 90;
input.minimumdepth      = 0.05;

%% Processes
input.genmodephys       = 3;                          
input.wavesetup         = 0;                                      
input.breaking          = 1;                                       
input.breakalpha        = 1.0;                             
input.breakgamma        = 0.8;                             
input.triads            = 0;                                      
input.triadsalpha       = 0.1;                             
input.triadsbeta        = 2.2;                             
input.bedfriction       = 'jonswap';
input.bedfriccoef       = 0.038;                             
input.diffraction       = 0;                                      
input.diffraccoef       = 0.2;                                           
input.diffracsteps      = 5;                                          
input.diffracprop       = 1;                                          
input.windgrowth        = 1;                                      
input.whitecapping      = 'Komen';                                          
input.quadruplets       = 1;                                      
input.refraction        = 1;                                       
input.freqshift         = 1;                                       
input.waveforces        = 'dissipation';                                       

input.includebedfriction= 1;                             
input.bedfriccoefjonswap= 0.038;                             
input.bedfriccoefcollins= 0.015;                             
input.bedfriccoefmadsen = 0.05;                             
input.bedfrictiontypestext={'JONSWAP','Collins','Madsen et al.'};
input.bedfrictiontypes={'jonswap','collins','madsen et al.'};
input.whitecappingtypes={'off','Komen','Westhuysen'};
input.whitecappingtypestext={'None','Komen','Westhuysen'};

%% Numerics
input.dirspacecdd       = 0.5;
input.freqspacecss      = 0.5;
input.rchhstm01         = 0.02;
input.rchmeanhs         = 0.02;
input.rchmeantm01       = 0.02;
input.percwet           = 98.0;
input.maxiter           = 15;            

input.order             = 'First';            

%% Output
input.testoutputlevel   = 0;    
input.tracecalls        = 0;
input.usehotfile        = 1;
input.mapwriteinterval  = 60.0;   
input.writecom          = 0;
input.comwriteinterval  = 10.0;   
input.int2keephotfile   = 0.0;  
input.appendcom         = 0;
input.locationfile      = {''};     
input.locationsets      = [];
input.locationsets=ddb_initializeDelft3DWAVELocationSet(input.locationsets,1);
input.nrlocationsets    = 0;     
input.activelocationset = 1;
input.writetable        = 0;
input.writespec1d       = 0;
input.writespec2d       = 0;

input.verify             = 0;
input.outputflowgridfile = 0;
input.outputlocations    = 0;

%% Domains
input.domains=[];
input.domains=ddb_initializeDelft3DWAVEDomain(input.domains,1);

input.gridnames={''};
input.nrgrids=0;
input.nestgrids = {''};
input.activegrids=[];

%% Boundaries
input.nrboundaries=0;
input.boundarynames={''};
input.activeboundary=1;
input.boundaries=[];
input.boundaries=ddb_initializeDelft3DWAVEBoundary(input.boundaries,1);

input.boundarydefinitions={'orientation','grid-coordinates','xy-coordinates','fromsp2file','fromwwfile'};
input.boundarydefinitionstext={'Orientation','Grid coordinates','XY coordinates','SP2 file','WW3 file'};
input.boundaryorientations={'north','northwest','west','southwest','south','southeast','east','northeast'};
input.boundaryorientationstext={'North','Northwest','West','Southwest','South','Southeast','East','Northeast'};
input.boundarydistancedirs={'clockwise','counter-clockwise'};
input.boundarydistancedirstext={'Clockwise','Counter-clockwise'};
input.boundaryspectraspecs={'fromfile','parametric'};
input.boundaryspectraspecstext={'From file','Parametric'};
input.boundaryspshapetypes={'jonswap','pierson-moskowitz','gauss'};
input.boundaryspshapetypestext={'JONSWAP','Pierson-Moskowitz','Gauss'};
input.boundaryperiodtypes={'peak','mean'};
input.boundarydirspreadtypes={'power','degrees'};

%% Obstacles
input.nrobstacles=0;
input.obstaclenames={''};
input.obstaclepolylinesfile='';
input.activeobstacle=1;
input.activeobstacles=1;
input.activeobstaclevertex=1;
input.obstacles=[];

input.obstacles=ddb_initializeDelft3DWAVEObstacle(input.obstacles,1);

input.obstacletypes={'dam','sheet'};
input.obstacletypestext={'Dam','Sheet'};

input.obstaclereflectiontypes={'no','specular','diffuse'};
input.obstaclereflectiontypestext={'No','Specular','Diffuse'};

handles.model.delft3dwave.domain=input;
