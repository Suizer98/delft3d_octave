function paramsnew = get_distparam(fhandle,params,P,xP,param_idx)
%GET_DISTPARAM  Finds unknown input parameter for statistical distribution
%
%   Finds unknown input parameter for statistical distribution based on 
%   a known probabilty of non-exceedance and its known associated x-value.
%
%   Syntax:
%   paramsnew = get_distparam(fhandle,params,P,xP,param_idx)
%
%   Input: 
%   fhandle   -- inverse cumulative distribution function handle
%   params    -- params (cell including parameters describing the statistical
%                distribtuion and an initial guess of the to be estimated parameter.
%   P         -- probability of non-exceedance
%   xP        -- accociated x-value
%   param_idx -- parameter to be varied  
%
%   Output:
%   paramsnew = params with params{param_idx} updated such that 
%               feval(fhandle,P,paramsnew{:}) = xP
%
%   Example 1:
%   Find the mean (mu) of a log-normally distributed function with a standard 
%   deviation sigma = 0.5 such that the 95-th percentile is equal to 3.4.
%
%   params = {0,0.5};
%   fhandle = @logn_inv;
%   P = 0.95;
%   xP = 3.4;
%   param_idx = 1;
%
%   paramsnew = get_distparam(fhandle,params,P,xP,param_idx);
%
%   mu = paramsnew{param_idx}
%
%   
%   Example 2:
%   Find the variance (sigma) of a normally distributed function with a
%   mean (mu) = 0.0 such that the 95-th percentile is equal to 3.4.
%
%   params = {0,0.5};
%   fhandle = @norm_inv;
%   P = 0.95;
%   xP = 3.4;
%   param_idx = 2;
%
%   paramsnew = get_distparam(fhandle,params,P,xP,param_idx);
%
%   sigma = paramsnew{param_idx}
%
%   See also feval, norm_inv, logn_inv
% 

% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <Deltares>
%       W. Ottevanger
%
%       willem.ottevanger@deltares.nl
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
% Created: 15 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
param0 = params{param_idx};
paramsnew = params;
y = fzero(@get_param_fun,param0,optimset('Display','off'),fhandle,params,P,xP,param_idx);
paramsnew{param_idx} = y;

    function xPdiff = get_param_fun(param0,fhandle,params,P,xP,param_idx)

       varargin{1} = P; 
       for k = 1:length(params);
          varargin{k+1} = params{k};
       end
          varargin{param_idx+1} = param0;  %replace unknown parameter

          xPnew = feval(fhandle,varargin{:});
          xPdiff = xPnew - xP;
    end

end