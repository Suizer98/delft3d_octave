% function createDUROSDocumentation()

addpath(fileparts(mfilename('fullpath')));

helpdir = 'duroshelpdocs';

%% exclude the following dirs and files
excl = {'.svn',...
    'docgen',...
    'IterationTool',...
    'Numerical_Integration',...
    'docs',...
    'html',...
    'Prob2B',...
    'Postprocessing',...
    'SensitivityAnalysis',...
    'SimpleProfile',...
    'batch',...
    'getVolume',...
    'getVolumeFast',...
    'plotVolume',...
    '_test',...
    'getG',...
    'Polygon',...
    'checkCrossShoreProfile',...
    'erosionPoint',...
    'plotDuneErosion',...
    'getRetreatDistance',...
    'findCrossings',...
    'addXvaluesExactCrossings',...
    'deshoal',...
    'recalculateDUROS',...
    'iterateWaveLength',...
    'getJARKUSProfile',...
    'testbank'};

%% main directories
maindirs =     {'F:\OpenEarthTools\matlab\applications\DUROS\',...
    'F:\McTools\matlab\applications\DUROS\'};

%% create documentation (main)
tempdir = fullfile(fileparts(mfilename('fullpath')),'temp');
OPT = struct(...
    'format','html',...
    'outputDir',tempdir,...
    'maxWidth',600,...
    'showCode',true,...
    'evalCode',true,...
    'catchError',false);
publish('getDuneErosion_doc.m',OPT);
close all
mkdir(fullfile(DUROSdocroot,helpdir,'tocpages'));
copyfile(fullfile(fileparts(mfilename('fullpath')),'TRDA.pdf'),...
    tempdir);
movefile(fullfile(tempdir,'*.*'),...
    fullfile(DUROSdocroot,helpdir,'tocpages'));
rmdir(tempdir,'s');

tbd = tbdocumentation(...
    'maindir',maindirs,...
    'exclude',excl,...
    'help_location',helpdir,...
    'templatename','simple',...
    'includesearch',false,...
    'verbose',true);

tbd.targetdir = DUROSdocroot;
tbd.name = 'DUROS+';
tbd.helpcontentmainpage = fullfile('tocpages','getDuneErosion_doc.html');

tbd.listitems(1) = tblistitem(...
    'label','Deltares website',...
    'icon','webicon',...
    'call','web http://www.deltares.nl -browser');
tbd.listitems(2) = tblistitem(...
    'label','Help',...
    'icon','book_mat',...
    'call','docsearch thisisthetempmainpage');

tbd.contentitems(1) = tbcontentitem(...
    'name','Getting started',...
    'target','tocpages\getDuneErosion_doc.html',...
    'icon','greencircleicon');
tbd.contentitems(2) = tbcontentitem(...
    'name','fcnref',...
    'target','',...
    'icon','greencircleicon');

tbd.makedocumentation;
% movefile(fullfile(DUROSdocroot,'info.xml'),fullfile(DUROSdocroot,'!info.xml'));
buildhelpjar(fullfile(DUROSdocroot,helpdir));

rmdir(fullfile(DUROSdocroot,helpdir,'backup'),'s');

builddocsearchdb(fullfile(DUROSdocroot,helpdir));