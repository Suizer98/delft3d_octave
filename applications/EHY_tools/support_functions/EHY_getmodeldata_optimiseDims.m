function [dims,start,count] = EHY_getmodeldata_optimiseDims(dims)

start = ones(1,numel(dims));
count = [dims.size];

% optimise dims before applying ncread
% examples:
%                input:          result:
% wanted index:  [3 4 5 6]       [1 2 3 4]
% start       :  1               3
% count       :  no_stations     4
%
% wanted index:  [4 10 8 11]     [1 7 5 8]
% start       :  1               4
% count       :  no_stations     8

for iD = 1:length(dims)
    minIndex = min(dims(iD).index);
    maxIndex = max(dims(iD).index);
    difIndex = maxIndex - minIndex;
    
    dims(iD).index = dims(iD).index - minIndex + 1;
    start(iD) = minIndex;
    count(iD) = difIndex +1; % +1 to include start and end of wanted indices
end
