function test_double_array
list = java.util.ArrayList();
jType = metaprop.base.jClassNameToJType('java.util.Date');

jProp = com.jidesoft.grid.DefaultProperty();


dateModel = com.jidesoft.combobox.DefaultDateModel;
dateFormat = java.text.SimpleDateFormat('yyyy-MM-dd HH:mm:ss');
dateModel.setDateFormat(dateFormat);

jEditor   = com.jidesoft.grid.DateCellEditor(dateModel, true);
% 
% jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;

jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer

jContext  = com.jidesoft.grid.EditorContext(jProp.getName);

% com.jidesoft.grid.CellRendererManager.registerRenderer(jType, jRenderer, jContext);

com.jidesoft.grid.CellEditorManager.registerEditor(jType, jEditor, jContext);
name = 'season';
set(jProp, 'Name',name, 'Type',jType, 'EditorContext',jContext);
list.add(jProp);
mValue = datenum(1955,2,3,4,5,6)
jValue = java.util.Date(datestr(mValue))
jValue.getTimezoneOffset
jProp.setValue(jValue);


%%

model = test_model(list);
jRenderer.setText('sf')
jRenderer.setDa
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


function test_callback_onPropertyChange(model, event)
    newValue = event.getNewValue()


    oldValue = event.getOldValue()
    
    
    jProp = model.getProperty(event.getPropertyName());
    
    
    model.refresh();  % refresh value onscreen
end
