function addDesignpointInfo(CaseNrs, basepath)
% ADDDESIGNPOINTINFO routine to write designpoint info in ini-file
%
% Routine reads summary result files of Prob2B and writes the 1e-5 retreat
% distance to the ini-file (or the smallest probability of failure)
%
% syntax:
% addDesignpointInfo(CaseNrs, basepath)
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

%%
for CaseNr = CaseNrs
    CaseNrstr = ['Case_' num2str(CaseNr, '%02i')];
    INIfname = fullfile(basepath, CaseNrstr, [CaseNrstr '.ini']);
    str = getProb2bINI(INIfname, 'all'); % read INI-file of case including comments
    id2 = find(~cellfun(@isempty, strfind(str, 'maxRD'))); % line where maxRD is defined

    ResultFileName = fullfile(basepath, CaseNrstr, ['results_' CaseNrstr '.txt']); % file name containing summary of results
    resultsdata = load(ResultFileName); % get summary of results
    resultsdata = resultsdata(resultsdata(:,3)==2,1:2); % get secondary results (P_f being powers of 10)
    id = resultsdata(:,2) == 1e-5; % find P_f = 1e-5
    if all(id == false) % P_f = 1e-5 not available
        id = 1; % choose smallest available probability of failure
    end
    [maxRD, P_f] = deal(resultsdata(id,1), resultsdata(id,2));
    
    str{id2-1} = sprintf('%% %3.1e retreat distance', P_f);
    str{id2} = sprintf('maxRD = %.1f; %% [m] (last update: %s)', maxRD, datestr(now));
    
    permission = 'w';
    fid = fopen(INIfname, permission);
    % write first part of file
    for i = 1:length(str)
        if i > 1 && strncmp(str{i}, '%', 1)
            % white space before comment lines (except the first line)
            fprintf(fid, '\n');
        end
        fprintf(fid, '%s\n', str{i});
    end
    fclose(fid);
    
    % display summary on the screen
    fprintf('%i %3.1e  %.1f\n', CaseNr, P_f, maxRD);
end
    