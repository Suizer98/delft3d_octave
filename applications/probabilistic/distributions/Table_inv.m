function X =  Table_inv(P, XP, Logyn)
% Table_inv  cdf of the "Table" probability distribution 
%
% This distribution is described by pairs of x-p values, where p is the
% probability of non-exceedance for all other values of X, the
% corresponding probability of non-exceedance is based on interpolation.
%
%
% input
%    - P:    probabilities of non-exceedance of X-values 
%    - XP:    nx2 table with x-values and asociated probabilities of non-exceedanace 
%    - Logyn  'true' or '1' if log-linear interpolation between p-values is used,
%             'false' or '0' if normal interpolation is used
%
% output
%    - X:     x-values for which probabilities are determined
%
%   Example
%   P =  Table_inv(X, XP, true)
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 
%       F.L.M. Diermanse
%
%       Fedrinand.diermanse@Deltares.nl	
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 29 jan 2013
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: Table_inv.m 8579 2013-05-06 13:31:32Z dierman $
% $Date: 2013-05-06 21:31:32 +0800 (Mon, 06 May 2013) $
% $Author: dierman $
% $Revision: 8579 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/Table_inv.m $

%% checks
if size(XP,2)>2 && size(XP,1)==2
    XP=XP';
end
if size(XP,2)~=2 
   error('input table has wrong dimensions'); 
end
if any(XP(:,2)<0 | XP(:,2)>1)
   error('probabilities should be between 0 and 1'); 
end
if length(unique(XP(:,1)))<size(XP,1);
   error('X-values of input table should be unique'); 
end

%% interpolate
xt = XP(:,1);
pt = XP(:,2);
if Logyn  % take log values
   % first remove zeros 
   ind0 = pt==0;
   pt(ind0) = [];
   xt(ind0) = [];
   pt=log(pt);
   P=log(P);
end
X = interp1(pt, xt, P);
