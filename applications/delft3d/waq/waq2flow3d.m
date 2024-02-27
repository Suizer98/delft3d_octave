function flowarray = waq2flow3D(WAQarray,pointerarray,varargin)
%WAQ2FLOW3D   Maps 1D WAQ array to 3D FlOW matrix
%
% flowarray = waq2flow3D(WAQarray,pointerarray)
%
% stores the data from a 1D WAQ (Lgrid) array (not containing dry 
% points) in the full flow array (containing all points,
% including dry points) where pointerarray comes from 
% from Delwaq('open','*.lga') or Delwaq('open','*.cco').
%
% flowarray = waq2flow(WAQarray,pointerarray,'cen<ter>')  removes the 1st
%                                                         and last dummy rows 
%                                                         and columns.
%
% flowarray = waq2flow(WAQarray,pointerarray,'cor<ner>')  removes the 
%                                                         last dummy row 
%                                                         and column.
%
% flowarray = waq2flow(WAQarray,pointerarray,'del<ft3d>') removes nothing
%
% flowarray = waq2flow(WAQarray,pointerarray,'d3d')       (default)
%
%  +-------> FLOW n direction (1st direction in which Delwaq counts)
%  |  ... ... ... ... ... ... ...    ... ... ... ... ... ... ...
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...   1   2   3   4   5 ...
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...   6   7   8   9  10 ...
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...  11  12  13  14  15 ...
%  |  ... ~~~ ~~~ ### ~~~ ~~~ ...    ...  16  17   0  18  19 ...
%  |  ... ~~~ ~~~ ### ~~~ ~~~ ...    ...  20  21   0  22  23 ... 
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...  24  25  26  27  28 ...
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...  29  30  31  32  33 ...
%  |  ... ~~~ ~~~ ~~~ ~~~ ~~~ ...    ...  34  35  36  37  38 ...
%  |  ... ... ... ... ... ... ...    ... ... ... ... ... ... ... 
%  v
%  FLOW m -direction (2nd dimension in which Delwaq counts)
%
%     FLOWARRAY (left):              POINTERARRAY (right): contains
%                                    for each position in the
%     ~~~ = active wet point         flowarray the position in the 
%     ### = inactive dry point       WAQarray where the data is to
%     ... = inactive boundary        be found. 0 = means inactive,
%           point                    negative indicates an inactive 
%                                    boundary element.
%
%  The 3rd dimension in which Delwaq counts is k:
%  from k=1 at water surface to k=kmax at bottom
%
%   WAQarray: 1D array with lenght = max(pointerarray) = 38;
%
%   [1   2   3   .....   36  37  38]
% 
% See also:
% WAQ2FLOW2D, FLOW2WAQ3D, FLOW2WAQ3D_COUPLING, DELWAQ

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl (also: gerben.deboer@wldelft.nl)
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

% $Id: waq2flow3d.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/waq2flow3d.m $

   flowarray  = nan.*zeros([size(pointerarray)]);
   
   for m=1:size(pointerarray,1)
   for n=1:size(pointerarray,2)
   for k=1:size(pointerarray,3)
      if ~(pointerarray(m,n)<=0)
      flowarray(m,n,k) = WAQarray(round(pointerarray(m,n,k)));
      end
   end
   end
   end

   if nargin==3
      boundaryhandling = lower(varargin{1});
      if     strcmp(boundaryhandling(1:3),'cen'); flowarray = flowarray(2:end-1,2:end-1,:);
      elseif strcmp(boundaryhandling(1:3),'cor'); flowarray = flowarray(1:end-1,1:end-1,:);
      elseif strcmp(boundaryhandling(1:3),'del') | ...
             strcmp(boundaryhandling(1:3),'d3d')
         %flowarray = flowarray(:,:);
      end
   end
   
%% EOF
