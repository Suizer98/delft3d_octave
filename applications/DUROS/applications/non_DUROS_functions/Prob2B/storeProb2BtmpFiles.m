function storeProb2BtmpFiles(basepath)
% STOREPROB2BTMPFILES    routine to copy temporary Prob2B files into Case folders
%
% Routine reads result files of Prob2B and saves them to the subfolder
% corresponding to the Case of concern
%
% syntax:
% storeProb2BtmpFiles(basepath)
%
% input:
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
% basepath is the path where the temporary Prob2B files are stored
getdefaults('basepath', cd, 0);

% temporary files are stored as tmp_prob2B_0001, tmp_prob2B_0002, etc.
tempFileNameBody = 'tmp_prob2B_';

% find all available temporary files in the basepath
tempfiles = dir(fullfile(basepath, [tempFileNameBody '*']));
Nrtempfiles = length(tempfiles); % number of files

% check whether files are available
if isempty(tempfiles)
    fprintf('No Prob2B temporary files found in ''%s''\n', basepath)
    return
end

for serialNr = 1:Nrtempfiles
    tempFileName = fullfile(basepath, tempfiles(serialNr).name); % file name
    result = readProb2Bresults(tempFileName); % read file
    virtCaseNr = result.results.values(strcmp(result.variable,'CaseNr')); % get Case Number
    
    [dummy CaseNr] = switchCaseNr(virtCaseNr);
    
    if virtCaseNr ~= CaseNr
        fid = fopen(tempFileName);
        str = fread(fid, '*char')';
        fclose(fid);

        str = strrep(str,...
            ['durosta	       CaseNr	 ' strrep(num2str(virtCaseNr, '%5.3E'), '+', '')],...
            ['durosta	       CaseNr	 ' strrep(num2str(CaseNr, '%5.3E'), '+', '')]);

        fid = fopen(tempFileName, 'w');
        fprintf(fid, '%s', str);
        fclose(fid);
    end
    
    maxRD = result.results.values(strcmp(result.variable,'maxRD')); % get maxRD
    if isempty(CaseNr) || isnan(CaseNr) || isempty(maxRD) || isnan(maxRD)
        continue
    end
    CaseNrstr = ['Case_' num2str(CaseNr, '%02i')];
    if maxRD == 0
        INIfname = fullfile(basepath, CaseNrstr, [CaseNrstr '.ini']); % INI-file name
        str = getProb2bINI(INIfname); % read file
        for i = 1:length(str)
            eval([str{i} ';']) % evaluate the lines of the INI-file
            if exist('maxRD', 'var') % until maxRD has been defined
                break
            end
        end
    end
    if maxRD == round(maxRD) % integer
        maxRDstr = num2str(maxRD,'%03i');
    else
        maxRDstr = num2str(maxRD,'%05.1f');
    end
    defFileName = fullfile(basepath, CaseNrstr, [CaseNrstr '_maxRD=' maxRDstr '.txt']); % new file name, including Case Number and maxRD
    [status message] = movefile(tempFileName, defFileName); % move/rename temporary file to new file
    if ~status % status = true if succeeded
        fprintf('Moving %s\nto %s\nFailed\n%s\n', tempFileName, defFileName, message); % dispay, if not succeeded
    end
end