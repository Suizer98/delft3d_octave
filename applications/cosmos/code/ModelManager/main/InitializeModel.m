function hm=InitializeModel(hm,i)

hm.models(i).nrStations=0;
hm.models(i).Abbr='';
hm.models(i).runid='';
hm.models(i).Location=[0 0];
hm.models(i).continent='northamerica';
hm.models(i).size=1;
hm.models(i).mapSize=[0 0];
hm.models(i).pixLoc=[0 0];
hm.models(i).xLim=[0 0];
hm.models(i).yLim=[0 0];
hm.models(i).priority=1;
hm.models(i).nestModel=[];
hm.models(i).nested=0;                
hm.models(i).spinUp=2;
hm.models(i).runTime=48;
hm.models(i).timeStep=5;
hm.models(i).mapTimeStep=360;
hm.models(i).hisTimeStep=10;
hm.models(i).comTimeStep=0;
hm.models(i).nrStations=0;

