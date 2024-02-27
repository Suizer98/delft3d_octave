function [U1,U2,Z] = u2z_grid(varargin)
%
%   This routine evaluates the 'x2zFunction' at the gridpoints of a
%   grid made up of values of the two selected stochastic variables. 
%   The other stochastic variables are set as deterministic variables 
%   having a value at which the probability of non-exceedance is 0.5.
%
%   Syntax:
%   [U1,U2,Z] = LSFgrid(varargin)
%
%   input:
%   varargin = series of keyword-value pairs to set properties
%
%   output:
%   U1 matrix with values in the standard normal space of the first variable
%   U2 matrix with values in the standard normal space of the first variable
%   Z matrix with vales of the limit state function
%
%   The matrices U1, U2 and Z correspond to each other

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       hengst
%
%       Simon.denHengst@deltares.nl	
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 25 Feb 2013
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: u2z_grid.m 9097 2013-08-23 08:13:10Z hengst $
% $Date: 2013-08-23 16:13:10 +0800 (Fri, 23 Aug 2013) $
% $Author: hengst $
% $Revision: 9097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/u2z_grid.m $
% $Keywords: $

% defaults
OPT = struct(...
    'stochast',         struct(),... % stochast structure
    'x2zFunction',      @x2z,...  % Function to transform x to z    
    'x2zVariables',     {{}},... % additional variables to use in x2zFunction
    'method',           'matrix',... % z-function method 'matrix' (default) or 'loop'
    'NameVar1',         'Var1',... % Variable on the horizontal axis of the grid
    'DomainVar1',       [-6 6],... % Domain of the horizontal axis in standard normal space
    'NameVar2',         'Var2',... % Variable on the vertical axis of the grid
    'DomainVar2',       [-6 6],... % Domain of the vertical axis in standard normal space
    'NrGridpoints',     [100 100]... % Number of grid points
     );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

% Check if the square root of the number of grid points is 
if length(OPT.NrGridpoints(:)) == 1;
    error('The NrGridpoints is a single value while it should be a vector containing the numer of grid points of each variable')
end

% Find index selected stochastic variables
[index] = ismember({OPT.stochast.Name}, {OPT.NameVar1});
ind(1) = find(index);

% Find index selected stochastic variables
[index] = ismember({OPT.stochast.Name}, {OPT.NameVar2});
ind(2) = find(index);

% Calculate value with the highest probability density of each stochastic
% variable other than the selected stochastic variables
% Transform the other stochastic variables to deterministic variables 
% having a value at which the probability of non-exceedance is 0.5.
for k=1:length(OPT.stochast)
    val(k) = feval(OPT.stochast(k).Distr,0.5,OPT.stochast(k).Params{:});
    if sum(k == ind) == 0;
        [OPT.stochast(k).Distr] = deal(@deterministic);
        [OPT.stochast(k).Params] = deal({val(k)});
    end
end

% generate a grid
u1range = linspace(OPT.DomainVar1(1),OPT.DomainVar1(2),OPT.NrGridpoints(1));
u2range = linspace(OPT.DomainVar2(1),OPT.DomainVar2(2),OPT.NrGridpoints(2));
[U1,U2] = meshgrid(u1range,u2range);

% dimensions
[n1, n2] = size(U1);
N = numel(U1);

% make column vectors
Uc1 = reshape(U1,N,1);
Uc2 = reshape(U2,N,1);

% make U-matrix for all variables
U = 0.5*ones(N,length(OPT.stochast)); % u=0.5 (corresponds to median)
U(:,ind(1))=Uc1;        % u-values of first variable
U(:,ind(2))=Uc2;        % u-values of second variable

% convert u to P and x
[P x] = u2Px(OPT.stochast, U);

% derive z
z = prob_zfunctioncall(OPT, OPT.stochast, x);

% put z-values in 2D-grid
Z = reshape(z,n1,n2);
