function sp2 = xb_swan_split(sp2, dim, varargin)
%XB_SWAN_SPLIT  Split a SWAN struct with a single file into a struct with multiple files
%
%   Split a SWAN struct with a single file into a struct with multiple
%   files.
%
%   Syntax:
%   sp2 = xb_swan_split(sp2, dim, varargin)
%
%   Input:
%   sp2       = SWAN struct with single file
%   dim       = Dimension to be splitted (time/location/etc)
%   varargin  = none
%
%   Output:
%   sp2       = SWAN struct with multiple files
%
%   Example
%   sp2 = xb_swan_split(sp2, 'time')
%
%   See also xb_swan_join

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_swan_split.m 4036 2011-02-15 15:32:35Z hoonhout $
% $Date: 2011-02-15 23:32:35 +0800 (Tue, 15 Feb 2011) $
% $Author: hoonhout $
% $Revision: 4036 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_swan/xb_swan_split.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% split sp2 file

sp2_split = xb_swan_struct();

% check wheather specified dimension exists and contains data
if isfield(sp2,dim) && isfield(sp2.(dim),'data') && ...
        ismember(dim,{'time','location','frequency','direction'})

    % loop through specified dimension
    for i = 1:size(sp2.(dim).data,1)
        sp2_split(i) = sp2;

        % split along dimension
        sp2_split(i).(dim).nr = 1;
        sp2_split(i).(dim).data = sp2.(dim).data(i,:);

        switch dim
            case 'time'
                sp2_split(i).spectrum.factor = sp2.spectrum.factor(i,:);
                sp2_split(i).spectrum.data = sp2.spectrum.data(i,:,:,:);
            case 'location'
                sp2_split(i).spectrum.factor = sp2.spectrum.factor(:,i);
                sp2_split(i).spectrum.data = sp2.spectrum.data(:,i,:,:);
            case 'frequency'
                sp2_split(i).spectrum.data = sp2.spectrum.data(:,:,i,:);
            case 'direction'
                sp2_split(i).spectrum.data = sp2.spectrum.data(:,:,:,i);
        end
    end
else
    error(['Unknown or not allowed dimension [' dim ']']);
end

sp2 = sp2_split;
