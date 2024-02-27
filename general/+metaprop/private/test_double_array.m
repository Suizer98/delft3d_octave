function test_double_array
list = java.util.ArrayList();
jType = javaclass('double',2);

jProp = com.jidesoft.grid.DefaultProperty();

jEditor   = com.jidesoft.grid.DoubleCellEditor;
jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
%          jRenderer = com.jidesoft.grid.MultilineTableCellRenderer;
jContext  = com.jidesoft.grid.EditorContext(jProp.getName);
com.jidesoft.grid.CellRendererManager.registerRenderer(jType, jRenderer, jContext);
com.jidesoft.grid.CellEditorManager.registerEditor(jType, jEditor, jContext);
name = 'season';
set(jProp, 'Name',name, 'Type',jType, 'EditorContext',jContext);
list.add(jProp);
mValue = magic(3);
jProp.setValue(mValue);
jProp.setEditable(false)
%%
for m = 1:size(mValue,1)
    jProp2 = com.jidesoft.grid.DefaultProperty();
    jType2 = javaclass('double',2);
    jEditor   = com.jidesoft.grid.DoubleCellEditor;
    jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    %          jRenderer = com.jidesoft.grid.MultilineTableCellRenderer;
    jContext  = com.jidesoft.grid.EditorContext(jProp2.getName);
    com.jidesoft.grid.CellRendererManager.registerRenderer(jType2, jRenderer, jContext);
    com.jidesoft.grid.CellEditorManager.registerEditor(jType2, jEditor, jContext);
    
    set(jProp2, 'Name',sprintf('%s(%0.0f,:)',name,m), 'Type',jType2, 'EditorContext',jContext);
    
    jProp2.setValue(mValue(m,:))
    jProp.addChild(jProp2)
    jProp2.setEditable(false)
    for n = 1:size(mValue,2)
        jProp3 = com.jidesoft.grid.DefaultProperty();
        jType3 = javaclass('double');
        jEditor   = com.jidesoft.grid.DoubleCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
        %          jRenderer = com.jidesoft.grid.MultilineTableCellRenderer;
        jContext  = com.jidesoft.grid.EditorContext(jProp3.getName);
        com.jidesoft.grid.CellRendererManager.registerRenderer(jType3, jRenderer, jContext);
        com.jidesoft.grid.CellEditorManager.registerEditor(jType3, jEditor, jContext);
        
        set(jProp3, 'Name',sprintf('%s(%0.0f,%0.0f)',name,m,n), 'Type',jType3, 'EditorContext',jContext);
        jProp2.addChild(jProp3)
        %         jProp3. (@metaprop.test_callback_onPropertyChange)
    end
end


%%

model = test_model(list);
updateValues(model,jProp)
end

function model = test_model (list)
model = com.jidesoft.grid.PropertyTableModel(list);


hModel = handle(model, 'CallbackProperties');
set(hModel, 'PropertyChangeCallback', @test_callback_onPropertyChange);
% Prepare a properties table containing the list

model.expandAll();
grid = com.jidesoft.grid.PropertyTable(model);
pane = com.jidesoft.grid.PropertyPane(grid);

% Display the properties pane onscreen
hFig = figure('Position',[-959   358   560   420]);
panel = uipanel(hFig);
javacomponent(pane, [0 0 400 400], panel);
end

function updateValues(model,jProp)
mValue = jProp.getValue

jChildren = jProp.getChildren
for m = 1:size(mValue,1)
    jProp2 = jChildren.get(m-1);
    jProp2.setValue(mValue(m,:));
    jChildren2 = jProp2.getChildren;
    mValue2 = jProp2.getValue;
    for n = 1:size(mValue,2)
        jProp3 = jChildren2.get(n-1);
        jProp3.setValue(mValue2(n));
    end
end
end


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
