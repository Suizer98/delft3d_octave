function hm=cosmos_readParameters(hm)

hm.parameters=xml2struct([hm.dataDir filesep 'parameters' filesep 'parameters.xml']);
