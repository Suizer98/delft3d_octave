function varargout = peri2cell(varargin)
%peri2cell   turn perimeter matrix into cell
%
%     G = dflowfm.readNet(ncfile,'peri2cell',0) 
%
%     x    = dflowfm.peri2cell(G.peri.x);
%     y    = dflowfm.peri2cell(G.peri.y);
%    [x,y] = dflowfm.peri2cell(G.peri.x,G.peri.y) 
%
% This function makes a kind of ragged array from the 
% nan-padded perimeter matrix.
%
% See also: dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

% $Id: peri2cell.m 4550 2011-05-05 10:11:03Z dam_ar $
% $Date: 2011-05-05 18:11:03 +0800 (Thu, 05 May 2011) $
% $Author: dam_ar $
% $Revision: 4550 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/peri2cell.m $
% $Keywords: $

%% pre allocate

   for iarg=1:nargin
      n(iarg) = size(varargin{iarg},2);
      varargout{iarg} = cell(1,n(iarg));
   end
   
   n = unique(n);
   
   if length(n) > 1; error('not all args have same size.');end;
   
%% do work

   for iarg=1:nargin
   for icen = 1:n
      ind                   = find(~isnan(varargin{iarg}(:,icen)));
      varargout{iarg}{icen} = varargin{iarg}([ind' 1],icen);
   end
   end
