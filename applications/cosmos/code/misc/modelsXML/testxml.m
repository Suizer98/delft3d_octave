clear all;close all;

hm=ReadOMSMainConfigFile;

hm=ReadModelsAndContinents(hm);

m=1;
for m=1:hm.nrModels
    UpdateModelsXML(hm,m);
end
