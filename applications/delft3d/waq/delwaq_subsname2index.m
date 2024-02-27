function indices = delwaq_subsname2index(Struct,varargin)
%DELWAQ_SUBSNAME2INDEX   Delft3D-WAQ substance name to substance index.
%
% indices = DELWAQ_SUBSNAME2INDEX(Struct,SubstanceNames)
%
% returns the index of a substance called SubstanceNames, where:
% * Struct can be a struct as loaded by Struct= DELWAQ('open',...).
% * a delwaq history or map file name to be loaded by delwaq internally.
% * a cell string with the substance names (Struct.SubsName).
%
% SubstanceNames can be a cellstr or char array,
% vectorized for SubstanceNames!
%
% Leading and traling blanks of the substance name are ignored, both in 
% the specified names, as in the names as present in the history or map file.
%
% When the specified names is not found, an empty value (0x0 or 0x1) is returned.	
%
% DELWAQ_SUBSNAME2INDEX(Struct,SubstanceNames,method)
% to choose a method:
% - 'strcmp'   gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern 
%    subsname is present (default).
%
% G.J. de Boer, Nov 2005
%
%See also: DELWAQ, DELWAQ_DISP, DELWAQ_SEGMENTNAME2INDEX
%          DELWAQ_TIME, DELWAQ_MESHGRID2DCORCEN

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2008 Delft University of Technology
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

% $Id: delwaq_subsname2index.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_subsname2index.m $

      if isstruct(Struct)
      elseif iscellstr(Struct)
          SubsName = Struct;
          clear Struct;
          Struct.SubsName = SubsName;
          clear SubsName;
      elseif ischar(Struct)
         Struct = delwaq('open',Struct);
      else
         error('first argument should be a struct, cellstring or char.')
      end
   
      OPT.method = 'strcmp';
      OPT.method = 'strmatch';
   
   if nargin > 1
      SubstanceName = varargin{1};
      if ischar(SubstanceName)
         SubstanceName = cellstr(SubstanceName);
      elseif ~iscell(SubstanceName)
         error('SubstanceName shoudl be char of cellstr')
      end
   end   
   
   if nargin > 2
      OPT.method = varargin{2};
   end   

%% Load all Substance names
%% ------------------------

   list_of_names = cellstr(char(Struct.SubsName));
   nsub          = length(list_of_names);

%% Cycle all Substances and quit immediatlety 
%% when a match has been found
%% ------------------------

switch OPT.method
   
   case 'strcmp'
   
      indices = [];
      
      for isub=1:nsub 

          for iarg=1:length(SubstanceName)
      
            if strcmpi(strtrim(SubstanceName{iarg}),...
                       strtrim(list_of_names(isub,:)))
   
               indices = [indices isub];
               
            end
      
         end
      
      end
   
   
   case {'strmatch','exact'}
   
      indices = [];
      
      for iarg=1:length(SubstanceName)
      
         isub    = strmatch(SubstanceName{iarg},list_of_names); % ,'exact'
         indices = [indices isub];
         
      end
      
    otherwise
        error(['unknwon method: ',OPT.method])
      
   end

%% EOF