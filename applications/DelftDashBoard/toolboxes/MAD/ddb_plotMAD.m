function ddb_plotMAD(option, varargin)
%DDB_PLOTMAD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotMAD(option, varargin)
%
%   Input:
%   option   =
%   varargin =
%
%
%
%
%   Example
%   ddb_plotMAD
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
switch lower(option)
    case{'delete'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            delete(h);
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            delete(h);
        end
    case{'activate'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            set(h,'Visible','on');
        end
    case{'deactivate'}
        h=findall(gca,'Tag','MADModels');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findall(gca,'Tag','ActiveMADModel');
        if ~isempty(h)
            set(h,'Visible','off');
        end
end


