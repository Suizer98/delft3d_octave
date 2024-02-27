function varargout = strrep_in_files(fileNames,str1,str2,varargin)
%STRREP_IN_FILES  replace strings in Ascii files
%
%   Similar to strrep, but can search multiple files
%
%   Syntax:
%   OPT = strrep_in_files(fileNames,str1,str2,varargin)
%
%   Input:
%   fileNames = structure of files to search (leave empty for gui)
%   str1      = string to find find
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

% $Id: strrep_in_files.m 11709 2015-02-16 09:58:50Z gerben.deboer.x $
% $Date: 2015-02-16 17:58:50 +0800 (Mon, 16 Feb 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11709 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/strrep_in_files.m $
% $Keywords: $

%% process varargin

OPT.copy        = false; % make the new files as a copy
OPT.quiet       = false; % disable output

if nargin==0
    varargout = {OPT};
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

if ~OPT.quiet
fprintf('\nprocessing files');
end
numberOfReplacements = 0;
changedFiles = 0;
for ii = 1:length(fileNames)
    fid = fopen(fileNames{ii},'r');
    contents = fread(fid,'*char')';
    fclose(fid);
    
    replacementsToMake = length(strfind(contents,str1));
    if replacementsToMake>0
        newcontents = strrep(contents,str1,str2);
        numberOfReplacements = numberOfReplacements + replacementsToMake;
        changedFiles = changedFiles+1;
        if OPT.copy
            fid = fopen([fileNames{ii}(1:end-4) '_copy' fileNames{ii}(end-3:end)],'w');
        else
            fid = fopen(fileNames{ii},'w');
        end
        fprintf(fid,'%s',newcontents);
        fclose(fid);
    end
    
    % output something to screen
    if ~OPT.quiet
        if ii == 60*round(ii/60)
            percentageDone = floor(ii/length(fileNames)*100);
            fprintf(' %3.0f%% done \nprocessing files',percentageDone);
        else
            fprintf('.');
        end
    end
end
if ~OPT.quiet
    fprintf(' 100%% done\n')
    fprintf('%d replacements made in %d out of %d files\n',numberOfReplacements,changedFiles,length(fileNames));
end
end