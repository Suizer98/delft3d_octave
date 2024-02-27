function strrep_in_large_files(fileNames,str1,str2,varargin)
%STRREP_IN_FILES  replace strings in very large Ascii files
%
%   Similar to strrep, but can search multiple very large files
%   Should be able to handle files of infinite size (if your OS can handle
%   that).  
%   
%   Syntax:
%   OPT = strrep_in_files(fileNames,str1,str2,varargin)
%
%   Input:
%   fileNames = structure of files to search (leave empty for gui)
%   str1      = string to find
%   str2      = string to replace it with
%   varargin  = keyword/value pairs for additional options
%
%
%   Example
%
%   strrep_in_files({'strrep_in_files.m'},'thijs','Thijs')
%
%   strrep_in_files([],'a','b')
%   replaces 'a' with 'b' in files selected with the gui
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 10 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: strrep_in_large_files.m 2890 2010-07-28 07:33:38Z thijs@damsma.net $
% $Date: 2010-07-28 15:33:38 +0800 (Wed, 28 Jul 2010) $
% $Author: thijs@damsma.net $
% $Revision: 2890 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strrep_in_large_files.m $
% $Keywords: $

%% process varargin

OPT.copy        = false; % make the new files as a copy
OPT.quiet       = false; % disable output
OPT.readBlock   =  1e6;

if nargin==0
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

if ischar(fileNames)
    fileNames = {fileNames};
end
%% gui to select fileNames if left empty

if isempty(fileNames)
    [sourceName,sourcePath] = uigetfile('*.*','Select files to search','MultiSelect','on');
    if ischar(sourceName)
        fileNames{1} = fullfile(sourcePath,sourceName);
    else
        for ii = 1:length(sourceName)
            fileNames{ii,1} = fullfile(sourcePath,sourceName{ii});
        end
    end
end

%% replace strings

fprintf('\nprocessing files');
numberOfReplacements = 0;
changedFiles = 0;
jj = 0;
for ii = 1:length(fileNames)
    fid0 = fopen(fileNames{ii},'r');
    fid1 = fopen([fileNames{ii}(1:end-4) '_copy' fileNames{ii}(end-3:end)],'w');
    changedFile = false;
    while ~feof(fid0)
        contents = fread(fid0,OPT.readBlock,'*char')';
        if ~feof(fid0)
            adjust = -length(str1)-1;
            fseek(fid0,adjust,'cof');
        else
            adjust = 0;
        end
        
        replacementsToMake = length(findstr(contents,str1));
        if replacementsToMake>0
            newcontents = strrep(contents,str1,str2);
            numberOfReplacements = numberOfReplacements + replacementsToMake;
            changedFile = true;
            fprintf(fid1,'%s',newcontents(1:end+adjust));
        else
            fprintf(fid1,'%s',contents(1:end+adjust));
        end
        
        % output something to screen
        if ~OPT.quiet
            jj = jj+1;
            if jj == 100*round(jj/100)
                fprintf('.');
            end
        end
    end
    if changedFile
        changedFiles = changedFiles+1;
        percentageDone = floor(ii/length(fileNames)*100);
        fprintf(' %3.0f%% done \nprocessing files',percentageDone);
    end
    
    fclose(fid0);
    fclose(fid1);
    if OPT.copy
    else
        delete(fileNames{ii});
        movefile([fileNames{ii}(1:end-4) '_copy' fileNames{ii}(end-3:end)],fileNames{ii});
    end
end
if ~OPT.quiet
    fprintf(' 100%% done\n')
    fprintf('%d replacements made in %d out of %d files\n',numberOfReplacements,changedFiles,length(fileNames));
end
end