function varargout = count(varargin)
%COUNT   counts freqeuncy of unique values
%
% [n_occurrences, c, ia, ic] = count(varargin)
% where c, ia, ic is the output of unique(varargin)
% varargin = the same as for unique
%
% Example: 
%   count([1 1 1 2 2 3]) gives [3 2 1]
% Also observe the differences in 
%   [n_occurrences, c] = count(['bbcaaa';'aaabbc']);
%   [n_occurrences, c] = count(['bbcaaa';'bbcaaa'],'rows');
%
%See also: HIST, MODE, ISMEMBER, UNIQUE, INTERSECT

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%
%       Gerben J. de Boer
%       g.j.deboer@tudelft.nl	
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

% $Id: count_unique.m 15231 2019-03-19 10:17:40Z joris.vanlede.x $
% $Date: 2019-03-19 18:17:40 +0800 (Tue, 19 Mar 2019) $
% $Author: joris.vanlede.x $
% $Revision: 15231 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/count_unique.m $
% $Keywords$

[c,ia,ic]     = unique(varargin{:});
n_occurrences = histc(int32(ic),int32(1:length(ia)));
varargout     = {n_occurrences,c,ia,ic};


%% EOF