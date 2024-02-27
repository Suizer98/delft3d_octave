function createBatchResult(inputfilename)
%
% cd f:\mctools\mc_toolbox;mcsettings internet
% fclose all; createBatchResult('P:\UCIT\UCIT_Projects\Projecten\H 5016 13 Kustplaatsen New2\13 Kustplaatsen new.txt', 'batchresults.txt')
%
% -------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, March 2008 (Version 1.0, March 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

if nargin == 0
    close all; clc
    cd f:\mctools\mc_toolbox;mcsettings internet
    fclose all;
    inputfilename  = 'p:\ucit\UCIT_Projects\Projecten\H 5016 13 Kustplaatsen New rule\H 5016 13 Kustplaatsen New6\largediffs.txt';
end

if nargin == 0
    DuneErosionSettings('set',...
        'AdditionalErosionMax',true,...             % can be used to turn on / off boundary limitation of the additional erosion to 15 meters
        'ChannelSlopes',false,...                   % can be used to turn on / off boundary limitation due to steep (channel) slopes
        'PreventLandwardTransport',false,...        % can be used to turn on / off volume correction for landward directed sediment transport
        'AutoStrengthening',false,...               % can be used to turn on / off automated strenghtening of a landward profile part
        'DuneBreachCalculation',false,...           % can be used to turn on / off secondary calculations after a first dune row has been breached
        'TargetVolume','min([-20,.25*Volume])');    % can be used to set the formulation to use for Volume T
end

%% get raw input
if ~exist('inputfilename', 'var')
    inputfilename = getFileName(cd, 'txt', [], 2);
end

workdir = fileparts(inputfilename);

n_d = 1; %#ok<NASGU> % scale factor

data  = load(inputfilename); %#ok<NASGU>
% data2 = load('F:\McTools\batchresults.comparison');

%% prepare inputvariables to be used in dune erosion calculation
rawinputvariables = strread('SoundingID, AreaCode, TransectID, cM, WL_t, Hsig_t, Tp_t, D50, dummy, Norm, Scen', '%s', 'delimiter', ',');
for i = 1:length(rawinputvariables)
    eval([rawinputvariables{i} ' = data(:,' num2str(i) ');'])
end

%% initialise batch results
% print used default settings to batch resultfile
prepareBatchResults(workdir, 'batchresults.txt')
prepareBatchReports(workdir, 'batchreport.txt')

%% perform duneerosion calculations
for id =  1:size(data,1)
    fun         = 'getDuneErosion'; %#ok<NASGU>
    DataType    = 'Jarkus Data';
    Area        = rws_kustvak(AreaCode(id));

    d           = readTransectData(DataType, Area, num2str(TransectID(id),'%05i'), num2str(SoundingID(id)));

    xInitial    = d.xe(~isnan(d.ze)); %#ok<NASGU> %keep only the points with non-NaN z-values
    zInitial    = d.ze(~isnan(d.ze)); %#ok<NASGU> %keep only the points with non-NaN z-values

    inputVariables = getInputVariables(fun);
    inputstring = 'xInitial, zInitial, ';
    for i = 3:length(inputVariables) - 1
        inputstring = [inputstring inputVariables{i} '(' num2str(id) '), ']; %#ok<AGROW>
    end
    inputstring = [inputstring inputVariables{length(inputVariables)} '(' num2str(id) ')'];
    try
        % get dune erosion by string evaluation
        clear result
        result = eval([fun '(' inputstring ');']);
        
        try
            close(gcf)
        end
        
        % plotDuneErosion(result, WL_t(id), 1)
        % title(['Transect: ' d.transectID ' - Year: ' d.soundingID])
        % printFigure(1,inputfilename)
        
        % process and store results
        result2batchresults(workdir, 'batchresults.txt', d, result, cM(id),WL_t(id),Hsig_t(id),Tp_t(id), Norm(id), Scen(id))
        result2batchreports(workdir, 'batchreport.txt', d, result)
    catch
        id
    end
end