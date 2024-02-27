function [results inputs] = getSensitivity(fhandle, variable2vary, values2vary, varargin)
%GETSENSITIVITY     routine to carry out a sensitivity analysis
%
% This routine returns the 'results' of a calculation using the
% 'values2vary' of variable 'variable2vary' and keeping the other variables
% constant. The basic situation should be given in varargin. The calculation
% uses function 'fhandle'.
%
% Syntax:        results = getSensitivity(fhandle, variable2vary,
%                                   values2vary, varargin)
%
% Input: 
%         fhandle        = string containing a function name
%         variable2vary  = string containing the name of the variable 
%                               to investigate
%         values2vary    = series of values of variable 'variableName'
%         varargin       = input variables of the function fhandle
%
% Output:       Eventual output is stored in a cell results and the
%               different inputs (for each run) are collected in inputs
%
%   See also getSensitivity_test, getDuneErosion_DUROS
% 
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 2.0, May 2008 (Version 1.0, February 2008)
% By:           <C.(Kees) den Heijer (email: Kees.denHeijer@deltares.nl)>                                                            
% --------------------------------------------------------------------------

%% check input
[fhandle fl] = checkfhandle(fhandle);
if ~fl
    error('GETSENSITIVITY:NoValidFunction', ['Function ' char(fhandle) ' could not be found']);
end

%% create commandstring: line to be evaluated for each of the 'values'
inputVariables = getInputVariables(fhandle);
outputVariables = getOutputVariables(fhandle);

varID2vary = find(strcmp(inputVariables, variable2vary));
if isempty(varID2vary)
    error('GETSENSITIVITY:UnknownVar2vary', ['Variable ' char(variable2vary) ' is unknown']);
end

%% create output string to fill the results cell in the right way
outstr = '[';
for i = 1:length(outputVariables)
    outstr = [outstr 'results{i,' num2str(i) '} ']; %#ok<AGROW>
end
outstr(end) = ']';

%% calculate the result values for each of the values
inputs = cell(length(values2vary), 1); % preallocate inputs
results = cell(length(values2vary), length(outputVariables)); % preallocate results
for i = 1 : length(values2vary)
    varargin{varID2vary} = values2vary(i);
    inputs{i} = varargin;
    eval([outstr '= feval(fhandle, varargin{:});'])
end