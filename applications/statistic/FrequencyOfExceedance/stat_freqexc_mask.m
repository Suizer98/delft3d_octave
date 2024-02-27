function [t x] = stat_freqexc_mask(t,x,varargin)
%STAT_FREQEXC_MASK  Masks a timeseries based on the time axis
%
%   Masks parts of a time series based on one or more masks. The masks are
%   applied on the time axis and are based on the datestr function. Points
%   in the time series that DO NOT match a mask are set to nan. A mask
%   consists of a cell array with two items. The first item is a datestr
%   expression, while the second is a cell or numerical array with valid
%   values for this expression. The first item in a mask can be preceded by
%   a ^-sign, indicating NOT. In this case the point matching the mask are
%   set to nan.
%
%   The result is a time series with nan's.
%
%   Syntax:
%   [t x] = stat_freqexc_mask(t,x,varargin)
%
%   Input:
%   t         = time axis of timeseries (datenum format)
%   x         = level axis of time series
%   varargin  = masks
%
%   Output:
%   t         = time axis of timeseries (datenum format)
%   x         = level axis of time series
%
%   Example
%   % only use the first three months of any year, but skip the first day
%   [tm xm] = stat_freqexc_mask(t,x,{'mm', [1 2 3]},{'^dd', 1})
%
%   figure; hold on;
%   plot(t,x,'-b');
%   plot(tm,xm,'-r');
%
%   See also stat_freqexc_get

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
% Created: 06 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_mask.m 5331 2011-10-13 16:09:35Z hoonhout $
% $Date: 2011-10-14 00:09:35 +0800 (Fri, 14 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5331 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_mask.m $
% $Keywords: $

%% apply masks

for i = 1:length(varargin)
    if length(varargin{i})>1
        
        m   = varargin{i}{2};
        
        if ischar(varargin{i}{1})
            
            not = varargin{i}{1}(1) == '^';
            
            if not
                varargin{i}{1} = varargin{i}{1}(2:end);
            end
            
            tm  = num2cell(datestr(t, varargin{i}{1}),2);
        
            switch class(m)
                case {'single' 'double' 'logical'}
                    tm  = str2double(tm);
                    m   = double(m);
            end
        else
            tm  = t;
        end
        
        idx    = ismember(tm,m) == not;
        
        x(idx) = nan;
    end
end