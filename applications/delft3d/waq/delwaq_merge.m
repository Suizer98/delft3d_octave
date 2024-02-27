function structOut = delwaq_merge(varargin)
%DELWAQ_MERGE Merges different Delwaq files
%
%   Struct = DELWAQ_MERGE(FileName,File1,File2,...,FileN)
%   Merges different Delwaq files and write one file. 
%   <FileName> is the name of the file where the information will be
%   storage. 
%
%   NOTE: The merge in <FileName> only will without matchig of
%   substances/segments/stations/times in the files. DELWAQ_MERGE asumes
%   that all the files have the same substances/segments/stations
%   This script is usefull to merge in one file different delwaq runs of
%   the same model
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_DIFF, 
%             DELWAQ_INTERSECT


%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jun-13 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

nfile = length(varargin);
copyfile(varargin{2}, varargin{1}) 

% Opening varargin
for ifile = 1:nfile
    struct1{ifile} = delwaq('open',varargin{ifile}); %#ok<AGROW>
end

% Setting time reference
structOut = struct1{1} ;

for ifile = 3:nfile
    
    for it = 1:struct1{ifile}.NTimes
        disp(['delwaq_merge progress:' num2str(it) '/' num2str(struct1{ifile}.NTimes)])
        
        % Reading data
        [time data] = delwaq('read',struct1{ifile},0,0,it);
        
        % Writing a File
        structOut = delwaq('write',structOut,time,data);
    end

end