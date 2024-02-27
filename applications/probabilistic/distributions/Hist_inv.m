function X =  Hist_inv(P, XP)
% Hist_INV  inverse of the discrete probability distribution 
%
% inverse cdf of a discrete probability distribution, with a finite number of outcomes. A
% All possible discrete realisations and asociated probabilities of occurrence are described by a "table"
%
% input
%    - P:    array of probabilties of non-exceedance. All elements of this array have to be between 0 and 1
%    - XP:   nx2 table with x-values and asociated probabilities of occurrence 

% output
%    - X:     x-values, asociated with input P
%
%   Example
%   X =  Hist_inv(P, XP)
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

% $Id: Hist_inv.m 12810 2016-07-20 09:49:36Z kaste $
% $Date: 2016-07-20 17:49:36 +0800 (Wed, 20 Jul 2016) $
% $Author: kaste $
% $Revision: 12810 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/Hist_inv.m $

%% checks
if size(XP,2)>2 && size(XP,1)==2
    XP=XP';
end
if size(XP,2)~=2 
   error('input table has wrong dimensions'); 
end
if abs(sum(XP(:,2))-1)>1e-15 
    error('sum of probabilities is not equal to 1'); 
end
if any(XP(:,2))<0
   error('probabilities should be positive'); 
end
if length(unique(XP(:,1)))<size(XP,1);
   error('X-values of input table should be unique'); 
end


%% remove zeros
ind0 = XP(:,2)==0;
XP(ind0,:)=[];


%% derive X-values
XPs=sortrows(XP,1);     % sort values of lookup table in ascending order
Plookup = [0; cumsum(XPs(:,2))];
X = NaN(size(P));
for j=1:size(XP,1);
    index = P>Plookup(j) & P<=Plookup(j+1);
    X(index) = XPs(j,1);    
end



