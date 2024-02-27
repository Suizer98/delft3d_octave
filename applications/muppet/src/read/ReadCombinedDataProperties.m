function [CombinedDatasetProperties,iword,noset]=ReadCombinedDatasetProperties(txt);
 
% READ DATASETS FROM SESSION FILE
 
i=1;
end_datasets = false;
noset=0;

CombinedDatasetProperties(1).Name='';
 
while end_datasets==0
 
    end_dataset = false;
 
    while and(end_dataset==0,end_datasets==0)
 
        switch lower(txt{i}),
            case {'combineddataset'},
 
                noset=noset+1;
                CombinedDatasetProperties(noset).Name=txt{i+1};
                CombinedDatasetProperties(noset).UnifOpt=0;
                CombinedDatasetProperties(noset).UniformValue=0;
                CombinedDatasetProperties(noset).DatasetB.Name='';
                CombinedDatasetProperties(noset).DatasetB.Multiply=0;
 
            case {'operation'},
                CombinedDatasetProperties(noset).Operation=txt{i+1};
            case {'uniformvalue'},
                CombinedDatasetProperties(noset).UniformValue=str2num(txt{i+1});
                CombinedDatasetProperties(noset).UnifOpt=1;
            case {'dataseta'},
                CombinedDatasetProperties(noset).DatasetA.Name=txt{i+1};
            case {'multiplya'},
                CombinedDatasetProperties(noset).DatasetA.Multiply=str2num(txt{i+1});
            case {'datasetb'},
                CombinedDatasetProperties(noset).DatasetB.Name=txt{i+1};
            case {'multiplyb'},
                CombinedDatasetProperties(noset).DatasetB.Multiply=str2num(txt{i+1});
 
        end
 
        end_dataset=strcmp(lower(txt{i}),'endcombineddataset');
        
        stopdatasets={'figure'};

        end_datasets=strcmp(lower(txt{i}),stopdatasets);
 
        i=i+1;
 
    end
 
end

iword=i-1;
