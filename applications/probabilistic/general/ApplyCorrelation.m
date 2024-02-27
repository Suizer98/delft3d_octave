function  [uCorr, correlated] = ApplyCorrelation(u,C)
% ApplyCorrelation: apply correlation matrix on u-values 
% if input u-values are independent and standard normally distrubuted, afterwards they will be 
% correlation according to the Gaussian correlation with correlation
% matrix C
%
% inverse cdf of a discrete probability distribution, with a finite number of outcomes. A
% All possible discrete realisations and asociated probabilities of occurrence are described by a "table"
%
% input
%    - u:   mxn array: M realisations of n standard normally distributed random variables 
%    - C:   nxn correlation matrix

% output
%    - uCorr:      correlated u-values
%    - correlated: indicator of random variables that are mutually correlated 
%
%   Example
%   u =  ApplyCorrelation(u, C)
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

% $Id: ApplyCorrelation.m 8508 2013-04-24 15:36:30Z dierman $
% $Date: 2013-04-24 23:36:30 +0800 (Wed, 24 Apr 2013) $
% $Author: dierman $
% $Revision: 8508 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/ApplyCorrelation.m $

%% check if C is a proper correlation matrix
n=size(C,1);

% check if C is symetric
if ~isequal(C',C)
    error('correlation matrix should be symetric');
end

% check if diagonal consist of ones
if ~isequal(diag(C), ones(n,1))
   error('diagonal should consist of ones');
end

% check if absolute values are between 0 and 1
if max(max(abs(C)))>1 || min(min(abs(C)))<0
   error('absolute values should be between 0 and 1');
end

% check if dimensions of C and u correspond
if size(u,2)~=n
    error('nr of columns of u and C are not the same');
end

%% identify subset of random variables that are mutually corelated 
correlated = true(n,1);
cmvec = [zeros(n-1,1); 1];
for col =1:n
    if isequal(sort(C(:,col)), cmvec)
       correlated(col)=false; 
    end
end

% relevant subset of correlation matrix
CC=C(correlated, correlated);
nCC=size(CC,1);


%% apply correlation matrix on correlated variables only

% deal with corr values outside diagonal equal to 1 
% because they can cause the correlation matrix to become non positive
% definite
eps=1e-15;
ID1 = CC-eye(nCC) > 1-eps;
CC(ID1)=1-eps;

% derive  for whic PP'=C, through Cholesky-decomposition
Pm = chol(CC);

% deal with corr values outside diagonal equal to 1  
eps=1e-15;
ID2 = Pm-eye(nCC) > 1-2*eps;
Pm(ID1&ID2)=1;

% apply correlation 
uCorr = u;
uCorr(:,correlated) = u(:,correlated)*Pm;


