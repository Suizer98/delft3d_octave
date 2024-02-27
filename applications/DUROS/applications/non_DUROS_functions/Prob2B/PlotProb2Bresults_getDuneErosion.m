function PlotProb2Bresults_getDuneErosion(CaseNr, maxRD, basepath)
%PLOTPROB2BRESULTS_GETDUNEEROSION   routine to visualise Prob2B results
%
%   Routine plot the results of a Prob2B calculation and to display
%   relevant information about the settings and the design point on the
%   screen
%
%   syntax:
%   result = plotProb2Bresults(fileid, directory)
%
%   input:
%       CaseNr          =   integer corresponding to an ini file number
%       maxRD           =   Retreat distance in limit state function
%       basepath        =   directory which contains subdirectories with
%                               cases
%
%   example:
%
%
%   See also getProb2bINI
%
% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics / TU Delft 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>
% -------------------------------------------------------------

%%
if isempty(basepath)
    basepath = cd;
end

if ~strcmp(basepath(end), filesep)
    basepath(end+1) = filesep;
end
resultpath = [basepath 'Case_' num2str(CaseNr) filesep];
RESULTfname = [resultpath 'result_Case_' num2str(CaseNr,'%g') '_maxRD=' num2str(maxRD,'%g') '.asc'];
INIfname = [resultpath 'Case_' num2str(CaseNr) '.ini'];

data = load(RESULTfname);

[CaseNr, maxRD, PD50, PWL_t, PHsig_t, PTp_t, PProfileFluct, PDuration, PGust, PAccuracy, Erosion, RD] = ...
    deal(data(:,1), data(:,2), data(:,3), data(:,4), data(:,5), data(:,6), data(:,7), data(:,8), data(:,9), data(:,10), data(:,11), data(:,12)); %#ok<NASGU>


%% evaluate INI file
[str, Globals, command] = getProb2bINI(INIfname);

for i = 1 : length(str)
    eval(str{i})
end

Nrcommands = size(command); %#ok<USENS>
for i = 1 : Nrcommands(1)
    if ~isempty(command{i,1})
        eval(command{i,1})
    else
        eval(command{i,2})
    end
end

%%
calculations = (1:size(data,1))/size(data,1);
TargetVolume = -TargetVolume; %#ok<NODEF,NASGU>
variables = strread('maxRD, D50, WL_t, Hsig_t, Tp_t, ProfileFluct, Erosion, TargetVolume, RD', '%s', 'delimiter', ',');

NrFigureColumns = ceil(sqrt(length(variables)));
if NrFigureColumns*(NrFigureColumns-1)>=length(variables)
    NrFigureRows = NrFigureColumns-1;
else
    NrFigureRows = NrFigureColumns;
end

for i = 1:length(variables)
    subplot(NrFigureRows, NrFigureColumns, i)
    mu = whos('-regexp', ['mu' variables{i}]);
    if sum(size(mu)) == 2
        mu = eval(mu.name);
        if length(mu)~=length(calculations)
            mu = repmat(mu, length(calculations), 1);
        end
        if sum(mu==eval(variables{i})) ~= length(mu)
            plot(calculations, mu, 'g')
            legendtext = {['\mu_{' variables{i} '}'], variables{i}};
            hold on
        else
            legendtext = variables{i};
        end
    else
        legendtext = variables{i};
    end
    plot(calculations, eval(variables{i}))
    ylabel(variables{i})
    legend(legendtext,2)
end

fprintf('\nWL_t = %4.2f %%m\nHsig_t = %4.2f %%m\nTp_t = %4.2f %%s\nProfileFluct = %4.1f %%m^3/m\nD50 = %ge-6 %%m\n',[WL_t(end), Hsig_t(end), Tp_t(end), ProfileFluct(end), roundoff(D50(end),6)*1e6])