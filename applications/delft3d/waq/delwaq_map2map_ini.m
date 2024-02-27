function delwaq_map2map_ini(map_files,varargin)
% Want to copy and use large delwaq map files for your model hot-/restarts?
% Use this script to only copy the required field data for the specific
% time-point of your hot-/restart.
%
% Syntax:
%
% delwaq_map2map_ini(map_files,<keyword,value>)
% 
% REQUIRED INPUT VARIABLE:
%
% map_files      Cellstring of map-files to consider, incl. or excluding
%                complete paths. Can also be a single line charcter string
%                when considering only 1 file. When left empty ('') a
%                dialog will appear to select *.map files.
%
%                Examples:
%                (1) ''
%                (2) 'D:/tmp/tmp.map'
%                (3) {'tmp.map','D:/tmp/run.map'}
%                (4) files (from tmp=dir('*.map'); files={tmp.name}';)
% 
% OPTIONAL INPUT <KEYWORD,VALUE> PAIRS:
% 
% time           This <keyword,value> is used to specify the time at which
%                the hotstart is specified. This can either be a matlab
%                datenum or the string 'end', the latter is default. When
%                specifying 'end', the last timestep of each *.map file
%                is used, when using a matlab datenum, the specified
%                date and time is used (when available in the *.map
%                files, else an error is thrown).
%
%                Examples:
%                (1) 'end'
%                (2) datenum(2015,4,25,18,0,0)
%                (3) 730486
%
% num_of_subs    This <keyword,value> pair allows you to only export the
%                substances (and not other requested output variables that
%                are stored in the *.map file) to the new file by setting
%                number of substances. This is actually required if you
%                want to restart while using additional output fields. The
%                number of substances can be found in the substances model
%                input file (required to run your Delwaq model in the first
%                place). When left empty, all data is transferred to the
%                new file (and if no additional output was requested within
%                the *.map file, this is also sufficient to restart from)
%
% output_folder  This <keyword,value> is used to specify the output folder
%                in which the generated *.map files are stored. By
%                default, this is the working directory (pwd), but can be
%                changed by specifying the location in a single line
%                charcter string.
%
%                Examples:
%                (1) 'D:/tmp/hotstart_run/'
%                (2) [pwd filesep 'hotstart_run']
%
% add_text       This <keyword,value> is used to specify the additional text
%                used when naming new files, default, this is '_res'. This 
%                would for instance create a tmp_new.map from the file
%                tmp.map. If you wish to keep the original filenames,
%                simply specify add_text as ''. Do note that this could
%                overwrite existing files if not considering the
%                output_folder keyword, but this is checked for.
%
%                Examples:
%                (1) ''
%                (2) '_new'
%
%
% OUPUT VARIABLES:
%
% Not considered
%
%________________________________________________________________________
%
%Contact Freek Scheel (freek.scheel@deltares.nl) if bugs are encountered
%              
%See also: delwaq

%   --------------------------------------------------------------------
%       Freek Scheel
%       +31(0)88 335 8241
%       <freek.scheel@deltares.nl>;
%
%       Developed as part of the TO27 project at the Water Institute of the
%       Gulf, Baton Rouge, Louisiana. Please do not make any functional
%       changes to this script, as it is relied upon within this modelling
%       framework.
%
%       Please contact me if errors occur.
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Default keywords:
%

OPT.time          = 'end';
OPT.output_folder = pwd;
OPT.add_text      = '_res';
OPT.num_of_subs   = [];

OPT = setproperty(OPT,varargin);

%% Check all the input:
%

%_____________________________________________
% map_files checks and modifications:
if isstr(map_files)
    if size(map_files,1) > 1
        error('Expected single line character input for trim-file location')
    else
        if strcmp(map_files,'')
            % Will be using the dialog
        else
            % We now have [N,1] cellstr, with N = 1:
            map_files = {map_files};
        end
    end
elseif iscellstr(map_files)
    % Make sure we have a [N,1] cellstr regardless of input:
    map_files = map_files(:);
else
    disp('Unknown input specified for map files, please use the dialog instead..');
    map_files = '';
    % Will be using the dialog
end

if isstr(map_files) && strcmp(map_files,'')
    [FILENAME, PATHNAME] = uigetfile('*.map','','','MultiSelect','on');
    if isnumeric(FILENAME)
        disp('Aborted by user')
        return
    end
    if isstr(FILENAME)
        map_files           = cellstr([PATHNAME FILENAME]);
    elseif iscellstr(FILENAME)
        map_files           = cellstr([repmat(PATHNAME,size(FILENAME,2),1) char(FILENAME')]);
    else
        error('Unknown error, code 43574363, contact the developer')
    end
else
    % Map files already specified, make sure all the paths are added as well:
    for ii=1:size(map_files,1)
        if isempty(strfind(map_files{ii,1},filesep))
            % No folder yet:
            map_files{ii,1} = [pwd filesep map_files{ii,1}];
        end
    end
end

% Now we also just want the names without the folders:
for ii=1:size(map_files,1)
    map_files_name_only{ii,1} = map_files{ii,1}(1,max(strfind(map_files{ii,1},filesep))+1:end);
end

if length(unique(map_files)) ~= length(map_files)
    error('Double files were found, please remove these...');
end

for ii=1:size(map_files,1)
    if exist(map_files{ii,1},'file') ~= 2
        error(['Map file does not exist: ' map_files{ii,1}]);
    end
end

%_____________________________________________
% OPT.num_of_subs checks and modifications:
if isnumeric(OPT.num_of_subs)
    if min(size(OPT.num_of_subs) == [0,0]) == 1
        % empty, fine
    elseif min(size(OPT.num_of_subs) == [1,1]) == 1
        % a single value, do a check:
        if OPT.num_of_subs <= 0
            error('Please specify a positive value for the number of substances')
        end
        if round(OPT.num_of_subs) ~= OPT.num_of_subs
            error('Please specify the number of substances as an interger (whole) value')
        end
    else
        error('Please specify a single value for the number of substances')
    end
else
    error('Please specify a single value for the number of substances')
end

%_____________________________________________
% OPT.time checks and modifications:
if isstr(OPT.time)
    if ~strcmp(OPT.time,'end')
        disp('Unknown string for time, set to end')
        OPT.time = 'end';
    end
elseif isnumeric(OPT.time)
    if min(size(OPT.time) == [1,1]) == 1
        % One value specified:
        OPT.time = repmat(OPT.time,size(map_files,1),1);
        disp(['Using map-file hotstart time: ' datestr(OPT.time(1,1))])
    elseif min(size(OPT.time)) == 1 && max(size(OPT.time)) == size(map_files,1)
        % Multiple values specified in correct format
        OPT.time = OPT.time(:);
        if length(unique(OPT.time))>1
            disp(['NOTE: Using various (different) map-file hotstart times!'])
        else
            disp(['Using unique map-file hotstart time for all files: ' datestr(OPT.time(1,1))])
        end
    else
        % Incorrect time format:
        disp('Incorrect format (shape) specified for keyword ''time'', automatically set to ''end''');
        OPT.time = 'end';
    end
else
    disp('Unknown input specified for keyword time, automatically set to ''end''');
    OPT.time = 'end';
end

if isstr(OPT.time) && strcmp(OPT.time,'end')
    OPT.time = [];
    for ii=1:size(map_files,1)
        tmp_file_info  = delwaq('open',map_files{ii,1});
        OPT.time(ii,1) = max(delwaq_time(tmp_file_info,'datenum',1,'quiet',true));
    end
%     if length(unique(OPT.time))>1
%         disp(['Using various trim_file hotstart times: ' datestr(OPT.time(1,1))])
%     else
%         disp(['Using trim-file hotstart time: ' datestr(OPT.time(1,1))])
%     end
end

%_____________________________________________
% OPT.output_folder checks and modifications:
if isstr(OPT.output_folder)
    if strcmp(OPT.output_folder(1,end),filesep)
        OPT.output_folder = OPT.output_folder(1,1:end-1);
    end
    if exist(OPT.output_folder,'dir') ~= 7
        mkdir(OPT.output_folder)
        disp(['Output folder ''' OPT.output_folder ''' did not exist yet, created succesfully'])
    end
else
    disp('Unknown input for keyword ''output_folder'', using current folder instead');
    OPT.output_folder = pwd
end

% All the input is ok, now, lets check if all the *.map files indeed exist and have data on the requested timepoints:

for ii=1:size(map_files,1)
    if exist(map_files{ii,1},'file') == 2
        try
            map_handles{ii,1} = delwaq('open',map_files{ii,1});
        catch
            error(['Cannot load map file: ' map_files{ii,1}]);
        end
    else
        error(['Map file does not exist: ' map_files{ii,1}]);
    end
    
    model_times{ii,1}  = delwaq_time(map_handles{ii,1},'datenum',1,'quiet',true)';
    % 6th time digit is not relevant for seconds:
    if ~isempty(find(round(model_times{ii,1} * 10^6) == round(OPT.time(ii,1) * 10^6)))
        time_inds(ii,1)    = find(round(model_times{ii,1} * 10^6) == round(OPT.time(ii,1) * 10^6));
    else
        error(['Map-file ''' map_files{ii,1} ''' does not contain fields for the specified date: ' datestr(OPT.time(ii,1)) ', please check this...'])
    end
    
    output_files{ii,1} = [OPT.output_folder filesep strrep(map_files_name_only{ii,1},'.map',[OPT.add_text '.map'])];
    if exist(output_files{ii,1},'file') == 2
        error(['The requested output file ''' output_files{ii,1} ''' already exists, this script will not overwrite any files and is thus aborted. Change your function call (''add_text'' or ''output_folder'') or delete the file(s) if needed..']);
    end
end

%% Finally, create all new files...
%

tic;
disp([' ']);
for ii=1:size(map_files,1)
    disp(['Creating file ' num2str(ii) ' out of ' num2str(size(map_files,1)) ':']);
    disp([' ']);
    disp(['Hotstart time = ' datestr(model_times{ii,1}(time_inds(ii,1),1)) ' for file ' map_files{ii,1}]);
    disp([' ']);
    
    % get the data to copy:
    [time_d,data_d] = delwaq('read',map_handles{ii,1},0,0,time_inds(ii,1));
    if min(size(OPT.num_of_subs) == [0,0]) == 1
        OPT.num_of_subs = size(map_handles{ii,1}.SubsName,1);
    end
    
    %%%%% This is something we don't want, why are there dummy values in this data?: 
    data_d(find(data_d==-999)) = 0;
    %%%%% This is a temporary solution, possibly a bug in the core of DELWAQ
    
    % If the delwaq code allows (consistency), you could use this call, but we leave the header data empty, and it will be copied: 
    % map_handles_new{ii,1} = delwaq('write',output_files{ii,1},map_handles{ii,1}.Header,map_handles{ii,1}.SubsName(1:OPT.num_of_subs),[map_handles{ii,1}.T0 map_handles{ii,1}.TStep*3600*24],time_d,data_d(1:OPT.num_of_subs,:));
    map_handles_new{ii,1} = delwaq('write',output_files{ii,1},map_handles{ii,1}.Header,map_handles{ii,1}.SubsName(1:OPT.num_of_subs),[],time_d,data_d(1:OPT.num_of_subs,:));
    disp([' ']);
end

fclose('all');
disp(['All files (' num2str(num2str(size(map_files,1))) ' in total) were succesfully created in ' num2str(round(toc)) ' seconds, you can find them here:'])
disp([' '])
disp([output_files])