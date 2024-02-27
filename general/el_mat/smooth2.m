function varargout = smooth2(data,varargin)
%SMOOTH2 Smooth 2D data.
%
%    W = SMOOTH2(V)
%    W = SMOOTH2(V, METHOD)
%    W = SMOOTH2(V, METHOD, SIZE)
%    W = SMOOTH2(V, METHOD, SIZE, ARG)
%
% smoothes a 2D map field V, using SMOOTH3. As SMOOTH2
% is a wrapper to smooth 3, it uses the same basic
% (optional) argument list (METHOD, SIZE, ARG) as to SMOOTH3,
% However, the filter size can be passed as a 1,2 or 3D array
% and is 3 by default.
%
% See also SMOOTH1, SMOOTH3

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: smooth2.m 623 2009-07-06 16:29:00Z damsma $
% $Date: 2009-07-07 00:29:00 +0800 (Tue, 07 Jul 2009) $
% $Author: damsma $
% $Revision: 623 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_mat/smooth2.m $
% $Keywords$

OPT.filter = 'box';
OPT.SIZE   = [3 3 3];
OPT.ARG    = 'gaussian';

if nargin>1
    OPT.filter = varargin{1};
end

if nargin>2
    OPT.SIZE = varargin{2};
    if numel(OPT.SIZE)==1
        OPT.SIZE = [OPT.SIZE OPT.SIZE 1];
    elseif numel(OPT.SIZE)==2
        OPT.SIZE = [OPT.SIZE 1];
    end
end

if nargin>3
    OPT.ARG = varargin{2};
end

data3         = repmat(data,[1 1 2]);

data_smoothed = smooth3(data3,OPT.filter,OPT.SIZE,OPT.ARG);

varargout     = {squeeze(data_smoothed(:,:,1))};

%% EOF
