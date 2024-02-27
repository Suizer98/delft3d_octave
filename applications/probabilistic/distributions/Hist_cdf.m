function P =  Hist_cdf(X, XP)
% Hist_cdf  cdf of the discrete probability distribution 
%
% determines the probability of occurrence of X-values, based on a discrete probability distribution, 
% with a finite number of outcomes. All possible discrete realisations and asociated probabilities of
% occurrence are described by a "table"
%
% input
%    - X:    x-values for which probabilities are determined
%    - XP:   nx2 table with x-values and asociated probabilities of occurrence 

% output
%    - P:    probabilities of non-exceedance of X-values 
%
%   Example
%   P =  Hist_cdf(X, XP)
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

% $Id: Hist_cdf.m 8396 2013-04-02 15:36:05Z dierman $
% $Date: 2013-04-02 23:36:05 +0800 (Tue, 02 Apr 2013) $
% $Author: dierman $
% $Revision: 8396 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/distributions/Hist_cdf.m $

%% checks
if size(XP,2)>2 && size(XP,1)==2
    XP=XP';
end
if size(XP,2)~=2 
   error('input table has wrong dimensions'); 
end
if sum(XP(:,2))-1>1e-15 
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

%% derive P-values
XPs=sortrows(XP,1);     % sort values of lookup table in ascending order
XPs(:,2) = cumsum(XPs(:,2));
[memberyn, index] = ismember(X, XPs(:,1));
if ~all(memberyn)
   error('input X contains values that are not available in table XP');
end
P = XPs(index,2);
