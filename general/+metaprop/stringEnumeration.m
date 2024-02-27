% STRINGENUMERATION property for a string that is limited to a set of possible values (on/off,left/right/top/bottom, etc)
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

% $Id: stringEnumeration.m 10526 2014-04-11 14:26:03Z tda.x $
% $Date: 2014-04-11 22:26:03 +0800 (Fri, 11 Apr 2014) $
% $Author: tda.x $
% $Revision: 10526 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+metaprop/stringEnumeration.m $
% $Keywords: $

%%
classdef stringEnumeration < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess = immutable)
        jEditor
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    properties
        Options = {}
    end
    methods
        function self = stringEnumeration(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {'row'};
            self.DefaultClasses    = {'char'};

            self.CheckDefault();
                    
            self.jEditor = com.jidesoft.grid.ListComboBoxCellEditor(self.Options);
        end
        function set.Options(self,value)
            % check options
            validateattributes(value,{'cell'},{'vector','nonempty'},self.DefiningClass.Name,[self.Name '.Options'])
            assert(iscellstr(value))
            self.Options = value;
        end
        % Overload Check method
        function Check(self,value) % error/no error
            validatestring(value,self.Options,self.DefiningClass.Name,self.Name);
        end
        
    end
end