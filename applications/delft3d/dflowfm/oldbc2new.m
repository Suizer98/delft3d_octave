function oldbc2new(varargin)

% This function converts (water level) boundary conditions for a DflowFM model
% from the old format (tim files) to the new format (ini files, you might
% question whether the ini format is suited for large amounts of, time
% series data).
%
% For new the function requires the name of the new ext file, the name
% of the new bc fileand the directory where the old tim files are stored as
% input.
% It is my intention to extent the function so that it uses the old ext
% file as input, generateds a new ext file and generates bc in the new
% format all in once
%
%
% Implemented <keyword> <value> pairs
% add2old: seqence number to substract from existing tim file number (specific for RMM 6th generation)
% itdate : reference date to include in ini bc file as matlab day number (refernce date not always included in tim files!)
%
% example of usage (for RMM 6th generation):
%
% oldbc2new('ext_file','RMM_bnd_measdis.ext', 'old_series', ['old_format' filesep], 'new_series', ['new_format' filesep 'rmm_zeewl_zunokf_corr5cm_20061225_20090101.bc'], ...
%           'itdate'  , datenum(2006,12,25) , 'add2old   ', -2                                                                                                        );
%
% Theo van der Kaaij; 20-09-2018
%
oetsettings('quiet');

%% Files and directories
OPT.ext_file    = 'RMM_bnd_measdis.ext';
OPT.old_series  = ['old_format' filesep];
OPT.new_series  = ['new_format' filesep 'rmm_zeewl_zunokf_corr5cm_20061225_20090101.bc'];

OPT.add2old    = 0 ; % Correction for new format, all.pli, original file, contained 2 boundary points that dry
OPT.itdate     = datenum(2050,01,01);

OPT            = setproperty(OPT,varargin);

ext_file       = OPT.ext_file;
old_series     = OPT.old_series;
new_series     = OPT.new_series;
add2old        = OPT.add2old;
itdate         = OPT.itdate;

%% To do: read the old extfile and convewrt to new, ini type, format
try
    ext_old = dflowfm_io_extfile('read',ext_file,'type','old');

    % Convert to new and write
    dflowfm_io_extfile('write',ext_file,'type','ini');
end

%% Now: read the new ext file
ext_new = dflowfm_io_extfile('read',ext_file);

%% Find information related to water level bnd
no_forcings = length(ext_new);
i_bnd       = 1;

for i_force = 1: no_forcings
    if strcmpi(ext_new(i_force).Chapter,'boundary')
        no_keywords = length(ext_new(i_force).Keyword.Name);
        for i_key = 1: no_keywords;
            if strcmpi(ext_new(i_force).Keyword.Name{i_key},'quantity')
                if strcmpi(ext_new(i_force).Keyword.Value{1},'waterlevelbnd')
                    loc_file  {i_bnd} = ext_new(i_force).Keyword.Value{2};
                    force_file{i_bnd} = ext_new(i_force).Keyword.Value{3};
                    i_bnd            = i_bnd + 1;
                end

            end
        end
    end
end

%% Read the location file
no_bnd = length(loc_file);

%% Get pli file names and construct names of the tim files (fixed whan old format is applied)
for i_bnd = 1: no_bnd
    Info = dflowfm_io_xydata('read',loc_file{i_bnd});

    % Names of support pointa (must be a smarter way of doing this)
    no_sup = size(Info.DATA,1);
    for i_sup = 1: no_sup sup{i_sup} = Info.DATA{i_sup,3}; end

    % Names of the belonging tim files
    for i_sup = 1: no_sup
        i_start = strfind(sup{i_sup},'_');
        number  = str2num(sup{i_sup}(i_start(end) + 1:end)) + add2old;
        tim_file{i_sup} = [old_series filesep sup{i_sup}(1:i_start(end)) num2str(number,'%4.4i') '.tim'];
    end

    clear Info

    %% Read the series and fil external forcing for writing
    for i_sup = 1: no_sup
        Info     = dflowfm_io_xydata('read',tim_file{i_sup});
        no_recs  = size(Info.DATA,1);
        i_tim    = 0;
        for i_rec = 1: no_recs
            if ~isstr(Info.DATA{i_rec,1})
                i_tim = i_tim + 1;
                ext_force.values{i_tim,1}      = Info.DATA{i_rec,1};
                ext_force.values{i_tim,2}      = Info.DATA{i_rec,2};
            end
        end

        ext_force.Chapter          = 'Forcing';
        ext_force.Keyword.Name {1} = 'Name';
        ext_force.Keyword.Value{1} = sup{i_sup};
        ext_force.Keyword.Name {2} = 'Function';
        ext_force.Keyword.Value{2} = 'timeseries';
        ext_force.Keyword.Name {3} = 'Time-interpolation';
        ext_force.Keyword.Value{3} = 'linear';
        ext_force.Keyword.Name {4} = 'Quantity';
        ext_force.Keyword.Value{4} = 'time';
        ext_force.Keyword.Name {5} = 'Unit';
        ext_force.Keyword.Value{5} = ['minutes since ' datestr(itdate,'yyyy-mm-dd  HH:MM:SS')];
        ext_force.Keyword.Name {6} = 'Quantity';
        ext_force.Keyword.Value{6} = 'waterlevelbnd';
        ext_force.Keyword.Name {7} = 'Unit';
        ext_force.Keyword.Value{7} = 'm';

        %% Write to file, one single support point at the time to avoid excessive memory usage)
        [path,~,~] = fileparts(new_series);
        if ~exist(path) mkdir (path); end

        tmp_series = ['new_format' filesep 'tmp_' num2str(i_sup,'%4.4i') '.bc'];
        dflowfm_io_extfile('write',tmp_series,'ext_force',ext_force,'type','ini');
    end

    %% Merge files
    command    = 'copy ';
    delete       (new_series);
    for i_sup = 1: no_sup
        tmp_series = ['new_format' filesep 'tmp_' num2str(i_sup,'%4.4i') '.bc'];
        command    = [ command  tmp_series ' + '];
    end
    command =[command(1:end-2) new_series];
    system (command);
    delete([path filesep 'tmp_*.bc']);
end




