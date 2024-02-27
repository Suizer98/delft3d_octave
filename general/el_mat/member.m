function varargout = member(A,S)
%MEMBER    returns values for which True for set member.
%
% [C,IA] = MEMBER(A,S)
%
% [C,IA] = INTERSECT(A,S) only returns index vector IA such
% that C = A(IA), where A(IA) are not all values in A that are 
% in S, while [C,IA]=member(A,S) returns vector IA 
% such that A(IA) yields all values in A that are in S.
% Accordingly [C,IA] = INTERSECT(A,S) yields C with unqiue values only,
% while [C,IA] = MEMBER(A,S) may have have repititions.
%
% Example: intersect([1 1 1 2 2 3],[2 3]) yields IA = [4 5 6]
%          member   ([1 1 1 2 2 3],[2 3]) yields IA = [5 6]
%
%See also: ISMEMBER, INTERSECT

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

% $Id: member.m 390 2009-04-22 09:07:39Z boer_g $
% $Date: 2009-04-22 17:07:39 +0800 (Wed, 22 Apr 2009) $
% $Author: boer_g $
% $Revision: 390 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/member.m $
% $Keywords$

[TF,LOC]   = ismember(A,S);

LOC = find(LOC);

AonS = A(TF);

if nargout < 2

   varargout = {AonS};

elseif nargout==2

   varargout = {AonS, LOC};

end

%% EOF