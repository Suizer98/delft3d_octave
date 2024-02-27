function string = path2os(string,input)
%PATH2OS   Replaces directory slashes to conform with a OS
%
% string = path2os(string)
%
% Replaces all slashes (/ or \) with the slash of the 
% current Operating System. string can be a cellstr.
%
% Options are:
%
% string = path2os(string,'\')
% string = path2os(string,'d<os>')    : \
% string = path2os(string,'w<indows>'): \
%
% string = path2os(string,'/')
% string = path2os(string,'h<ttp>')   : / retains http://
% string = path2os(string,'l<inux>')  : /
% string = path2os(string,'u<nix>')   : /
%
% Also removes redundant (double) slashes that might
% have arisen when merging pathnames like in d:\temp\\foo\\,
% except for double slashes at the beginning of a path or url,
% as in //networkdrive/ or http://
%
%See also: MKDIR,  EXIST, MKPATH,     COPYFILE, CD, LAST_SUBDIR,
%          DELETE, DIR,   FILEATTRIB, MOVEFILE, RMDIR.

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: path2os.m 12027 2015-06-22 12:59:02Z gerben.deboer.x $
% $Date: 2015-06-22 20:59:02 +0800 (Mon, 22 Jun 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12027 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/path2os.m $
% $Keywords$

   if nargin==1
       slash = filesep;
   else
       if     input(1) == 'u' || ...
              input(1) == 'l' || ...
              input(1) == 'h'
              slash    =  '/';
              
       elseif input(1) == 'w' || ...
              input(1) == 'd'
              slash    =  '\';
              
       elseif input(1) == '\' || ...
              input(1) == '/'
              slash    =  input(1);
       end
   end
   
   if iscell(string)
       string = cellfun(@(x) path2os(x,slash),string,'UniformOutput',0);
   elseif isempty(string)
       return
   else

%% Lock special combis
   prefix = '';
   if     length(string) > 6  
      if strcmpi(string(1:7),'http://') | strcmpi(string(1:7),'http:\\');prefix = 'http://';string = string(8:end);
        if strcmpi(slash,'\')
            slash = '/';
            %warning('for http:// backward \ slash is recommended');
        end
      end
   end
   if length(string) > 1     
      if strcmpi(string(1:2),'\\'     );prefix = '\'      ;string = string(2:end);
      end
   end

%% Replace all slashes 

   string = strrep(string,'/',slash);
   string = strrep(string,'\',slash);

%% Remove redundant fileseps
   
   string1 = '';

   while ~strcmp(string,string1)

      string1 = string;
      string  = strrep(string,[slash, slash],slash);

   end
   
   string = [prefix string];
   
   end % cell
   
%% EOF   