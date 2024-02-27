classdef Inspect < oop.handle_light
% inspect a class with a user interface
% inspired by:
%	  propertiesGUI by Yair M. Altman: altmany(at)gmail.com;
%     http://www.mathworks.com/matlabcentral/fileexchange/38864-propertiesgui-display-properties-in-an-editable-context-aware-table
%   and  
%     PropertyGrid by Levente Hunyadi
%     http://www.mathworks.com/matlabcentral/fileexchange/28732-property-grid-using-jide-implementation/content/PropertyGrid.m

    properties
        Figure
        Object % object to be inspected
        Metaprops
        ObjectListener
        InitialState
        Model
    end
    methods
        function self = Inspect(Object,Metaprops,varargin)
            % input check
            assert(isa(Object,'oop.inspectable'),'Inspect can only inspect objects derived from oop.inspectable');
            assert(isa(Metaprops,'struct'),'Second argument for Inspect must be a structure with instances of metaprop');
            
            self.Object = Object;
            
            self.Metaprops = Metaprops;
            
            self.ObjectListener = addlistener(Object,'ObjectBeingDestroyed',@(varargin) delete(self));
            
            self.storeInitialState();
            
            % Initialize JIDE's usage within Matlab
            com.mathworks.mwswing.MJUtilities.initJIDE;
            
            % Prepare the properties list:
            list = java.util.ArrayList();
            propnames = fieldnames(self.Metaprops);
            for ii = 1:length(propnames)
                propname = propnames{ii};
                metaprop = self.Metaprops.(propname);
                jProp    = metaprop.jProp(self.Object.(propname));
                list.add(jProp);
            end
            
            % Prepare a properties table containing the list
            self.Model = javaObjectEDT(com.jidesoft.grid.PropertyTableModel(list));
            self.Model.expandFirstLevel();
            
            grid = javaObjectEDT(com.jidesoft.grid.PropertyTable(self.Model));
            grid.setShowNonEditable(grid.SHOW_NONEDITABLE_BOTH_NAME_VALUE);
            com.jidesoft.grid.TableUtils.autoResizeAllColumns(grid);
            grid.setRowHeight(19); 
            grid.putClientProperty('terminateEditOnFocusLost',true);
            
            pane = javaObjectEDT(com.jidesoft.grid.PropertyPane(grid));
            
            hModel = handle(self.Model, 'CallbackProperties');
            set(hModel, 'PropertyChangeCallback', @self.callback_onPropertyChange);
            
            % Display the properties pane onscreen
            self.Figure = figure(...
                'Name',   sprintf('%s property inspector',class(self.Object)),...
                'Units',  'Pixels',...
                'Pos',    [300,200,400,500],...
                'Menu',   'none',...
                'Toolbar','none',...
                'Tag',    'metaprop.Inspector',...
                'Visible','off',...
                'CloseRequestFcn',@(varargin) self.delete);
            
            % make menu buttons
            uimenu('parent',self.Figure,'Label','&Undo'    ,'callback',{@releaseButtonAfterCallback,@self.undo},'Enable','off');
            uimenu('parent',self.Figure,'Label','&Undo all','callback',{@releaseButtonAfterCallback,@self.undoAll});
            uimenu('parent',self.Figure,'Label','&Ok'      ,'callback',{@releaseButtonAfterCallback,@self.ok});
            uimenu('parent',self.Figure,'Label','&Cancel'  ,'callback',{@releaseButtonAfterCallback,@self.cancel});
            
            % Set the figure icon & make visible
            jFrame = get(handle(self.Figure),'JavaFrame');
            icon = javax.swing.ImageIcon(fullfile(matlabroot, '/toolbox/matlab/icons/tool_legend.gif'));
            jFrame.setFigureIcon(icon);
            set(self.Figure, 'Visible','on'); % 'WindowStyle','modal',
            [~, container] =  javacomponent(pane);
            
            set(container,'Units', 'normalized');
            set(container,'Position', [0,0,1,1]);
        end
        
        function callback_onPropertyChange(self, ~, event)
            newValue = event.getNewValue();
            jProp = self.Model.getProperty(event.getPropertyName());
            noWarnings = true;
            % discern between normal and child properties
            if jProp.getLevel > 0
                % by convention, the index of the property is the last bit of the
                % name, so name ends with (x,y,z)
                index = regexp(char(jProp.getName),'\d+(?=[,\d]*\)$)','match');
                index = cellfun(@str2double,index,'UniformOutput',false);
                
                % get the parent property
                while jProp.getLevel > 0
                    jProp = jProp.getParent;
                end
                
                propname = char(jProp.getName);
                metaprop = self.Metaprops.(propname);
                
                oldValue = metaprop.mValue(self.Object.(propname));
                try
                    oldValue(index{:}) = metaprop.mValue(newValue);
                catch ME
                    warning('Could not change value of %s\n%s',propname,ME.message);
                    noWarnings = false;
                end
                newValue = oldValue;
                
            else
                propname = char(jProp.getName);
                try
                    newValue = self.Metaprops.(propname).mValue(newValue);
                catch ME
                    warning('Could not change value of %s\n%s',propname,ME.message);
                    noWarnings = false;
                end
            end
            
            % assign new value to Object
            if noWarnings
                try
                    self.Object.(propname) = newValue;
                catch ME
                    warning('Could not change value of %s\n%s',propname,ME.message);
                end
            end
            
            self.refreshPropertyValues();
        end
        
        function refreshPropertyValues(self)
            % refresh all property values
            propnames = fieldnames(self.Metaprops);
            for ii = 1:length(propnames)
                propname = propnames{ii};
                jProp = self.Model.getProperty(propname);
                jProp.setValue(self.Metaprops.(propname).jValue(self.Object.(propname)));
                
                % update value of child jProps, if any
                self.Metaprops.(propname).updateChildValues(jProp);
            end
            self.Model.refresh();  % refresh value onscreen
        end
        
        function storeInitialState(self)
            mc = metaclass(self.Object);
            PropertyList = mc.PropertyList;
            
            % only store properties that 
            propsTostore = (...
                strcmp({PropertyList.GetAccess},'public') & ... both set and
                strcmp({PropertyList.SetAccess},'public') & ...  get are public
                ~[PropertyList.Constant] & ... are not constant
                ~[PropertyList.Hidden]); % are not hidden
            
            PropertyList = PropertyList(propsTostore);
            self.InitialState = cell(1,length(PropertyList)*2);
            for ii = 1:length(PropertyList)
                propname = PropertyList(ii).Name;
                self.InitialState{2*ii-1} = propname;
                self.InitialState{2*ii  } = self.Object.(propname);
            end
        end
        function ok(self,~,~)
            self.Object.Inspector_LastButtonPressed = 'ok';
            self.delete;
        end
        function cancel(self,~,~)
            try
                self.undoAll();
            catch
                uiwait(warndlg('Matlab will exit','Warning','modal'));
                exit();
            end
            self.Object.Inspector_LastButtonPressed = 'cancel';
            self.delete;
        end
        function undo(self,~,~)
            self.Object.Inspector_LastButtonPressed = 'undo';
            % not implemented
        end              
        function undoAll(self,~,~)
            try
                self.Object.set(self.InitialState{:});
                self.refreshPropertyValues();
            catch ME
                self.refreshPropertyValues();
                uiwait(warndlg('Could not undo all','Warning','modal'));
                throw(ME)
            end
            self.Object.Inspector_LastButtonPressed = 'undoAll';
        end
        function delete(self)
            % clear Java mess
            com.jidesoft.grid.CellRendererManager.unregisterAllRenderers
                       
            % delete figure
            delete(self.Figure);
            
            % delete listener
            delete(self.ObjectListener);
            
            % call superclass delete method
            delete@handle(self);
        end
    end
end