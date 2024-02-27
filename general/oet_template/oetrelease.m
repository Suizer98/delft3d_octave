function varargout = oetrelease(varargin)
%OETRELEASE  create release in new folder and zipfile
%
%   Function to create a release of specific folders (including subfolders)
%   and files. If the files in the selection are dependent on other files
%   in OpenEarthTools, these are also included in the release. The release
%   is created as separate folder and as zipfile.
%
%   Syntax:
%   [zipfilename files targetdir] = oetrelease(<targetdir>,<keyword,value>)
%   Input:
%   varargin    =
%
%   Output:
%   zipfilename =
%   files       =
%   targetdir   =
%
%   Example: make a release of the current folder:
%      oetrelease
%
%   Example: make a release of a specific folder:
%      oetrelease('f:\checkouts\mymtools\atoolbox')
%
%   See also: getCalls, oetroot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 04 Dec 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: oetrelease.m 6262 2012-05-29 12:41:09Z hoonhout $
% $Date: 2012-05-29 20:41:09 +0800 (Tue, 29 May 2012) $
% $Author: hoonhout $
% $Revision: 6262 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_template/oetrelease.m $
% $Keywords: $

%%
OPT = struct(...
    'targetdir'     , fullfile(cd, ['release_' datestr(now, 'ddmmmyyyy')]),...
    'zipfilename'   , tempname,...
    'folders'       , cd,...
    'files'         , 'oetsettings',...
    'omitextensions', {{'.asv' '.m~'}},...
    'omitfiles'     , {{}},...
    'omitdirs'      , {{'svn'}},...
    'copy'          , true,...
    'log'           , true);
 
if odd(nargin)
   OPT = setproperty(OPT, varargin{2:end});
   OPT.folders = varargin{1};
else
   OPT = setproperty(OPT, varargin);
end

if ischar(OPT.omitextensions)
   OPT.omitextensions = {OPT.omitextensions};
end

%% gather all files of the selected (sub) folders

   if ischar(OPT.folders)
       OPT.folders = {OPT.folders};
   end
   
   files = {};
   for i = 1:length(OPT.folders)
       [dirs dircont tempfiles] = dirlisting(OPT.folders{i}, OPT.omitdirs);
       tempfiles(strfilter(tempfiles,OPT.omitfiles)) = [];
       files(end+1:end+length(tempfiles)) = tempfiles;
   end

%% gather all other selected files

   if ischar(OPT.files)
       OPT.files = {OPT.files};
   end
   
   for i = 1:length(OPT.files)
       if ~ismember(which(OPT.files{i}), files)
           files{end+1} = which(OPT.files{i});
       end
   end
   
%% gather all related files (dependencies in entire active path)

    if OPT.log
        mkpath(OPT.targetdir);
        fid = fopen(fullfile(OPT.targetdir,'xb_release_toolbox.log'),'w');
    end

    i = 0;
    ind = 0;
    while i < length(files)
        i = i + 1;
        l = length(ind)-1;
        [pathstr filename fileext] = fileparts(files{i});
        if strcmp(fileext, '.m')
            
            tempfiles = getCalls(files{i}, oetroot, 'quiet');
            
            if ~isempty(tempfiles)
                
                % filter omit-extensions, files and directories
                m1 = cellfun(@(x)strfind(tempfiles,x),OPT.omitextensions,'UniformOutput',false);
                m1 = any(~cellfun(@isempty,reshape([m1{:}],length(tempfiles),length(OPT.omitextensions))),2);
                m2 = strfilter(tempfiles,OPT.omitfiles);
                m3 = false(size(tempfiles));
                for j = 1:length(OPT.omitdirs)
                    m3 = m3|~cellfun(@isempty,strfind(tempfiles,OPT.omitdirs{j}));
                end
                tempfiles(m1|m2|m3) = [];

                % filter duplicates
                tempid = ~ismember(tempfiles, files);
            end
            
            % add log lines
            if OPT.log
                fprintf(fid,'%02d: %s%s\r\n',l,repmat('  ',1,l),files{i});
                if length(tempfiles)-sum(tempid)-1>0
                    idx = find(~tempid);
                    for j = 1:length(idx)
                        if ~strcmpi(files{i},tempfiles{idx(j)})
                            fprintf(fid,'%02d: %s%s <\r\n',l+1,repmat('  ',1,l+1),tempfiles{idx(j)});
                        end
                    end
                end

                ind(end) = max(0,ind(end)-1);

                if sum(tempid)>0
                    ind = [ind sum(tempid)];
                else
                    while ind(end)==0 && length(ind)>1
                        ind(end) = [];
                    end
                end
            end
            
            % add dependencies
            files = [files(1:i) tempfiles(tempid)' files(i+1:end)];
        end
    end

    fclose(fid);

%% copy all selected files to separate folder

    if OPT.copy
       for i = 1:length(files)
           mkpath(fileparts(files{i}))
           destinationfile = strrep(abspath(files{i}), oetroot, [OPT.targetdir filesep]);
           mkpath(fileparts(destinationfile))
           if ~exist(destinationfile, 'file')
               try
                    copyfile(files{i}, destinationfile)
               catch
                   fprintf(2, 'File "%s" cannot be copied\n', files{i})
               end
           end
       end
    end

%% create zipfile of newly created folder

    if OPT.copy
       mkpath(OPT.targetdir)
       zip(OPT.zipfilename, OPT.targetdir, oetroot)
    end

%% prepare output

    varargout = {};
    if OPT.copy
        varargout = {OPT.zipfilename, OPT.targetdir};
    else
        varargout{1} = files;
    end