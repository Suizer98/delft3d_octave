classdef saveload < oop.setproperty
%saveload save oop to file or read oop from file
%
%See also: oop

    methods
        function data = objSave(self)
            % Convert object to struct. 
            if numel(self) ~= 1
                if isa(self,'matlab.mixin.Heterogeneous')
                    data = arrayfun(@(self) self.objSave,self,'UniformOutput',false);
                else
                    data = arrayfun(@(self) self.objSave,self);
                end
                return
            end
            
            mc          = metaclass(self);
            pLst        = mc.PropertyList;
            propsToSave = {pLst(~[pLst.Transient] & ~[pLst.Constant]).Name};
            fldValues   = cellfun(@(propname) self.(propname),propsToSave,'UniformOutput',false);
            fldNames    = propsToSave;
            data        = cell2struct(fldValues,fldNames,2);
        end
        
        function objLoad(self,data)
            self.set(data);
        end
    end
end