function stochast = exampleStochastVar(varargin)
%EXAMPLESTOCHASTVAR  routine to create example of stochast variable
%
% Routine creates structure with fields 'Name', 'Distr' and 'Params'. The
% structure should be a row vector. The field 'Name' contains the variable
% names. The field 'Distr' contains function handles of the respective pdf
% functions (e.g. @norm_inv for normal distribution), these can also be
% custom functions (as long as the first input argument is P and the other
% arguments are specified in the field 'Params'). The field 'Params'
% contains the parameters for the respective distributions specified as
% cell arrays. Parameters can also be specified by cell (row) arrays, where
% the first argument is a function handle and the others are the input
% arguments; in that case feval will be applied. When specifing a parameter
% as a string corresponding with a variable name, the result of the
% corresponding variable will be applied.
%
%   Syntax:
%   varargout = exampleStochastVar(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   exampleStochastVar
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: exampleStochastVar.m 7360 2012-09-28 14:40:41Z heijer $
% $Date: 2012-09-28 22:40:41 +0800 (Fri, 28 Sep 2012) $
% $Author: heijer $
% $Revision: 7360 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/examples/example/exampleStochastVar.m $

%%
stochast = struct(...
    'Name', {
        'Accuracy'...
        'D50'...
        'Duration'...
        'WL_t'...
        'Hsig_t'...
        'Tp_t'...
        },...
    'Distr', {
        @norm_inv...
        @norm_inv...
        @norm_inv...
        @conditionalWeibull...
        @norm_inv...
        @norm_inv...
        },...
    'Params', {
        {0 .15}...
        num2cell([1 .1]*225e-6)...
        {0 .1}...
        {1.95 7.237 0.57 0.0158}...
        {{@getHsig_t 'WL_t' 4.35 .6 .0008 7 4.67} 0.6}...
        {{@interp1...
            [3.339 4.227 4.862 5.367 5.791 6.159 6.484 6.777 7.044 7.289 7.516 7.728 7.926 8.114 8.291 8.459 8.619 8.771 8.917 9.057 9.192 9.322 9.447 9.568 9.684 9.798]...
            [7.821 8.61 9.235 9.756 10.204 10.598 10.95 11.269 11.561 11.83 12.079 12.312 12.531 12.737 12.932 13.117 13.293 13.461 13.621 13.775 13.923 14.065 14.203 14.335 14.463 14.586]...
            'Hsig_t' 'linear' 'extrap'} 1}...
        } ...
    );

%%
OPT = struct(...
    'active', true(size(stochast)));

OPT = setproperty(OPT, varargin{:});

for i = find(~OPT.active)
    stochast(i).Distr = @deterministic;
    stochast(i).Params = {0};
end