function OPT = syncdirs(source, destination,varargin)
%SYNCDIRS  synchronizes files and folders source directory to destination
%
%   More detailed description goes here.
%
%   Syntax:
%   OPT = syncdirs(source, destination, varargin)
%
%   Input:
%   source      = source directory
%   destination = destination directory
%   varargin    = <keyword>,<value>
%
%   Output:
%   OPT         = structure with applied settings
%
%   Example
%   syncdirs
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 May 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: syncdirs.m 7343 2012-09-27 14:19:44Z tda.x $
% $Date: 2012-09-27 22:19:44 +0800 (Thu, 27 Sep 2012) $
% $Author: tda.x $
% $Revision: 7343 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/syncdirs.m $
% $Keywords: $

%%
OPT.remove_files_from_destination   = false;  
OPT.source_dir_excl                 = '';
OPT.source_file_incl                = '.*';
OPT.destination_dir_excl            = '';
OPT.destination_file_incl           = '.*';
OPT.ignorefiledate                  = false;
OPT.checkByMD5Hash                  = false; % use this to compare files by their hash. This is usefull when you want to ignore file dates, but
OPT.extraBytesForWaitbar            = 40;  % To compensate for the the reduced throughput when copying many small files add some bytes to their size (this is only for the waitbar) 
OPT.log                             = 1;

OPT = setproperty(OPT,varargin{:});

if nargin==0;
    return;
end
%% code

% create destination if it does not exist yet
if ~exist(destination,'dir')
    mkpath(destination);
end

D_srce          = dir2(source,     'dir_excl',OPT.source_dir_excl,     'file_incl',OPT.source_file_incl     );
D_dest          = dir2(destination,'dir_excl',OPT.destination_dir_excl,'file_incl',OPT.destination_file_incl);


% add a field relativepathname to the source files
for ii = 1:length(D_srce)
    D_srce(ii).relativepathname = strrep(D_srce(ii).pathname ,[D_srce(1).pathname D_srce(1).name filesep],'');
end

% add a field relativepathname to the destination files
for ii = 1:length(D_dest)
    D_dest(ii).relativepathname = strrep(D_dest(ii).pathname ,[D_dest(1).pathname D_dest(1).name filesep],'');
end

%% look for existing / outdated / modified files and directories
to_remove_from_dest = false(size(D_dest));
to_remove_from_srce = false(size(D_dest));

% find for files/folders with the same name and path
[tf,loc] = ismember(...
    strcat({D_dest.relativepathname}, {D_dest.name}),...
    strcat({D_srce.relativepathname}, {D_srce.name}));

for ii = 2:length(D_dest)
    remove_file = true;
    if tf(ii)
        % discern between directories and files
        if isequal(D_dest(ii).isdir  ,D_srce(loc(ii)).isdir  )
            if D_dest(ii).isdir
                remove_file = false;
            else
                % for files compare file date...
                if OPT.ignorefiledate || isequal(D_dest(ii).datenum,D_srce(loc(ii)).datenum)
                    % and file size...
                    if isequal(D_dest(ii).bytes,D_srce(loc(ii)).bytes  )
                        % and finally compare md5 hash
                        if ~OPT.checkByMD5Hash || isequal(...
                                CalcMD5([D_dest(ii)     .pathname D_dest(ii)     .name],'File','dec'),...
                                CalcMD5([D_srce(loc(ii)).pathname D_srce(loc(ii)).name],'File','dec'));
                            
                            % only if all these conditions are met, set the remove file flag to false
                            remove_file = false;
                        end
                    end
                end
            end
        end
    end
    if remove_file
        to_remove_from_dest(ii)      = true;
    else
        to_remove_from_srce(loc(ii)) = true;
    end
end

% log message
if OPT.log
    fprintf(OPT.log,'\n%d files and folders appear identical and will be skipped\n',sum(to_remove_from_srce));
end

D_srce(to_remove_from_srce) = [];
if OPT.remove_files_from_destination
    if ~isempty(to_remove_from_dest)
        % log message
        if OPT.log
            temp = strcat(...
                {D_dest(to_remove_from_dest).pathname},...
                {D_dest(to_remove_from_dest).name})';
            
            fprintf(OPT.log,'attempting to remove files and folders:\n');
            fprintf(OPT.log,'     %s\n',temp{:});
        end
        delete2(D_dest(to_remove_from_dest));
    end
end

%% print log message
if OPT.log
    if length(D_srce)>1
        temp = strcat(...
            {D_srce(2:end).pathname},...
            {D_srce(2:end).name})';
        fprintf(OPT.log,'\nattempting to copy the following files and folders:\n');
        fprintf(OPT.log,'     %s\n',temp{:});
    else
        fprintf(OPT.log,'\nno files and folders copied\n');
    end
end
%% create directory tree
multiWaitbar('Making directories','reset')
dirs_to_make = D_srce([D_srce.isdir]);
for ii = 2:length(dirs_to_make);
    dirname = [D_dest(1).pathname D_dest(1).name filesep dirs_to_make(ii).relativepathname dirs_to_make(ii).name];
    if ~exist(dirname,'dir')
        mkpath(dirname)
    end
    multiWaitbar('Making directories',ii/length(dirs_to_make))
end
multiWaitbar('Making directories','close')

%% copy files

multiWaitbar('Copying files','reset')
file_to_copy  = D_srce(~[D_srce.isdir]);
bytes_to_copy = sum([file_to_copy.bytes] + OPT.extraBytesForWaitbar);
for ii = 1:length(file_to_copy);
    multiWaitbar('Copying files','label',[file_to_copy(ii).relativepathname file_to_copy(ii).name]);
    srcename = [D_srce(1).pathname D_srce(1).name filesep file_to_copy(ii).relativepathname file_to_copy(ii).name];
    destname = [D_dest(1).pathname D_dest(1).name filesep file_to_copy(ii).relativepathname file_to_copy(ii).name];
    copyfile(srcename,destname,'f');
    multiWaitbar('Copying files','increment',(file_to_copy(ii).bytes + OPT.extraBytesForWaitbar) / bytes_to_copy);
end
if OPT.remove_files_from_destination
    label_msg = sprintf('Syncdirs completed, %d files copied. %d files or folders removed from destination',length(file_to_copy),sum(to_remove_from_dest));
else
    label_msg = sprintf('Syncdirs completed, %d files copied. %d files or folders found that are not in source.',length(file_to_copy),sum(to_remove_from_dest));
end
multiWaitbar('Copying files',1,'label',label_msg);

%% log message
if OPT.log
    fprintf(OPT.log,'Synchronization of\n    %s\nto\n    %s\nis completed. ',[D_srce(1).pathname D_srce(1).name],[D_dest(1).pathname D_dest(1).name]);
    if OPT.remove_files_from_destination
        fprintf('%d files were copied. %d files or folders removed from destination\n',length(file_to_copy),sum(to_remove_from_dest));
    else
        fprintf('%d files were copied. %d files or folders found that are not in source\n',length(file_to_copy),sum(to_remove_from_dest));
    end
end
