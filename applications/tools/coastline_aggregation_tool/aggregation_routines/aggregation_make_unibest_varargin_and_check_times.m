function unibest_varargin = aggregation_make_d3d_varargin_and_check_times(data)

%   Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
%       Freek Scheel
%
%       Freek.Scheel@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
% This tool is developed as part of the research cooperation between
% Deltares and the Korean Institute of Science and Technology (KIOST).
% The development is funded by the research project titled "Development
% of Coastal Erosion Control Technology (or CoMIDAS)" funded by the Korean
% Ministry of Oceans and Fisheries and the Deltares strategic research program
% Coastal and Offshore Engineering. This financial support is highly appreciated.

disp('   Checking timepoints of Unibest model files');
for ii = 1:length(data.model_files)
    tmp_unibest_data = readPRN(data.model_files{ii});
    times{ii} = tmp_unibest_data.year;
    if ii == 1
        times_s = times{ii};
        ignore_time_inds = false;
    else
        err = 0;
        if length(times{ii-1}) ~= length(times{ii})
            err = 1;
        elseif ~isempty(find((times{ii-1} == times{ii}) == 0))
            err = 1;
        end
        if err
            disp(['   WARNING: Unibest-files have different time-axes!']);
            ignore_time_inds = true;
            break
        end
    end
end

unibest_varargin = '';
if sum(strcmp(fieldnames(data),'set_model_time')) ~= 0
    if ignore_time_inds
        disp('   Ignoring data.set_model_time due to different time-axes of the Unibest models');
    elseif isempty(data.set_model_time)
        % Nothing...
    elseif isnumeric(data.set_model_time) && min(size(data.set_model_time)) == 1 && max(size(data.set_model_time)) == 2
        if data.set_model_time(1) > data.set_model_time(2)
            disp(['   ERROR: Initial time indice should be smaller than the end time indice, default [1 end] is used']);
        elseif data.set_model_time(1) < 1 || data.set_model_time(2) > length(times_s)
            disp(['   ERROR: time indices ' num2str(data.set_model_time(1)) ' and ' num2str(data.set_model_time(2)) ' are not in between 1 and ' num2str(length(times_s)) ', default [1 end] is used']);
        else
            unibest_varargin = [unibest_varargin ',''time_inds'',[' num2str(data.set_model_time(1)) ' ' num2str(data.set_model_time(2)) ']'];
            disp(['   Using Unibest time inds: ' unibest_varargin(1,max(strfind(unibest_varargin,','))+1:end)]);
        end
    elseif data.set_model_time == 1
        s = 0;
        while s == 0
            [a_s,s] = listdlg('ListString',[repmat('Year: ',length(times_s),1) num2str(times_s)],'SelectionMode','single','InitialValue',1,'Name','Select initial time','PromptString','Select start time of Unibest computation');
            if s == 0
                uiwait(warndlg('No start time selected, please try again','Warning'));
            elseif a_s == length(times_s)
                s = 0;
                uiwait(warndlg('Impossible to select last time indice, please try again','Warning'));
            end
        end
        s = 0;
        times_e = times_s(a_s+1:end);
        while s == 0
            [a_e,s] = listdlg('ListString',[repmat('Year: ',length(times_e),1) num2str(times_e)],'SelectionMode','single','InitialValue',length(times_e),'Name','Select end time','PromptString','Select end time of Unibest computation');
            if s == 0
                uiwait(warndlg('No end time selected, please try again','Warning'));
            end
        end
        unibest_varargin = [unibest_varargin ',''time_inds'',[' num2str(a_s) ' ' num2str(find(times_s == times_e(a_e))) ']'];
        disp(['   Using Unibest time inds: ' unibest_varargin(1,max(strfind(unibest_varargin,','))+1:end)]);
    else
        disp(['   Unknown input for data.set_model_time, ignoring and using time indices [1 end]'])
    end
end

% function end
end
