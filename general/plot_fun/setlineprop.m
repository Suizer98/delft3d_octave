function varargout = setlineprop(linehandle,lineproperties,varargin)
%SETLINEPROP function to set multiple properties of a line object at once.
%
%  SETLINEPROP(LineHanle,lineprop_struct,i)
%  set the line properties of a line object to i-th 
%  value of the values stored in a struct containing 
%  fields with names equal to the line properties.
%
%  Also the the name of an m-function returning such a
%  the lineprop_struct can be passed:
%  setlineprop(LineHanle,'lineprop_struct',i)
%  in which 'linepropfile' should have the *.m extension
%  and look like this:
%
%>   function L = linepropfile
%>    L.color           = [0 0 1
%>                         1 0 0]; % or
%>    L.color           = jet;
%>    L.linestyle       = ['- ';'-.';'--';': ']; 
%>    L.linewidth       = [0.5];
%>    L.marker          = ['none'];
%>    L.markersize      = [6];
%>    L.markeredgecolor = ['auto']
%>    L.markerfacecolor = ['none'];
%
% Note that in the example above 
% the first values (i=1) are the default line property values.
%
% Note that in a character array all elements should have equal lentgh.
% Applies for instance to colors 'r','g' etc. and linestyles '-',':' etc.
%
% Each single property is cycled if i exceeds the dimension for a 
% particular property.
%
% As strcut field names are case sensitive, use only lower
% case: L.color rather than L.Color;
%
% Only properties present in the struct are set, other properties
% keep the default value.% USE:
%
% * setlineprop(LineHandle,'linepropfile',i)
%      sets the properties of Linehandle to value number i from
%      the struct.
% * setlineprop(LineHandle,'linepropfile')
%      assumes i=1
% * L = setlineprop(LineHandle,'linepropfile') and
%   L = setlineprop(LineHandle,linepropstruct)
%      return the lineprop_struct in L
%
% See also: SET, GET

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   % Load line properties struct
   % and remove extension *.m if necesarry
   % ---------------------------
   
   if nargin==3
      i = varargin{1};
   else
      i = 1;
   end
   
   %% 
   %% --------------------------------
   if ~isstruct(lineproperties)
      linepropertiesfile = lineproperties;
      [lpath, lfile, lextension]=fileparts(linepropertiesfile);
      
      if ~isempty(which([lpath, lfile]))
         L = feval([lpath, lfile]);
      else
         error(['Line style properties function "',linepropertiesfile,'.m" does not exist'])
      end
   else
      L = lineproperties;
   end
   
   %% Make all field names lower case
   %% Note that old mixed case fieldnames are not deleted.
   %% --------------------------------
   fldnames = fieldnames(L);
   for ifld = 1:length(fldnames)
      fLdNaMe     = fldnames{ifld};
      fldname     = lower(fLdNaMe);
      L.(fldname) = L.(fLdNaMe);
   end
   
   % If property is present in property struct
   % - Read size of line properties
   % - Select one line property
   % - Apply one line properties to one line
   % ------------------------
   
   if isfield(L,'linestyle')
      n.linestyle       = size  (L.linestyle      ,1);
      l.linestyle       = L.linestyle      (mod(i-1,n.linestyle      )+1,:);
      set(linehandle,   'linestyle'      ,l.linestyle      );
   end
   if isfield(L,'linewidth')
      n.linewidth       = length(L.linewidth        );
      l.linewidth       = L.linewidth      (mod(i-1,n.linewidth      )+1  );
      set(linehandle,   'linewidth'      ,l.linewidth      );
   end
   if isfield(L,'marker')
      n.marker          = length(L.marker);
      l.marker          = L.marker         (mod(i-1,n.marker         )+1  );
      set(linehandle,   'marker'         ,l.marker         );
   end
   if isfield(L,'markersize')
      n.markersize      = length(L.markersize       );
      l.markersize      = L.markersize     (mod(i-1,n.markersize     )+1  );
      set(linehandle,   'markersize'     ,l.markersize     );
   end
   if isfield(L,'color')
      if isstr(L.color)
      n.color           = length(L.color            ); % rgb triplets or letter codes
      l.color           = L.color          (mod(i-1,n.color          )+1);   
      else
      n.color           = size(L.color            ,1);% rgb triplets or letter codes
      l.color           = L.color          (mod(i-1,n.color          )+1,:);   
      end
      set(linehandle,   'color'          ,l.color          );
   end
   if isfield(L,'markeredgecolor')
      n.markeredgecolor = size  (L.markeredgecolor,1);
      l.markeredgecolor = L.markeredgecolor(mod(i-1,n.markeredgecolor)+1,:);
      set(linehandle,   'markeredgecolor',l.markeredgecolor);
   end
   if isfield(L,'markerfacecolor')
      n.markerfacecolor = size  (L.markerfacecolor,1);
      l.markerfacecolor = L.markerfacecolor(mod(i-1,n.markerfacecolor)+1,:);
      set(linehandle,   'markerfacecolor',l.markerfacecolor);
   end
      
      
   % Return output for one line
   % ---------------------------
   if nargout == 1
      varargout = {l};
   elseif nargout ~=0
      error('Too much output variables, either 1 or 2');
   end   

%% EOF