function indices = vs_trih_crosssection_index(trih,varargin)
%VS_TRIH_CROSSSECTION_INDEX   Read index NEFIS cross-section properties.
%
% index = vs_trih_crosssection_index(trih,crosssectionname)
%
% returns the index of a crosssection called crosssectionname.
%
% trih can be a struct as loaded by vs_use(...)
% or a NEFIS history file name to be loaded by vs_use
% internally.
%
% Leading and trailing blanks of the crosssection name are ignored,
% both in the specified names, as in the names as present
% in the history file.
%
% When the specified name is not found, an empty value 
% (0x0 or 0x1) is returned.	
%
% vs_trih_crosssection_index(trih,crosssectionname,method)
% to choose a method:
% - 'strcmp'   gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern 
%              crosssectionname is present (default).
%
% vs_trih_crosssection_index(trih) prints a list with all 
% crosssection names and indices on screen with 10 columns:
% index,name,m1,n1,m2,n2,x1,y1,x2,y2. 
%
% S = vs_trih_crosssection_index(trih) returns a struct S.
%
% Vectorized over 1st dimension of crosssectionname.
%
% NOTE that the order of the cross sections in the NEFIS output
%      file differs from that in the *.crs input file!
%
% See also: VS_USE, VS_LET, VS_TRIH_CROSSSECTION
%           VS_TRIH_STATION_INDEX

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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

% $Id: vs_trih_crosssection_index.m 7999 2013-02-01 13:40:36Z ivo.pasmans.x $
% $Date: 2013-02-01 21:40:36 +0800 (Fri, 01 Feb 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 7999 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trih_crosssection_index.m $

if ~isstruct(trih)
   trih = vs_use(trih);
end

   method = 'strcmp';
   method = 'strmatch';

if nargin==1
   method = 'list';
end

if nargin > 1
   crosssectionname = varargin{1};
end   

if nargin > 2
   method = varargin{2};
end   


%% Load all crosssection names
%% ------------------------
namst = squeeze(vs_let(trih(1),'his-const','NAMTRA'));

nstat = size(namst,1);

%% Cycle all crosssections and quit immediatlety 
%% when a match has been found
%% ------------------------

switch method

case 'list' %this one should be first in case

   mn1  = squeeze(vs_let(trih(1),'his-const','MNTRA',{[1 2],0}));
   mn2  = squeeze(vs_let(trih(1),'his-const','MNTRA',{[3 4],0}));
   
   xy  = squeeze(vs_let(trih(1),'his-const','XYTRA',{0,0}));
   xy  = reshape(xy,[],4); 
   xy1  = xy(:,1:2)'; xy2=xy(:,3:4)';
   
   if nargout==0
   
      disp('+------------------------------------------------------------------------------->')
      disp(['| ',trih(1).FileName])
      disp('| index         name         m1   n1     m2   n2     x1 and y1 ... x2 and y2')
      disp('+-----+--------------------+-----+-----+-----+-----+---------------------------->')
      
      for istat=1:nstat
      
         disp([' ',...
           pad(num2str(      istat  ) ,-5,' ') ,' ',...
                   pad(namst(istat,:) ,20,' ') ,' ',...
           pad(num2str(mn1  (1,istat)),-5,' ') ,' ',...
           pad(num2str(mn1  (2,istat)),-5,' ') ,' ',...
           pad(num2str(mn2  (1,istat)),-5,' ') ,' ',...
           pad(num2str(mn2  (2,istat)),-5,' ') ,' ',...
           pad(num2str(xy1  (1,istat),'%+16.6f'),-14,' '),' ',...
           pad(num2str(xy1  (2,istat),'%+16.6f'),-14,' '),' ',...
           pad(num2str(xy2  (1,istat),'%+16.6f'),-14,' '),' ',...
           pad(num2str(xy2  (2,istat),'%+16.6f'),-14,' ')]);
      
      end
      
      istat = nan;
   
   elseif nargout==1
   
      indices.namst = namst;
      indices.mn1   = mn1;
      indices.xy1   = xy1;
      indices.mn2   = mn2;
      indices.xy2   = xy2;
      
   end

case 'strcmp'

   indices = [];
   
   for istat=1:nstat

      for i=1:size(crosssectionname,1)
   
         if strcmp(strtrim(crosssectionname(i,:)),...
                   strtrim(namst(istat,:)))

            indices = [indices istat];
            
         end
   
      end
   
   end


case 'strmatch'

   indices = [];
   
   for i=1:size(crosssectionname,1)
   
      istat = strmatch(crosssectionname(i,:),namst); % ,'exact'
      
      indices = [indices istat];
      
   end
   
end


 