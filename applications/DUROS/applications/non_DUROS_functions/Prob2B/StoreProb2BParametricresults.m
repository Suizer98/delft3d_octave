function StoreProb2BParametricresults(CaseNrs, basepath)
% STOREPROB2BPARAMETRICRESULTS routine to save summary of Prob2B results
%
% Routine reads result files of Prob2B and saves for each Case a summary of
% the results, containing the retreat distances and corresponding
% probabilities of failure, as well as the log-interpolated values for the
% powers of 10 within the range of the results
%
% syntax:
% StoreProb2BParametricresults(CaseNrs, basepath)
%
% input:
% CaseNrs  = series of Case numbers
% basepath = string containing the path where the temporary Prob2B files
%            have been stored
%
% example:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C. (Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%%
% basepath is the main path, various cases are stored in subdirs of the basepath
getdefaults('basepath', cd, 0);

for CaseNr = CaseNrs
    CaseNrstr = ['Case_' num2str(CaseNr, '%02i')];
    INIfname = fullfile(basepath, CaseNrstr, [CaseNrstr '.ini']);
    str = getProb2bINI(INIfname, 'all'); % read INI-file of case including comments
    spaceslocs = find(isspace(str{1})); % find spaces in first line of INI-file
    searchstr = strtrim(str{1}(spaceslocs(end-1):spaceslocs(end))); % read sensitivity analysis variable
    for i = 1:length(str)
        try %#ok<TRYNC>
            eval(str{i}) % evaluate each line
        end
        if exist(searchstr, 'var')
            break % until sensitivity analysis variable has been defined
        end
    end
    fid = fopen(fullfile(basepath, CaseNrstr, ['results_' CaseNrstr '.txt']), 'w'); % create results file
    % write Case info, sensitivity analysis variable including value
    fprintf(fid, '%s\n%%%s = %e\n%%%5s%15s%5s\n', str{1}, searchstr, eval(searchstr), 'maxRD', 'P_f', 'id');
    % find Case files
    casefiles = dir(fullfile(basepath, CaseNrstr, [CaseNrstr '_maxRD=*.txt']));
    Nrcasefiles = length(casefiles); % Number of Case files
    fprintf('\nCase number : %i\n', CaseNr) % display Case number on the screen
    if Nrcasefiles>0
        for i = 1:Nrcasefiles
            FileName = fullfile(basepath, CaseNrstr, casefiles(i).name); % file name Prob2B file
            result = readProb2Bresults(FileName); % read file
            P_f(i) = result.results.P_f; %#ok<AGROW> % get probability of failure
            maxRD = result.results.values(strcmp(result.variable,'maxRD')); % get maxRD
            if maxRD ~= 0 % if maxRD is predefined
                maxRDs(i) = maxRD;
            else % otherwise, read maxRD from INI-file
                str = getProb2bINI(INIfname); % read file
                for j = 1:length(str)
                    eval([str{j} ';']) % evaluate the lines of the INI-file
                    if exist('maxRD', 'var') % until maxRD has been defined
                        break
                    end
                end
                maxRDs(i) = maxRD; % add current maxRD to series of maxRDs
                clear maxRD
            end

            fprintf(fid, '%6.1f%15e%5i\n', maxRDs(i), P_f(i), 1); % write maxRD, P_f and 1 (means that this is a primary result)
        end
        fprintf(fid, '%%%s\n', 'Interpolated values');
        exponents = unique(ceil(log10(P_f))); % get exponents of probabilities of failure of primary results
        exponents = exponents(1:end-1); % omit the largest exponent
        for i = 1:length(exponents) % for al exponents
            RDs(i) = interp1(log(P_f), maxRDs, eval(['log(1e' num2str(exponents(i)) ')'])); %#ok<AGROW> % log-interpolate corresponding maxRD
            fprintf(fid, '%6.1f%15e%5i\n', RDs(i), eval(['1e' num2str(exponents(i))]), 2); % write maxRD, P_f and 2 (means that this is a secondary result)
        end
        clear RDs maxRDs P_f
        fclose(fid);
    end
    eval(['clear ' searchstr])
end