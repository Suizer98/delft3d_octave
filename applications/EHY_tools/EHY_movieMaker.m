function EHY_movieMaker(imageDir,varargin)
%% EHY_movieMaker(varargin)
%
% This functions makes a .avi file based on a folder
% with images. Make sure the filenames are in ascending order.

% Example1: EHY_movieMaker
% Example2: EHY_movieMaker('D:\pngFiles\')
% Example3: EHY_movieMaker('D:\pngFiles\','outputFile','D:\animation.avi','frameRate',3)
% Example4: EHY_movieMaker('D:\pngFiles\','outputFile','D:\animation.avi','frameRate',3,'quality',90)

% created by Julien Groenenboom, June 2018
%% OPT
if nargin == 0
    EHY_movieMaker_interactive;
    return
else
    OPT.outputFile = [imageDir filesep 'EHY_movieMaker_OUTPUT' filesep 'movie.avi'];
    OPT.frameRate  = 4;
    OPT.quality    = []; % see https://nl.mathworks.com/help/matlab/ref/videowriter.html
    OPT.profile    = 'Motion JPEG AVI'; % see options in VideoWriter.m
    OPT            = setproperty(OPT,varargin);
end

%% Let the extension be determined by profile / VideoWriter (to avoid *.avi.mp4)
[pathstr, name] = fileparts(OPT.outputFile);
OPT.outputFile = [pathstr filesep name];

%% images 2 movie
if contains(imageDir,'*') && (contains(imageDir,'.png') || contains(imageDir,'.png'))
    imageFiles = dir(imageDir);
else
    imageFiles = [dir([imageDir filesep '*.png']),...
        dir([imageDir filesep '*.jpg'])];
end

if isempty(imageFiles)
    if isnumeric(filename); disp('EHY_convert stopped by user.'); return; end
end
% str2num
if ischar(OPT.frameRate); OPT.frameRate=str2num(OPT.frameRate); end
if ischar(OPT.quality); OPT.quality=str2num(OPT.quality); end

%create output directory
if ~exist(fileparts(OPT.outputFile),'dir')
    mkdir(fileparts(OPT.outputFile))
end

writerObj = VideoWriter(OPT.outputFile,OPT.profile);
writerObj.FrameRate = OPT.frameRate;
if ~isempty(OPT.quality)
    writerObj.Quality = OPT.quality;
end
open(writerObj);

for iF = 1:length(imageFiles)
    disp(['progress: ' num2str(iF) '/' num2str(length(imageFiles))]);
    thisimage = imread([imageFiles(iF).folder filesep imageFiles(iF).name]);
    writeVideo(writerObj, thisimage);
end
close(writerObj);
disp(['EHY_movieMaker created:' newline OPT.outputFile])
disp('If the resolution of the images is too large, you might not be able to play the video.')

end

%% EHY_movieMaker_interactive
function EHY_movieMaker_interactive
% get imageDir
disp('Open a directory containing images (.png / .jpg)')
imageDir=uigetdir('*.*','Open a directory containing images (.png / .jpg)');
if isnumeric(imageDir); disp('EHY_movieMaker stopped by user.'); return; end

% get OPT.frameRate
answer=inputdlg('Frame rate in frames per seconde (fps):','Frame rate',1,{'4'});
if isempty(answer); disp('EHY_movieMaker stopped by user.'); return; end
OPT.frameRate=str2num(answer{1});

% get OPT.quality
answer=inputdlg('Quality of animation (0-100), better quality also means larger filesize:','Quality',1,{'75'});
if isempty(answer); disp('EHY_movieMaker stopped by user.'); return; end
OPT.quality=str2num(answer{1});

%
disp('start writing the screenplay')
disp('start making the movie')
EHY_movieMaker(imageDir,OPT);

disp([newline 'Note that next time you want to make this movie, you can also use:'])
disp(['<strong>EHY_movieMaker(''' imageDir ''',''frameRate'',' num2str(OPT.frameRate) ',''quality'',' num2str(OPT.quality) ');</strong>'])
end