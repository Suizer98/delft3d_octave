% DOUBLEROW property for a row of double precision numbers. Editor has one line for each element
classdef doubleRow < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('[[D')
    end
    properties (SetAccess=immutable)        
        jEditor = com.jidesoft.grid.DoubleCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = doubleRow(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultClasses    = {'double'};
            self.DefaultAttributes = {'row'};
            
            self.CheckDefault();
        end
        function jProp = jProp(self,mValue)
            jProp = jProp@metaprop.base(self,mValue); %#ok<NODEF>
            jChildType = metaprop.base.jClassNameToJType('java.lang.Double');
            for ii = 1:length(mValue)
                jChildProp = com.jidesoft.grid.DefaultProperty();
                jChildProp.setName(sprintf('%s(%0.0f)',self.Name,ii));
                jChildProp.setDescription(sprintf('Sub element of %s',self.Name));
                jChildProp.setType(jChildType);
                
                jChildContext = com.jidesoft.grid.EditorContext(jChildProp.getName);
                jChildProp.setEditorContext(jChildContext);
                
                com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, jChildContext);
                com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, jChildContext);
                jProp.addChild(jChildProp);
               
            end
            jProp.setEditable(false);
            self.updateChildValues(jProp);
        end
    end
    methods (Static)
        function updateChildValues(jProp)
            mValue = metaprop.doubleRow.mValue(jProp.getValue);
            jChildren = jProp.getChildren;
            for ii = 1:size(mValue,1)
                jProp = jChildren.get(ii-1);
                jValue = metaprop.doubleRow.jValue(mValue(ii));
                jProp.setValue(jValue);
            end
        end
    end
end