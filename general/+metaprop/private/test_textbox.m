function test_textbox
list = java.util.ArrayList();
jType = metaprop.base.jClassNameToJType('java.lang.Character');

jProp = com.jidesoft.grid.DefaultProperty();

jEditor   = com.jidesoft.grid.MultilineStringCellEditor;
jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
%          jRenderer = com.jidesoft.grid.MultilineTableCellRenderer;
jContext  = com.jidesoft.grid.EditorContext(jProp.getName);
com.jidesoft.grid.CellRendererManager.registerRenderer(jType, jRenderer, jContext);
com.jidesoft.grid.CellEditorManager.registerEditor(jType, jEditor, jContext);
name = 'season';
set(jProp, 'Name',name, 'Type',jType, 'EditorContext',jContext);
list.add(jProp);
mValue = {'sgdsdg','aaa','bb'}
jValue = sprintf('%s\n',mValue{:});
jValue = jValue(1:end-1);
jProp.setValue(jValue);
%%

%%

model = test_model(list);
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
% hFig = figure('Position',[-959   358   560   420]);
hFig = figure;
panel = uipanel(hFig);
javacomponent(pane, [0 0 400 400], panel);
end

function test_callback_onPropertyChange(model, event)
    newValue = event.getNewValue()
    oldValue = event.getOldValue()
    cellstr(newValue)
    str = textscan(newValue,'%s');
    str = str{1}
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
