allclear
t = textbox('String','Some text','AnchorPosition',[.5 .5]);
t.inspect

%%


% edit arry as inpsect: expandable thingy, name positions
% open uitable
% 
%%
switch lower(dataType)
    case 'signed',    %alignProp(prop, com.jidesoft.grid.IntegerCellEditor,    'int32');
        model = javax.swing.SpinnerNumberModel(prop.getValue, -intmax, intmax, 1);
        jEditor = com.jidesoft.grid.SpinnerCellEditor(model);
        alignProp(prop, jEditor, 'int32');
    case 'unsigned',  %alignProp(prop, com.jidesoft.grid.IntegerCellEditor,    'uint32');
        val = max(0, min(prop.getValue, intmax));
        model = javax.swing.SpinnerNumberModel(val, 0, intmax, 1);
        jEditor = com.jidesoft.grid.SpinnerCellEditor(model);
        alignProp(prop, jEditor, 'uint32');
    case 'float',     alignProp(prop, com.jidesoft.grid.CalculatorCellEditor, 'double');  % DoubleCellEditor
    case 'boolean',   alignProp(prop, com.jidesoft.grid.BooleanCheckBoxCellEditor, 'logical');
    case 'folder',    alignProp(prop, com.jidesoft.grid.FolderCellEditor);
    case 'file',      alignProp(prop, com.jidesoft.grid.FileCellEditor);
    case 'ipaddress', alignProp(prop, com.jidesoft.grid.IPAddressCellEditor);
    case 'password',  alignProp(prop, com.jidesoft.grid.PasswordCellEditor);
    case 'color',     alignProp(prop, com.jidesoft.grid.ColorCellEditor);
    case 'font',      alignProp(prop, com.jidesoft.grid.FontCellEditor);
    case 'text',      alignProp(prop);
    case 'time',      alignProp(prop);  % maybe use com.jidesoft.grid.FormattedTextFieldCellEditor ?
        
    case 'date',      dateModel = com.jidesoft.combobox.DefaultDateModel;
        dateFormat = java.text.SimpleDateFormat('dd/MM/yyyy');
        dateModel.setDateFormat(dateFormat);
        jEditor = com.jidesoft.grid.DateCellEditor(dateModel, 1);
        alignProp(prop, jEditor, 'java.util.Date');
        try
            prop.setValue(dateFormat.parse(prop.getValue));  % convert string => Date
        catch
            % ignore
        end
        
    otherwise,        alignProp(prop);  % treat as a simple text field
        
        
        %%
        
        % Initialize JIDE's usage within Matlab
        com.mathworks.mwswing.MJUtilities.initJIDE;
        
        % Prepare the properties list:
        % First two logical values (flags)
        list = java.util.ArrayList();
        prop1 = com.jidesoft.grid.DefaultProperty();
        prop1.setName('mylogical');
        prop1.setType(javaclass('logical'));
        prop1.setValue(true);
        list.add(prop1);
        
        %%
        list = java.util.ArrayList();
        jType = javaclass('double', 2);

        
        jEditor = com.jidesoft.grid.DoubleCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
        
        
        
        jProp = com.jidesoft.grid.DefaultProperty();
        
        
        jContext = com.jidesoft.grid.EditorContext(jProp.getName);
        com.jidesoft.grid.CellEditorManager.registerEditor(jType, jEditor, jContext);
        
        set(jProp, 'Name','season', 'Type',jType, 'EditorContext',jContext);
        list.add(jProp);
        
        jProp.setValue([1 2])
        
                % Prepare a properties table containing the list
        model = com.jidesoft.grid.PropertyTableModel(list);
        model.expandAll();
        grid = com.jidesoft.grid.PropertyTable(model);
        pane = com.jidesoft.grid.PropertyPane(grid);
        
        % Display the properties pane onscreen
        hFig = figure('Position',[-959   358   560   420]);
        panel = uipanel(hFig);
        javacomponent(pane, [0 0 400 400], panel);
        
        %%
        
        
        list = java.util.ArrayList();
        % jType = javaclass('double');
        
        jclassname = 'java.awt.Color'
        
        jType = java.lang.Class.forName(jclassname, true, java.lang.Thread.currentThread().getContextClassLoader());
        prop = com.jidesoft.grid.DefaultProperty();
        prop.setName('test');
        jContext = com.jidesoft.grid.EditorContext(prop.getName);
        
        prop.setEditorContext(jContext);
        prop.setType(jType);
        prop.setValue(java.awt.Color(1,0,1));
        
        
        
        jEditor = com.jidesoft.grid.ColorCellEditor; %%%%%
        
        com.jidesoft.grid.CellEditorManager.registerEditor(jType, jEditor, jContext);
        
        renderer = com.jidesoft.grid.ColorCellRenderer;
        com.jidesoft.grid.CellRendererManager.registerRenderer(jType, renderer, jContext);
        % renderer.setIcon
        
        % a = com.jidesoft.grid.ColorIcon
        renderer.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        % ColorCellRenderer
        % com.jidesoft.grid.ColorCellRenderer.ColorIcon
        
        
        list.add(prop);
        
        
        prop.getValue.getColorComponents([])'
        
        col = prop.getValue
        col.getClass
        
        %
        % Prepare a properties table containing the list
        model = com.jidesoft.grid.PropertyTableModel(list);
        model.expandAll();
        grid = com.jidesoft.grid.PropertyTable(model);
        pane = com.jidesoft.grid.PropertyPane(grid);
        
        % Display the properties pane onscreen
        hFig = figure('Position',[-959   358   560   420]);
        panel = uipanel(hFig);
        javacomponent(pane, [0 0 400 400], panel);
