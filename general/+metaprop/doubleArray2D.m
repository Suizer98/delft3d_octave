% DOUBLEARRAY2D property for a 2d array of double precision numbers. Editor has one line for each row
% expands further to one line for each element

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

% $Id: doubleArray2D.m 10276 2014-02-24 16:11:40Z tda.x $
% $Date: 2014-02-25 00:11:40 +0800 (Tue, 25 Feb 2014) $
% $Author: tda.x $
% $Revision: 10276 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+metaprop/doubleArray2D.m $
% $Keywords: $

%%
classdef doubleArray2D < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('[[D')
    end
    properties (SetAccess=immutable)        
        jEditor = com.jidesoft.grid.DoubleCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = doubleArray2D(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultClasses    = {'double'};
            self.DefaultAttributes = {'2d'};
            
            self.CheckDefault();
        end
        function jProp = jProp(self,mValue)
            jProp = jProp@metaprop.base(self,mValue); %#ok<NODEF>
            jjColPropType = metaprop.base.jClassNameToJType('java.lang.Double');
            for m = 1:size(mValue,1)
                jRowProp = com.jidesoft.grid.DefaultProperty();
                jRowProp.setName(sprintf('%s(%0.0f,:)',self.Name,m));
                jRowProp.setDescription(sprintf('Sub row of %s',self.Name));
                jRowProp.setType(self.jType);
                
                jRowContext = com.jidesoft.grid.EditorContext(jRowProp.getName);
                jRowProp.setEditorContext(jRowContext);
                
                com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, jRowContext);
                com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, jRowContext);
                for n = 1:size(mValue,2)
                    jColProp = com.jidesoft.grid.DefaultProperty();
                    jColProp.setName(sprintf('%s(%0.0f,%0.0f)',self.Name,m,n));
                    jColProp.setDescription(sprintf('Sub element of %s',self.Name));
                    jColProp.setType(jjColPropType);
                    
                    jColContext = com.jidesoft.grid.EditorContext(jColProp.getName);
                    jColProp.setEditorContext(jColContext);
                    
                    com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, jColContext);
                    com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, jColContext);
                    jRowProp.addChild(jColProp);
                end
                jProp.addChild(jRowProp);
                jRowProp.setEditable(false);
            end
            jProp.setEditable(false);
            self.updateChildValues(jProp);
        end
    end
    methods (Static)
        function updateChildValues(jProp)
            mValue = metaprop.doubleRow.mValue(jProp.getValue);
            jRows = jProp.getChildren;
            for m = 1:size(mValue,1)
                jRowProp = jRows.get(m-1);
                jCols = jRowProp.getChildren;
                for n = 1:size(mValue,2);
                    jColProp = jCols.get(n-1);
                    jValue = metaprop.doubleArray2D.jValue(mValue(m,n));
                    jColProp.setValue(jValue);
                end
                jValue = metaprop.doubleArray2D.jValue(mValue(m,:));
                jRowProp.setValue(jValue);
            end
        end
    end
end