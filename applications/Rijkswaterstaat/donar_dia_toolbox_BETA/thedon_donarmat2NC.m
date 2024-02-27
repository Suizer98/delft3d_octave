function thedon_dia2donarmat(OPT)
%thedon_donarmat2NC  Transform mat file to netCDF-CF, loop wrapper for donar_donarMat2nc
%
% Read the data from the matlab file and produce a netCDF-CF file.
% The structure is organized by observed parameter. 
% thedon_dia2donarmat is a wrapper for donar_donarMat2nc
%
%See also: donar_donarMat2nc

OPT.diadir = 'p:\1204561-noordzee\data\raw\RWS\';
OPT.diadir = 'p:\1209005-eutrotracks\raw\CTD\mat\';

%% The location of the donar mat files

diafiles  = findAllFiles(OPT.diadir,'pattern_incl','*the_compend.mat');
nfile     = length(diafiles);

for ifile = 1:1:nfile
        
%% Load the Information

        disp(['Loading: ', diafiles{ifile}]);
        thecompend  = importdata([diafiles{ifile}]);
        
%% Folder for Saving

        the_filename = [diafiles{ifile}(1:max(strfind(diafiles{ifile},'_the_compend.mat'))-1)]
        
%% Produce the NetCDF File

        donar_donarMat2nc(thecompend,the_filename);

%% It turns out that this memory might be necessary for the next iteration. 
        
        clear thecompend;

end