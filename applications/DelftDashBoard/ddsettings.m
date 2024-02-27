disp(' ');
disp('You can start DelftDashBoard by typing ddb or DelftDashBoard in the Matlab command prompt.');
disp(' ');
disp('First time users are recommended to change the data directory. Simply copy the data folder');
disp('to another directory (on a disk with plenty of space), and change the path in delftdashboard.ini.')
disp('This data folder is used to cache bathymetry and shoreline data, as well as a number of other utilities,');
disp('and it can become very large (several gigabytes).');
disp(' ');
disp('When code changes are committed, please do NOT commit cached data as well!');
disp(' ');
disp('Have fun using DelftDashBoard!');
disp('Maarten van Ormondt (Maarten.vanOrmondt@deltares.nl)');
disp(' ');

% basePath=fileparts(which('ddsettings.m'));
% 
% subDirs={...
%     'general'
%     'main'
%     'models'
%     'toolboxes'
%     'utils'
%     };
% 
% totalPath=[];
% 
% for ii=1:length(subDirs)
%     pp=genpath([basePath filesep subDirs{ii}]);
%     pp=strread(strrep(pp,';',char(13)),'%s');
%     pp(~cellfun('isempty',regexp(pp,'\.svn')))=[];
%     pp(~cellfun('isempty',regexp(pp,'mex\\V')))=[];
%     
%     pp=[pp repmat({';'},size(pp,1),1)];
%     pp=pp';
%     totalPath=[totalPath [pp{:}]];
% end
% 
% addpath(totalPath);
% 
% %Add appropriate V* dir
% verDir=strrep(version,'.','');
% addpath([basePath filesep 'general' filesep 'mex' filesep 'V' verDir(1:2)]);
% 
% % SuperTrans
% 
% addpath(genpath('..\..\..\SuperTrans'));
% addpath(genpath('..\..\io\netcdf\'));
% addpath(genpath('..\matlab\'));
% 
% netcdf_settings('quiet',false) % in /io/netcdf/

run('../../oetsettings');
