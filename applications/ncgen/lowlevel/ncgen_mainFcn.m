function varargout = ncgen_mainFcn(schemaFcn, readFcn, writeFcn, varargin)
%NCGEN_MAINFCN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgen_mainFcn(schemaFcn, readFcn, writeFcn, varargin)
%
%   Input:
%   schemaFcn =
%   readFcn   =
%   writeFcn  =
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgen_mainFcn
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Apr 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgen_mainFcn.m 14732 2018-10-17 14:31:45Z santinel $
% $Date: 2018-10-17 22:31:45 +0800 (Wed, 17 Oct 2018) $
% $Author: santinel $
% $Revision: 14732 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/lowlevel/ncgen_mainFcn.m $
% $Keywords: $

%% First basic input check
if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
    % version 2011a and older
    error(nargchk(3,inf,nargin)) %#ok<NCHKN>
else
    % version 2011b and newer
    narginchk(3,inf)
end

if isempty(schemaFcn); schemaFcn = @(~)    struct('undefined',true); else  assert(isa(schemaFcn,'function_handle'),'schemaFcn must be a function handle'); end
if isempty(readFcn);   readFcn   = @(~,~,~)struct('undefined',true); else  assert(isa(readFcn,  'function_handle'),  'readFcn must be a function handle'); end
if isempty(writeFcn);  writeFcn  = @(~,~)  struct('undefined',true); else  assert(isa(writeFcn, 'function_handle'), 'writeFcn must be a function handle'); end

%% Options

% general settings
OPT.main.log            = 1;
OPT.main.file_incl      = '.*';
OPT.main.dir_incl       = '.*';
OPT.main.dir_excl       = '.svn$';  % regex style pattern to exclude
OPT.main.zip            = false; % specify if source files are compressed or not
OPT.main.zip_file_incl  = '.*';
OPT.main.case_sensitive = false;
OPT.main.unzip_with_gui = 1;
OPT.main.dateFcn        = @(s) datenum(s(1:6),'yymmdd'); % how to extract date from the filename
OPT.main.datefield      = 'name'; % apply dateFcn on this field
OPT.main.defaultdate    = []; 
OPT.main.dir_depth      = inf;
OPT.main.hash_source    = true;
OPT.main.store_hash     = false;
OPT.main.merge_data     = false;
OPT.main.projectFcn     = @(s) regexp(s, '((?<=_)(...)(?=\.(?i)(asc)))', 'match'); % extract prj name from filename
OPT.main.project        = ''; % default prj name

% path settings
OPT.main.path_source    = ''; % path to source data. Can be a directory or a single file
OPT.main.path_unzip_tmp = fullfile(tempdir,'ncgen'); % path to unzipped source data, should be a tempdir
OPT.main.path_netcdf    = 'D:\products\nc'; % local path to write ncdf files to

% settings from sub functions
OPT.schema              = schemaFcn([]);
OPT.read                = readFcn([],[],[]);
OPT.write               = writeFcn([],[]);

% parse varargin in two steps to enforce the OPT.xxx structure
parsed_varargin         = setproperty(OPT,varargin);

OPT.main                = setproperty(OPT.main,  parsed_varargin.main);
OPT.schema              = setproperty(OPT.schema,parsed_varargin.schema);
OPT.read                = setproperty(OPT.read,  parsed_varargin.read);
OPT.write               = setproperty(OPT.write, parsed_varargin.write);

% return OPT if only input is 
if nargin == 3
    varargout = {OPT};
    return
end

%% Second input check
assert(~isempty(OPT.main.path_source) ,'No source directory was defined');
assert(~isempty(OPT.main.path_netcdf) ,'No netcdf directory to write to was defined');
assert(exist(OPT.main.path_source,'dir') || exist(OPT.main.path_source,'file'),...
    'Source directory ''%s'' does not exist',OPT.main.path_source);

%% create schema
if isempty(OPT.write.schema)
    OPT.write.schema = schemaFcn(OPT);
else
    required_fields = {'Filename','Name','Dimensions','Variables','Attributes','Groups','Format'};
    assert(all(ismember(required_fields,fieldnames(OPT.write.schema))),'User defined netcdf schema is not valid. Use schemaFcn to create a validschema');
end

%% other preparations
% initialize waitbars
multiWaitbar('Generating netcdf from source files...',          'reset', 'Color', [0.2 0.6 0.2])     % green
% initialise cache dir and locate source files
if OPT.main.zip
    if ~exist(OPT.main.path_unzip_tmp,'dir'); mkdir(OPT.main.path_unzip_tmp); end
    fns1 = dir2(OPT.main.path_source,'file_incl',OPT.main.zip_file_incl,'dir_incl',OPT.main.dir_incl,'dir_excl',OPT.main.dir_excl,'no_dirs',true,'depth',OPT.main.dir_depth,'case_sensitive',OPT.main.case_sensitive);
else
    fns1 = dir2(OPT.main.path_source,'file_incl',OPT.main.file_incl,'dir_incl',OPT.main.dir_incl,'dir_excl',OPT.main.dir_excl,'no_dirs',true,'depth',OPT.main.dir_depth,'case_sensitive',OPT.main.case_sensitive);
    % get the timestamp from the file date
    fns1 = get_date_from_filename(OPT,fns1);
    % sort with ascending data date
    [~, ix] = sort([fns1.date_from_filename]);
    fns1 = fns1(ix);
end

% check if files are found
if isempty(fns1)
     error('NCGEN_GRID:noSourcefiles','No source files were found in directory %s',OPT.main.path_source)
end

% generate md5 hashes of all source files
if OPT.main.hash_source
    fns1 = hash_files(fns1,'store_hash',OPT.main.store_hash);
else
    [fns1.hash] = deal([]);
end

%% check the contents of the output directory
if exist(OPT.main.path_netcdf,'dir');
    fns1 = check_existing_nc_files(OPT,fns1);
else
    mkdir(OPT.main.path_netcdf);
end

% lock the output directory
fclose(fopen(fullfile(OPT.main.path_netcdf,'ncgen.lock'),'w'));

WB.bytesToDo         = sum([fns1.bytes]);
WB.bytesDone         = 0;
WB.zipRatio          = 1;

%% loop through source files
multiWaitbar('Processing file','reset', 'Color', [0.9 0.7 0.1]);
for jj = 1:length(fns1);
    % unzip
    if OPT.main.zip
        fns2 = unzip_src_files(OPT,fns1(jj));
        % calculate a zip ratio to estimate the compression level (used to estimate the total work for the progress bar)
        WB.zipRatio  = sum([fns2.bytes])/fns1(jj).bytes;
    else
        fns2 = fns1(jj);
    end
    
    for ii = length(fns2);
        % do function
        readFcn(OPT,writeFcn,fns2(ii));
        
        % waitbar
        multiWaitbar('Generating netcdf from source files...',(WB.bytesDone + sum(fns2(1:ii).bytes)/WB.zipRatio)/WB.bytesToDo);
    end
    WB.bytesDone = WB.bytesDone + fns1(jj).bytes;
end
multiWaitbar('Processing file','close');
multiWaitbar('Generating netcdf from source files...','close');
returnmessage(OPT.main.log,'Netcdf generation completed\n')

% remove lock file
delete(fullfile(OPT.main.path_netcdf,'ncgen.lock'));

%% return OPT
varargout = {OPT};

function fns2 = unzip_src_files(OPT,fns1)
%delete files in cache

delete(fullfile(OPT.main.path_unzip_tmp,'*.*'))

% uncompress files with a gui for progress indication
uncompress(fullfile(fns1.pathname,fns1.name),...
    'outpath',fullfile(OPT.main.path_unzip_tmp),'gui',OPT.main.unzip_with_gui,'quiet',true);

% read the output of unpacked files
fns2 = dir2(OPT.main.path_unzip_tmp,'file_incl',OPT.main.file_incl,'dir_incl',OPT.main.dir_incl,'dir_excl',OPT.main.dir_excl,'no_dirs',true,'depth',OPT.main.dir_depth,'case_sensitive',OPT.main.case_sensitive);

[fns2.hash] = deal(fns1.hash); % hash of zipped file is passed

fns2 = get_date_from_filename(OPT,fns2);

function fns = get_date_from_filename(OPT,fns)

if isempty(OPT.main.defaultdate);
    try
        date_from_filename = cellfun(OPT.main.dateFcn,{fns.(OPT.main.datefield)});
    catch ME
        error('NCGEN_GRID:unreadableDateStr',...
            'Failed to get date from filename, reason:\n%s',ME.message);
    end
else
    date_from_filename = repmat(OPT.main.defaultdate,size(fns));
end

% convert time to the units specified 
date_from_filename = datenum2udunits(date_from_filename,OPT.schema.time_units);

for ii = 1:length(fns)
    fns(ii).date_from_filename = date_from_filename(ii);
end


function fns1 = check_existing_nc_files(OPT,fns1)

if exist(fullfile(OPT.main.path_netcdf,'ncgen.lock'),'file')
    delete(fullfile(OPT.main.path_netcdf,'*.nc'));
    delete(fullfile(OPT.main.path_netcdf,'ncgen.lock'));
    returnmessage(OPT.main.log,'Netcdf output directory emptied because a previous run of ncgen was not completed.\n')
    return
end
    
if ~OPT.main.hash_source
    delete(fullfile(OPT.main.path_netcdf,'*.nc'));
    returnmessage(OPT.main.log,'Netcdf output directory emptied because no hash was computed.\n')
    return
end
    
nc_fns = dir2(OPT.main.path_netcdf,...
    'file_incl','\.nc$',...
    'file_excl','^catalog\.nc$',...
    'no_dirs',true,...
    'depth',0,...
    'case_sensitive',OPT.main.case_sensitive);

outdated         = false;
source_file_hash = [];
for ii = length(nc_fns):-1:1
    ncfile = [nc_fns(ii).pathname nc_fns(ii).name];
    % query nc schema to compare variables and dimensions
    info(ii) = ncinfo(ncfile);
    try
        % compare history attribute 
        %  - removed
        
        % compare if all attributes in the schema are defined
        
        
        % compare dimension names
        if ~isequal([info(ii).Dimensions.Name],[OPT.write.schema.Dimensions.Name]);
            reason = 'Difference found in dimensions';
            outdated = true;
            break;
        end
        
        % compare variables
        if ...
                ~isequal([info(ii).Variables.Name],        [OPT.write.schema.Variables.Name])     || ...
                ~isequal([info(ii).Variables.Datatype],    [OPT.write.schema.Variables.Datatype]) || ...
                ~isequal([info(ii).Variables.DeflateLevel],[OPT.write.schema.Variables.DeflateLevel]);
            reason = 'Difference found in variables';
            outdated = true;
            break;
        end
        
        % compare dimension lengths
        current_length = [info(ii).Dimensions.Length];
        current_length([info(ii).Dimensions.Unlimited]) = nan;
        new_length = [OPT.write.schema.Dimensions.Length];
        new_length([OPT.write.schema.Dimensions.Length] == inf | [OPT.write.schema.Dimensions.Unlimited])= nan;
        if ~isequalwithequalnans(current_length,new_length);
            reason = 'Difference found in dimension lengths';
            outdated = true;
            break;
        end
        
    catch  ME
        % isf anything went wrong, assume netcdf is outdated
        reason   = ['Error when comparing netcdf files: ' ME.message];
        outdated = true;
        break;
    end
    
    % collect source file hashes
    source_file_hash_info = ncinfo(ncfile,'source_file_hash');
    if source_file_hash_info.Size(2) > 0
        source_file_hash = [source_file_hash; ncread(ncfile,'source_file_hash')']; %#ok<AGROW>
    end
end
%Remove rows with all nan's
source_file_hash = source_file_hash(~all(isnan(source_file_hash),2),:);
%Remove rows with all zero's
source_file_hash = source_file_hash(~all((source_file_hash==0),2),:);

if ~outdated && ~OPT.main.merge_data
    % check hashes
    source_file_hash = unique(source_file_hash,'rows');
    % all hashes in nc structure must be in files.
    if ~isempty(source_file_hash)
        outdated = ~all(ismember(source_file_hash,vertcat(fns1.hash),'rows'));
    end
    if outdated
        reason = 'Difference found in hashes of source files';
    end
end   

if outdated
    delete(fullfile(OPT.main.path_netcdf,'*.nc'));
    returnmessage(OPT.main.log,'Netcdf output directory was outdated and therefore emptied.\n  Reason:\n  %s\n',reason)
    return;
end
    
% remove files already in nc from file name stucture  as they are
% already in the nc file
a = length(fns1);

if ~isempty(source_file_hash)
    fns1(ismember(vertcat(fns1.hash),source_file_hash,'rows')) = [];
end
b = length(fns1);
fprintf(OPT.main.log,'%d of %d source files were skipped as they were already processed.\n',a-b,a);

if any(strcmp({OPT.write.schema.Attributes.Name},'history'))
    % append history attribute if it is defined
    for ii = 1:length(nc_fns)
        % read current history attribute
        current_history_att = info(ii).Attributes(strcmp({info(ii).Attributes.Name},'history')).Value;
        new_history_att     = OPT.write.schema.Attributes(strcmp({OPT.write.schema.Attributes.Name},'history')).Value;
        temp                =  strfind(current_history_att,new_history_att);
        
        % if the new history attribute is not already in the netcdf files,
        % append it.
        if isempty(temp)
            ncwriteatt([nc_fns(ii).pathname nc_fns(ii).name],'/',...
                'history',[current_history_att char(10) new_history_att])
        end
    end
end