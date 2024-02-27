function EHY_wait(time,mFile)
%% EHY_wait
% EHY_wait(time,path)
% Onces TIME is reached, this function runs the mFile
% time can be either a MATLAB datenum or datestr
%
% Example1: EHY_wait
% Example2: EHY_wait('D:\script.m','23-Mar-2018 12:00')
%
% created by Julien Groenenboom, March 2017
%% Interactive (no input argument)
if ~exist('time','var') || ~exist('mFile','var')
    disp('Select MATLAB-script to run')
    mFile = uigetfile('*.m','Select MATLAB-script to run');
    if isnumeric(mFile); disp('EHY_wait was stopped by user'); return; end
    disp('Select MATLAB-script to run')
    time = inputdlg('When would you like to execute this script? [dd-mm-yyyy HH:MM]','EHY_wait',1,{datestr(now,'dd-mm-yyyy HH:MM')});
    if isempty(time); disp('EHY_wait was stopped by user'); return; end
    time = datenum(time,'dd-mm-yyyy HH:MM');
end
%% convert time if needed
if ~isnumeric(time)
    time = EHY_datenum(time);
end

%% wait and run
[~, name, ext] = fileparts(mFile);

keepLooping = 1;
while keepLooping
    if now > time
        run(mFile)
        keepLooping=0;
    else
        disp(['Waiting until ' datestr(time) ' to run the script ''' name ext ''' - time now: ' datestr(now)]);
        pause(5)
    end
end
