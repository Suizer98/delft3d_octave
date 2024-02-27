function [z x_var1] = u2z(varargin)
%
%   This routine evaluates the 'x2zFunction' at the specified u-values of the
%   indicated stochastic variables in standard normal space. 
%   The other stochastic variables are set as deterministic variables having a 
%   value at which the probability of non-exceedance is 0.5.
%
%   Syntax:
%   [z] = u2z(varargin)
%
%   input:
%   varargin = series of keyword-value pairs to set properties
%
%   output:
%   z = z-value of the point at which the limit state function is evaluated
%   x_var1 = x-vale of the first variable in NameVar

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

% $Id: u2z.m 9098 2013-08-23 09:08:28Z hengst $
% $Date: 2013-08-23 17:08:28 +0800 (Fri, 23 Aug 2013) $
% $Author: hengst $
% $Revision: 9098 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/general/u2z.m $
% $Keywords: $

% defaults
OPT = struct(...
    'stochast',         struct(),... % stochast structure
    'x2zFunction',      @x2z,...  % Function to transform x to z    
    'x2zVariables',     {{}},... % additional variables to use in x2zFunction
    'method',           'matrix',... % z-function method 'matrix' (default) or 'loop'
    'NameVar',          {'NameVar1'},... % Names of the variables with a u value different from 0
    'UvalueVar',        [0]... % The u value of the variables with a u value different from 0
     );
     
% Overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.NameVar);
    error('Please indicate at least one variable with a u-value different from 0');
end

if sum(ismember({OPT.stochast.Name},OPT.NameVar))==0
    error('THe indicated variables in the vector NameVar are not present in the stochast');
end

for k=1:length(OPT.NameVar);
        
    % Find index selected stochastic variables
    [index] = ismember({OPT.stochast.Name},OPT.NameVar(k));
    ind(k) = find(index);

end
    
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

%  Construct U-vector
u = 0.5*ones(1,length(OPT.stochast)); % u=0.5 (corresponds to median)
for i = 1:length(OPT.NameVar)
    u(1,ind(i)) = OPT.UvalueVar(i);
end

% convert u to P and x
[P x] = u2Px(OPT.stochast, u);

% derive z
z = prob_zfunctioncall(OPT, OPT.stochast, x);
x_var1 = x(ind(1));