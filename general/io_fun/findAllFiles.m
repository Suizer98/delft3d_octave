function varargout = findAllFiles(varargin)
%FINDALLFILES   get list of all files in a directory tree.
%
%    files          = findAllFiles(basepath,<keyword,value>)
%   [files,folders] = findAllFiles(basepath,<keyword,value>)
%
% returns cellstr with a list of all files in a directory tree, 
% and optionally also of all unique folder names.
% The following <keyword,value> pairs have been implemented.
%
% * pattern_excl (default '.svn')
% * pattern_incl (default '*')
% * basepath     (default '')
% * recursive    (default 1): 
%   return relative filenames inside basepath only if 0, 
%   returns absulote filenames if 1
%
% Notice that the pattern_excl paths are filtered with regexp. The syntax
% is slightly different. Example: '*.svn' versus '\.svn' see help regexp
% for more
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = findAllFiles()
%
%See also: DIR, DIR2, OPENDAP_CATALOG, ADDPATHFAST, REGEXP, DIRLISTING

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Mark van Koningsveld
%
%       mrv@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
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

% TO DO rename to something sensible: e.g. dir_files?
% TO DO add that sensible name to see also line of opendap_catalog
% TO DO explain regexp for people who work with '*', cause it should be '.'

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: findAllFiles.m 12734 2016-05-13 08:33:31Z gerben.deboer.x $
% $Date: 2016-05-13 16:33:31 +0800 (Fri, 13 May 2016) $
% $Author: gerben.deboer.x $
% $Revision: 12734 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/findAllFiles.m $
% $Keywords: $

%% settings
%  defaults

   OPT.pattern_excl = {'\.svn'}; % pattern to exclude
   OPT.pattern_incl = '*';       % pattern to include
   OPT.basepath     = '';        % indicate basedpath to start looking
   OPT.recursive    = 1;         % indicate whether or not the request is recursive
       
   if odd(nargin)
      OPT.basepath = varargin{1};
      nextarg = 2;
   else
      nextarg = 1;
   end

   % overrule default settings by property pairs, given in varargin

   OPT = setproperty(OPT, varargin{nextarg:end});
   
   if nargin==0;varargout = {OPT};return;end
   
   if ~exist(OPT.basepath,'dir')
      error(['directory ''',OPT.basepath,''' does not exist'])
   end

%% Find all subdirs in basepath

   if ispc
       if OPT.recursive
           [a b] = system(['dir /b /a /s ' '"' path2os([OPT.basepath filesep OPT.pattern_incl]) '"']);
       else
           [a b] = system(['dir /b /a ' '"'    path2os([OPT.basepath filesep OPT.pattern_incl]) '"']);
       end
       
   else
       % Go to path to return relative paths....
       [a b] = system(['cd ' OPT.basepath '; find . -iname ''' OPT.pattern_incl '''; cd - > /dev/null']);
   end

if strcmpi(strtrim(b),'File Not Found') || isempty(strtrim(b)) % NB b(end) = char(10) % empty for unix/osx

   s = [];
   
else   

%% Exclude the .svn directories from the path
%  read path as cell

   s = strread(b, '%s', 'delimiter', char(10));  

%% clear cells which contain OPT.pattern_excl

   for imask = 1:length(OPT.pattern_excl)
       OPT.pattern = OPT.pattern_excl{imask};
       s = s(cellfun('isempty', regexp(s, [OPT.pattern]))); % keep only paths not containing [filesep '.svn']
   end

end

%% return cell with resulting files (including pathnames)

   filenames   = s;
   
   if nargout==1
      varargout = {filenames};
   else

      foldernames = filenames; % preallocate
   
      for i=1:length(foldernames)
         if ~isdir(foldernames{i})
            foldernames{i} = fileparts(foldernames{i});
         end
      end
      foldernames = unique(foldernames);

      varargout = {filenames,foldernames};
   end
   
%% EOF   