function out = datenumnan(varargin)
%  datenumnan datenum-version that does not crash on text but returns nans
%  
%      S = datenum(...)
%  
%      Examples:
%
%      datenumnan('foo')
%      datenumnan({'2018-01-01','#N/A'}) % e.g. empty Excel values
%      datenumnan({'2018-01-01','#N/A'}.')
%      datenumnan(char({'2018-01-01','#N/A'}))
%
% Only chars and cellstr are supported, no date vectors (as datenum does).
%  
%   See also: datenum, datestrnan

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Gerben J. de Boer
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: datenumnan.m 15023 2019-01-08 16:41:12Z gerben.deboer.x $
% $Date: 2019-01-09 00:41:12 +0800 (Wed, 09 Jan 2019) $
% $Author: gerben.deboer.x $
% $Revision: 15023 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/datenumnan.m $
% $Keywords: $

try
    out = datenum(varargin);
    % out = cellfun(@(x) datenum(x,varargin{2:end}) ,varargin{1}); % faster
catch
    in = cellstr(varargin{1});
    out = nan(size(in));
    for i=1:length(in)
        try
            out(i) = datenum(in{i});
        catch
            out(i) = nan;
        end
    end
end
