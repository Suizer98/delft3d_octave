function indices = delwaq_segmentname2index(Struct,varargin)
%DELWAQ_SEGMENTNAME2INDEX   Delft3D-WAQ segment name to segment index
%
% index = DELWAQ_SEGMENTNAME2INDEX(Struct,segmentname)
%
% returns the index of a station called segmentname, where
% Struct can be a struct as loaded by DELWAQ('open',...)
% or a delwaq history file name to be loaded by delwaq
% internally.
%
% Leading and traling blanks of the station name are ignored,
% both in the specified names, as in the names as present
% in the history file.
%
% When the specified names is not found, an empty value 
% (0x0 or 0x1) is returned.	
%
% DELWAQ_SEGMENTNAME2INDEX(Struct,segmentname,method)
% to choose a method:
% - 'strcmp' gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern 
%    segmentname is present (default).
%
% Vectorized over 1st dimension of segmentname.
%
% G.J. de Boer, Nov 2005
%
%See also: DELWAQ, DELWAQ_SUBSNAME2INDEX, DELWAQ_DISP
%          DELWAQ_TIME, DELWAQ_MESHGRID2DCORCEN


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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: delwaq_segmentname2index.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_segmentname2index.m $

   if ~isstruct(Struct)
      Struct = delwaq('open',Struct);
   end
   
      method = 'strcmp';
      method = 'strmatch';
   
   if nargin > 1
      segmentname = varargin{1};
   end   
   
   if nargin > 2
      method = varargin{2};
   end   


%% Load all station names
%% ------------------------

   list_of_names = char(Struct.SegmentName);

   nstat = length(list_of_names);

%% Cycle all stations and quit immediatlety 
%% when a match has been found
%% ------------------------

   switch method
   
   case 'strcmp'
   
      indices = [];
      
      for istat=1:nstat
   
         for i=1:size(segmentname,1)
      
            if strcmp(strtrim(segmentname(i,:)),...
                      strtrim(list_of_names(istat,:)))
   
               indices = [indices istat];
               
            end
      
         end
      
      end
   
   
   case 'strmatch'
   
      indices = [];
      
      for i=1:size(segmentname,1)
      
         istat = strmatch(segmentname(i,:),list_of_names); % ,'exact'
         
         indices = [indices istat];
         
      end
      
   end

%% EOF