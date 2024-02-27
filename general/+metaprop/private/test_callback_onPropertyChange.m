function test_callback_onPropertyChange(model, event)
    newValue = event.getNewValue()
    oldValue = event.getOldValue()
    
    jProp = model.getProperty(event.getPropertyName());
    
    if jProp.getLevel > 0
        % do some tricks to determinethe parent property, and update the parent property value
        jParentProp = jProp.getParent;
        while jParentProp.getLevel > 0
            jParentProp = jParentProp.getParent;
        end
        
        % by convention, the index of the property is the last bit of the
        % name, so name ends with (x,y,z)
        index = regexp(char(jProp.getName),'\d+(?=[,\d]*\)$)','match');
        index = cellfun(@str2double,index,'UniformOutput',false);
        value = jParentProp.getValue;
        value(index{:}) = newValue;
        jParentProp.setValue(value) 
        
        updateValues(model,jParentProp)
    else
        jProp.setValue(newValue);
    end
   
    model.refresh();  % refresh value onscreen
end