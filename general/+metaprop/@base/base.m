classdef (Abstract) base < oop.setproperty & matlab.mixin.Heterogeneous
% Abstract base class for metaproperties    
    properties
        Description = ''
        Classes = {} %--> to be passed to validateattributes
        Attributes = {} %--> to be passed to validateattributes
        Category = '' %--> for grouping when displayed
    end
    properties (SetAccess=protected)
        DefaultAttributes = {}
        DefaultClasses = {}
        jContext
    end
    properties (Abstract,Constant)
        jType
    end
    properties (Abstract,SetAccess=immutable)
        jRenderer
        jEditor
    end
    
    properties (SetAccess=immutable)
        % derive from meta.property
        Name
        DefaultValue
        Constant
        Dependent
        Hidden
        HasDefault
        DefiningClass
    end

    methods
        function self = base(meta_property,varargin)
            assert(isa(meta_property,'meta.property'),'Instantiate with ''findprop(object,''PropName'')''')
            self.Name          = meta_property.Name;
            self.Constant      = meta_property.Constant;
            self.Dependent     = meta_property.Dependent;
            self.Hidden        = meta_property.Hidden;
            self.HasDefault    = meta_property.HasDefault;
            self.DefiningClass = meta_property.DefiningClass;
            if self.HasDefault
                self.DefaultValue = meta_property.DefaultValue;
            else
                self.DefaultValue = [];
            end
            self.set(varargin{:});
        end

        function Check(self,value) % error/no error
            atts = [self.DefaultAttributes self.Attributes];
            % merge default and custom attributes, as more atts is more restrictive
            % more classes means more permissive, so do seperate checks for
            % default attributes and custom classes. If no custom classes are
            % defined, skip the ceck
            validateattributes(value,self.DefaultClasses,atts,self.DefiningClass.Name,self.Name)
            if ~isempty(self.Classes)
                validateattributes(value,self.Classes,{},self.DefiningClass.Name,self.Name)
            end
        end
        
        function CanAccept = CanAccept(self,value) % true/false
            try
                self.Check(value);
                CanAccept = true;
            catch
                CanAccept = false;
            end
        end
        
        function CheckDefault(self)
            if self.HasDefault
                self.Check(self.DefaultValue);
            end
        end
    end
    
    %% methods to enable gui inspection
    methods
        function jProp = jProp(self,mValue)
            jProp = javaObjectEDT(com.jidesoft.grid.DefaultProperty);
            jProp.setName(self.Name);
            jProp.setDescription(self.Description)
            jProp.setType(self.jType);
            jProp.setValue(self.jValue(mValue));
            jProp.setCategory(self.Category);

            self.jContext = javaObjectEDT(com.jidesoft.grid.EditorContext(jProp.getName));
            jProp.setEditorContext(self.jContext);

            self.registerEditor();
            self.registerRenderer();

            % Right align everything
            direction = javax.swing.SwingConstants.RIGHT;
            try self.jRenderer.setHorizontalAlignment(direction);            catch; end
            try self.jEditor.setHorizontalAlignment(direction);              catch; end
            try self.jEditor.getTextField.setHorizontalAlignment(direction); catch; end
            try self.jEditor.getComboBox.setHorizontalAlignment(direction);  catch; end
        end
        
        function registerEditor(self)
            com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, self.jContext);
        end
        
        function registerRenderer(self)
            com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, self.jContext);
        end
    end
    methods (Static)
        function updateChildValues(jProp) %#ok<INUSD>
            % only implement for class with chidren
        end
        function jValue = jValue(mValue)
            % conversion from matlab value to java value
            jValue = mValue;
        end
        function mValue = mValue(jValue)
            % conversion from java value to matlab value
            mValue = jValue;
        end        
        function jType = jClassNameToJType(jClassName)
            jType = java.lang.Class.forName(jClassName, true, java.lang.Thread.currentThread().getContextClassLoader());
        end
    end
end