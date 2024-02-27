function [DataProperties,NrAvailableDatasets,CombinedDatasetProperties]=mp_combineDatasets(DataProperties,NrAvailableDatasets,CombinedDatasetProperties,NrCombinedDatasets)
 
for i=1:NrCombinedDatasets
    NrAvailableDatasets=NrAvailableDatasets+1;
    DataProperties=mp_combineDataset(DataProperties,CombinedDatasetProperties,NrAvailableDatasets,i);
end
