function D = fortran_namelist2struct(fname,varargin)
%FORTRAN_NAMELIST2STRUCT read fortran namelist file into struct
%
%    D = fortran_namelist2struct(fname,<D>)
%
% parses namelist fname to struct D. Optionally D can
% be supplied as well, so that fields of D are overwritten.
%
% NB: only scalars are implemented: RHS grammer is an error and 
% LHS side grammer is replaced by MKVAR: m(:) = 3 will be m___ = 3
%
%See also: fgetl, iniread

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% $Id: fortran_namelist2struct.m 7798 2012-12-06 16:49:39Z boer_g $
% $Date: 2012-12-07 00:49:39 +0800 (Fri, 07 Dec 2012) $
% $Author: boer_g $
% $Revision: 7798 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/fortran_namelist2struct.m $
% $Keywords: $

OPT.debug = 1;

fid = fopen(fname,'r');

rec = fgetl_no_comment_line(fid,'!');

if nargin==1
   D = [];
else
   D = varargin{1};
end

while ~isnumeric(rec)
    
   [group_name,rest] = strtok(rec);

   % termination forced
   if strcmpi(group_name(1),'/')
      break
   end

   % new group
   if strcmpi(group_name(1),'&')

       % handle blanks between & and group-name
       if length(group_name)==1
          group_name = strtok(rest);
       else
          group_name = group_name(2:end);
       end
       
       % handle values
       rec = fgetl_no_comment_line(fid,'!');
       [key,rest] = strtok(rec);
       while ~strcmpi(key(1),'/')
          ind0 = strfind(rest,'=');
          ind1 = strfind(rest,',');
          
          val = strtrim(rest(ind0+1:ind1-1));
          
          if     strcmpi(val(1),'''') & strcmpi(val(end),'''')
             val = val(2:end-1);
          elseif strcmpi(val(1),'.') & strcmpi(val(end),'.')
             if     strcmpi(val(2),'t');val = true;  % (.TRUE.  or any value beginning with T, .T, t, or .t)
             elseif strcmpi(val(2),'f');val = false; % (.FALSE. or any value beginning with F, .F, f, or .f)
             end
          else
             val = str2num(val);
          end
          
          D.(group_name).(mkvar(key)) = val; % deal with key  = 'matrix(:)'
          rec = fgetl_no_comment_line(fid,'!');
          [key,rest] = strtok(rec);
       end
       
       group_name = key;
       
   end
   
   rec = fgetl_no_comment_line(fid,'!');
   
end

fclose(fid);

if OPT.debug
   var2evalstr(D)
end