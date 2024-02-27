%DELWAQ_CONC Concatenate different Delwaq files and write one file.
%
%   Struct = DELWAQ_CONC(FileName,File1,File2,...,FileN)
%   Concatenate different Delwaq files and write one file. 
%   <FileName> is the name of the file where the information will be
%   storage. 
%   FileName is empty then the name will be CONCATENATE.(MAP/HIS)
%
%   NOTE: The Concatenation in <FileName> only will be for the matchig of
%   substances/segments/stations/times in all files. If double exist a
%   double record then only the last record will be taked into account

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-11 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function structOut = delwaq_conc(varargin)

Files = {varargin{2:end}};
nfile = nargin-1;
S = delwaq_intersect(Files{:});

% Matching Subs
if isempty(S.Subs)
   disp('There is no match in the substance');
   return 
end

% Matching Segm
if isempty(S.Segm)
   disp('There is no match in the segments');
   return 
end


if isempty(varargin{1})
   FileName = ['CONCATENATE' '.' S.extId];
else
   FileName = varargin{1};
end
   

% Header
Header = {'Concatenation:'};
Header = char(Header);

% Opening Files
for ifile = 1:nfile
    struct1{ifile} = delwaq('open',Files{ifile}); %#ok<AGROW>
end

% Setting time reference
T0 = S.T0;
refTime =  [T0 1];    

for it = 1:S.nUTime
    disp(['delwaq_conc progress:' num2str(it) '/' num2str(S.nUTime)])
    
    ist = S.iUFile(it);
    
    [time1 data1] = delwaq('read',struct1{ist},S.iSubs{ist},S.iSegm{ist},S.iUTime(it));

    % Writing a File
    switch S.extId
        case 'map'                
            if it == 1
                structOut = delwaq('write',FileName,Header,S.Subs,refTime,time1,data1);
            else
                structOut = delwaq('write',structOut,time1,data1);
            end
            
        case 'his'
            if it == 1
               structOut = delwaq('write',FileName,Header,S.Subs,S.Segm,refTime,time1,data1);
            else
               structOut = delwaq('write',structOut,time1,data1);
            end
    end

end