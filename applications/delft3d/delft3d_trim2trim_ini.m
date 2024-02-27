function delft3d_trim2trim_ini(trim_files,varargin)
% Want to copy and use large trim files for your model hot-/restarts?
% Use this script to only copy the required field data for the specific
% time-point of your  hot-/restart.
%
% Syntax:
%
% delft3d_trim2trim_ini(trim_files,<keyword,value>)
% 
% REQUIRED INPUT VARIABLE:
%
% trim_files     Cellstring of trim-files to consider, incl. or excluding
%                complete paths. Can also be a single line charcter string
%                when considering only 1 file. When left empty ('') a
%                dialog will appear to select trim-*.dat files.
%
%                Examples:
%                (1) ''
%                (2) 'D:/tmp/trim-tmp.dat'
%                (3) {'trim-tmp.dat','D:/tmp/trim-run.dat'}
%                (4) files (from tmp=dir('trim-*.dat'); files={tmp.name}';)
% 
% OPTIONAL INPUT <KEYWORD,VALUE> PAIRS:
% 
% time           This <keyword,value> is used to specify the time at which
%                the hotstart is specified. This can either be a matlab
%                datenum or the string 'end', the latter is default. When
%                specifying 'end', the last timestep of each trim-*.dat
%                file is used, when using a matlab datenum, the specified
%                date and time is used (when available in the trim-*.dat
%                files, else an error is thrown).
%
%                Examples:
%                (1) 'end'
%                (2) datenum(2015,4,25,18,0,0)
%                (3) 730486
%
% output_folder  This <keyword,value> is used to specify the output folder
%                in which the generated trim-*.dat files are stored. By
%                default, this is the working directory (pwd), but can be
%                changed by specifying the location in a single line
%                charcter string.
%
%                Examples:
%                (1) 'D:/tmp/hotstart_run/'
%                (2) [pwd filesep 'hotstart_run']
%
% add_text       This <keyword,value> is used to specify the additional text
%                used when naming new files, default, this is '_new'. This 
%                would for instance create a trim_tmp_new.dat from the file
%                trim_tmp.dat. If you wish to keep the original filenames,
%                simply specify add_text as ''. Do note that this could
%                overwrite existing files if not considering the
%                output_folder keyword, but this is checked for.
%
%                Examples:
%                (1) ''
%                (2) '_rst'
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
%See also: vs_use, vs_ini, vs_copy

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
OPT.add_text      = '_new';

OPT = setproperty(OPT,varargin);

%% Check all the input:
%

%_____________________________________________
% trim_files checks and modifications:
if isstr(trim_files)
    if size(trim_files,1) > 1
        error('Expected single line character input for trim-file location')
    else
        if strcmp(trim_files,'')
            % Will be using the dialog
        else
            % We nog have [N,1] cellstr, with N = 1:
            trim_files = {trim_files};
        end
    end
elseif iscellstr(trim_files)
    % Make sure we have a [N,1] cellstr regardless of input:
    trim_files = trim_files(:);
else
    disp('Unknown input specified for trim files, please use the dialog instead..');
    trim_files = '';
    % Will be using the dialog
end

if isstr(trim_files) && strcmp(trim_files,'')
    [FILENAME, PATHNAME] = uigetfile('trim-*.dat','','','MultiSelect','on');
    if isnumeric(FILENAME)
        disp('Aborted by user')
        return
    end
    if isstr(FILENAME)
        trim_files           = cellstr([PATHNAME FILENAME]);
    elseif iscellstr(FILENAME)
        trim_files           = cellstr([repmat(PATHNAME,size(FILENAME,2),1) char(FILENAME')]);
    else
        error('Unknown error, code 43574363, contact the developer')
    end
else
    % Trim files already specified, make sure all the paths are added as well:
    for ii=1:size(trim_files,1)
        if isempty(strfind(trim_files{ii,1},filesep))
            % No folder yet:
            trim_files{ii,1} = [pwd filesep trim_files{ii,1}];
        end
    end
end

% Now we also just want the names without the folders:
for ii=1:size(trim_files,1)
    trim_files_name_only{ii,1} = trim_files{ii,1}(1,max(strfind(trim_files{ii,1},filesep))+1:end);
end

if length(unique(trim_files)) ~= length(trim_files)
    error('Double files were found, please remove these...');
end

for ii=1:size(trim_files,1)
    if exist(trim_files{ii,1},'file') ~= 2
        error(['Trim file does not exist: ' trim_files{ii,1}]);
    end
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
        OPT.time = repmat(OPT.time,size(trim_files,1),1);
        disp(['Using trim-file hotstart time: ' datestr(OPT.time(1,1))])
    elseif min(size(OPT.time)) == 1 && max(size(OPT.time)) == size(trim_files,1)
        % Multiple values specified in correct format
        OPT.time = OPT.time(:);
        if length(unique(OPT.time))>1
            disp(['NOTE: Using various (different) trim_file hotstart times!'])
        else
            disp(['Using unique trim-file hotstart time for all files: ' datestr(OPT.time(1,1))])
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
    for ii=1:size(trim_files,1)
        OPT.time(ii,1) = max(get_d3d_output_times(trim_files{ii,1}));
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
    if exist(OPT.output_folder,'dir') ~= 7
        mkdir(OPT.output_folder)
        disp(['Output folder ''' OPT.output_folder ''' did not exist yet, created succesfully'])
    end
else
    disp('Unknown input for keyword ''output_folder'', using current folder instead');
    OPT.output_folder = pwd
end

% All the input is ok, now, lets check if all the trim-*.dat files indeed exist and have data on the requested timepoints:

for ii=1:size(trim_files,1)
    if exist(trim_files{ii,1},'file') == 2
        try
            trim_handles{ii,1} = vs_use(trim_files{ii,1},'quiet');
        catch
            error(['Cannot load trim file: ' trim_files{ii,1}]);
        end
    else
        error(['Trim file does not exist: ' trim_files{ii,1}]);
    end
    
    model_times{ii,1}  = get_d3d_output_times(trim_handles{ii,1});
    % 6th time digit is not relevant for seconds:
    if ~isempty(find(round(model_times{ii,1} * 10^6) == round(OPT.time(ii,1) * 10^6)))
        time_inds(ii,1)    = find(round(model_times{ii,1} * 10^6) == round(OPT.time(ii,1) * 10^6));
    else
        error(['Trim-file ''' trim_files{ii,1} ''' does not contain fields for the specified date: ' datestr(OPT.time(ii,1)) ', please check this...'])
    end
    
    output_files{ii,1} = [OPT.output_folder filesep strrep(trim_files_name_only{ii,1},'.dat',[OPT.add_text '.dat'])];
    if exist(output_files{ii,1},'file') == 2
        error(['The requested output file ''' output_files{ii,1} ''' already exists, this script will not overwrite any files and is thus aborted. Change your function call (''add_text'' or ''output_folder'') or delete the file(s) if needed..']);
    end
end

%% Finally, create all new files...
%

tic;
disp([' ']);
for ii=1:size(trim_files,1)
    disp(['Creating file ' num2str(ii) ' out of ' num2str(size(trim_files,1)) ':']);
    disp([' ']);
    disp(['Hotstart time = ' datestr(model_times{ii,1}(time_inds(ii,1),1)) ' for file ' trim_files{ii,1}]);
    disp([' ']);
    
    trim_handles_new{ii,1} = vs_ini(output_files{ii,1},strrep(output_files{ii,1},'.dat','.def'));
    function_text = 'trim_handles_new{ii,1} = vs_copy(trim_handles{ii,1},trim_handles_new{ii,1}';
    for field = vs_disp(trim_handles{ii,1},[])
        dat=vs_disp(trim_handles{ii,1},field{:},[]);
        if ~isempty(find(dat.SizeDim == size(model_times{ii,1},1)))
            function_text = [function_text ',''' field{:} ''',{' num2str(time_inds(ii,1)) '}'];
        end
    end
    eval([function_text ');']);
    disp([' ']);
end

fclose('all');
disp(['All files (' num2str(num2str(size(trim_files,1))) ' in total) were succesfully created in ' num2str(round(toc)) ' seconds, you can find them here:'])
disp([' '])
disp([output_files])
