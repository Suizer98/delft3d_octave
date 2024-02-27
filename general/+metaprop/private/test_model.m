function model = test_model (list)
model = com.jidesoft.grid.PropertyTableModel(list);


hModel = handle(model, 'CallbackProperties');
set(hModel, 'PropertyChangeCallback', @metaprop.test_callback_onPropertyChange);
% Prepare a properties table containing the list

model.expandAll();
grid = com.jidesoft.grid.PropertyTable(model);
pane = com.jidesoft.grid.PropertyPane(grid);

% Display the properties pane onscreen
hFig = figure('Position',[-959   358   560   420]);
panel = uipanel(hFig);
javacomponent(pane, [0 0 400 400], panel);
end