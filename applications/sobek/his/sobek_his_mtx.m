function varargout = sobek_his_mtx(his, varargin)
%SOBEK_HIS_MTX  Converts a HIS file structure to a matrix
%
%   Converts a structure obtained from the sobek_his_read function to a
%   matrix as if a SOBEK ascii file is read from disk. For each parameter
%   a separate matrix is returned.
%
%   Syntax:
%   varargout = sobek_his_mtx(his, varargin)
%
%   Input:
%   his       = Result structure from sobek_his_read function
%   varargin  = none
%
%   Output:
%   varargout = Matrices for each parameter with dimensions
%               time x (locations + 3)
%               where the first three columns indicate year, month and day
%               respectively
%
%   Example
%   his = sobek_his_read('CALCPNT.HIS');
%   A   = sobek_his_mtx(his);
%
%   See also sobek_his_read

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
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
% Created: 14 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: sobek_his_mtx.m 5331 2011-10-13 16:09:35Z hoonhout $
% $Date: 2011-10-14 00:09:35 +0800 (Fri, 14 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5331 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/sobek/his/sobek_his_mtx.m $
% $Keywords: $

%% read settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% create matrices

varargout = cell(1,size(his.data,2));

for i = 1:size(his.data,2)
    varargout{i} = [str2num(datestr(his.time, 'yyyy mm dd')) squeeze(his.data(:,i,:))];
end