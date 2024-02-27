function stochast = exampleStochastVar_2stp(varargin)
%EXAMPLESTOCHASTVAR_2STP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = exampleStochastVar_2stp(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   exampleStochastVar_2stp
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% Created: 10 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: exampleStochastVar_2stp.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/examples/example_2stp/exampleStochastVar_2stp.m $
% $Keywords:

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
        @getHsig_t_2stp...
        @getTp_t_2stp...
        },...
    'Params', {
        {0 .15}...
        mat2cell([1 .1]*225e-6, 1, [1 1])...
        {0 .1}...
        {[1.95 1.85] [7.237 5.341] [0.57 0.63] [0.0158 0.0358] 0.5}... % Hoek van Holland - IJmuiden
        {'WL_t'...
            (1:8)'...
            [5.63155 5.63155 5.63155 6.61472 7.32963 7.9492 8.55 9.15]'...
            (1:8)'...
            [6.49821 6.49821 6.49821 7.74733 8.70674 9.4546 10.08 10.68]'...
            0.5... % lambda
            0.6 0.6}... % sigma1 sigma2
        {'Hsig_t'...
            3.86 1.09... % alfa1 beta1
            4.67 1.12... % alfa2 beta2
            0.5... % lambda
            1 1}... % sigma1 sigma2
        } ...
    );