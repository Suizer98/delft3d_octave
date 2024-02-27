function ncFiles = EHY_getListOfPartitionedNcFiles(inputFile,mergePartitionNrs)
%% ncFiles = EHY_getListOfPartitionedNcFiles(inputFile)
% This function returns a cell array with ncFiles based on a single inputFile
% Example:      ncFiles = EHY_getListOfPartitionedNcFiles(D:/NorthSea_0003_map.nc)
% returns:        ncFiles{1}  = D:/NorthSea_0000_map.nc
%                    ...
%                 ncFiles{20} = D:/NorthSea_0019_map.nc

%% get list of ncFiles

% correction for bug in DFM: *0001_0001_fou.nc / *_0012_0012_map.nc / *_0007_0007_numlimdt.xyz
if length(inputFile) > 16 && ~isempty(str2num(inputFile(end-15:end-12))) && ...
        strcmp(inputFile(end-15:end-12), inputFile(end-10:end-7))
    ncFiles = dir([inputFile(1:end-16) '*' inputFile(end-6:end)]);
    ncFilesName = regexpi({ncFiles.name},['\S{' num2str(length(ncFiles(1).name)-16) '}+\d{4}_+\d{4}_+\S{3}.nc'],'match');
else
    ncFiles = dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    ncFilesName = regexpi({ncFiles.name},['\S{' num2str(length(ncFiles(1).name)-11) '}+\d{4}_+\S{3}.nc'],'match');
end
ncFilesName = ncFilesName(~cellfun('isempty',ncFilesName));
ncFiles = strcat(fileparts(inputFile),filesep,vertcat(ncFilesName{:}));

if ischar(ncFiles)
    ncFiles = cellstr(ncFiles);
end

%% Only keep requested partition numbers
if exist('mergePartitionNrs','var') && ~isempty(mergePartitionNrs)
    deleteInd = [];
    for iF = 1:length(ncFiles)
        [~,name] = fileparts(ncFiles{iF}); 
        domainnr = str2num(name(end-7:end-4)); % domain number
        if ~ismember(domainnr,mergePartitionNrs)
            deleteInd(end+1) = iF;
        end
    end
    ncFiles(deleteInd) = [];
end
