function handles = ddb_initializeDD(handles, varargin)
%DDB_INITIALIZEDD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeDD(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeDD
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

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.toolbox.dd.longName='Domain Decomposition';
            return
    end
end

handles.toolbox.dd.mRefinement=5;
handles.toolbox.dd.nRefinement=5;
handles.toolbox.dd.firstCornerPointM=NaN;
handles.toolbox.dd.firstCornerPointN=NaN;
handles.toolbox.dd.secondCornerPointM=NaN;
handles.toolbox.dd.secondCornerPointN=NaN;
handles.toolbox.dd.domains={''};
handles.toolbox.dd.newRunid='new';
handles.toolbox.dd.attributeName='new';
handles.toolbox.dd.DDBoundaries=[];
handles.toolbox.dd.cornerPointHandles=[];
handles.toolbox.dd.adjustBathymetry=1;
%handles.toolbox.dd.ddFile='test.ddb';

