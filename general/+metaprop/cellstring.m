% CELLSTRING property that can be either a string or a cellstring. Has multiline editor
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

% $Id: cellstring.m 10630 2014-05-01 10:13:52Z tda.x $
% $Date: 2014-05-01 18:13:52 +0800 (Thu, 01 May 2014) $
% $Author: tda.x $
% $Revision: 10630 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+metaprop/cellstring.m $
% $Keywords: $

%%
classdef cellstring < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('java.lang.Character');
    end
    properties (SetAccess=immutable)
        jEditor = com.jidesoft.grid.MultilineStringCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = cellstring(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultAttributes = {};
            self.DefaultClasses    = {};
            
            self.CheckDefault();
            
            self.jRenderer.disable();
        end
        function Check(self,value) % error/no error
            if iscellstr(value)
                atts = [{'vector'},self.Attributes];
                % merge default and custom attributes, as more atts is more restrictive
                % more classes means more permissive, so do seperate checks for
                % default attributes and custom classes. If no custom classes are
                % defined, skip the ceck
                if ~isempty(value)
                    validateattributes(value,{'cell'},atts,self.DefiningClass.Name,self.Name)
                end
                if ~isempty(self.Classes)
                    validateattributes(value,self.Classes,{},self.DefiningClass.Name,self.Name)
                end
            elseif ischar(value)
                if ~isempty(value)
                    atts = [{'row'},self.Attributes];
                    validateattributes(value,{'char'},atts,self.DefiningClass.Name,self.Name)
                end
            else
                error('Error setting %s.%s, expected input to be a string or cellstring',self.DefiningClass.Name,self.Name)
            end
        end
    end
    
    methods (Static)
        function jValue = jValue(mValue)
            % conversion from matlab value to java value
            if iscellstr(mValue)
                jValue = sprintf('%s\n',mValue{:});
                % trim last linebreak
                jValue = jValue(1:end-1);
            else
                jValue = mValue;
            end
        end
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            % make cellstr from string with linebreaks
            if isempty(jValue)
                mValue = '';
            else
                mValue = regexp(jValue,sprintf('\n'),'split')';
            end
        end
    end
end