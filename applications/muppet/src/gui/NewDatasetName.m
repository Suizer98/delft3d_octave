function i=NewDatasetName(DataProperties,NrAvailableDatasets,name)
 
i=1;
for j=1:NrAvailableDatasets
    if strcmp(DataProperties(j).Name,name)
        i=0;
    end
end
