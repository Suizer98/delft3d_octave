function outputDir = EHY_getOutputDirFM(filename)
%% outputDir = EHY_getOutputDirFM(filename)
%
% This function returns the output directory of a FM simulation
% based on a filename/rundirectory.
%
% Example1: 	outputDir = EHY_getOutputDirFM('D:\run01\')
% Example2: 	outputDir = EHY_getOutputDirFM('D:\run01\r01.mdu')
%
% returns either:                                  'D:\run01\DFM_OUTPUT_r01\'
% or when 'OutputDir' is specified in .mdu-file:   'D:\run01\<mdu.output.OutputDir>\'
%               
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
mdFile=EHY_getMdFile(filename);
modelType=EHY_getModelType(mdFile);
if strcmp(modelType,'dfm')
    mdu = dflowfm_io_mdu('read',mdFile);
    if isempty(mdu.output.OutputDir)
        [~,runid]=fileparts(mdFile);
        outputDir = [fileparts(mdFile) filesep 'DFM_OUTPUT_' runid filesep];
    else
        outputDir = [fileparts(mdFile) filesep mdu.output.OutputDir filesep];
    end
end

