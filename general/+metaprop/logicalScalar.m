% LOGICALSCALAR property for a single logical (true/false)
%
% See also: metaprop.example

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
%       Netherlands
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
% Created: 21 Feb 2014
% Created with Matlab version: 8.3.0.73043 (R2014a)

% $Id: logicalScalar.m 10272 2014-02-24 11:32:31Z tda.x $
% $Date: 2014-02-24 19:32:31 +0800 (Mon, 24 Feb 2014) $
% $Author: tda.x $
% $Revision: 10272 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+metaprop/logicalScalar.m $
% $Keywords: $

%%
classdef logicalScalar < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Boolean');
    end
    properties (SetAccess=immutable)
        jEditor = com.jidesoft.grid.BooleanCheckBoxCellEditor;
        jRenderer = com.jidesoft.grid.BooleanCheckBoxCellRenderer;
    end
    methods
        function self = logicalScalar(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'scalar'};
            self.DefaultClasses    = {'logical'};

            self.CheckDefault();
        end
        function updateRenderer(self)
            self.jRenderer.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        end
     end
end